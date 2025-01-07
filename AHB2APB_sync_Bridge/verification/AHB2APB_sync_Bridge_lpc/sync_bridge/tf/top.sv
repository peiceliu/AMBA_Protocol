/////////////////////////////////////////
// file name   : top.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : tb_top
// log         : no
/////////////////////////////////////////

`timescale 1ns/1ps


module tb_top();

    my_sync_bridge_interface my_sync_bridge_if();

    //instantiate design
ahb2apb_bridge AHB2APB_Bridge_dut(
    // AHB bus signals
    .HCLK(my_sync_bridge_if.clk),
    .HRESETn(my_sync_bridge_if.rst_n),
    .HSEL(my_sync_bridge_if.hsel),
    .HADDR(my_sync_bridge_if.haddr),
    .HTRANS(my_sync_bridge_if.htrans),
    .HSIZE(my_sync_bridge_if.hsize),
    .HPROT(my_sync_bridge_if.hport),
    .HWRITE(my_sync_bridge_if.hwrite),
    .HWDATA(my_sync_bridge_if.hwdata),
    .HREADY(my_sync_bridge_if.hready),//
    .HREADYOUT(my_sync_bridge_if.hreadyout),
    .HRDATA(my_sync_bridge_if.hrdata),
    .HRESP(my_sync_bridge_if.hresp),
    // APB bus signals
    .PCLKEN(my_sync_bridge_if.pclken),
    .PRDATA(my_sync_bridge_if.prdata),
    `ifdef APB3
    .PREADY(my_sync_bridge_if.pready),
    .PSLVERR(my_sync_bridge_if.pslverr),
    `endif 
    .PSEL(my_sync_bridge_if.psel),
    .PENABLE(my_sync_bridge_if.penable),
    .PADDR(my_sync_bridge_if.paddr),
    .PWRITE(my_sync_bridge_if.pwrite),
    .PWDATA(my_sync_bridge_if.pwdata),
    `ifdef APB4
    .PPROT(my_sync_bridge_if.pport),
    .PSTRB(my_sync_bridge_if.pstrb),
    `endif
    .APBACTIVE(my_sync_bridge_if.apbactive)
);

    initial begin
        run_test();
    end

    always @(*) begin
        repeat(100)@(posedge my_sync_bridge_if.clk);
        $fsdbDumpflush();
    end

`ifndef FSDB_OFF
    initial begin//do_not_remove
        $fsdbAutoSwitchDumpfile("/home/liupeice/AMBA_Protocol/AHB2APB_sync_Bridge/verification/AHB2APB_sync_Bridge_lpc/sync_bridge/wave/my_case1.fsdb");//do_not_remove
        $fsdbDumpvars(0,tb_top);//do_not_remove
    end//do_not_remove
`endif

endmodule
