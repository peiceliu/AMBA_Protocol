/////////////////////////////////////////
// file name   : my_sync_bridge_apb_slave_driver.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_apb_slave_driver
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"
// import uvm_pkg::*;

                     
class my_sync_bridge_apb_slave_driver extends uvm_driver#(my_sync_bridge_apb_slave_transaction);

    `uvm_component_utils(my_sync_bridge_apb_slave_driver)

    virtual my_sync_bridge_interface vif;
    uvm_analysis_port #(my_sync_bridge_apb_slave_transaction) ap;

    function new(string name = "my_sync_bridge_apb_slave_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern task drive_one_pkt(my_sync_bridge_apb_slave_transaction tr);
endclass

function void my_sync_bridge_apb_slave_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_sync_bridge_interface)::get(this, "", "vif", vif))begin
        `uvm_fatal("NO_INTERFACE", "my_sync_bridge_apb_slave_driver can't get interface")
    end

    ap = new("ap",this);

endfunction

task my_sync_bridge_apb_slave_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    super.reset_phase(phase);
    phase.drop_objection(this);
endtask

task my_sync_bridge_apb_slave_driver::main_phase(uvm_phase phase);
    while(!vif.rst_n)begin
        @(posedge vif.clk);
    end
    forever begin
        seq_item_port.get_next_item(req);
        drive_one_pkt(req);
        ap.write(req);
        seq_item_port.item_done();
    end
endtask

task my_sync_bridge_apb_slave_driver::drive_one_pkt(my_sync_bridge_apb_slave_transaction tr);

    if(vif.pclken === 1'b1)begin
        vif.prdata <= tr.prdata;
        `ifdef APB3
        vif.pready <= tr.pready;
        vif.pslverr <= tr.pslverr;
        `endif
    end
    @(posedge vif.clk);

endtask


