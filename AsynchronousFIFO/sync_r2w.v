`timescale 1ns / 1ps
module sync_r2w #(parameter ADDRSIZE = 4)
				 (output reg [ADDRSIZE:0] wq2_rptr,			//Base representation *q2_!ptr where the *q2 represents the domain to which the !ptr has to be synchronized to
				  input [ADDRSIZE:0] rptr,			//Read pointer to be synchronized to the write clock domain
				  input wclk, wrst_n);			//wclk --> write clock, wrst_n --> write clock reset

reg [ADDRSIZE:0] wq1_rptr;			//Basic Synchronization scheme by using two registers in the path of the two signals (two different domains) and use one as the reference

always @(posedge wclk or negedge wrst_n)

if (!wrst_n) {wq2_rptr,wq1_rptr} <= 0;
else {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};		//Simple register shift to synchronize

endmodule