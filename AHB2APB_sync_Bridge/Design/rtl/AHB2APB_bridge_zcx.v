module AHB2APB_Bridge #(
    parameter ADDRWIDTH = 16,
    parameter DATAWIDTH = 32
) (
    // AHB bus signals
    input                       HCLK        , // AHB clock
    input                       HRESETn     ,

    input                       HSEL        ,
    input       [ADDRWIDTH-1:0] HADDR       ,
    input                       HWRITE      ,
    input       [DATAWIDTH-1:0] HWDATA      ,
    input                       HREADYIN    ,
    input       [2:0]           HSIZE       ,

    input       [1:0]           HTRANS      ,
    input       [3:0]           HPROT       ,

    output reg                  HREADYOUT   ,
    output      [DATAWIDTH-1:0] HRDATA      ,
    output                      HRESP       ,

    // APB bus signals
    input                       PCLKEN      ,
    input       [DATAWIDTH-1:0] PRDATA      ,

    `ifdef APB3 
    input                       PREADY      ,
    input                       PSLVERR     ,
    `endif

    output                      PSEL        ,
    output reg                  PENABLE     ,
    output reg  [ADDRWIDTH-1:0] PADDR       ,
    output                      PWRITE      ,
    output reg  [DATAWIDTH-1:0] PWDATA      ,

    `ifdef APB4 
    output      [2:0]           PPROT       ,
    output      [3:0]           PSTRB       ,
    `endif

    output                      APBACTIVE


) ;

reg     [2:0]               state1              ;       //TODO 'b101: AHB->APB write;    'b100: AHB->APB read
reg     [2:0]               state2              ;
reg     [3:0]               hprot_r             ;
reg     [ADDRWIDTH-1:0]     addr_r              ;
reg                         hready_up           ;       // pull HREADY UP when H2P read is first command

localparam H2P_WRITE = 'b101;
localparam H2P_READ = 'b100;

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        state1 <= 'd0;
        PADDR <= 'd0;
        PWDATA <= 'd0;
        hready_up <= 'd0;
    end else begin
        if (PCLKEN) begin
        `ifdef APB3
            if (HSEL && HREADYIN && HTRANS[1] && ~HWRITE && state2 == 'd0) begin
                state1 <= H2P_READ;
                PADDR <= HADDR;
                hready_up <= 'd1;
            end else if ((PENABLE && PREADY) || state1 == 'd0) begin
                state1 <= state2;
                PADDR <= addr_r;
                PWDATA <= HWDATA;
            end else begin
                hready_up <= 'd0;
            end
        `else 
            if (HSEL && HREADYIN && HTRANS[1] && ~HWRITE && state2 == 'd0) begin
                state1 <= H2P_READ;
                PADDR <= HADDR;
                hready_up <= 'd1;
            end else if (PENABLE || state1 == 'd0) begin
                state1 <= state2;
                PADDR <= addr_r;
                PWDATA <= HWDATA;
            end else begin
                hready_up <= 'd0;
            end
        `endif
        end
    end
end

`ifdef APB4
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        PPROT <= 'd0;
    end else begin
        if (PCLKEN) begin
            if (PENABLE || state1 == 'd0) begin
                PPROT <= {{~hprot_r[0]},hprot_r[1],hprot_r[2]};
            end
        end
    end
end
`endif

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        state2 <= 'd0;
        addr_r <= 'd0;
        hprot_r <= 'd0;
    end else begin
    `ifdef APB3
        if (PENABLE && PREADY && (~HSEL || HTRANS[1] || state1 == H2P_READ)) begin
            state2 <= 'd0;
            addr_r <= 'd0;
            hprot_r <= 'd0;
        end else if (HSEL && HREADYIN && HTRANS[1] && HWRITE && state2 == 'd0) begin
            state2 <= H2P_WRITE;
            addr_r <= HADDR;
            hprot_r <= HPROT;
        end else if (HSEL && HREADYIN && HTRANS[1] && ~HWRITE && state2 == 'd0) begin
            state2 <= H2P_READ;
            addr_r <= HADDR;
            hprot_r <= HPROT;
        end
    `else
        if (PENABLE && (~HSEL || HTRANS[1] || state1 == H2P_READ)) begin
            state2 <= 'd0;
            addr_r <= 'd0;
            hprot_r <= 'd0;
        end else if (HSEL && HREADYIN && HTRANS[1] && HWRITE && state2 == 'd0) begin
            state2 <= H2P_WRITE;
            addr_r <= HADDR;
            hprot_r <= HPROT;
        end else if (HSEL && HREADYIN && HTRANS[1] && ~HWRITE && state2 == 'd0) begin
            state2 <= H2P_READ;
            addr_r <= HADDR;
            hprot_r <= HPROT;
        end
    `endif
    end
end

assign PSEL = (state1 != 'd0)? 'd1:'d0;
assign PWRITE = state1[0];

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        PENABLE <= 'd0;
    end else begin
        if (PCLKEN) begin
        `ifdef APB3
            if (PSEL && ~PENABLE) begin
                PENABLE <= 'd1;
            end else if (PSEL && PENABLE && PREADY) begin
                PENABLE <= 'd0;
            end
        `else
            if (PSEL) begin
                PENABLE <= ~PENABLE;
            end
        `endif
        end
    end
end

always @(*) begin
    HREADYOUT = 'd1;
    `ifdef APB3
        if (state1 == H2P_WRITE && state2 == H2P_WRITE && (~PENABLE || ~PREADY)) begin
            HREADYOUT = 'd0;
        end else if (state1 == H2P_WRITE && state2 == H2P_READ) begin
            HREADYOUT = 'd0;
        end else if (state1 == H2P_READ && (~PENABLE || ~PREADY) && ~hready_up) begin
            HREADYOUT = 'd0;
        end
    `else 
        if (state1 == H2P_WRITE && state2 == H2P_WRITE && ~PENABLE) begin
            HREADYOUT = 'd0;
        end else if (state1 == H2P_WRITE && state2 == H2P_READ) begin
            HREADYOUT = 'd0;
        end else if (state1 == H2P_READ && ~PENABLE && ~hready_up) begin
            HREADYOUT = 'd0;
        end
    `endif
end

assign HRDATA = PRDATA;
assign APBACTIVE = (state1 != 'd0 || state2 != 'd0);
assign HRESP = PSLVERR;
`ifdef APB4 
    assign PSTRB = 'b1111;
`endif







endmodule