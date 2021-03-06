module pipe_arch (clk);

input clk;

reg [15:0] im [0:65535];          //------ instruction memory

//65535

reg [15:0] rf [0:7];             //--------register file

reg [15:0] dm [0:20];            //--------data memory

//---------initializing memory and register file--------//

initial 

begin

pipe_arch.rf[0]=16'd0;
pipe_arch.rf[1]=16'd9;
pipe_arch.rf[2]=16'd2;
pipe_arch.rf[3]=16'd3;
pipe_arch.rf[4]=16'd4;
pipe_arch.rf[5]=16'd5;
pipe_arch.rf[6]=16'd6;
pipe_arch.rf[7]=16'd0;
 
pipe_arch.im[0]=16'b1000100000000111;         //---------add instruction
pipe_arch.im[1]=16'b0000010001010000;         //-------- addi instruction
pipe_arch.im[2]=16'b0000000101000000;         //---------branch instuction, branches to 2 + 3 =5
pipe_arch.im[7]=16'b0000110001010000;         //---------add instruction
//pipe_arch.im[4]=16'b0101000001000001;
//pipe_arch.im[2]=16'b1100000000000010;
//pipe_arch.im[3]=16'b0101000001000001;
//pipe_arch.im[0]=16'b0110101011110000;


//pipe_arch.im[0]=16'b0011000101110000;         //---------add instruction
//pipe_arch.im[1]=16'b0001001000001010;         //-------- addi instruction
//pipe_arch.im[2]=16'b1100010100000011;         //---------branch instuction, branches to 2 + 3 =5
//pipe_arch.im[5]=16'b0000000101000000;         //---------add instruction
 
pipe_arch.dm[0]=16'd10;                        //---data memory limited to 20 words for easy compilation
pipe_arch.dm[1]=16'd1;
pipe_arch.dm[2]=16'd2;
pipe_arch.dm[3]=16'd10;
pipe_arch.dm[4]=16'd4;
pipe_arch.dm[5]=16'd5;
pipe_arch.dm[6]=16'd6;
pipe_arch.dm[7]=16'd7;
pipe_arch.dm[8]=16'd8;
pipe_arch.dm[9]=16'd9;
pipe_arch.dm[10]=16'd10;
pipe_arch.dm[11]=16'd11;
pipe_arch.dm[12]=16'd12;
pipe_arch.dm[13]=16'd13;
pipe_arch.dm[14]=16'd14;
pipe_arch.dm[15]=16'd15;
pipe_arch.dm[16]=16'd16;
pipe_arch.dm[17]=16'd17;
pipe_arch.dm[18]=16'd18;
pipe_arch.dm[19]=16'd19;
pipe_arch.dm[20]=16'd20;

end


//-------instruction_fetch stage--------//

reg [15:0] if_inst, if_pc;

reg [15:0] if_id_pc;

reg [5:0] ex_ma_alu_op;

reg [15:0] ma_wb_data_out, ma_wb_pc1;

reg [2:0] id_rg_11_9, id_rg_8_6, id_rg_5_3;

reg [15:0] rg_ex_alu_out;

always @ (posedge clk)

begin

 if_pc=rf[7];                                    //---- reading instruction from pc
 
 if_inst=im[if_pc];                              //-----forwarding instructuon to next stage
 
end

//-------instruction_decode stage------//

reg [2:0] if_id_11_9, if_id_8_6, if_id_5_3;

reg [3:0] if_id_op;

reg [1:0] if_id_fn;

reg [5:0] if_id_alu_op;

reg [15:0] if_id_se_8_0, if_id_se_5_0, if_id_se_8_0a, if_id_pc1, if_id_pc2, if_id_pc3, if_id_pcb, if_id_pcjp, if_id_pcjp2, data1_z, data2_z, outp1_z;

reg ma_wb_rw, tz, if_id_a, if_id_b, if_id_j, if_id_rw, if_id_rw_pc, if_id_c, if_id_d, if_id_e, if_id_f, if_id_dr, if_id_dw, if_id_lm, if_id_g, if_id_h, if_id_pcj, if_id_sm;

reg [15:0] ma_wb_mux1, ma_wb_mux2, ma_wb_data, ma_wb_addr;

reg [2:0] ma_wb_11_9;

reg ma_wb_g, ma_wb_h, ma_wb_pcj, ma_wb_lm;

reg [15:0] ma_wb_se_8_0a, ma_wb_data_out0, ma_wb_data_out1, ma_wb_data_out2, ma_wb_data_out3, ma_wb_data_out4, ma_wb_data_out5, ma_wb_data_out6, ma_wb_data_out7;

reg [2:0] addr=3'b000;

reg [2:0] wb_11_9;

reg [15:0] ma_wb_alu_out, wb_alu_out;

always @ (negedge clk)

begin

if_id_11_9=if_inst[11:9];

if_id_8_6=if_inst[8:6];

if_id_5_3=if_inst[5:3];

if_id_op=if_inst[15:12];

