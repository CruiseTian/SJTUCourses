<center><h1>五段流水线CPU设计</h1>
</center>

<center>
    田亚博<br>
    518030910367
</center>

## 实验目的

+ 理解计算机指令流水线的协调工作原理，初步掌握流水线的设计和实现原理。 
+ 深刻理解流水线寄存器在流水线实现中所起的重要作用。 
+ 理解和掌握流水段的划分、设计原理及其实现方法原理。 
+ 掌握运算器、寄存器堆、存储器、控制器在流水工作方式下，有别于实验一的设 计和实现方法。 
+ 掌握流水方式下，通过 I/O 端口与外部设备进行信息交互的方法。 

## 实验要求

+ 完成五级流水线CPU核心模块的设计。 
+ 完成对五级流水线CPU的仿真，仿真测试程序应该具有与实验一提供的标准测试 程序代码相同的功能。对两种CPU实现核心处理功能的过程和设计处理上的区别 作对比分析。 
+ 完成流水线CPU的IO模块仿真，对两种CPU实现相同IO功能的过程和设计处理上 的区别作对比分析。 

## 说明

+ 本次实验中在跳转指令后面插入 `nop` 指令来实现控制冒险
+ 本次实验 `wpcir` 信号位高电平有效。
+ 本次实验主要原理来自下图

