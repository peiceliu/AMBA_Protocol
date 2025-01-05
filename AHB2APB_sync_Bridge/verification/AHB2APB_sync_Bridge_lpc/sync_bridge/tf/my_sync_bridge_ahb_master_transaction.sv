/////////////////////////////////////////
// file name   : my_sync_bridge_ahb_master_fcov_transaction.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_ahb_master_fcov_transaction
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"

// import uvm_pkg::*;

class my_sync_bridge_ahb_master_transaction extends uvm_sequence_item;
    rand bit hsel;                         //output
    rand bit [`ADDRWIDTH-1:0] haddr;       //output
    rand bit [1:0] htrans;                 //output
    rand bit [2:0] hsize;                  //output
    rand bit [3:0] hport;                  //output
    rand bit hwrite;                       //output
    rand bit hready;                       //output
    rand bit [`DATAWIDTH-1:0] hwdata;                //output
    `uvm_object_utils_begin(my_sync_bridge_ahb_master_transaction)
        `uvm_field_int(hsel, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(haddr, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(htrans, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hsize, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hport, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hwrite, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hready, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hwdata, UVM_ALL_ON | UVM_NOPACK)
    `uvm_object_utils_end
    function new(string name = "my_sync_bridge_ahb_master_transaction");
        super.new();
    endfunction
endclass
class my_sync_bridge_ahb_master_monitor_transaction extends uvm_sequence_item;
    rand bit hsel;                         
    rand bit [`ADDRWIDTH-1:0] haddr;
    rand bit [1:0] htrans;
    rand bit [2:0] hsize;
    rand bit [3:0] hport;
    rand bit hwrite;
    rand bit hready;
    rand bit [`DATAWIDTH-1:0] hwdata;
    rand bit hreadyout;                   
    rand bit hresp;                       
    rand bit [31:0] hrdata;               

    `uvm_object_utils_begin(my_sync_bridge_ahb_master_monitor_transaction)
        `uvm_field_int(hsel, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(haddr, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(htrans, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hsize, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hport, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hwrite, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hready, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hwdata, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hreadyout, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hresp, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_int(hrdata, UVM_ALL_ON | UVM_NOPACK)
    `uvm_object_utils_end
    function new(string name = "my_sync_bridge_ahb_master_monitor_transaction");
        super.new();
    endfunction
endclass
