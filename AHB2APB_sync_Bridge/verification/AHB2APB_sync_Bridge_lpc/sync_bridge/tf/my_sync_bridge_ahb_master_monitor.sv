/////////////////////////////////////////
// file name   : my_sync_bridge_ahb_master_monitor.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_ahb_master_monitor
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"
// import uvm_pkg::*;

class my_sync_bridge_ahb_master_monitor extends uvm_monitor;
    `uvm_component_utils(my_sync_bridge_ahb_master_monitor)

    virtual my_sync_bridge_interface vif;
    my_sync_bridge_ahb_master_transaction tr ;

    uvm_analysis_port #(my_sync_bridge_ahb_master_transaction)  ap;
    
    function new(string name = "my_sync_bridge_ahb_master_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(my_sync_bridge_ahb_master_transaction tr);
endclass

function void my_sync_bridge_ahb_master_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_sync_bridge_interface)::get(this, "", "vif", vif))begin
        `uvm_fatal("my_sync_bridge_ahb_master_monitor", "virtual interface must be set for vif!!!")
    end

    ap = new("ap", this);

endfunction

task my_sync_bridge_ahb_master_monitor::main_phase(uvm_phase phase);
    my_sync_bridge_ahb_master_transaction tr;
    while(1) begin
        tr = new("tr");
        collect_one_pkt(tr);
        ap.write(tr);
    end
endtask

task my_sync_bridge_ahb_master_monitor::collect_one_pkt(my_sync_bridge_ahb_master_transaction tr);
    @(posedge vif.clk);
    //byte unsigned data_q[$];
    //byte unsigned data_array[];
    //logic [7:0] data;
    //logic valid = 0;
    //int data_size;
    //
    //while(1) begin
    //    @(posedge vif.clk);
    //    if(vif.valid) break;
    //end
    //
    ////`uvm_info("my_sync_bridge_ahb_master_monitor", "begin to collect one pkt", UVM_LOW);
    //while(vif.valid) begin
    //    data_q.push_back(vif.data);
    //    @(posedge vif.clk);
    //end
    //data_size  = data_q.size();   
    //data_array = new[data_size];
    //for ( int i = 0; i < data_size; i++ ) begin
    //    data_array[i] = data_q[i]; 
    //end
    //tr.pload = new[data_size - 18]; //da sa, e_type, crc
    //data_size = tr.unpack_bytes(data_array) / 8; 
    ////`uvm_info("my_sync_bridge_ahb_master_monitor", "end collect one pkt", UVM_LOW);
endtask


