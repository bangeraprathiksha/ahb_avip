`ifndef AHBHMASTKOCKTEST_INCLUDED_
`define AHBHMASTLOCKTEST_INCLUDED_

class AhbHmastlockTest extends AhbBaseTest;
  `uvm_component_utils(AhbHmastlockTest)

  AhbVirtualHmastlockSequence ahbVirtualHmastlockSequence;

  extern function new(string name = "AhbHmastlockTest", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : AhbHmastlockTest

function AhbHmastlockTest::new(string name = "AhbHmastlockTest",uvm_component parent = null);
  super.new(name, parent);
endfunction : new


task AhbHmastlockTest::run_phase(uvm_phase phase);

  foreach(ahbEnvironment.ahbSlaveAgentConfig[i]) begin
    if(!ahbEnvironment.ahbSlaveAgentConfig[0].randomize() with {noOfWaitStates==3;}) begin
      `uvm_fatal(get_type_name(),"Unable to randomise noOfWaitStates")
    end
   if(!ahbEnvironment.ahbSlaveAgentConfig[1].randomize() with {noOfWaitStates==0;}) begin
      `uvm_fatal(get_type_name(),"Unable to randomise noOfWaitStates")
    end
  end

  ahbVirtualHmastlockSequence = AhbVirtualHmastlockSequence::type_id::create("ahbVirtualHmastlockSequence");
  `uvm_info(get_type_name(),$sformatf("AhbHmastlockTest"),UVM_LOW);

  phase.raise_objection(this);
  ahbVirtualHmastlockSequence.start(ahbEnvironment.ahbVirtualSequencer);
        #10;
  phase.drop_objection(this);

endtask : run_phase

`endif

