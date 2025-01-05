/////////////////////////////////////////
// file name   : my_sync_bridge_ahb_master_sequencer.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_ahb_master_sequencer
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"
// import uvm_pkg::*;


class my_sync_bridge_ahb_master_sequencer extends uvm_sequencer #(my_sync_bridge_ahb_master_transaction);
    `uvm_component_utils(my_sync_bridge_ahb_master_sequencer)
    
    function new(string name= "my_sync_bridge_ahb_master_sequencer", uvm_component parent=null);
        super.new(name, parent);
    endfunction 

endclass

