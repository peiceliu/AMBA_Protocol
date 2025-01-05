/////////////////////////////////////////
// file name   : my_sync_bridge_interface.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_interface
// log         : no
/////////////////////////////////////////

interface my_sync_bridge_interface();
    // system signal
    logic  clk;       //HCLK
    logic  rst_n;     //HRESETn
    // ahb signal
    logic  hsel;
    logic  [`ADDRWIDTH-1:0] haddr;
    logic  [1:0] htrans;
    logic  [2:0] hsize;
    logic  [3:0] hport;
    logic  hwrite;
    logic  hready;
    logic  [31:0] hwdata;
    logic  hreadyout;
    logic  hresp;
    logic  [31:0] hrdata;
    // apb clock controll signal 
    logic  pclken;
    logic  apbactive;
    // apb signal
    logic  [`ADDRWIDTH-1:0] paddr;
    logic  penable;
    logic  psel;
    logic  pwrite;
    logic  [31:0] pwdata;
    logic  [31:0] prdata;

    `ifdef APB3
    logic  pready;
    logic  pslverr;
    `endif 
    
    `ifdef  APB4
    logic  pready;
    logic  pslverr;
    logic  [3:0] pstrb;
    logic  [2:0] pport;
    `endif

    // `ifdef APB4
    // logic  [3:0] pstrb;
    // logic  [2:0] pport;
    // `endif
    // clocking cb @(posedge clk);

    // endclocking

endinterface

