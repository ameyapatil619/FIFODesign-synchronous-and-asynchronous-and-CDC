`timescale 1ns / 1ps
module rptr_empty #(parameter ADDRSIZE = 4)
				   (output reg rempty,			//empty flag (o/p)
					output [ADDRSIZE-1:0] raddr,			//read-address sent to memory
					output reg [ADDRSIZE :0] rptr,			//read pointer (gray code) generated to get synchronized in the write clock domain (o/p)
					input [ADDRSIZE :0] rq2_wptr,			//synchronized write pointer in read clock domain (gray code). 
					input rinc, rclk, rrst_n);				//rinc --> read signal, rclk --> read clock, rrst_n --> read reset only

reg [ADDRSIZE:0] rbin;			//it starts of with an initial value of 4b'0000 when the read clock reset is first hit 
wire [ADDRSIZE:0] rgraynext, rbinnext;			//Check block diagram of style 2 in Cummings paper

//-------------------
// GRAYSTYLE2 pointer
//-------------------

always @(posedge rclk or negedge rrst_n)
if (!rrst_n) {rbin, rptr} <= 0;			//reset condition to initialize the address and the read pointers to zero
else {rbin, rptr} <= {rbinnext, rgraynext};			//read pointer is set to a gray code value

// Memory read-address pointer (okay to use binary to address memory)

assign raddr = rbin[ADDRSIZE-1:0];		//We can use the direct binary value for the read address given to the memory block
assign rbinnext = rbin + (rinc & ~rempty);		//Next value of address to be checked (if empty == 1'b1, the next state and the current state value (in binary) are the same 
assign rgraynext = (rbinnext>>1) ^ rbinnext;		//Simple way of converting binary to gray code.

//---------------------------------------------------------------
// FIFO empty when the next rptr == synchronized wptr or on reset
//---------------------------------------------------------------

assign rempty_val = (rgraynext == rq2_wptr);			//if synchronized write pointer is equal to the next read pointer value (equal to the current read pointer in the previous "if" block for empty == 1'b1, both in gray code). Condition for empty check.

always @(posedge rclk or negedge rrst_n)
if (!rrst_n) rempty <= 1'b1;			//Simple reset in read clock domain will make sure the empty flag gets set
else rempty <= rempty_val;
endmodule