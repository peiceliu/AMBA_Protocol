/////////////////////////////////////////
// file name   : my_sync_bridge_virtual_sequencer.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_virtual_sequencer
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"
// import uvm_pkg::*;


class my_sync_bridge_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(my_sync_bridge_virtual_sequencer)
    
    my_sync_bridge_output_sequencer m_output_sqr;
    my_sync_bridge_apb_slave_sequencer m_apb_slave_sqr;
    my_sync_bridge_ahb_master_sequencer m_ahb_master_sqr;
    function new(string name= "my_sync_bridge_virtual_sequencer", uvm_component parent=null);
        super.new(name, parent);
    endfunction 
   
endclass

 