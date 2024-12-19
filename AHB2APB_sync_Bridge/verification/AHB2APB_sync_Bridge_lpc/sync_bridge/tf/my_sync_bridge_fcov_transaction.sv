/////////////////////////////////////////
// file name   : my_sync_bridge_fcov_transaction.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_fcov_transaction
// log         : no
/////////////////////////////////////////


class my_sync_bridge_fcov_transaction extends uvm_sequence_item;

    `uvm_object_utils_begin(my_sync_bridge_fcov_transaction)
    `uvm_object_utils_end

    function new(string name = "my_sync_bridge_fcov_transaction");
        super.new(name);
    endfunction

endclass
