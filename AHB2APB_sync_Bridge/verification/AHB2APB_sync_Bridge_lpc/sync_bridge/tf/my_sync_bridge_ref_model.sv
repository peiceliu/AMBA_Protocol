/////////////////////////////////////////
// file name   : my_sync_bridge_ref_model.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_ref_model
// log         : no
/////////////////////////////////////////

// import uvm_pkg::*;
                    
class my_sync_bridge_ref_model extends uvm_component;
    `uvm_component_utils(my_sync_bridge_ref_model)

    virtual my_sync_bridge_interface vif;
    my_sync_bridge_cfg_transaction m_cfg;

    uvm_blocking_get_port #(my_sync_bridge_apb_slave_transaction) m_apb_slave_agt_get_port;
    uvm_blocking_get_port #(my_sync_bridge_ahb_master_transaction) m_ahb_master_agt_get_port;


    function new(string name = "my_sync_bridge_ref_model", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    extern function void build_phase(uvm_phase phase);
    extern virtual  task main_phase(uvm_phase phase);

endclass 


function void my_sync_bridge_ref_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_sync_bridge_interface)::get(this,"","vif",vif))begin
        `uvm_fatal("NO_INTERFACE","ref_model can't get interface");
    end
    if(!uvm_config_db#(my_sync_bridge_cfg_transaction)::get(this,"","m_cfg",m_cfg))begin
        `uvm_fatal("NO_CFG","my_sync_bridge_ref_model can't get m_cfg");
    end

    m_ahb_master_agt_get_port = new("m_ahb_master_agt_get_port",this);
    m_apb_slave_agt_get_port = new("m_apb_slave_agt_get_port",this);

endfunction


task my_sync_bridge_ref_model::main_phase(uvm_phase phase);
    //my_sync_bridge_transaction tr;
    //my_sync_bridge_transaction new_tr;
    //super.main_phase(phase);
    //while(1) begin
    //   port.get(tr);
    //   new_tr = new("new_tr");
    //   new_tr.copy(tr);
    //   //`uvm_info("my_sync_bridge_ref_model", "get one transaction, copy and print it:", UVM_LOW)
    //   //new_tr.print();
    //   ap.write(new_tr);
    //end
endtask
