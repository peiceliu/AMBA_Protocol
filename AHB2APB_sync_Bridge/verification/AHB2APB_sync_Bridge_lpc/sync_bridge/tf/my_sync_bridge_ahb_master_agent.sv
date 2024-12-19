/////////////////////////////////////////
// file name   : my_sync_bridge_ahb_master_agent.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_ahb_master_agent
// log         : no
/////////////////////////////////////////

class my_sync_bridge_ahb_master_agent extends uvm_agent ;
    `uvm_component_utils(my_sync_bridge_ahb_master_agent)

    my_sync_bridge_ahb_master_sequencer  sqr;
    my_sync_bridge_ahb_master_driver     drv;
    my_sync_bridge_ahb_master_monitor    mon;

    my_sync_bridge_cfg_transaction    m_cfg;
    
    
    function new(string name = "my_sync_bridge_ahb_master_agent", uvm_component parent = null);
       super.new(name, parent);
    endfunction 
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass 


function void my_sync_bridge_ahb_master_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(my_sync_bridge_cfg_transaction)::get(this,"","m_cfg",m_cfg))begin
        `uvm_fatal("NO_CFG","my_sync_bridge_ahb_master_agent can't get cfg");
    end
    is_active = m_cfg.my_sync_bridge_ahb_master_agent_is_active;
    if (is_active == UVM_ACTIVE) begin
        sqr = my_sync_bridge_ahb_master_sequencer::type_id::create("sqr", this);
        drv = my_sync_bridge_ahb_master_driver::type_id::create("drv", this);
    end
    mon = my_sync_bridge_ahb_master_monitor::type_id::create("mon", this);
endfunction 

function void my_sync_bridge_ahb_master_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
    end
endfunction


