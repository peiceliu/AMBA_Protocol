module ahb2apb_bridge #(
    parameter ADDRWIDTH = 16,
    parameter DATAWIDTH = 32,
    parameter WDATA_IFREG = 1,
    parameter RDATA_IFREG = 1
) (
    // AHB bus signals
    input                   HCLK, // AHB clock
    input                   HRESETn,

    input                   HSEL,
    input   [ADDRWIDTH-1:0] HADDR,
    input                   HWRITE,
    input   [DATAWIDTH-1:0] HWDATA,
    input                   HREADY,
    input   [2:0]           HSIZE,
    input   [1:0]           HTRANS,
    input   [3:0]           HPROT,

    output                  HREADYOUT,
    output  [DATAWIDTH-1:0] HRDATA,
    output                  HRESP,

    // APB bus signals
    input                   PCLKEN,
    input   [DATAWIDTH-1:0] PRDATA,
    input                   PREADY,
    input                   PSLVERR,

    output                  PSEL,
    output                  PENABLE,
    output  [ADDRWIDTH-1:0] PADDR,
    output                  PWRITE,
    output  [DATAWIDTH-1:0] PWDATA,
    output  [2:0]           PPROT,
    output  [3:0]           PSTRB,

    output                  APBACTIVE

);

reg [ADDRWIDTH-1:0] addr_reg;
reg                 write_reg;
reg [DATAWIDTH-1:0] data_reg;

reg [2:0]           state_reg;
reg [2:0]           next_state;


localparam IDLE  = 3'b000;
localparam WAIT  = 3'b001;  // input delay
localparam SETUP = 3'b010;  // transfer 1st cycle
localparam PROCESS = 3'b011;    // transfer 2nd cycle


assign wdata_ifreg = (WDATA_IFREG == 1) ? 1'b1 : 1'b0 ;
assign rdata_ifreg = (RDATA_IFREG == 1) ? 1'b1 : 1'b0 ;

// 数据是否寄存
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
        data_reg <= 'b0 ;
    end else begin
        if(wdata_ifreg && HWRITE && PCLKEN)begin
            data_reg <= HWDATA ;
        end else if(rdata_ifreg && PCLKEN)begin
            data_reg <= PRDATA ;
        end else begin
            data_reg <= data_reg ;
        end
    end
end

assign apb_sel = (HSEL && HREADY && HTRANS[1]) ? 1'b1 : 1'b0 ; // HTRANS[1]的时候代表不在空闲状态

always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
        addr_reg <= 'b0 ;
        write_reg <= 'b0 ;
    end else if(apb_sel)begin
        addr_reg <= {HADDR[ADDRWIDTH-1:2],2'b00} ;              // 地址对齐
        write_reg <= HWRITE ;
    end else begin
        addr_reg <= addr_reg ;
        write_reg <= write_reg ;
    end
end


always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        state_reg <= IDLE ;
    end else begin
        state_reg <= next_state ;
    end
end

always @(*)begin
    case(state_reg)
        IDLE:begin
            if(apb_sel && PCLKEN && wdata_ifreg && HWRITE)begin
                next_state = WAIT ;
            end else begin
                if(apb_sel && PCLKEN && (~(wdata_ifreg && HWRITE)))begin
                    next_state = SETUP ;
                end else begin
                next_state = IDLE ;
                end
            end
        end
        WAIT:begin
            if(PCLKEN)begin
                next_state = SETUP ;
            end else begin
                next_state = WAIT ;
            end
        end
        SETUP:begin
            if(PCLKEN)begin
                next_state = PROCESS ;
            end else begin
                next_state = SETUP ;
            end
        end
        PROCESS:begin
            if(PCLKEN && apb_sel)begin
                next_state = SETUP ;
            end else begin
                if(PCLKEN)begin
                    next_state = IDLE ;
                end else begin
                    next_state = PROCESS ;
                end
            end
        end
    endcase

// HREADYOUT
always @(*)begin
    case(state_reg)
        IDLE:begin
            HREADYOUT = 1'b1 ;
        end
        WAIT:begin
            HREADYOUT = 1'b0 ;
        end
        SETUP:begin
            HREADYOUT = 1'b1 ;
        end
        PROCESS:begin
            HREADYOUT = 1'b1 && PCLKEN ;
        end
    endcase
end



//  AHB bus signals
assign HRESP = (state_reg == PROCESS) ? 1'b1 : 1'b0 ;
assign HRDATA = (rdata_ifreg == 1'b1) ? data_reg : PRDATA ;



// APB bus signals
assign PSEL = ((state_reg == SETUP)||(state_reg == PROCESS)) ? 1'b1 : 1'b0 ;
assign PENABLE = (state_reg == PROCESS) ? 1'b1 : 1'b0 ;
assign PADDR = addr_reg ;
assign PWRITE = write_reg ;
assign PWDATA = (wdata_ifreg == 1'b1) ? data_reg : HWDATA ;

assign APBACTIVE = (HSEL & HTRANS[1]) || (state_reg != IDLE) ;

end







endmodule