module ahb2apb_bridge #(
    parameter ADDRWIDTH = 16,
    parameter DATAWIDTH = 32,
    parameter REGISTER_WDATA = 1,
    parameter REGISTER_RDATA = 1
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
    output reg [ADDRWIDTH-1:0] PADDR,  // APB address
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
    reg [DATAWIDTH-1:0] write_data_reg; // 写数据寄存
    reg [DATAWIDTH-1:0] read_data_reg;  // 读数据寄存
    // reg ahb_read_active;                // AHB读指示
    // reg ahb_write_active;               // AHB写指示
    reg apb_transaction_done;           // APB传输完成

    // 状态机定义
    // typedef enum logic [1:0] {
    //     IDLE  = 2'b00,
    //     SETUP = 2'b01,
    //     PROCESSING = 2'b10
    // } fsm_state_t;

    // fsm_state_t current_state, next_state;

    reg [1:0]           current_state;
    reg [1:0]           next_state;


    localparam IDLE  = 2'b00;
    localparam SETUP = 2'b01;
    localparam PROCESSING = 2'b10;

    // AHB 信号
    wire ahb_active = HSEL && (HTRANS[1] == 'b1) && HREADY; // HTRANS[1] == 1 可进行传输
    wire ahb_write = ahb_active && HWRITE; // ahb写信号
    wire ahb_read = ahb_active && !HWRITE; // ahb读信号

    assign wdata_ifreg = (REGISTER_WDATA == 1) ? 1'b1 : 1'b0 ;
    assign rdata_ifreg = (REGISTER_RDATA == 1) ? 1'b1 : 1'b0 ;

    // 状态机
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // 状态机转换
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (ahb_active) begin
                    next_state = SETUP;
                end else begin
                    next_state = IDLE;
                end
            end
            SETUP: begin
                next_state = PROCESSING;
            end
            PROCESSING: begin
                `ifdef APB3
                if (PREADY && PCLKEN) begin
                    next_state = IDLE;
                end else begin
                    next_state = PROCESSING;
                end
                `else
                if (PCLKEN) begin
                    next_state = IDLE;
                end else begin
                    next_state = PROCESSING;
                end
                `endif
            end
            default: next_state = IDLE;
        endcase
    end

    // 状态机输出
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            PSEL <= 'b0;
            PENABLE <= 'b0;
            PADDR <= 'b0;
            PWRITE <= 'b0;
            PWDATA <= 'b0;
            HREADYOUT <= 'b1;
            HRDATA <= 'b0;
            HRESP <= 'b0;
            APBACTIVE <= 'b0;
            apb_transaction_done <= 'b0;

            // APB4 signals
            `ifdef APB4
            PPROT <= 'b0;
            PSTRB <= 'b0;
            `endif
        end else begin
            case (current_state)
                IDLE: begin
                    PSEL <= 'b0;
                    PENABLE <= 'b0;
                    HREADYOUT <= 'b1;
                    HRESP <= 'b0;
                    APBACTIVE <= 'b0;
                    apb_transaction_done <= 'b0;

                    if (ahb_active) begin
                        PADDR <= {HADDR[ADDRWIDTH-1:2],2'b00} ;
                        PWRITE <= HWRITE;

                        // Register write data if enabled
                        if (wdata_ifreg) begin
                            write_data_reg <= HWDATA;
                        end else begin
                            PWDATA <= HWDATA;
                        end

                        APBACTIVE <= 'b1;
                        HREADYOUT <= 'b0;
                    end
                end
                SETUP: begin
                    PSEL <= 'b1;
                    PENABLE <= 'b0;
                    HRESP <= 'b0;

                    if (!wdata_ifreg) begin
                        PWDATA <= HWDATA;
                    end
                end
                PROCESSING: begin
                    if (PCLKEN) begin
                        PENABLE <= 'b1;

                        // APB write
                        if (PWRITE) begin
                            if (wdata_ifreg) begin
                                PWDATA <= write_data_reg;
                            end
                        end

                        // APB read
                        if (!PWRITE) begin
                            if (rdata_ifreg) begin
                                read_data_reg <= PRDATA;
                            end else begin
                                HRDATA <= PRDATA;
                            end
                        end

                        `ifdef APB3
                        if (PREADY) begin
                            PENABLE <= 'b0;
                            PSEL <= 'b0;
                            HREADYOUT <= 'b1;

                            if (!PWRITE && rdata_ifreg) begin
                                HRDATA <= read_data_reg;
                            end
                            apb_transaction_done <= 'b1;
                        end
                        `else
                        PENABLE <= 'b0;
                        PSEL <= 'b0;
                        HREADYOUT <= 'b1;

                        if (!PWRITE && rdata_ifreg) begin
                            HRDATA <= read_data_reg;
                        end
                        apb_transaction_done <= 'b1;
                        `endif
                    end
                end
            endcase
        end
    end

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