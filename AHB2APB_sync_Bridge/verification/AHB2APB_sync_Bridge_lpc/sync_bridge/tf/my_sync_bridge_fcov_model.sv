/////////////////////////////////////////
// file name   : my_sync_bridge_fcov_model.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_fcov_model
// log         : no
/////////////////////////////////////////


class my_sync_bridge_fcov_model extends uvm_subscriber#(my_sync_bridge_fcov_transaction);
    `uvm_component_utils(my_sync_bridge_fcov_model)

    covergroup example_group;

    endgroup

    function new(string name = "my_sync_bridge_fcov_model", uvm_component parent = null);
        super.new(name, parent);
        example_group = new();
    endfunction 

    extern virtual  function void build_phase(uvm_phase phase);
    extern virtual  function void write(my_sync_bridge_fcov_transaction tr);

endclass 


function void my_sync_bridge_fcov_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

function void my_sync_bridge_fcov_model::write(my_sync_bridge_fcov_transaction tr);
    example_group.sample();
endfunction

