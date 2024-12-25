/////////////////////////////////////////
// file name   : my_case1.sv
// create time : 2019 - 12 - 31
// author      : ximata
// version     : v1.0
// decription  : my_case1
// log         : no
/////////////////////////////////////////



// case sequence
/*
class normal_sequence extends uvm_sequence #(my_transaction);
   my_transaction m_trans;

   function  new(string name= "normal_sequence");
      super.new(name);
   endfunction 
   
   virtual task pre_body();
      if(starting_phase != null) 
         starting_phase.raise_objection(this);
   endtask 
   virtual task post_body();
      if(starting_phase != null) 
         starting_phase.drop_objection(this);
   endtask 
   
   virtual task body();
      repeat (10) begin
         `uvm_do(m_trans)
         m_trans.print();
      end
      #100;
   endtask

   `uvm_object_utils(normal_sequence)
endclass
*/









// virtual sequence
class my_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(my_virtual_sequence)
    `uvm_declare_p_sequencer(my_sync_bridge_virtual_sequencer)

    function new(string name = "my_virtual_sequence");
        super.new(name);
    endfunction

    extern virtual task body();

endclass

task my_virtual_sequence::body();
    if(starting_phase != null)begin
        starting_phase.raise_objection(this);
    end


    if(starting_phase != null)begin
        starting_phase.drop_objection(this);
    end
endtask

///////////////////////////////////////
//// main test case body //////////////
/////////////////////////////////////// 
class my_case1 extends my_sync_bridge_base_test;
    `uvm_component_utils(my_case1)

    function new(string name = "my_case1", uvm_component parent = null);
       super.new(name,parent);
    endfunction 

    extern virtual function void build_phase(uvm_phase phase); 
    extern virtual function void connect_phase(uvm_phase phase); 

endclass


function void my_case1::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //factory.set_type_override_by_type(my_driver::get_type(), crc_driver::get_type());
    //start virtual sequence 
    uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "m_env.m_vsqr.main_phase", 
                                           "default_sequence", 
                                           my_virtual_sequence::type_id::get());
    // set the value of m_cfg,for example m_cfg.cycle = 10.0

    //send m_cfg to tb
    uvm_config_db#(my_sync_bridge_cfg_transaction)::set(this, 
                                           "m_env*", 
                                           "m_cfg", 
                                           m_cfg);

endfunction

function void my_case1::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // m_env.set_report_verbosity_level_hier(UVM_HIGH);
    //
endfunction

