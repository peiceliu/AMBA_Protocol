/////////////////////////////////////////
// file name   : my_sync_bridge_ahb_master_driver.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_ahb_master_driver
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"
// import uvm_pkg::*;

                     
class my_sync_bridge_ahb_master_driver extends uvm_driver#(my_sync_bridge_ahb_master_transaction);

    `uvm_component_utils(my_sync_bridge_ahb_master_driver)

    virtual my_sync_bridge_interface vif;
    uvm_analysis_port #(my_sync_bridge_ahb_master_transaction) ap;

    function new(string name = "my_sync_bridge_ahb_master_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern task drive_one_pkt(my_sync_bridge_ahb_master_transaction tr);
endclass

function void my_sync_bridge_ahb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_sync_bridge_interface)::get(this, "", "vif", vif))begin
        `uvm_fatal("NO_INTERFACE", "my_sync_bridge_ahb_master_driver can't get interface")
    end

    ap = new("ap",this);

endfunction

task my_sync_bridge_ahb_master_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    super.reset_phase(phase);
    phase.drop_objection(this);
endtask

task my_sync_bridge_ahb_master_driver::main_phase(uvm_phase phase);
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

bit [`ADDRWIDTH-1:0]HADDR;    
bit [1:0] HTRANS;
        
task my_sync_bridge_ahb_master_driver::drive_one_pkt(my_sync_bridge_ahb_master_transaction tr);
    // if(tr.hsel === 1'b1 &&  vif.hreadyout === 1'b0 &&  vif.hresp === `OKAY)begin   //首先判断当前是否为 waited transfers
    //     if(HTRANS === `IDLE && tr.htrans=== `NONSEQ )begin
    //         vif.haddr <= tr.haddr;
    //         vif.htrans <= tr.htrans;
    //     end else if(HTRANS === `BUSY &&  tr.htrans === `SEQ)begin
    //         vif.haddr <= HADDR;
    //         vif.htrans <= tr.htrans;
    //     end else if(HTRANS === `BUSY &&  tr.htrans === `NONSEQ)begin
    //         vif.haddr <= tr.haddr;
    //         vif.htrans <= tr.htrans;
    //     end else if(HTRANS === `IDLE &&  tr.htrans === `IDLE)begin
    //         vif.haddr <= tr.haddr;
    //         vif.htrans <= tr.htrans;
    //     end else begin
    //         vif.haddr <= HADDR;
    //         vif.htrans <= HTRANS;end
    // end else if(tr.hsel === 1'b1 &&  vif.hreadyout === 1'b0 &&  vif.hresp === `ERROR)begin
    //     vif.haddr <= tr.haddr;
    //     vif.htrans <= tr.htrans;
    // end else begin
    //     vif.haddr <= tr.haddr;
    //     vif.htrans <= tr.htrans;
    // end
    vif.haddr <= tr.haddr;
    vif.htrans <= tr.htrans;
    vif.hsel <= tr.hsel;
    vif.hsize <= tr.hsize;
    vif.hport <= tr.hport;
    vif.hwrite <= tr.hwrite;
    vif.hready <= vif.hreadyout;
    vif.hwdata <= tr.hwdata;
        
    if(tr.hsel === 1'b1)
        HADDR <= tr.haddr;
        HTRANS <= tr.htrans;

    // vif.pclken <= 1'b1;
    @(posedge vif.clk);
    `uvm_info("my_sync_bridge_ahb_master_driver","had driven one ahb_input pkt successfully",UVM_LOW);


endtask


