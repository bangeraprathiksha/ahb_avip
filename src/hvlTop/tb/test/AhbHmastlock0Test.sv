`ifndef AHBHMASTKOCK0TEST_INCLUDED_
`define AHBHMASTLOCK0TEST_INCLUDED_

class AhbHmastlock0Test extends AhbBaseTest;
  `uvm_component_utils(AhbHmastlock0Test)

  AhbVirtualHmastlock0Sequence ahbVirtualHmastlock0Sequence;

  extern function new(string name = "AhbHmastlock0Test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : AhbHmastlock0Test

function AhbHmastlock0Test::new(string name = "AhbHmastlock0Test",uvm_component parent = null);
  super.new(name, parent);
endfunction : new


task AhbHmastlock0Test::run_phase(uvm_phase phase);

  foreach(ahbEnvironment.ahbSlaveAgentConfig[i]) begin
    if(!ahbEnvironment.ahbSlaveAgentConfig[i].randomize() with {noOfWaitStates==0;}) begin
      `uvm_fatal(get_type_name(),"Unable to randomise noOfWaitStates")
    end
  end

  ahbVirtualHmastlock0Sequence = AhbVirtualHmastlock0Sequence::type_id::create("ahbVirtualHmastlock0Sequence");
  `uvm_info(get_type_name(),$sformatf("AhbHmastlock0Test"),UVM_LOW);

  phase.raise_objection(this);
  ahbVirtualHmastlock0Sequence.start(ahbEnvironment.ahbVirtualSequencer);
        #10;
  phase.drop_objection(this);

endtask : run_phase

`endif

