`timescale 1ns / 1ps
module sync_w2r #(parameter ADDRSIZE = 4)
				 (output reg [ADDRSIZE:0] rq2_wptr,			//Base representation *q2_!ptr where the *q2 represents the domain to which the !ptr has to be synchronized to
 				  input [ADDRSIZE:0] wptr,			//Write pointer to be synchronized to the read clock domain
				  input rclk, rrst_n);			//rclk --> read clock, rrst_n --> read clock reset

reg [ADDRSIZE:0] rq1_wptr;			//Basic Synchronization scheme by using two registers in the path of the two signals (two different domains) and use one as the reference

always @(posedge rclk or negedge rrst_n)
if (!rrst_n) {rq2_wptr,rq1_wptr} <= 0;
else {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};			//Simple register shift to synchronize
endmodule