if_id_fn=if_inst[1:0];

if(if_inst[8]==0)

 if_id_se_8_0={1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, if_inst[8:0]};
 
else if(if_inst[8]==1)

 if_id_se_8_0={1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, if_inst[8:0]};
 
if(if_inst[5]==0)

 if_id_se_5_0={1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, if_inst[5:0]};
 
else if(if_inst[5]==1)

 if_id_se_5_0={1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, if_inst[5:0]};
 
if_id_se_8_0a={if_inst[8:0], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};

//---------controller-------//

//------ADD----//

if(if_id_op==4'b0000 && if_id_fn==2'b00)

begin

 if_id_alu_op=6'b000000;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b1;
 if_id_d=1'b1;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;
 
end

//-----ADC------//

if(if_id_op==4'b0000 && if_id_fn==2'b10)

begin

 if_id_alu_op=6'b000010;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b1;
 if_id_d=1'b1;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;

end

//-----ADZ------//

if(if_id_op==4'b0000 && if_id_fn==2'b01)

begin

 if_id_alu_op=6'b000001;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b1;
 if_id_d=1'b1;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;

end

//------ADI-----//

if(if_id_op==4'b0001)

begin

 if_id_alu_op=6'b000000;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b0;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;
  
end

//------NDU-------//

if(if_id_op==4'b0010 && if_id_fn==2'b00)

begin

 if_id_alu_op=6'b001000;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b1;
 if_id_d=1'b1;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;

end

//-----NDC-------//

if(if_id_op==4'b0010 && if_id_fn==2'b10)

begin

 if_id_alu_op=6'b001010;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b1;
 if_id_d=1'b1;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;

end

//----NDZ-------//

if(if_id_op==4'b0010 && if_id_fn==2'b01)

begin

 if_id_alu_op=6'b001001;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b1;
 if_id_d=1'b1;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;

end

//------LHI------//

if(if_id_op==4'b0011)

begin

 if_id_alu_op=6'b111111;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b0;
 if_id_e=1'b0;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b0;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;

end

//--------LW-------//

if(if_id_op==4'b0100)

begin

 if_id_alu_op=6'b100000;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b0;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b1;
 if_id_dw=1'b0;
 if_id_g=1'b1;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;

end

//-------SW--------//

if(if_id_op==4'b0101)

begin

 if_id_alu_op=6'b100000;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b0;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b0;
 if_id_e=1'b1;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b1;
 if_id_g=1'b1;
 if_id_h=1'b1;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;
 
end

//-------BEQ-------//

if(if_id_op==4'b1100)

begin

 if_id_alu_op=6'b110000;
 if_id_a=1'b0;
 if_id_b=1'b1;
 if_id_j=1'b0;
 if_id_rw=1'b0;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b0;
 if_id_e=1'b0;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b0;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b0;
 
end

//-------JAL-------//

if(if_id_op==4'b1000)

begin

 if_id_alu_op=6'bxxxxxx;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b1;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b0;
 if_id_e=1'b0;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b0;
 if_id_pcj=1'b1;
 if_id_lm=1'b0;
 if_id_sm=1'b0;
 
end

//------JLR--------//

if(if_id_op==4'b1001)

begin

 if_id_alu_op=6'bxxxxxx;
 if_id_a=1'b1;
 if_id_b=1'b0;
 if_id_j=1'b1;
 if_id_rw=1'b1;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b0;
 if_id_e=1'b0;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b0;
 if_id_pcj=1'b1;
 if_id_lm=1'b0;
 if_id_sm=1'b0;
 
end

//---------LM---------//

if(if_id_op==4'b0110)

begin

 if_id_alu_op=6'b111000;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b0;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b1;
 if_id_e=1'b0;
 if_id_f=1'b0;
 if_id_dr=1'b1;
 if_id_dw=1'b0;
 if_id_g=1'b0;
 if_id_h=1'b0;
 if_id_pcj=1'b0;
 if_id_lm=1'b1;
 if_id_sm=1'b0;
 
end

//--------SM----------//

if(if_id_op==4'b0111)

begin

 if_id_alu_op=6'bxxxxxx;
 if_id_a=1'b0;
 if_id_b=1'b0;
 if_id_j=1'b0;
 if_id_rw=1'b0;
 if_id_rw_pc=1'b1;
 if_id_c=1'b0;
 if_id_d=1'b1;
 if_id_e=1'b0;
 if_id_f=1'b0;
 if_id_dr=1'b0;
 if_id_dw=1'b1;
 if_id_g=1'b0;
 if_id_h=1'b0;
 if_id_pcj=1'b0;
 if_id_lm=1'b0;
 if_id_sm=1'b1;
 
end
//----------zero_checker---------------//

//data1_z=rf[if_id_11_9];

//data2_z=rf[if_id_8_6];

//outp1_z=data1_z-data2_z;

//if(outp1_z==16'b0)
 
// tz=1'b1;
 
//else 

// tz=1'b0;

//----------program_counter------------//

//if_id_pc=rf[7];
//
//if_id_pc1=if_id_pc+16'b1;
//
//if_id_pcb=if_id_pc+if_id_se_5_0;
//
//if(if_id_a==1)
//
// if_id_pcjp=rf[if_id_11_9];
// 
//else if(if_id_a==0)
//
// if_id_pcjp=if_id_se_8_0;
// 
//if_id_pcjp2=if_id_pc+if_id_pcjp;
//
//if(if_id_b==1 && tz==1)
//
// if_id_pc2=if_id_pcb;
// 
//else 
//
// if_id_pc2=if_id_pc1;
// 
//if(if_id_j==1)
//
// if_id_pc3=if_id_pcjp2;
// 
//else if(if_id_j==0)
//
// if_id_pc3=if_id_pc2;
// 
//if(if_id_rw_pc==1)
//
// rf[7]=if_id_pc3;
 
//-----partial-write back----//
 
if(ma_wb_rw==1 && ma_wb_lm==0)

 rf[ma_wb_11_9]=ma_wb_data;

if(ma_wb_lm==1 && ma_wb_rw==0)

 begin
  
  if(ma_wb_se_8_0a[14]==1)
 
   begin
  
    rf[addr]=ma_wb_data_out0;
	 addr=addr+3'b1;
   
   end
	
  else 
  
   addr=addr+3'b1;
	
  if(ma_wb_se_8_0a[13]==1)
 
   begin
  
    rf[addr]=ma_wb_data_out1;
	 addr=addr+3'b1;
   
   end
	
  else 
  
   addr=addr+3'b1;
	
  if(ma_wb_se_8_0a[12]==1)
 
   begin
  
    rf[addr]=ma_wb_data_out2;
	 addr=addr+3'b1;
   
   end
	
  else 
  
   addr=addr+3'b1;
	
  if(ma_wb_se_8_0a[11]==1)
 
   begin
  
    rf[addr]=ma_wb_data_out3;
	 addr=addr+3'b1;
   
   end
	
  else 
  
   addr=addr+3'b1;
	
  if(ma_wb_se_8_0a[10]==1)
 
   begin
  
    rf[addr]=ma_wb_data_out4;
	 addr=addr+3'b1;
   
   end
	
  else 
  
   addr=addr+3'b1;
	
  if(ma_wb_se_8_0a[9]==1)
 
   begin
  
    rf[addr]=ma_wb_data_out5;
	 addr=addr+3'b1;
   
   end
	
  else 
  
   addr=addr+3'b1;
	
  if(ma_wb_se_8_0a[8]==1)
 
   begin
  
    rf[addr]=ma_wb_data_out6;
	 addr=addr+3'b1;
   
   end
	
  else 
  
   addr=addr+3'b1;
	
  if(ma_wb_se_8_0a[7]==1)
 
   begin
  
    rf[addr]=ma_wb_data_out7;
	 addr=addr+3'b1;
   
   end
	
  else 
  
   addr=addr+3'b1;
	
 end
 
end


//----------register_read stage----------//

reg [15:0] id_rg_pc1, id_rg_se_5_0, id_rg_se_8_0a;

reg id_rg_c, id_rg_d, id_rg_rw, id_rg_e, id_rg_f, id_rg_dr, id_rg_dw, id_rg_g, id_rg_h, id_rg_pcj, id_rg_lm;

reg [15:0] id_rg_d1, id_rg_d2;

reg [2:0] id_rg_a1, id_rg_a2;

reg [5:0] id_rg_alu_op;

reg id_rg_sm;

reg [15:0] id_rg_reg0, id_rg_reg1, id_rg_reg2, id_rg_reg3, id_rg_reg4, id_rg_reg5, id_rg_reg6, id_rg_reg7;

reg [2:0] addrs=3'b000;

always @ (posedge clk)

begin

id_rg_sm=if_id_sm;

id_rg_lm=if_id_lm;

id_rg_alu_op=if_id_alu_op;

id_rg_11_9=if_id_11_9;

id_rg_8_6=if_id_8_6;

id_rg_5_3=if_id_5_3;

id_rg_pc1=if_id_pc1;

id_rg_se_5_0=if_id_se_5_0;

id_rg_se_8_0a=if_id_se_8_0a;

id_rg_c=if_id_c;

id_rg_d=if_id_d;

id_rg_rw=if_id_rw;

id_rg_e=if_id_e;

id_rg_f=if_id_f;

id_rg_dr=if_id_dr;

id_rg_dw=if_id_dw;

id_rg_g=if_id_g;

id_rg_h=if_id_h;

id_rg_pcj=if_id_pcj;

id_rg_a1=id_rg_8_6;

if(id_rg_c==1)

 id_rg_a2=id_rg_5_3;
 
else if(id_rg_c==0)

 id_rg_a2=id_rg_11_9;
 
id_rg_d1=rf[id_rg_a1];

id_rg_d2=rf[id_rg_a2];

if(id_rg_sm==1)

 begin
 
  if(id_rg_se_8_0a[14]==1)
  
   begin
	
	 addrs=3'b000;
	 id_rg_reg0=rf[addrs];
	 addrs=addrs+3'b1;
	 
	end
	
  else
  
   addrs=addrs+3'b1;
	
  if(id_rg_se_8_0a[13]==1)
  
   begin
	
	 id_rg_reg1=rf[addrs];
	 addrs=addrs+3'b1;
	 
	end
	
  else
  
   addrs=addrs+3'b1;
	
  if(id_rg_se_8_0a[12]==1)
  
   begin
	
	 id_rg_reg2=rf[addrs];
	 addrs=addrs+3'b1;
	 
	end
	
  else
  
   addrs=addrs+3'b1;
	
  if(id_rg_se_8_0a[11]==1)
  
   begin
	
	 id_rg_reg3=rf[addrs];
	 addrs=addrs+3'b1;
	 
	end
	
  else
  
   addrs=addrs+3'b1;
	
  if(id_rg_se_8_0a[10]==1)
  
   begin
	
	 id_rg_reg4=rf[addrs];
	 addrs=addrs+3'b1;
	 
	end
	
  else
  
   addrs=addrs+3'b1;
	
  if(id_rg_se_8_0a[9]==1)
  
   begin
	
	 id_rg_reg5=rf[addrs];
	 addrs=addrs+3'b1;
	 
	end
	
  else
  
   addrs=addrs+3'b1;
	
  if(id_rg_se_8_0a[8]==1)
  
   begin
	
	 id_rg_reg6=rf[addrs];
	 addrs=addrs+3'b1;
	 
	end
	
  else
  
   addrs=addrs+3'b1;
	
  if(id_rg_se_8_0a[7]==1)
  
   begin
	
	 id_rg_reg7=rf[addrs];
	 addrs=addrs+3'b1;
	 
	end
	
  else
  
   addrs=addrs+3'b1;
	
 end

end

//-----------execution stage----------//

reg [2:0] rg_ex_11_9;

reg [5:0] rg_ex_alu_op;

reg [15:0] rg_ex_d1, rg_ex_d2, rg_ex_pc1, rg_ex_se_5_0, rg_ex_se_8_0a, rg_ex_d22;

reg rg_ex_d, rg_ex_e, rg_ex_f, rg_ex_dr, rg_ex_dw, rg_ex_g, rg_ex_h, rg_ex_pcj, rg_ex_rw, rg_ex_lm;

reg c, z=1'b0;

reg rg_ex_sm;

reg [15:0] rg_ex_reg0, rg_ex_reg1, rg_ex_reg2, rg_ex_reg3, rg_ex_reg4, rg_ex_reg5, rg_ex_reg6, rg_ex_reg7;

reg [2:0] ex_ma_11_9;

reg [15:0] ex_ma_alu_out, ex_ma_pc1, ex_ma_d22, ex_ma_d2, ex_ma_se_8_0a;

//reg [15:0] ma_wb_se_8_0a1;

reg [15:0] ex_ma_data_out0, ex_ma_data_out1, ex_ma_data_out2, ex_ma_data_out3, ex_ma_data_out4, ex_ma_data_out5, ex_ma_data_out6, ex_ma_data_out7;

reg ex_ma_e, ex_ma_f, ex_ma_dr, ex_ma_dw, ex_ma_g, ex_ma_h, ex_ma_rw, ex_ma_pcj, ex_ma_lm;

reg [15:0] temp_alu0, temp_alu1, temp_alu2, temp_alu3, temp_alu4, temp_alu5, temp_alu6, temp_alu7;

always @ (negedge clk)

begin

rg_ex_reg0=id_rg_reg0;

rg_ex_reg1=id_rg_reg1;

rg_ex_reg2=id_rg_reg2;

rg_ex_reg3=id_rg_reg3;

rg_ex_reg4=id_rg_reg4;

rg_ex_reg5=id_rg_reg5;

rg_ex_reg6=id_rg_reg6;

rg_ex_reg7=id_rg_reg7;

rg_ex_sm=id_rg_sm;

rg_ex_lm=id_rg_lm;

rg_ex_alu_op=id_rg_alu_op;

rg_ex_11_9=id_rg_11_9;

rg_ex_d2=id_rg_d2;

rg_ex_pc1=id_rg_pc1;

rg_ex_se_5_0=id_rg_se_5_0;

rg_ex_se_8_0a=id_rg_se_8_0a;

rg_ex_d=id_rg_d;

rg_ex_e=id_rg_e;

rg_ex_f=id_rg_f;

rg_ex_dr=id_rg_dr;

rg_ex_dw=id_rg_dw;

rg_ex_g=id_rg_g;

rg_ex_h=id_rg_h;

rg_ex_rw=id_rg_rw;

rg_ex_pcj=id_rg_pcj;

if(ex_ma_11_9==id_rg_a1 && ex_ma_alu_op==6'b100000)

 rg_ex_d1=ma_wb_data_out;
 
else if(ex_ma_11_9==id_rg_a1 && (ex_ma_alu_op==6'b000000 || ex_ma_alu_op==6'b000001 || ex_ma_alu_op==6'b000010 || ex_ma_alu_op==6'b001000 || ex_ma_alu_op==6'b001010 || ex_ma_alu_op==6'b001001)) // do for add and r type instruction'
 
 rg_ex_d1=rg_ex_alu_out;
 
else if(ex_ma_11_9==id_rg_a1 && ex_ma_alu_op==6'b111111)

 rg_ex_d1=ex_ma_se_8_0a;
 
else if(ex_ma_lm==1 && ex_ma_se_8_0a[14]==1 && id_rg_a1==3'b000)

 rg_ex_d1=ex_ma_data_out0;
 
else if(ex_ma_lm==1 && ex_ma_se_8_0a[13]==1 && id_rg_a1==3'b001)

 rg_ex_d1=ex_ma_data_out1;
 
else if(ex_ma_lm==1 && ex_ma_se_8_0a[12]==1 && id_rg_a1==3'b010)

 rg_ex_d1=ex_ma_data_out2;

else if(ex_ma_lm==1 && ex_ma_se_8_0a[11]==1 && id_rg_a1==3'b011)

 rg_ex_d1=ex_ma_data_out3;

else if(ex_ma_lm==1 && ex_ma_se_8_0a[10]==1 && id_rg_a1==3'b100)

 rg_ex_d1=ex_ma_data_out4;

else if(ex_ma_lm==1 && ex_ma_se_8_0a[9]==1 && id_rg_a1==3'b101)

 rg_ex_d1=ex_ma_data_out5;

else if(ex_ma_lm==1 && ex_ma_se_8_0a[8]==1 && id_rg_a1==3'b110)

 rg_ex_d1=ex_ma_data_out6;

else if(ex_ma_lm==1 && ex_ma_se_8_0a[13]==1 && id_rg_a1==3'b111)

 rg_ex_d1=ex_ma_data_out7; 
 
else if(wb_11_9==id_rg_8_6)

 rg_ex_d1=wb_alu_out;
 
else 

 rg_ex_d1=id_rg_d1;

if(rg_ex_d==1)

 begin
 
 if(ex_ma_11_9==id_rg_a2 && ex_ma_alu_op==6'b100000)
 
  rg_ex_d22=ma_wb_data_out;
  
 else if(ex_ma_11_9==id_rg_a2 && (ex_ma_alu_op==6'b000000 || ex_ma_alu_op==6'b000001 || ex_ma_alu_op==6'b000010 || ex_ma_alu_op==6'b001000 || ex_ma_alu_op==6'b001010 || ex_ma_alu_op==6'b001001))
  
  rg_ex_d22=rg_ex_alu_out;
  
 else if(ex_ma_11_9==id_rg_a2 && ex_ma_alu_op==6'b111111)
 
  rg_ex_d22=ex_ma_se_8_0a;
  
 else if(ex_ma_lm==1 && ex_ma_se_8_0a[14]==1 && id_rg_a2==3'b000)
 
  rg_ex_d22=ex_ma_data_out0;
  
 else if(ex_ma_lm==1 && ex_ma_se_8_0a[13]==1 && id_rg_a2==3'b001)
 
  rg_ex_d22=ex_ma_data_out1;
  
 else if(ex_ma_lm==1 && ex_ma_se_8_0a[12]==1 && id_rg_a2==3'b010)
 
  rg_ex_d22=ex_ma_data_out2;
  
 else if(ex_ma_lm==1 && ex_ma_se_8_0a[11]==1 && id_rg_a2==3'b011)
 
  rg_ex_d22=ex_ma_data_out3;
  
 else if(ex_ma_lm==1 && ex_ma_se_8_0a[10]==1 && id_rg_a2==3'b100)
 
  rg_ex_d22=ex_ma_data_out4;
  
 else if(ex_ma_lm==1 && ex_ma_se_8_0a[9]==1 && id_rg_a2==3'b101)
 
  rg_ex_d22=ex_ma_data_out5;
  
 else if(ex_ma_lm==1 && ex_ma_se_8_0a[8]==1 && id_rg_a2==3'b110)
 
  rg_ex_d22=ex_ma_data_out6;
  
 else if(ex_ma_lm==1 && ex_ma_se_8_0a[7]==1 && id_rg_a2==3'b111)
 
  rg_ex_d22=ex_ma_data_out7;
  
 else if(wb_11_9==id_rg_5_3)
 
  rg_ex_d22=wb_alu_out;
   
 else

  rg_ex_d22=rg_ex_d2;
  
 end
 
else if(rg_ex_d==0)

 rg_ex_d22=rg_ex_se_5_0;
 
case (rg_ex_alu_op)

 6'b000000 : begin
 
             
             {c, rg_ex_alu_out}={1'b0, rg_ex_d1} + {1'b0, rg_ex_d22};
 
             if({c, rg_ex_alu_out}==17'b0)
				 
				  z=1'b1;
				  
				 else 
				 
				  z=1'b0;
				  
				 end
				  

 6'b000010 : begin
 
              if(c==1)
				  
				   begin
					
                {c, rg_ex_alu_out}={1'b0, rg_ex_d1} + {1'b0, rg_ex_d22};
 
                 if({c, rg_ex_alu_out}==17'b0)
				 
				      z=1'b1;
				  
				     else 
				 
				     z=1'b0;
				  
				   end
					 
             end
				 
 6'b000001 : begin
 
              if(z==1)
				  
				   begin
					
                {c, rg_ex_alu_out}={1'b0, rg_ex_d1} + {1'b0, rg_ex_d22};
 
                 if({c, rg_ex_alu_out}==17'b0)
				 
				      z=1'b1;
				  
				     else 
				 
				     z=1'b0;
				  
				   end
					 
             end 
				 
 6'b001000 : begin
             
              rg_ex_alu_out=rg_ex_d1 & rg_ex_d22;
 
               if(rg_ex_alu_out==16'b0)
				 
				    z=1'b1;
				  
				   else 
				 
				    z=1'b0;
				  
				 end
				 
 6'b001010 : begin
 
              if(c==1)
				  
				   begin
					
                 rg_ex_alu_out=rg_ex_d1 & rg_ex_d22;
 
                 if(rg_ex_alu_out==16'b0)
				 
				      z=1'b1;
				  
				     else 
				 
				     z=1'b0;
				  
				   end
					 
             end
				 
 6'b001001 : begin
 
              if(z==1)
				  
				   begin
					
                rg_ex_alu_out=rg_ex_d1 + rg_ex_d22;
 
                 if(rg_ex_alu_out==17'b0)
				 
				      z=1'b1;
				  
				     else 
				 
				      z=1'b0;
				  
				   end
					 
             end 

 6'b100000 : begin
  
             rg_ex_alu_out=rg_ex_d1 + rg_ex_d22;
				 
            end
				
 default : rg_ex_alu_out=16'bx;
 
endcase

temp_alu0=dm[id_rg_11_9];

temp_alu1=dm[id_rg_11_9+4'd1];

temp_alu2=dm[id_rg_11_9+4'd2];

temp_alu3=dm[id_rg_11_9+4'd3];

temp_alu4=dm[id_rg_11_9+4'd4];

temp_alu5=dm[id_rg_11_9+4'd5];

temp_alu6=dm[id_rg_11_9+4'd6];

temp_alu7=dm[id_rg_11_9+4'd7];
 
if(if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b100000)

 data1_z=dm[rg_ex_alu_out];
 
else if(if_id_11_9==id_rg_11_9 && (id_rg_alu_op==6'b000000 || id_rg_alu_op==6'b000001 || id_rg_alu_op==6'b000010 || id_rg_alu_op==6'b001000 || id_rg_alu_op==6'b001010 || id_rg_alu_op==6'b001001))

 data1_z=rg_ex_alu_out;
 
else if(if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111111)

 data1_z=rg_ex_se_8_0a;
 
else if(id_rg_se_8_0a[14]==1 && if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data1_z=temp_alu0;
 
else if(id_rg_se_8_0a[13]==1 && if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data1_z=temp_alu1;
 
else if(id_rg_se_8_0a[12]==1 && if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data1_z=temp_alu2;

else if(id_rg_se_8_0a[11]==1 && if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data1_z=temp_alu3;

else if(id_rg_se_8_0a[10]==1 && if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data1_z=temp_alu4;

else if(id_rg_se_8_0a[9]==1 && if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data1_z=temp_alu5;

else if(id_rg_se_8_0a[8]==1 && if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data1_z=temp_alu6; 
 
else if(id_rg_se_8_0a[7]==1 && if_id_11_9==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data1_z=temp_alu7;
 
else

 data1_z=rf[if_id_11_9];
 
if(if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b100000)

 data2_z=dm[rg_ex_alu_out];
 
else if(if_id_8_6==id_rg_11_9 && (id_rg_alu_op==6'b000000 || id_rg_alu_op==6'b000001 || id_rg_alu_op==6'b000010 || id_rg_alu_op==6'b001000 || id_rg_alu_op==6'b001010 || id_rg_alu_op==6'b001001))

 data2_z=rg_ex_alu_out;
 
else if(if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111111)

 data2_z=rg_ex_se_8_0a;
 
else if(id_rg_se_8_0a[14]==1 && if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data2_z=temp_alu0;
 
else if(id_rg_se_8_0a[13]==1 && if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data2_z=temp_alu1;
 
else if(id_rg_se_8_0a[12]==1 && if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data2_z=temp_alu2;
 
else if(id_rg_se_8_0a[11]==1 && if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data2_z=temp_alu3;
 
else if(id_rg_se_8_0a[10]==1 && if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data2_z=temp_alu4;
 
else if(id_rg_se_8_0a[9]==1 && if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data2_z=temp_alu5;
 
else if(id_rg_se_8_0a[8]==1 && if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data2_z=temp_alu6;
 
else if(id_rg_se_8_0a[7]==1 && if_id_8_6==id_rg_11_9 && id_rg_alu_op==6'b111000)

 data2_z=temp_alu7;
 
else 

 data2_z=rf[if_id_8_6];

outp1_z=data1_z-data2_z;

if(outp1_z==16'b0)
 
 tz=1'b1;
 
else 

 tz=1'b0;
 
if_id_pc=rf[7];

if_id_pc1=if_id_pc+16'b1;

if_id_pcb=if_id_pc+if_id_se_5_0;

if(if_id_a==1)

 if_id_pcjp=rf[if_id_11_9];
 
else if(if_id_a==0)

 if_id_pcjp=if_id_se_8_0;
 
if_id_pcjp2=if_id_pc+if_id_pcjp;

if(if_id_b==1 && tz==1)

 if_id_pc2=if_id_pcb;
 
else 

 if_id_pc2=if_id_pc1;
 
if(if_id_j==1)

 if_id_pc3=if_id_pcjp2;
 
else if(if_id_j==0)

 if_id_pc3=if_id_pc2;
 
if(if_id_rw_pc==1)

 rf[7]=if_id_pc3;
 
end

//--------------memory_access stage-------------//

//reg [15:0] ex_ma_alu_out, ex_ma_pc1, ex_ma_d22, ex_ma_d2, ex_ma_se_8_0a;

//reg ex_ma_e, ex_ma_f, ex_ma_dr, ex_ma_dw, ex_ma_g, ex_ma_h, ex_ma_rw, ex_ma_pcj, ex_ma_lm;

reg [15:0] ex_ma_addr, ex_ma_data_in, ex_ma_data_out;

//reg [15:0] ex_ma_data_out0, ex_ma_data_out1, ex_ma_data_out2, ex_ma_data_out3, ex_ma_data_out4, ex_ma_data_out5, ex_ma_data_out6, ex_ma_data_out7;

reg ex_ma_sm;

reg [15:0] ex_ma_reg0, ex_ma_reg1, ex_ma_reg2, ex_ma_reg3, ex_ma_reg4, ex_ma_reg5, ex_ma_reg6, ex_ma_reg7;

always @ (posedge clk)

begin

ex_ma_alu_op=rg_ex_alu_op;

ex_ma_sm=rg_ex_sm;

ex_ma_reg0=rg_ex_reg0;

ex_ma_reg1=rg_ex_reg1;

ex_ma_reg2=rg_ex_reg2;

ex_ma_reg3=rg_ex_reg3;

ex_ma_reg4=rg_ex_reg4;

ex_ma_reg5=rg_ex_reg5;

ex_ma_reg6=rg_ex_reg6;

ex_ma_reg7=rg_ex_reg7;

ex_ma_lm=rg_ex_lm;

ex_ma_11_9=rg_ex_11_9;

ex_ma_alu_out=rg_ex_alu_out;

ex_ma_pc1=rg_ex_pc1;

ex_ma_d22=rg_ex_d22;

ex_ma_d2=rg_ex_d2;

ex_ma_se_8_0a=rg_ex_se_8_0a;

ex_ma_e=rg_ex_e;

ex_ma_f=rg_ex_f;

ex_ma_dr=rg_ex_dr;

ex_ma_dw=rg_ex_dw;

ex_ma_g=rg_ex_g;

ex_ma_h=rg_ex_h;

ex_ma_rw=rg_ex_rw;

ex_ma_pcj=rg_ex_pcj;

if(ex_ma_e==1)

 ex_ma_addr=ex_ma_alu_out;
 
else if(ex_ma_e==0)

 ex_ma_addr=ex_ma_d22;
 
if(ex_ma_f==1)

 ex_ma_data_in=ex_ma_d22;
 
else if(ex_ma_f==0)

 ex_ma_data_in=ex_ma_d2;
 
if(ex_ma_dw==1 && ex_ma_sm==0)

 dm[ex_ma_addr]=ex_ma_data_in;
 
if(ex_ma_dr==1 && ex_ma_lm==0)

 ex_ma_data_out=dm[ex_ma_addr];

if(ex_ma_dr==1 && ex_ma_lm==1)

 begin
 
  if(ex_ma_se_8_0a[14]==1)

   begin
	
	 ex_ma_data_out0=dm[ex_ma_addr];
	 ex_ma_addr=ex_ma_addr+16'b1;
	 
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[13]==1)

   begin
	
	 ex_ma_data_out1=dm[ex_ma_addr];
	 ex_ma_addr=ex_ma_addr+16'b1;
	 
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[12]==1)

   begin
	
	 ex_ma_data_out2=dm[ex_ma_addr];
	 ex_ma_addr=ex_ma_addr+16'b1;
	 
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[11]==1)

   begin
	
	 ex_ma_data_out3=dm[ex_ma_addr];
	 ex_ma_addr=ex_ma_addr+16'b1;
	 
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[10]==1)

   begin
	
	 ex_ma_data_out4=dm[ex_ma_addr];
	 ex_ma_addr=ex_ma_addr+16'b1;
	 
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[9]==1)

   begin
	
	 ex_ma_data_out5=dm[ex_ma_addr];
	 ex_ma_addr=ex_ma_addr+16'b1;
	 
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[8]==1)

   begin
	
	 ex_ma_data_out6=dm[ex_ma_addr];
	 ex_ma_addr=ex_ma_addr+16'b1;
	 
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[7]==1)

   begin
	
	 ex_ma_data_out7=dm[ex_ma_addr];
	 ex_ma_addr=ex_ma_addr+16'b1;
	 
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;

 end
 
if(ex_ma_dw==1 && ex_ma_sm==1)

 begin
 
  if(ex_ma_se_8_0a[14]==1)
  
   begin
	
	 dm[ex_ma_addr]=ex_ma_reg0;
	 ex_ma_addr=ex_ma_addr+16'b1;
	
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[13]==1)
  
   begin
	
	 dm[ex_ma_addr]=ex_ma_reg1;
	 ex_ma_addr=ex_ma_addr+16'b1;
	
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[12]==1)
  
   begin
	
	 dm[ex_ma_addr]=ex_ma_reg2;
	 ex_ma_addr=ex_ma_addr+16'b1;
	
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[11]==1)
  
   begin
	
	 dm[ex_ma_addr]=ex_ma_reg3;
	 ex_ma_addr=ex_ma_addr+16'b1;
	
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[10]==1)
  
   begin
	
	 dm[ex_ma_addr]=ex_ma_reg4;
	 ex_ma_addr=ex_ma_addr+16'b1;
	
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[9]==1)
  
   begin
	
	 dm[ex_ma_addr]=ex_ma_reg5;
	 ex_ma_addr=ex_ma_addr+16'b1;
	
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[8]==1)
  
   begin
	
	 dm[ex_ma_addr]=ex_ma_reg6;
	 ex_ma_addr=ex_ma_addr+16'b1;
	
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
  if(ex_ma_se_8_0a[7]==1)
  
   begin
	
	 dm[ex_ma_addr]=ex_ma_reg7;
	 ex_ma_addr=ex_ma_addr+16'b1;
	
	end
	
  else 
  
    ex_ma_addr=ex_ma_addr+16'b1;
	
 end
 
end

//-----------write-back stage-----------//

//reg [15:0] ma_wb_data_out, ma_wb_pc1;

//reg [2:0] ma_wb_11_9;

//reg ma_wb_g, ma_wb_h, ma_wb_pcj, ma_wb_lm;

//reg [15:0] ma_wb_se_8_0a, ma_wb_data_out0, ma_wb_data_out1, ma_wb_data_out2, ma_wb_data_out3, ma_wb_data_out4, ma_wb_data_out5, ma_wb_data_out6, ma_wb_data_out7;

//reg [15:0] ma_wb_mux1, ma_wb_mux2, ma_wb_data, ma_wb_addr;

//reg [15:0] ma_wb_se_8_0a1;

//always @ (negedge clk)
//
//begin
//
//ma_wb_se_8_0a1=ex_ma_se_8_0a;
//
//end

always @ (clk)

begin

ma_wb_data_out0=ex_ma_data_out0;

ma_wb_data_out1=ex_ma_data_out1;

ma_wb_data_out2=ex_ma_data_out2;

ma_wb_data_out3=ex_ma_data_out3;

ma_wb_data_out4=ex_ma_data_out4;

ma_wb_data_out5=ex_ma_data_out5;

ma_wb_data_out6=ex_ma_data_out6;

ma_wb_data_out7=ex_ma_data_out7;

ma_wb_data_out=ex_ma_data_out;

ma_wb_lm=ex_ma_lm;

ma_wb_addr=ex_ma_addr;

ma_wb_pc1=ex_ma_pc1;

ma_wb_se_8_0a=ex_ma_se_8_0a;

ma_wb_11_9=ex_ma_11_9;

ma_wb_g=ex_ma_g;

ma_wb_h=ex_ma_h;

ma_wb_rw=ex_ma_rw;

ma_wb_pcj=ex_ma_pcj;

if(ma_wb_g==1)

 ma_wb_mux1=ma_wb_data_out;
 
else if (ma_wb_g==0)

 ma_wb_mux1=ma_wb_addr; 
 
if(ma_wb_h==1)

 ma_wb_mux2=ma_wb_mux1;
 
else if(ma_wb_h==0)

 ma_wb_mux2=ma_wb_se_8_0a;
 
if(ma_wb_pcj==1)

 ma_wb_data=ma_wb_pc1;
 
else if (ma_wb_pcj==0)

 ma_wb_data=ma_wb_mux2;

end

always @ (posedge clk)

begin

 wb_alu_out=ma_wb_data;
 
 wb_11_9 = ma_wb_11_9;

end

endmodule
