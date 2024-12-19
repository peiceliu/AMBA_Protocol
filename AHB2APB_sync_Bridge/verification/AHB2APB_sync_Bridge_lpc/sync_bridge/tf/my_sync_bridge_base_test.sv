/////////////////////////////////////////
// file name   : my_sync_bridge_my_sync_bridge_base_test.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_my_sync_bridge_base_test
// log         : no
/////////////////////////////////////////
//
// `include "uvm_macros.svh"
//import uvm_pkg::*;

class my_sync_bridge_base_test extends uvm_test;
    `uvm_component_utils(my_sync_bridge_base_test)

    my_sync_bridge_env             m_env;
    my_sync_bridge_cfg_transaction m_cfg;
    
    function new(string name = "my_sync_bridge_base_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);

endclass


function void my_sync_bridge_base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env  =  my_sync_bridge_env::type_id::create("m_env", this); 
    m_cfg  =  my_sync_bridge_cfg_transaction::type_id::create("m_cfg", this); 

    uvm_config_db#(virtual my_sync_bridge_interface)::set(this,"m_env*","vif",tb_top.my_sync_bridge_if);

    `ifndef PRESSURE_TEST
        uvm_top.set_timeout(8000000ns,0);
    `endif

endfunction

function void my_sync_bridge_base_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uvm_top.print_topology();
    //factory.print();
    m_env.set_report_verbosity_level_hier(UVM_HIGH);

endfunction

function void my_sync_bridge_base_test::report_phase(uvm_phase phase);
    uvm_report_server server;
    int err_num;
    super.report_phase(phase);

    server = get_report_server();
    err_num = server.get_severity_count(UVM_ERROR);

    if (err_num != 0) begin
        $display("TEST CASE FAILED");
    end
    else begin
        $display("TEST CASE PASSED");
    end
endfunction

