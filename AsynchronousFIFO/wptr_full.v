`timescale 1ns / 1ps
module wptr_full #(parameter ADDRSIZE = 4)
				  (output reg wfull,			//full status flag 
				   output [ADDRSIZE-1:0] waddr,			//write pointer address sent to memory to access
				   output reg [ADDRSIZE :0] wptr,			//write pointer (gray code) generated to get synchronized in the read clock domain
				   input [ADDRSIZE :0] wq2_rptr,			//read pointer synchronized in the write clock domain (gray code)
				   input winc, wclk, wrst_n);			//winc --> write signal, wclk --> write clock, wrst_n --> write clock domain reset

reg [ADDRSIZE:0] wbin;			//it starts with an initial value of 4b'0000 when the write rst is first hit
wire [ADDRSIZE:0] wgraynext, wbinnext;

//-------------------
// GRAYSTYLE2 pointer
//-------------------

always @(posedge wclk or negedge wrst_n)
if (!wrst_n) {wbin, wptr} <= 0;				//Initialization
else {wbin, wptr} <= {wbinnext, wgraynext};			//every clock edge the next value is loaded and the write pointer in the write clock domain is converted to gray code.

// Memory write-address pointer (okay to use binary to address memory)

assign waddr = wbin[ADDRSIZE-1:0];			//write pointer address in binary
assign wbinnext = wbin + (winc & ~wfull);			//Next value of address to be checked (if full == 1'b1, the next state and the current state value (in binary) are the same 
assign wgraynext = (wbinnext>>1) ^ wbinnext;			//Simple one line code to generate gray code.

//------------------------------------------------------------------
// Simplified version of the three necessary full-tests:
// assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
// (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
// (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
//------------------------------------------------------------------

assign wfull_val = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1], wq2_rptr[ADDRSIZE-2:0]});			//Condition to mainly check for is that all other bits than the last added MSB bit of the write pointers and the synchronized read pointers have to be the same for full == 1'b1

always @(posedge wclk or negedge wrst_n)
if (!wrst_n) wfull <= 1'b0;			//when the write reset is hit, the full flag goes back to its default state of 1'b0 till it becomes full
else wfull <= wfull_val;
endmodule