![图1](http://figure.cruisetian.top/img/example.jpg)

## 实验过程

### `pipepc`模块

该模块为获取下一条指令的pc值，在时钟的上升沿时更新pc值，如果`resten`信号为零，则将pc值改为-4，否则判断`wpcir`的值，如果`wpcir`有效，则更新pc为下一条指令的pc，实现代码如下

```verilog
module pipepc( npc,wpcir,clock,resetn,pc );
	input  [31:0] npc;
   input         clock,resetn,wpcir;
   output [31:0] pc;
   reg 	 [31:0] pc;
   always @ (negedge resetn or posedge clock)
      if (resetn == 0)   // 清零
		begin
          pc <= -4;
      end 
		else 
		if (wpcir != 0)  
		begin
          pc <= npc;  // 更新
      end
endmodule
```

### `pipeif`模块

该模块为IF阶段根据pc值从指令寄存器中取出指令，同时根据图1，该模块还将定义一个四选一多选器，用于根据`pcsource`选择下一个pc值，该模块实现代码如下：

```verilog
module pipeif( pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock );
	input  [1:0]  pcsource;
	input			  mem_clock;
	input  [31:0] pc, bpc, jpc, da;
	output [31:0] npc, pc4, ins;
	
	wire	 [31:0] npc, pc4, ins;
	
	mux4x32 npc_mux( pc4, bpc, da, jpc, pcsource, npc ); // 下一个pc值
	
	assign pc4 = pc + 4;
	
	sc_instmem imem ( pc, ins, mem_clock );  //mem_clock是clock的反向
	
endmodule
```

### `pipeir`模块

该模块是连接IF和ID阶段的寄存器，受`wpcir`控制，用来实现数据冒险，实现代码如下：

```verilog
module pipeir( pc4, ins, wpcir, clock, resetn, dpc4, inst );
	input  [31:0]  pc4, ins;
	input          wpcir, clock, resetn;
	output [31:0]  dpc4, inst;
	
	reg    [31:0]  dpc4, inst;
	
	always @(posedge clock or negedge resetn)
	begin
		if (resetn == 0)  //清零 
		begin
			dpc4 <= 0;
			inst <= 0;  //  指令清0实际上是sll $0,$0,0
		end
		else 
		if (wpcir != 0)
		begin
			dpc4 <= pc4;  // 实现数据的传递
			inst <= ins;
		end
	end	
endmodule
```

### `pipeid`模块

该模块功能较为复杂，根据图1，该模块需要生成控制信号，即需要实现`sc_cu`模块，还需要从寄存器堆中取出数据，以及两个四选一多选器和一个二选一多选器，直接上代码比较科学：

**`pipeid.v`**

```verilog
module pipeid(mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
				  wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,      
				  bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,      
				  daluimm,da,db,dimm,dsa,drn,dshift,djal    
				  /*,npc*/,ebubble,dbubble);
	
	input  [4:0]  mrn, ern, wrn;
	input			  mm2reg, em2reg, mwreg, ewreg, wwreg, clock, resetn,ebubble;
	input  [31:0] inst, wdi, ealu, malu, mmo, dpc4;
	output [31:0] bpc, dimm, jpc, da, db,dsa;
	output [1:0]  pcsource;
	output 		  wpcir, dwreg, dm2reg, dwmem, daluimm, dshift, djal,dbubble;
	output [3:0]  daluc;
	output [4:0]  drn;
	
	wire   [31:0] q1, q2, da, db;
	wire	 [1:0]  fwda, fwdb;
	wire 			  rsrtequ = (da == db);
	wire          regrt, sext;
	wire          e = sext & inst[15];
	wire   [31:0] dimm = {{16{e}}, inst[15:0]};
	wire   [31:0] jpc = {dpc4[31:28],inst[25:0],1'b0,1'b0};
	wire   [31:0] offset = {{14{e}},inst[15:0],1'b0,1'b0};
	wire   [31:0] bpc = dpc4 + offset;
	wire 			  dbubble = (pcsource[1:0] != 2'b00);
	wire   [31:0] dsa = { 27'b0, inst[10:6] };
	
	
	regfile rf( inst[25:21], inst[20:16], wdi, wrn, wwreg, clock, resetn, q1, q2 );  //寄存器堆
	mux4x32 da_mux( q1, ealu, malu, mmo, fwda, da ); // 四选一  可能的直通
	mux4x32 db_mux( q2, ealu, malu, mmo, fwdb, db );
	mux2x5  rn_mux( inst[15:11], inst[20:16], regrt, drn );
	sc_cu cu( inst[31:26], inst[5:0], rsrtequ, dwmem, dwreg, regrt, dm2reg, daluc, dshift, daluimm, pcsource, djal, sext, wpcir, inst[25:21], inst[20:16], mrn, mm2reg, mwreg, ern, em2reg, ewreg, fwda, fwdb, ebubble );//控制单元
	
endmodule
```

**`sc_cu.v`**

该模块生成了整个CPU的工作信号，这次的流水线设计还加入了`wpcir`信号，用于解决数据冒险，如果`wpcir`为0 那么插入气泡停顿 将所有的控制信号置0；同时还定义了`fwda`和`fwdb`信号用于数据直通。代码如下：

```verilog
module sc_cu (op, func, rsrtequ, wmem, wreg, regrt, m2reg, aluc, shift,
              aluimm, pcsource, jal, sext, wpcir, rs, rt, mrn, mm2reg, mwreg, ern, em2reg, ewreg, fwda, fwdb, ebubble);
   input  [5:0] op,func;
   input        rsrtequ, mwreg, ewreg, mm2reg, em2reg, ebubble;
	input  [4:0] rs, rt, mrn, ern;
   output       wreg, regrt, jal, m2reg, shift, aluimm, sext, wmem, wpcir;
   output [3:0] aluc;
   output [1:0] pcsource, fwda, fwdb;
	reg [1:0] fwda, fwdb;
   wire r_type = ~|op;  // 是否是R型指令
	
	//该R型指令是否出现 
   wire i_add = r_type & func[5] & ~func[4] & ~func[3] &  ~func[2] & ~func[1] & ~func[0];		//100000	 
   wire i_sub = r_type & func[5] & ~func[4] & ~func[3] &~func[2] &  func[1] & ~func[0];      //100010
   wire i_and = r_type & func[5] & ~func[4] & ~func[3] &func[2] & ~func[1] & ~func[0];       //100100
   wire i_or  = r_type & func[5] & ~func[4] & ~func[3] &func[2] & ~func[1] &  func[0];       //100101
   wire i_xor = r_type & func[5] & ~func[4] & ~func[3] &func[2] &  func[1] & ~func[0];       //100110
   wire i_sll = r_type & ~func[5] & ~func[4] & ~func[3] &~func[2] & ~func[1] & ~func[0];     //000000
   wire i_srl = r_type & ~func[5] & ~func[4] & ~func[3] &~func[2] &  func[1] & ~func[0];     //000010
   wire i_sra = r_type & ~func[5] & ~func[4] & ~func[3] &~func[2] &  func[1] &  func[0];     //000011
   wire i_jr  = r_type & ~func[5] & ~func[4] &  func[3] &~func[2] & ~func[1] & ~func[0];     //001000
	
	
	//该I型指令是否出现
   wire i_addi = ~op[5] & ~op[4] &  op[3] & ~op[2] & ~op[1] & ~op[0]; //001000
   wire i_andi = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] & ~op[0]; //001100
   wire i_ori  = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] &  op[0]; //001101
   wire i_xori = ~op[5] & ~op[4] &  op[3] &  op[2] &  op[1] & ~op[0]; //001110  
   wire i_lw   =  op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] &  op[0]; //100011
   wire i_sw   =  op[5] & ~op[4] &  op[3] & ~op[2] &  op[1] &  op[0]; //101011
   wire i_beq  = ~op[5] & ~op[4] & ~op[3] &  op[2] & ~op[1] & ~op[0]; //000100
   wire i_bne  = ~op[5] & ~op[4] & ~op[3] &  op[2] & ~op[1] &  op[0]; //000101
   wire i_lui  = ~op[5] & ~op[4] &  op[3] &  op[2] &  op[1] &  op[0]; //001111
   wire i_j    = ~op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] & ~op[0]; //000010
   wire i_jal  = ~op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] &  op[0]; //000011
   
  
	assign wpcir = ~(em2reg & ( ern == rs | ern == rt ));  //lw的数据冒险  可能需要停顿 
	
	// 如果wpcir为0 那么插入气泡停顿 将所有的控制信号置0
   assign pcsource[1] = i_jr | i_j | i_jal;
   assign pcsource[0] = ( i_beq & rsrtequ ) | (i_bne & ~rsrtequ) | i_j | i_jal ;
   
   assign wreg = wpcir & (i_add | i_sub | i_and | i_or   | i_xor  |
                 i_sll | i_srl | i_sra | i_addi | i_andi |
                 i_ori | i_xori | i_lw | i_lui  | i_jal);
   
   assign aluc[3] = wpcir & i_sra;
   assign aluc[2] = wpcir & (i_sub | i_or | i_lui | i_srl | i_sra | i_ori);
   assign aluc[1] = wpcir & (i_xor | i_lui | i_sll | i_srl | i_sra | i_xori);
   assign aluc[0] = wpcir & (i_and | i_or | i_sll | i_srl | i_sra | i_andi | i_ori);
   assign shift   = wpcir & (i_sll | i_srl | i_sra);

   assign aluimm  = wpcir & (i_addi | i_andi | i_ori | i_xori | i_lw | i_sw);
   assign sext    = wpcir & (i_addi | i_lw | i_sw | i_beq | i_bne);
   assign wmem    = wpcir & i_sw;
   assign m2reg   = wpcir & i_lw;
   assign regrt   = wpcir & (i_addi | i_andi | i_ori | i_xori | i_lw | i_lui);
   assign jal     = wpcir & i_jal;
	

   	
// fwda和fwda的设置
   always @(*)
   begin
	if(ewreg & ~ em2reg & (ern != 0) & (ern == rs) )  //将上一条指令的alu结果直通 如果上一条指令是lw的话 那么会停顿一个时钟周期 所以误直通了也无所谓
         fwda<=2'b01;
      else 
		if (mwreg & ~ mm2reg & (mrn != 0) & (mrn == rs) ) //将前两条指令的alu结果直通
            fwda<=2'b10;
         else  
            if  (mwreg & mm2reg & (mrn != 0) & (mrn == rs) )  // 将前两条指令的数据RAM的输出直通
               fwda<=2'b11;
            else 
               fwda<=2'b00;  // 无需直通 
   end


   always @(*)
   begin
      if(ewreg & ~ em2reg &(ern != 0) & (ern == rt) ) //将上一条指令的alu结果直通
         fwdb<=2'b01;
      else  
         if (mwreg & ~ mm2reg & (mrn != 0) & (mrn == rt) )  //将前两条指令的alu结果直通
            fwdb<=2'b10;
         else 
            if  (mwreg & mm2reg & (mrn != 0) & (mrn == rt) )   // 将前两条指令的数据RAM的输出直通
               fwdb<=2'b11;
            else 
               fwdb<=2'b00; // 无需直通 

   end
	
	/*

	wire [1:0] fwda, fwdb;
	assign fwda[1] = ~(ewreg & (ern != 0) & (ern == rs) & ~em2reg) & (mwreg & (mrn != 0) & (mrn == rs));
	assign fwda[0] = (ewreg & (ern != 0) & (ern == rs) & ~em2reg) | (mwreg & (mrn != 0) & (mrn == rs) & mm2reg);
	
	assign fwdb[1] = ~(ewreg & (ern != 0) & (ern == rt) & ~em2reg) & (mwreg & (mrn != 0) & (mrn == rt));
	assign fwdb[0] = (ewreg & (ern != 0) & (ern == rt) & ~em2reg) | (mwreg & (mrn != 0) & (mrn == rt) & mm2reg);
*/
	
endmodule
```

**`regfile.v`**

该模块没什么变化

```verilog
module regfile (rna,rnb,d,wn,we,clk,clrn,qa,qb);
   input [4:0] rna,rnb,wn;
   input [31:0] d;
   input we,clk,clrn;
   
   output [31:0] qa,qb;
   
   reg [31:0] register [1:31]; // r1 - r31
   
   assign qa = (rna == 0)? 0 : register[rna]; // read
   assign qb = (rnb == 0)? 0 : register[rnb]; // read
   integer i;
   always @(posedge clk or negedge clrn) begin
      if (clrn == 0) begin // reset
         integer i;
         for (i=1; i<32; i=i+1)
            register[i] <= 0;
      end else begin
         if ((wn != 0) && (we == 1))          // write
            register[wn] <= d;
      end
   end
endmodule
```

### `pipedereg`模块

该模块为ID阶段到EXE阶段的寄存器，由`resetn`控制，实现控制信号传递。代码实现如下：

```verilog
module pipedereg (dbubble, drs, drt, dwreg, dm2reg, dwmem, daluc, daluimm, da, db, dimm,dsa, drn, dshift,
	djal, dpc4, clock, resetn,ebubble, ers, ert, ewreg, em2reg, ewmem, ealuc, ealuimm,
	ea, eb, eimm, esa, ern0, eshift, ejal, epc4); 
	input         dwreg, dm2reg, dwmem, daluimm, dshift, djal, clock, resetn, dbubble;
	input  [3:0]  daluc;
	input  [31:0] dimm, da, db, dpc4,dsa;
	input  [4:0]  drn, drs, drt;
	output 		  ewreg, em2reg, ewmem, ealuimm, eshift, ejal, ebubble; 
	output [3:0]  ealuc;
	output [31:0] eimm, ea, eb, epc4, esa;
	output [4:0]  ern0, ers, ert;
	reg       	  ewreg, em2reg, ewmem, ealuimm, eshift, ejal, ebubble; 
	reg    [3:0]  ealuc;
	reg    [31:0] eimm, ea, eb, epc4, esa;
	reg    [4:0]  ern0, ers, ert;
	
	always @( posedge clock or negedge resetn)
	begin
		if (resetn == 0 )  //清零
		begin
			ewreg <= 0;
			em2reg <= 0;
			ewmem <= 0;
			ealuimm <= 0;
			eshift <= 0;
			ejal <= 0;
			ealuc <= 0;
			eimm <= 0;
			ea <= 0;
			eb <= 0;
			epc4 <= 0;
			ern0 <= 0;
			ebubble <= 0;
			esa <= 0;
			ers <= 0;
			ert <= 0;
		end
		else
		begin  
			ewreg <= dwreg;
			em2reg <= dm2reg;
			ewmem <= dwmem;
			ealuimm <= daluimm;
			eshift <= dshift;
			ejal <= djal;
			ealuc <= daluc;
			eimm <= dimm;
			ea <= da;
			eb <= db;
			epc4 <= dpc4;
			ern0 <= drn;
			ebubble <= dbubble;
			esa <= dsa;
			ers <= drs;
			ert <= drt;
		end
	end
endmodule
```

### `pipeexe`模块

该模块为CPU指令执行阶段，调用了`alu.v`,主要进行一些算术运算，代码实现如下：

```verilog
module pipeexe( ealuc, ealuimm, ea, eb, eimm, esa, eshift, ern0, epc4, ejal, ern, ealu);
	input  [3:0]  ealuc;
	input  [31:0] ea, eb, eimm, epc4, esa;
	input  [4:0]  ern0;
	input  		  ealuimm, eshift, ejal;
	output [31:0] ealu;
	output [4:0]  ern;
	wire   [31:0] a, b, r;
	wire   [31:0] epc8 = epc4 + 4;
	wire   [4:0]  ern = ern0 | {5{ejal}};
	mux2x32 a_mux( ea, esa, eshift, a );
	mux2x32 b_mux( eb, eimm, ealuimm, b );
	mux2x32 ealu_mux( r, epc4, ejal, ealu );
	alu     al_unit( a, b, ealuc, r);  // alu模块
endmodule
```

**`alu.v`**

和单周期CPU相同

```verilog
module alu (a,b,aluc,s);
   input [31:0] a,b;
   input [3:0] aluc;
   output [31:0] s;
   reg [31:0] s;
   always @ (a or b or aluc) 
      begin                                   // event
         case (aluc)
             4'b0000: s = a + b;              //x000 ADD
             4'b0100: s = a - b;              //x100 SUB
             4'b0001: s = a & b;              //x001 AND
             4'b0101: s = a | b;              //x101 OR
             4'b0010: s = a ^ b;              //x010 XOR
             4'b0110: s = b << 16;            //x110 LUI: imm << 16bit             
             4'b0011: s = b << a;             //0011 SLL: rd <- (rt << sa)
             4'b0111: s = b >> a;             //0111 SRL: rd <- (rt >> sa) (logical)
             4'b1111: s = $signed(b) >>> a;   //1111 SRA: rd <- (rt >> sa) (arithmetic)
             default: s = 0;
         endcase      
      end      
endmodule 
```

### `pipeemreg`模块

该模块为连接EXE和MEM阶段的寄存器，几个`*reg`模块作用与实现差不多一样。代码实现如下：

```verilog
module pipeemreg( ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,
	mwreg,mm2reg,mwmem,malu,mb,mrn);
	input          ewreg, em2reg, ewmem, clock, resetn;
	input  [31:0]  ealu, eb;
	input  [4:0]   ern;
	output         mwreg, mm2reg, mwmem;
	output [31:0]  malu, mb;
	output [4:0]   mrn;
	reg            mwreg, mm2reg, mwmem;
	reg    [31:0]  malu, mb;
	reg    [4:0]   mrn;
	
	always @( posedge clock or negedge resetn)
	begin
		if (resetn == 0 )  // 清零
		begin
			mwreg <= 0;
			mm2reg <= 0;
			mwmem <= 0;
			malu <= 0;
			mb <= 0;
			mrn <= 0;
		end
		else
		begin
			mwreg <= ewreg;
			mm2reg <= em2reg;
			mwmem <= ewmem;
			malu <= ealu;
			mb <= eb;
			mrn <= ern;
		end
	end
endmodule
```

### `pipemem`模块

该模块主要将数据写入mem或者从mem中读取数据，需要调用`sc_datamem`模块。代码实现如下：

**`pipemem.v`**

```verilog
module pipemem(mwmem, malu, mb, clock, mem_clock, mmo,resetn,in_port0,in_port1,out_port0,out_port1,out_port2);
	input          mwmem, clock,resetn;
	input  [31:0]  malu, mb;
	input         mem_clock;
	input [31:0] in_port0,in_port1;
	output [31:0]  mmo,out_port0,out_port1,out_port2;
	wire   [31:0] mem_dataout, io_read_data;
	sc_datamem dmem( resetn,malu, mb, mmo, mwmem, mem_clock,in_port0,in_port1,out_port0,out_port1,out_port2,mem_dataout,io_read_data);

endmodule
```

**`sc_datamem.v`**

```verilog
module sc_datamem (resetn,addr,datain,dataout,we,clock,in_port0_tmp,in_port1_tmp,out_port0,out_port1,out_port2,mem_dataout,io_read_data);

   input  [31:0]  addr;
   input  [31:0]  datain;
   input          we, clock;
	input [3:0]	in_port0_tmp, in_port1_tmp;
	output [31:0]	out_port0, out_port1, out_port2;
   output [31:0]  dataout;
	input				resetn;
	output [31:0]		mem_dataout,io_read_data;
   wire           write_enable, write_io_enable, write_datamem_enable;
   wire [31:0] in_port0,in_port1;
   assign in_port0={28'b0,in_port0_tmp};
   assign in_port1={28'b0,in_port1_tmp};


   assign         write_enable = we ; 
   assign 			write_io_enable = addr[7] & write_enable;
	assign			write_datamem_enable = ~addr[7] & write_enable;

   mux2x32 mem_io_dataout_mux(mem_dataout,io_read_data,addr[7],dataout);
   // module mux2x32 (a0,a1,s,y);
   // when address[7]=0, means the access is to the datamem.
   // that is, the address space of datamem is from 000000 to 011111 word(4 bytes)
	lpm_ram_dq_dram dram(addr[6:2],clock,datain,write_datamem_enable,mem_dataout);
   // when address[7]=1, means the access is to the I/O space.
   // that is, the address space of I/O is from 100000 to 111111 word(4 bytes)
   io_output_reg io_output_regx2(addr,datain,write_io_enable,clock,resetn,out_port0,out_port1,out_port2);
	// module io_output_reg (addr,datain,write_io_enable,io_clk,clrn,out_port0,out_port1 );
   io_input_reg io_input_regx2(addr,clock,io_read_data,in_port0,in_port1);
	// module io_input_reg (addr,io_clk,io_read_data,in_port0,in_port1);
endmodule
```

### `pipemwreg`模块

该模块为连接MEM和WB阶段的寄存器，几个`*reg`模块作用与实现差不多一样。代码实现如下：

```verilog
module pipemwreg( mwreg, mm2reg, mmo, malu, mrn, clock, resetn,
	wwreg, wm2reg, wmo, walu, wrn );
	input          mwreg, mm2reg, clock, resetn;
	input  [31:0]  mmo, malu;
	input  [4:0]   mrn;
	output         wwreg, wm2reg;
	output [31:0]  wmo, walu;
	output [4:0]   wrn;
	reg            wwreg, wm2reg;
	reg    [31:0]  wmo, walu;
	reg    [4:0]   wrn;
	always @( posedge clock or negedge resetn)
	begin
		if (resetn == 0 )
		begin
			wwreg <= 0;
			wm2reg <= 0;
			wmo <= 0;
			walu <= 0;
			wrn <= 0;
		end
		else
		begin
			wwreg <= mwreg;
			wm2reg <= mm2reg;
			wmo <= mmo;
			walu <= malu;
			wrn <= mrn;
		end
	end
endmodule
```

## *.mif `文件修改

### 无IO

在每个跳转指令后增加了nop指令

![图2](http://figure.cruisetian.top/img/Snipaste_2020-06-12_18-36-32.png)

### 有IO

重新写了`io_test.mif`

```text
DEPTH = 32;           % Memory depth and width are required% 
WIDTH = 32;           % Enter a decimal number % 
ADDRESS_RADIX = HEX;  % Address and value radixes are optional % 
DATA_RADIX = HEX;     % Enter BIN, DEC, HEX, or OCT; unless %
                       % otherwise specified, radixes = HEX % 
CONTENT 
BEGIN 
 
0 : 20010080;        % (00) main:  addi $1, $0, 128 # outport0, inport0              % 
1 : 20020084;        % (04)       addi $2, $0, 132 # outport1, inport1              % 
2 : 20030088;        % (08)       addi $3, $0, 136 # outport2                       % 
3 : 8c240000;        % (0c) loop:  lw   $4, 0($1)   # input inport0 to $4            % 
4 : 8c450000;        % (10)       lw   $5, 0($2)   # input inport1 to $5            % 
5 : 00853020;        % (14)       add  $6, $4, $5  # add inport0 with inport1 to $6 % 
6 : ac240000;        % (18)       sw   $4, 0($1)   # output inport0 to outport0     % 
7 : ac450000;        % (1c)       sw   $5, 0($2)   # output inport1 to outport1     % 
8 : ac660000;        % (20)       sw   $6, 0($3)   # output result to outport2      % 
9 : 08000003;        % (24)       j loop           # repeat                      % 
END ;
```



## 实验仿真结果

### 无IO

![图3](http://figure.cruisetian.top/img/Snipaste_2020-06-12_18-41-34.png)

**细节部分**

![图4](http://figure.cruisetian.top/img/Snipaste_2020-06-12_18-42-12.png)

### 有IO

![图5](http://figure.cruisetian.top/img/Snipaste_2020-06-12_18-50-29.png)

根据三个输出端口可以看出，得到的结果正确

## 参考

+ 主要原理参考图1