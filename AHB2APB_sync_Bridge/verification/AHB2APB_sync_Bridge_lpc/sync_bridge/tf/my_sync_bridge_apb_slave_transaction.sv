/////////////////////////////////////////
// file name   : my_sync_bridge_apb_slave_fcov_transaction.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_apb_slave_fcov_transaction
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"

// import uvm_pkg::*;

class my_sync_bridge_apb_slave_transaction extends uvm_sequence_item;

    rand bit [`DATAWIDTH-1:0] prdata;
    rand bit pready;
    rand bit pslverr;

    `uvm_object_utils_begin(my_sync_bridge_apb_slave_transaction)
        `uvm_field_int(prdata, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(pready, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(pslverr, UVM_ALL_ON | UVM_NOPACK)
    `uvm_object_utils_end

    function new(string name = "my_sync_bridge_apb_slave_transaction");
        super.new();
    endfunction

endclass

class my_sync_bridge_apb_slave_monitor_transaction extends uvm_sequence_item;

    rand bit [`DATAWIDTH-1:0] prdata;
    rand bit pready;
    rand bit pslverr;
    rand bit psel;
    rand bit penable;
    rand bit [`ADDRWIDTH-1:0] paddr;
    rand bit pwrite;
    rand bit [`DATAWIDTH-1:0] pwdata;
    rand bit [2:0] pport;
    rand bit [3:0]pstrb;
    rand bit apbactive;

    `uvm_object_utils_begin(my_sync_bridge_apb_slave_monitor_transaction)
        `uvm_field_int(prdata, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(pready, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(pslverr, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(psel, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(penable, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(paddr, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(pwrite, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(pwdata, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(pport, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(pstrb, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(apbactive, UVM_ALL_ON | UVM_NOPACK)
    `uvm_object_utils_end

    function new(string name = "my_sync_bridge_apb_slave_monitor_transaction");
        super.new();
    endfunction

endclass
      
