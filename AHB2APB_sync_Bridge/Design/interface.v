module interface #(
    parameter ADDRWIDTH = 16,
    parameter DATAWIDTH = 32,
) (
    // AHB bus signals
    input                   HCLK,
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

endmodule