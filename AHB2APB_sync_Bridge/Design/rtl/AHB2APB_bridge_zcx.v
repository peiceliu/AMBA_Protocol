module ahb2apb_Bridge #(
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
    input                       HREADY    ,
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
reg     [DATAWIDTH-1:0]     PRDATA_r            ;
reg     [1:0]               state2_cnt          ;
// reg                         hready_up           ;       // pull HREADY UP when H2P read is first command

localparam H2P_WRITE = 'b101;
localparam H2P_READ = 'b100;

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        state1 <= 'd0;
        PADDR <= 'd0;
        // hready_up <= 'd0;
    end else begin
        if (PCLKEN) begin
        `ifdef APB3
            if (HSEL && HREADY && HTRANS[1] && ~HWRITE && (state1 == 'd0 || state1 == H2P_READ) && state2 == 'd0) begin
                state1 <= H2P_READ;
                PADDR <= HADDR;
                // hready_up <= 'd1;
            end else if ((PENABLE && PREADY) || state1 == 'd0) begin
                state1 <= state2;
                PADDR <= addr_r;
            end
        `else 
            if (HSEL && HREADY && HTRANS[1] && ~HWRITE && (state1 == 'd0 || state1 == H2P_READ) && state2 == 'd0) begin
                state1 <= H2P_READ;
                PADDR <= HADDR;
                // hready_up <= 'd1;
            end else if (PENABLE || state1 == 'd0) begin
                state1 <= state2;
                PADDR <= addr_r;
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
        PWDATA <= 'd0;
        state2_cnt <= 'd0;
    end else begin
    `ifdef APB3
        if ((~PENABLE || ~PREADY) && state1 == H2P_READ) begin
            state2 <= 'd0;
            addr_r <= 'd0;
            hprot_r <= 'd0;
        end else if (HSEL && HREADY && HTRANS[1] && HWRITE) begin
            state2 <= H2P_WRITE;
            addr_r <= HADDR;
            hprot_r <= HPROT;
            PWDATA <= HWDATA;
        end else if (HSEL && HREADY && HTRANS[1] && ~HWRITE) begin
            state2 <= H2P_READ;
            addr_r <= HADDR;
            hprot_r <= HPROT;
            PWDATA <= HWDATA;
        end else if (state2_cnt == 'd1 && PCLKEN) begin
            state2 <= 'd0;
        end
    `else
        if (~PENABLE && state1 == H2P_READ) begin
            state2 <= 'd0;
            addr_r <= 'd0;
            hprot_r <= 'd0;
        end else if (HSEL && HREADY && HTRANS[1] && HWRITE) begin
            state2 <= H2P_WRITE;
            addr_r <= HADDR;
            hprot_r <= HPROT;
            PWDATA <= HWDATA;
        end else if (HSEL && HREADY && HTRANS[1] && ~HWRITE) begin
            state2 <= H2P_READ;
            addr_r <= HADDR;
            hprot_r <= HPROT;
            PWDATA <= HWDATA;
        end else if (state2_cnt == 'd1 && PCLKEN) begin
            state2 <= 'd0;
        end
    `endif
        if (HSEL && HREADY && HTRANS[1]) begin
            state2_cnt <= 'd0;
        end else if (state2_cnt == 'd1 && PCLKEN) begin
            state2_cnt <= 'd0;
        end else if (state2 != 'd0 && PCLKEN) begin
            state2_cnt <= state2_cnt + 'd1;
        end
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
        if (state1 != 'd0 && (~PENABLE || ~PREADY)) begin
            HREADYOUT = 'd0;
        end else if (state1 == H2P_WRITE && state2 == H2P_READ) begin
            HREADYOUT = 'd0;
        end
    `else 
        if (state1 != 'd0 && ~PENABLE) begin
            HREADYOUT = 'd0;
        end else if (state1 == H2P_WRITE && state2 == H2P_READ) begin
            HREADYOUT = 'd0;
        end
    `endif
end

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        PRDATA_r <= 'd0;
    end else begin
        if (state1 == H2P_READ && PSEL && PENABLE) begin
            PRDATA_r <= PRDATA;
        end
    end
end 

assign HRDATA = (state1 == H2P_READ && PSEL && PENABLE && HSEL && HTRANS[1] && HREADYOUT) ? PRDATA : PRDATA_r;
   
assign APBACTIVE = (state1 != 'd0 || state2 != 'd0);
`ifdef APB3
    assign HRESP = PSLVERR;
`else
    assign HRESP = 'd0;
`endif
`ifdef APB4 
    assign PSTRB = 'b1111;
`endif

endmodule