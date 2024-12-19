/////////////////////////////////////////
// file name   : my_sync_bridge_output_fcov_transaction.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_output_fcov_transaction
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"

// import uvm_pkg::*;

class my_sync_bridge_output_transaction extends uvm_sequence_item;

    rand byte      pload[];

    rand bit       pre_err;
    
  
    constraint pre_err_cons{
        pre_err == 1'b0;
    } 
    
    constraint pload_cons{
        pload.size >= 46;
        pload.size <= 1500;
    }

    `uvm_object_utils_begin(my_sync_bridge_output_transaction)
        `uvm_field_array_int(pload, UVM_ALL_ON)
        `uvm_field_int(pre_err, UVM_ALL_ON | UVM_NOPACK)
    `uvm_object_utils_end

    function new(string name = "my_sync_bridge_output_transaction");
        super.new();
    endfunction

endclass
      
