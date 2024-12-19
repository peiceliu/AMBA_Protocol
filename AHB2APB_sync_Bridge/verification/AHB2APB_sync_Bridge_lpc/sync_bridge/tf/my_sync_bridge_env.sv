/////////////////////////////////////////
// file name   : my_sync_bridge_env.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_env
// log         : no
/////////////////////////////////////////

// `include "uvm_macros.svh"
//import uvm_pkg::*;


class my_sync_bridge_env extends uvm_env;
    `uvm_component_utils(my_sync_bridge_env)

    my_sync_bridge_ref_model         m_ref_mdl;
    my_sync_bridge_scoreboard        m_scb;
    my_sync_bridge_clock_model       m_clk_mdl;
    my_sync_bridge_virtual_sequencer m_vsqr;
    my_sync_bridge_fcov_model        m_fcov_mdl;
    my_sync_bridge_output_agent m_output_agt;
    my_sync_bridge_apb_slave_agent m_apb_slave_agt;
    my_sync_bridge_ahb_master_agent m_ahb_master_agt;
    
    
    uvm_tlm_analysis_fifo #(my_sync_bridge_ahb_master_transaction) m_ahb_master_agt_ref_mdl_fifo;
    uvm_tlm_analysis_fifo #(my_sync_bridge_apb_slave_transaction) m_apb_slave_agt_ref_mdl_fifo;

    uvm_tlm_analysis_fifo #(my_sync_bridge_output_transaction) m_output_agt_scb_fifo;
    function new(string name = "my_sync_bridge_env", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
   
endclass


function void my_sync_bridge_env::build_phase(uvm_phase phase);
    m_ahb_master_agt = my_sync_bridge_ahb_master_agent::type_id::create("m_ahb_master_agt",this);
    m_apb_slave_agt = my_sync_bridge_apb_slave_agent::type_id::create("m_apb_slave_agt",this);
    m_output_agt = my_sync_bridge_output_agent::type_id::create("m_output_agt",this);
    super.build_phase(phase);
    m_ref_mdl = my_sync_bridge_ref_model::type_id::create("m_ref_mdl",this);
    m_scb = my_sync_bridge_scoreboard::type_id::create("m_scb", this);
    m_clk_mdl = my_sync_bridge_clock_model::type_id::create("m_clk_mdl", this);
    m_vsqr = my_sync_bridge_virtual_sequencer::type_id::create("m_vsqr", this);
    m_fcov_mdl = my_sync_bridge_fcov_model::type_id::create("m_fcov_mdl", this);
    m_ahb_master_agt_ref_mdl_fifo = new("m_ahb_master_agt_ref_mdl_fifo",this);
    m_apb_slave_agt_ref_mdl_fifo = new("m_apb_slave_agt_ref_mdl_fifo",this);
    m_output_agt_scb_fifo = new("m_output_agt_scb_fifo",this);

endfunction

function void my_sync_bridge_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //connect m_ahb_master_agt.sqr with virtual sequencer
    m_vsqr.m_ahb_master_sqr = m_ahb_master_agt.sqr;
    //connect m_ahb_master_agt with m_ref_mdl
    m_ahb_master_agt.drv.ap.connect(m_ahb_master_agt_ref_mdl_fifo.analysis_export);
    m_ref_mdl.m_ahb_master_agt_get_port.connect(m_ahb_master_agt_ref_mdl_fifo.blocking_get_export);
    //connect m_apb_slave_agt.sqr with virtual sequencer
    m_vsqr.m_apb_slave_sqr = m_apb_slave_agt.sqr;
    //connect m_apb_slave_agt with m_ref_mdl
    m_apb_slave_agt.drv.ap.connect(m_apb_slave_agt_ref_mdl_fifo.analysis_export);
    m_ref_mdl.m_apb_slave_agt_get_port.connect(m_apb_slave_agt_ref_mdl_fifo.blocking_get_export);
    //connect m_output_agt.sqr with virtual sequencer
    m_vsqr.m_output_sqr = m_output_agt.sqr;
    //connect m_output_agt with m_scb
    m_output_agt.mon.ap.connect(m_output_agt_scb_fifo.analysis_export);
    m_scb.m_output_agt_get_port.connect(m_output_agt_scb_fifo.blocking_get_export);
endfunction

