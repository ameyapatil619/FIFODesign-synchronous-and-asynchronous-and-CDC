`timescale 1ns / 1ps
//Author: Ameya Patil
//Module: configurable memory (data width and depth of FIFO) or vendor memory usage

module fifomem #(parameter DATASIZE = 32, // Memory data word width
				 parameter ADDRSIZE = 4) // Number of mem address bits

//Invoking a dual ported SRAM block with 32 bit words and 2^4 = 16 words 

				(output [DATASIZE-1:0] rdata,			//data_out always associated with read
				 input [DATASIZE-1:0] wdata,			//data_in always associated with write
				 input [ADDRSIZE-1:0] waddr, raddr,		//read and write addresses 
				 input wclken, wfull, wclk);			//write clock enable, full flag (associated with write), write clock

`ifdef VENDORRAM
// instantiation of a vendor's dual-port RAM
vendor_ram mem (.dout(rdata), 
				.din(wdata),
				.waddr(waddr), 
				.raddr(raddr),
				.wclken(wclken),
				.wclken_n(wfull), 
				.clk(wclk));
`else
// RTL Verilog memory model

localparam DEPTH = 1<<ADDRSIZE;			//FIFO depth is 4 and hence the RAM has 2^(FIFOdepth) words
reg [DATASIZE-1:0] mem [0:DEPTH-1]; 

assign rdata = mem[raddr];			//output port for the SRAM

always @(posedge wclk)
if (wclken && !wfull) mem[waddr] <= wdata;			//writing data into the SRAM block depending on write clock and full flag
`endif			//Final Synthesis report tells us this is a 16*8 bit dual port distributed RAM
endmodule