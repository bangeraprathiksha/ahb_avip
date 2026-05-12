`ifndef AHBSLAVEDRIVERBFM_INCLUDED_
`define AHBSLAVEDRIVERBFM_INCLUDED_
 
import AhbGlobalPackage::*;
 
interface AhbSlaveDriverBFM(input  bit   hclk,
                             input  bit   hresetn,
	                     input  logic [2:0] hburst,
			     input  logic hmastlock,
                             input  logic [ADDR_WIDTH-1:0] haddr,                             
                             input  logic [HPROT_WIDTH-1:0] hprot,
                             input  logic [2:0] hsize,
                             input  logic hnonsec,
                             input  logic hexcl,
                             input  logic [HMASTER_WIDTH-1:0] hmaster,
                             input  logic [1:0] htrans, 
   			     input  logic [DATA_WIDTH-1:0] hwdata,
                             input  logic [(DATA_WIDTH/8)-1:0]hwstrb,
                             input  logic hwrite,                             
                             output logic [DATA_WIDTH-1:0] hrdata,
			     output bit hreadyout,
			     output logic hresp,
                             output logic hexokay,
                             input  logic hready,                                                           
                             input  logic hselx
                            );
 
  import AhbSlavePackage::*;
 
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  int slave_id;
  reg[7:0]normalReg[longint];

  string name = "AHB_SLAVE_DRIVER_BFM";
 
  AhbSlaveDriverProxy ahbSlaveDriverProxy ;
  
  initial begin
    `uvm_info(name,$sformatf(name),UVM_LOW);
  end
  
  clocking SlaveDriverCb @(posedge hclk);
    default input #1step output #1step;
    input  haddr,hburst,hmastlock,hprot,hsize,hnonsec,hexcl,hmaster,htrans,hwrite,hwdata,hwstrb,hselx;
    input hready;
    output hreadyout,hrdata;
  endclocking 

  task waitForResetn();
    @(negedge hresetn);
    `uvm_info(name,$sformatf("SYSTEM RESET DETECTED"),UVM_LOW)  
    hreadyout =1;
    @(posedge hresetn);
    @(SlaveDriverCb);
    `uvm_info(name,$sformatf("SYSTEM RESET DEACTIVATED"),UVM_LOW)
  endtask: waitForResetn

  task slaveDriveToBFM(inout ahbTransferCharStruct dataPacket, input ahbTransferConfigStruct configPacket);
    forever begin  
      slaveDriveSingleTransfer(dataPacket,configPacket);
    end  
  endtask: slaveDriveToBFM

  task slaveDriveSingleTransfer(inout ahbTransferCharStruct dataPacket,input ahbTransferConfigStruct configPacket);
    bit[31:0]temp;
    logic pipWrite;
    bit[31:0]addressTemp;
    bit[1:0] htransTemp;
    bit[1:0] readhtransTemp;
    bit [31:0]readAddress;
    bit[31:0]dataTemp;
    int num_bytes;  

 
    do begin 
      @(SlaveDriverCb);
    end while((SlaveDriverCb.hselx==0 || $isunknown(SlaveDriverCb.hselx)) || (SlaveDriverCb.hready==0 || $isunknown(SlaveDriverCb.hready))); 

    if(SlaveDriverCb.hwrite==1&&!configPacket.needWaitStates )begin
      addressTemp               <=  SlaveDriverCb.haddr;
      htransTemp                <=  SlaveDriverCb.htrans;
      pipWrite                  <=  SlaveDriverCb.hwrite;
    end
    else if(SlaveDriverCb.hwrite==1&&configPacket.needWaitStates&&(configPacket.noOfWaitStates>0)) begin 
        addressTemp             =   SlaveDriverCb.haddr;
        htransTemp              =   SlaveDriverCb.htrans;
        pipWrite                =   SlaveDriverCb.hwrite;
    end 
    else if(SlaveDriverCb.hwrite==1&&configPacket.needWaitStates&&(configPacket.noOfWaitStates==0)) begin
        addressTemp             <=  SlaveDriverCb.haddr;
        htransTemp              <=  SlaveDriverCb.htrans;
        pipWrite                <=  SlaveDriverCb.hwrite;
    end 
    if(SlaveDriverCb.hwrite ==0)begin
         pipWrite               <=  0;
         readAddress            =   SlaveDriverCb.haddr;
         readhtransTemp         =   SlaveDriverCb.htrans;
    end
 
    if(configPacket.needWaitStates) begin
        SlaveDriverCb.hreadyout <=  0;
        repeat(configPacket.noOfWaitStates)@(SlaveDriverCb);
        SlaveDriverCb.hreadyout <=  1;
    end
    SlaveDriverCb.hreadyout     <=  1;
    dataTemp                    =   SlaveDriverCb.hwdata;
    dataPacket.haddr            <=  haddr;
    dataPacket.htrans           <=  ahbTransferEnum'(htrans);
    dataPacket.hsize            <=  ahbHsizeEnum'(hsize); 
    dataPacket.hburst           <=  ahbBurstEnum'(hburst);
    dataPacket.hwrite           <=  ahbOperationEnum'(hwrite);  
    dataPacket.hmastlock        <=  hmastlock; 
    dataPacket.hselx            <=  hselx;   
      
    if (pipWrite && htransTemp != 2'b00) begin
      num_bytes = 1 << hsize;
      for (int i = 0; i < 4; i++) begin
        if(SlaveDriverCb.hwstrb[i] == 1)begin
          normalReg[addressTemp++] = dataTemp[(8*i) +: 8];
        end
      end
    end
    if (SlaveDriverCb.hwrite == 0) begin
      temp = '0;  
      for (int i = 0; i < 4; i++) begin
        temp[(8*i) +: 8] = normalReg[readAddress + i];
      end
      SlaveDriverCb.hrdata <= temp;
    end
  
  endtask: slaveDriveSingleTransfer 

endinterface
`endif
