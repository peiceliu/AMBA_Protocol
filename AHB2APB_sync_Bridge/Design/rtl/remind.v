module ahb2apb_bridge2 #(
    parameter ADDRWIDTH = 16,
    parameter DATAWIDTH = 32,
    parameter REGISTER_WDATA = 0,
    parameter REGISTER_RDATA = 0
) (
    // AHB bus signals
    input                   HCLK,      // AHB clock
    input                   HRESETn,   // AHB reset

    input                   HSEL,      // AHB select
    input   [ADDRWIDTH-1:0] HADDR,     // AHB address
    input                   HWRITE,    // AHB write enable
    input   [DATAWIDTH-1:0] HWDATA,    // AHB write data
    input                   HREADY,    // AHB ready
    input   [2:0]           HSIZE,     // AHB transfer size
    input   [1:0]           HTRANS,    // AHB transfer type
    input   [3:0]           HPROT,     // AHB protection info

    output reg              HREADYOUT, // AHB ready output
    output reg [DATAWIDTH-1:0] HRDATA, // AHB read data
    output reg              HRESP,     // AHB response

    // APB bus signals
    input                   PCLKEN,    // APB clock enable signal
    input   [DATAWIDTH-1:0] PRDATA,    // APB read data
    output reg              PSEL,      // APB select
    output reg              PENABLE,   // APB enable
    output  [ADDRWIDTH-1:0] PADDR,  // APB address
    output reg              PWRITE,    // APB write enable
    output reg [DATAWIDTH-1:0] PWDATA, // APB write data

    `ifdef APB3
    input                   PREADY,    // APB ready signal
    input                   PSLVERR,   // APB error signal
    `endif

    `ifdef APB4
    output reg [2:0]        PPROT,     // APB protection
    output reg [3:0]        PSTRB,     // APB strobe
    `endif

    output reg              APBACTIVE  // Indicate active APB transaction
);

    // 内部信号定义
    reg [DATAWIDTH-1:0] data_reg; // 数据寄存
    reg [DATAWIDTH-1:0] PRDATA_reg; // 地址寄存
    reg [ADDRWIDTH-1:0] addr_reg; // 地址寄存
    reg [ADDRWIDTH-1:0] PADDR_reg; // 地址寄存
    // reg ahb_read_active;                // AHB读指示
    // reg ahb_write_active;               // AHB写指示
    reg apb_transaction_done;           // APB传输完成

    reg HSEL_reg; // AHB select寄存
    reg HWRITE_reg; // AHB write寄存

    reg HWRITE_reg_reg; // AHB write寄存



    // 状态机定义
    // typedef enum logic [1:0] {
    //     IDLE  = 2'b00,
    //     SETUP = 2'b01,
    //     PROCESSING = 2'b10
    // } fsm_state_t;

    // fsm_state_t current_state, next_state;

    reg [2:0]           current_state;
    reg [2:0]           next_state;
    reg [2:0]           last_state; // APB state寄存


    localparam IDLE  = 3'b000;
    localparam SETUP = 3'b001;
    localparam PROCESSING = 3'b010;
    localparam READ_WAIT = 3'b011;  // 3
    localparam READ_WAIT2 = 3'b100; // 4
    localparam WRITE_WAIT = 3'b101; // 5
    // localparam READ_PROCS = 3'b110; // 6

    // AHB 信号
    wire ahb_active = HSEL && (HTRANS[1] == 'b1) && HREADY; // HTRANS[1] == 1 可进行传输
    wire ahb_write = ahb_active && HWRITE; // ahb写信号
    wire ahb_read = ahb_active && !HWRITE; // ahb读信号

    assign wdata_ifreg = (REGISTER_WDATA == 1) ? 1'b1 : 1'b0 ;
    assign rdata_ifreg = (REGISTER_RDATA == 1) ? 1'b1 : 1'b0 ;

    // AHB select寄存
    // always @(posedge HCLK or negedge HRESETn) begin
    //     if (!HRESETn) begin
    //         HSEL_reg <= 'b0;
    //     end else begin
    //         HSEL_reg <= HSEL;
    //     end
    // end


    // 状态机
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            last_state <= IDLE;
        end else begin
            last_state <= current_state;
        end
    end

    // 状态机转换
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (ahb_write && !HWRITE_reg ) begin
                    next_state = WRITE_WAIT;
                end else if (ahb_read ||(ahb_write && HWRITE_reg)) begin
                    next_state = SETUP;
                end else begin
                    next_state = IDLE;
                end
            end
            WRITE_WAIT:begin
                if(HSEL && HTRANS[1]) begin
                    next_state = SETUP;
                end else begin
                    next_state = WRITE_WAIT;
                end
            end
            SETUP: begin
                // if(HSEL && HTRANS[1] && HWRITE_reg_reg == 'b1 && HWRITE_reg == 'b0 ) begin // HSEL && HTRANS[1] 且之前是写读操作
                if(HWRITE_reg_reg == 'b1 && HWRITE_reg == 'b0 ) begin
                    next_state = READ_WAIT;
                // end else if(HSEL && HTRANS[1]) begin
                end else begin
                    next_state = PROCESSING;
                end 
            end
            READ_WAIT: begin
                next_state = READ_WAIT2;
            end
            READ_WAIT2: begin
                // if(HWRITE_reg == 'b0 && (!HSEL || !HTRANS[1]))begin
                //     next_state = READ_PROCS;
                // end else begin
                    next_state = PROCESSING;
                
            end
            PROCESSING: begin
                `ifdef APB3
                if (PREADY && PCLKEN && ahb_active) begin
                    next_state = SETUP;
                end else if (PREADY && PCLKEN) begin
                    next_state = IDLE;
                end else begin
                    next_state = PROCESSING;
                end
                `else
                // if(HWRITE_reg_reg == 'b1 && HWRITE_reg == 'b0 && HWRITE) begin
                if(HSEL && HTRANS[1] && !HWRITE_reg && HWRITE) begin //选中 前读现写
                    next_state = WRITE_WAIT;
                end else if((!HSEL || !HTRANS[1]) && !HWRITE_reg) begin //未选中 前读 
                    next_state = PROCESSING;
                end else if (PCLKEN && ahb_active) begin
                    next_state = SETUP;
                end else if (PCLKEN) begin
                    next_state = IDLE;
                end else begin
                    next_state = PROCESSING;
                end
                `endif
            end
            default: next_state = IDLE;
        endcase
    end


    // 状态机信号输出 2.0版
    always @(*)begin
        case(current_state)
            IDLE:begin
                PSEL = 'b0;
                PENABLE = 'b0;
                HREADYOUT = 'b1;
                APBACTIVE = 'b0;
                apb_transaction_done = 'b0;
            end
            WRITE_WAIT:begin
                PSEL = 'b0;
                PENABLE = 'b0;
                APBACTIVE = 'b0;
                HREADYOUT = 'b1;
                apb_transaction_done = 'b0;
            end
            SETUP:begin
                PSEL = 'b1;
                PENABLE = 'b0;
                APBACTIVE = 'b1;
                HREADYOUT = 'b0;
                apb_transaction_done = 'b0;
            end
            READ_WAIT:begin
                PSEL = 'b1;
                PENABLE = 'b1;
                APBACTIVE = 'b1;
                HREADYOUT = 'b0;
                apb_transaction_done = 'b1;
            end
            READ_WAIT2:begin
                PSEL = 'b1;
                PENABLE = 'b0;
                APBACTIVE = 'b1;
                HREADYOUT = 'b0;
                apb_transaction_done = 'b0;
            end
            PROCESSING:begin
                PSEL = 'b1;
                PENABLE = (HWRITE_reg == 'b0)? (HSEL && HTRANS[1]): 1'b1;
                APBACTIVE = 'b1;
                HREADYOUT = 'b1;
                apb_transaction_done = 'b1;
            end
            default: begin
                PSEL = 'b0;
                PENABLE = 'b0;
                HREADYOUT = 'b1;
                APBACTIVE = 'b0;
                apb_transaction_done = 'b0;
        end
        endcase
    end

    // 地址/写使能信号寄存
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_reg <= 'b0;
            HWRITE_reg <= 'b0;
            HWRITE_reg_reg <= 'b0;
        end else if ((current_state == IDLE && HSEL && HTRANS[1])|| ahb_active) begin // ahb_active = HSEL && (HTRANS[1] == 'b1) && HREADY
            // addr_reg <= {HADDR[ADDRWIDTH-1:2],2'b00} ;
            addr_reg <= HADDR;
            HWRITE_reg <= HWRITE;
            HWRITE_reg_reg <= HWRITE_reg;
        end else begin
            addr_reg <= addr_reg;
            HWRITE_reg <= HWRITE_reg;
            HWRITE_reg_reg <= HWRITE_reg_reg;
        end
    end

    always@ (posedge HCLK or negedge HRESETn) begin
        if(!HRESETn)begin
            PWRITE <= 'b0;
            PADDR_reg <= 'b0;
        end else begin
            if((current_state == IDLE && ahb_read)||(current_state == PROCESSING && !HWRITE_reg && HSEL && HTRANS[1]))begin
                PWRITE <= HWRITE;
                PADDR_reg <= HADDR;
            end else begin
                if(PENABLE || current_state == WRITE_WAIT) begin
                    PWRITE <= HWRITE_reg;
                    PADDR_reg <= addr_reg;
                end
            end
        end
    end

    assign PADDR = PADDR_reg ;


    // // 数据寄存
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            data_reg <= 'b0;
        end else begin
            if (HWRITE && wdata_ifreg) begin
                data_reg <= HWDATA; // 写操作时更新 data_reg
            end else if (!HWRITE && rdata_ifreg) begin
                data_reg <= PRDATA; // 读操作时更新 data_reg
            end
        end
    end


    // 写数据输出
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            PWDATA <= 'b0;
        end else begin
            if(ahb_active || (current_state == WRITE_WAIT && HSEL && HTRANS[1]))begin
                PWDATA <= HWDATA;
            end else begin
                PWDATA <= PWDATA;
            end
        end
    end


    // 读数据输出
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            PRDATA_reg <= 'b0;
        end else begin
            if (last_state == READ_WAIT2 && current_state == PROCESSING) begin
                PRDATA_reg <= PRDATA;
            end else begin
                PRDATA_reg <= PRDATA_reg;
            end
        end
    end

    // assign HRDATA = (PENABLE && HSEL && HTRANS[1]) ? PRDATA : PRDATA_reg ;
    assign HRDATA = (PENABLE == 'b1 && last_state == PROCESSING) ? PRDATA_reg : PRDATA ;

    `ifdef APB3
    assign HRESP = PSLVERR;
    `else
    assign HRESP = 'b0 ;
    `endif 


    // APB4 signals 随便写的
    `ifdef APB4
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            PPROT <= 'b0;
            PSTRB <= 'b0;
        end else if (current_state == SETUP) begin
            PPROT <= HPROT[2:0]; // 使用HPROT
            PSTRB <= 4'b1111; // 所有数据有效
        end
    end
    `endif



endmodule