/////////////////////////////////////////
// file name   : my_sync_bridge_cfg_transaction.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_cfg_transaction
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"

// import uvm_pkg::*;

class my_sync_bridge_cfg_transaction extends uvm_object;

    `uvm_object_utils_begin(my_sync_bridge_cfg_transaction)
    `uvm_object_utils_end
    uvm_active_passive_enum my_sync_bridge_output_agent_is_active = UVM_ACTIVE;
    uvm_active_passive_enum my_sync_bridge_apb_slave_agent_is_active = UVM_ACTIVE;
    uvm_active_passive_enum my_sync_bridge_ahb_master_agent_is_active = UVM_ACTIVE;

    real cycle;

    function new(string name = "my_sync_bridge_cfg_transaction");
        super.new(name);
        cycle = 5.0;
    endfunction

endclass
