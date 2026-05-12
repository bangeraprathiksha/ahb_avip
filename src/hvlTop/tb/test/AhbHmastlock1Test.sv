`ifndef AHBHMASTKOCK1TEST_INCLUDED_
`define AHBHMASTLOCK1TEST_INCLUDED_

class AhbHmastlock1Test extends AhbBaseTest;
  `uvm_component_utils(AhbHmastlock1Test)

  AhbVirtualHmastlock1Sequence ahbVirtualHmastlock1Sequence;

  extern function new(string name = "AhbHmastlock1Test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : AhbHmastlock1Test

function AhbHmastlock1Test::new(string name = "AhbHmastlock1Test",uvm_component parent = null);
  super.new(name, parent);
endfunction : new


task AhbHmastlock1Test::run_phase(uvm_phase phase);

  foreach(ahbEnvironment.ahbSlaveAgentConfig[i]) begin
    if(!ahbEnvironment.ahbSlaveAgentConfig[i].randomize() with {noOfWaitStates==0;}) begin
      `uvm_fatal(get_type_name(),"Unable to randomise noOfWaitStates")
    end
  end

  ahbVirtualHmastlock1Sequence = AhbVirtualHmastlock1Sequence::type_id::create("ahbVirtualHmastlock1Sequence");
  `uvm_info(get_type_name(),$sformatf("AhbHmastlock1Test"),UVM_LOW);

  phase.raise_objection(this);
  ahbVirtualHmastlock1Sequence.start(ahbEnvironment.ahbVirtualSequencer);
        #10;
  phase.drop_objection(this);

endtask : run_phase

`endif

