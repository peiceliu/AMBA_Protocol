/////////////////////////////////////////
// file name   : my_sync_bridge_clock_model.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_clock_model
// log         : no
/////////////////////////////////////////


class my_sync_bridge_clock_model extends uvm_component;
   
    `uvm_component_utils(my_sync_bridge_clock_model)

    virtual my_sync_bridge_interface vif;  
    my_sync_bridge_cfg_transaction m_cfg;

    real cycle;

    function new(string name = "my_sync_bridge_clock_model", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    extern function void build_phase(uvm_phase phase);
    extern virtual  task run_phase(uvm_phase phase);

endclass 


function void my_sync_bridge_clock_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_sync_bridge_interface)::get(this,"","vif",vif))begin
        `uvm_fatal("NO_INTERFACE","clock_model can't get interface");
    end
    if(!uvm_config_db#(my_sync_bridge_cfg_transaction)::get(this,"","m_cfg",m_cfg))begin
        `uvm_fatal("NO_CFG","my_sync_bridge_clock_model can't get m_cfg");
    end
    cycle = m_cfg.cycle;
    `uvm_info("CYCLE",$sformatf("cycle is %fns",cycle),UVM_LOW);

endfunction

task my_sync_bridge_clock_model::run_phase(uvm_phase phase);
    fork
        begin
            vif.clk <= 1'b0;
            forever #(cycle/2) vif.clk <= ~vif.clk;
        end
        begin
            vif.rst_n = 1'b0;
            #1000ns;
            vif.rst_n = 1'b1;
        end
        begin
            vif.pclken <= 1'b1;
            // forever #(cycle/2) vif.pclken <= ~vif.pclken;
        end
    join
endtask
