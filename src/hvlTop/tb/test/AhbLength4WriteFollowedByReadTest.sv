`ifndef AHBLENGTH4WRITEFOLLOWEDBYREADTEST_INCLUDED_
`define AHBLENGTH4WRITEFOLLOWEDBYREADTEST_INCLUDED_

class AhbLength4WriteFollowedByReadTest extends AhbBaseTest;
  `uvm_component_utils(AhbLength4WriteFollowedByReadTest)

  AhbVirtualLength4WriteFollowedByReadSequence ahbVirtualLength4WriteFollowedByReadSequence;

  extern function new(string name = "AhbLength4WriteFollowedByReadTest", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : AhbLength4WriteFollowedByReadTest

function AhbLength4WriteFollowedByReadTest::new(string name = "AhbLength4WriteFollowedByReadTest",uvm_component parent = null);
  super.new(name, parent);
endfunction : new


task AhbLength4WriteFollowedByReadTest::run_phase(uvm_phase phase);

  foreach(ahbEnvironment.ahbSlaveAgentConfig[i]) begin
    if(!ahbEnvironment.ahbSlaveAgentConfig[i].randomize() with {noOfWaitStates==0;}) begin
      `uvm_fatal(get_type_name(),"Unable to randomise noOfWaitStates")
    end
 end

  ahbVirtualLength4WriteFollowedByReadSequence = AhbVirtualLength4WriteFollowedByReadSequence::type_id::create("ahbVirtualWriteFollowedByReadSequence");
  `uvm_info(get_type_name(),$sformatf("AhbLength4WriteFollowedByReadTest"),UVM_LOW);

  phase.raise_objection(this);
  ahbVirtualLength4WriteFollowedByReadSequence.start(ahbEnvironment.ahbVirtualSequencer);
        #10;
  phase.drop_objection(this);

endtask : run_phase

`endif

