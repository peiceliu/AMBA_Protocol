/////////////////////////////////////////
// file name   : my_sync_bridge_scoreboard.sv
// create time : 2024-12-18
// author      : lpc
// version     : v1.0
// decription  : my_sync_bridge_scoreboard
// log         : no
/////////////////////////////////////////

// import uvm_pkg::*;
                    
class my_sync_bridge_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_sync_bridge_scoreboard)

    virtual my_sync_bridge_interface vif;


    uvm_blocking_get_port #(my_sync_bridge_output_transaction) m_output_agt_get_port;

    extern function new(string name = "my_sync_bridge_scoreboard", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass 

function my_sync_bridge_scoreboard::new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction 

function void my_sync_bridge_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_sync_bridge_interface)::get(this,"","vif",vif))begin
        `uvm_fatal("NO_INTERFACE","scoreboard can't get interface");
    end
    m_output_agt_get_port = new("m_output_agt_get_port",this);


endfunction 

task my_sync_bridge_scoreboard::main_phase(uvm_phase phase);
    //my_sync_bridge_transaction  get_expect,  get_actual, tmp_tran;
    //bit result;
 
    //super.main_phase(phase);
    //fork 
    //   while (1) begin
    //      exp_port.get(get_expect);
    //      expect_queue.push_back(get_expect);
    //   end
    //   while (1) begin
    //      act_port.get(get_actual);
    //      if(expect_queue.size() > 0) begin
    //         tmp_tran = expect_queue.pop_front();
    //         result = get_actual.compare(tmp_tran);
    //         if(result) begin 
    //            `uvm_info("my_sync_bridge_scoreboard", "Compare SUCCESSFULLY", UVM_LOW);
    //         end
    //         else begin
    //            `uvm_error("my_sync_bridge_scoreboard", "Compare FAILED");
    //            $display("the expect pkt is");
    //            tmp_tran.print();
    //            $display("the actual pkt is");
    //            get_actual.print();
    //         end
    //      end
    //      else begin
    //         `uvm_error("my_sync_bridge_scoreboard", "Received from DUT, while Expect Queue is empty");
    //         $display("the unexpected pkt is");
    //         get_actual.print();
    //      end 
    //   end
    //join
endtask
