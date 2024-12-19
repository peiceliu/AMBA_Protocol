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
