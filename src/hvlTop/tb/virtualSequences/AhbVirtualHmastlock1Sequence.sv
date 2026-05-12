`ifndef AHBVIRTUALHMASTLOCK1SEQUENCE_INCLUDED_
`define AHBVIRTUALHMASTLOCK1SEQUENCE_INCLUDED_

class AhbVirtualHmastlock1Sequence extends AhbVirtualBaseSequence;
  `uvm_object_utils(AhbVirtualHmastlock1Sequence)

  AhbMasterSequence ahbMasterWriteSequence[NO_OF_MASTERS];
  AhbMasterSequence ahbMasterReadSequence[NO_OF_MASTERS];

  AhbSlaveSequence ahbSlaveWriteSequence[NO_OF_SLAVES];
  AhbSlaveSequence ahbSlaveReadSequence[NO_OF_SLAVES];


  AhbVirtualSingleWriteSequence ahbVirtualSingleWriteSequence;
  AhbVirtualSingleReadSequence ahbVirtualSingleReadSequence;
  AhbVirtualIdleSequence ahbVirtualIdleSequence;

  extern function new(string name ="AhbVirtualHmastlock1Sequence");
  extern task body();

endclass : AhbVirtualHmastlock1Sequence

function AhbVirtualHmastlock1Sequence::new(string name ="AhbVirtualHmastlock1Sequence");
  super.new(name);
endfunction : new

task AhbVirtualHmastlock1Sequence::body();
  super.body();


  foreach(ahbMasterWriteSequence[i]) begin
    ahbMasterWriteSequence[i] = AhbMasterSequence::type_id::create($sformatf("ahbMasterWriteSequence[%0d]", i));
    ahbMasterReadSequence[i]  = AhbMasterSequence::type_id::create($sformatf("ahbMasterReadSequence[%0d]", i));
  end

  foreach(ahbSlaveWriteSequence[i]) begin
    ahbSlaveWriteSequence[i] = AhbSlaveSequence::type_id::create($sformatf("ahbSlaveWriteSequence[%0d]", i));
    ahbSlaveReadSequence[i]  = AhbSlaveSequence::type_id::create($sformatf("ahbSlaveReadSequence[%0d]", i));
  end

  if(!ahbMasterWriteSequence[1].randomize() with {
         hsizeSeq == WORD;
         hwriteSeq == 1; // WRITE
         hmastlockSeq == 1;
         htransSeq == SEQ;
         hburstSeq == INCR4;
         foreach(busyControlSeq[k]) busyControlSeq[k] dist {0:=100, 1:=0};
    }) begin
       `uvm_error(get_type_name(), "Randomization failed : Inside Write Sequence")
  end

  if(!ahbMasterWriteSequence[0].randomize() with {
         hsizeSeq == WORD;
         hwriteSeq == 0; // WRITE
         hmastlockSeq == 0;
         htransSeq == SEQ;
         hburstSeq == INCR4;
         foreach(busyControlSeq[k]) busyControlSeq[k] dist {0:=100, 1:=0};
    }) begin
       `uvm_error(get_type_name(), "Randomization failed : Inside Write Sequence")
  end

  fork
    // Start Slave Sequences (Reactive)
    begin
       foreach(ahbSlaveWriteSequence[i]) begin
         fork
           automatic int k = i;
           ahbSlaveWriteSequence[k].start(p_sequencer.ahbSlaveSequencer[k]);
         join_none
       end
    end

    // Start Master Write Sequences
    begin
       foreach(ahbMasterWriteSequence[i]) begin
         fork
            automatic int k = i;
            ahbMasterWriteSequence[k].start(p_sequencer.ahbMasterSequencer[k]);
         join_none
       end
       wait fork; // Wait for ALL writes to finish
    end
  join



  if(!ahbMasterReadSequence[1].randomize() with {
         hsizeSeq == WORD;
         hwriteSeq == 0; // READ
         hmastlockSeq == 1;
         htransSeq == SEQ;
         hburstSeq == INCR4;
         foreach(busyControlSeq[k]) busyControlSeq[k] dist {0:=100, 1:=0};
    }) begin
      `uvm_error(get_type_name(), "Randomization failed : Inside Read Sequence")
  end

  if(!ahbMasterReadSequence[0].randomize() with {
         hsizeSeq == WORD;
         hwriteSeq == 0; // READ
         hmastlockSeq == 0;
         htransSeq == SEQ;
         hburstSeq == INCR4;
         foreach(busyControlSeq[k]) busyControlSeq[k] dist {0:=100, 1:=0};
    }) begin
      `uvm_error(get_type_name(), "Randomization failed : Inside Read Sequence")
  end

   foreach(ahbMasterReadSequence[i]) begin
      ahbMasterReadSequence[i].haddr_list = ahbMasterWriteSequence[i].haddr_list;
   end

  fork
    // Start Slave Sequences (Reactive)

    // Start Master Read Sequences
    begin

  foreach(ahbMasterReadSequence[i]) begin
         fork
            automatic int k = i;
            ahbMasterReadSequence[k].start(p_sequencer.ahbMasterSequencer[k]);
         join_none
       end
       wait fork; // Wait for ALL reads to finish
    end
  join

endtask : body

`endif

