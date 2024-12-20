/////////////////////////////////////////
// file name   : my_case3.sv
// create time : 2024-12-20
// author : ximata
// version     : v1.0
// decription  : my_case3
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

class ahb_master_write_sequence_once extends uvm_sequence #(my_sync_bridge_ahb_master_transaction);
    my_sync_bridge_ahb_master_transaction tr_once;
    
    function new(string name = "ahb_master_write_sequence_once");
        super.new(name);
    endfunction

    virtual task body();
            `uvm_info(get_type_name(), "ahb_master_write_sequence_once", UVM_LOW);
            `uvm_do_with(tr_once,{
                tr_once.hsel == 1;
                tr_once.haddr == 32'h00000000;
                tr_once.htrans == 2'b10;
                tr_once.hsize == 3'b010;
                tr_once.hport == 3'b000;
                tr_once.hwrite == 1;
                tr_once.hready == 1;
                tr_once.hwdata == 32'h00000001;
            })
    endtask

    `uvm_object_utils(ahb_master_write_sequence_once)
endclass



// virtual sequence
class my_sync_bridge_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(my_sync_bridge_virtual_sequence)
    `uvm_declare_p_sequencer(my_sync_bridge_virtual_sequencer)

    ahb_master_write_sequence_once seq_once;


    function new(string name = "my_sync_bridge_virtual_sequence");
        super.new(name);
    endfunction

    extern virtual task body();

endclass

task my_sync_bridge_virtual_sequence::body();

    repeat(10)begin
        `uvm_do_on(seq_once,p_sequencer.m_ahb_master_sqr)
    end
    #100;
endtask

///////////////////////////////////////
//// main test case body //////////////
/////////////////////////////////////// 
class my_case3 extends my_sync_bridge_base_test;
    `uvm_component_utils(my_case3)
    my_sync_bridge_virtual_sequence m_vseq;
    function new(string name = "my_case3", uvm_component parent = null);
       super.new(name,parent);
    endfunction 

    extern virtual function void build_phase(uvm_phase phase); 
    extern virtual function void connect_phase(uvm_phase phase); 
    extern virtual task main_phase(uvm_phase phase);

endclass


function void my_case3::build_phase(uvm_phase phase);
    super.build_phase(phase);
    //send m_cfg to tb
    uvm_config_db#(my_sync_bridge_cfg_transaction)::set(this, 
                                           "m_env*", 
                                           "m_cfg", 
                                           m_cfg);

endfunction

function void my_case3::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

endfunction

task my_case3::main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);
    m_vseq = new();
    m_vseq.start(m_env.m_vsqr);
    #1000;
    phase.drop_objection(this);
endtask