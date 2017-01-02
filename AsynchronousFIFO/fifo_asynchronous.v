`timescale 1ns / 1ps
module fifo_asynchronous #(parameter DSIZE = 8, parameter ASIZE = 4)			//Modifiable fifo parameters (data width and fifo size)
			  
			  (output [DSIZE-1:0] rdata,			//data_out in the FIFO which is basically the read system data
			   output wfull,				//full flag (associated with the write clock domain system)
			   output rempty,				//empty flag (associated with the read clock domain system)
			   input [DSIZE-1:0] wdata,			//data_in to the FIFO which is the basically the write system data
			   input winc, wclk, wrst_n,			//winc --> write signal, wclk --> write clock, wrst_n --> write reset
			   input rinc, rclk, rrst_n);			//rinc --> read signal, rclk --> read clock, rrst_n --> read reset

wire [ASIZE-1:0] waddr, raddr;			//write and read address given to the dual port RAM
wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;			//NOTE: All generated in gray code format. wptr --> write pointer to be synchronized to the read clock domain, rptr --> read pointer to be synchronized to the write clock domain, wq2_rptr --> read pointer synchronized in the write clock domain, rq2_wptr --> write pointer synchronized in the read clock domain

sync_r2w sync_r2w (.wq2_rptr(wq2_rptr),			//read pointer to write clock domain synchronizer
				   .rptr(rptr),
				   .wclk(wclk), 
				   .wrst_n(wrst_n));
				   
sync_w2r sync_w2r (.rq2_wptr(rq2_wptr),			//write pointer to read clock domain synchronizer		
				   .wptr(wptr),
				   .rclk(rclk), 
				   .rrst_n(rrst_n));
				   
fifomem #(DSIZE, ASIZE) fifomem (.rdata(rdata),			//dual port RAM (two read ports --> one for the read address and the other for the read pointer and one port for write). The reference clock to be used is the write clock. 
								 .wdata(wdata),
								 .waddr(waddr), 
								 .raddr(raddr),
								 .wclken(winc), 
								 .wfull(wfull),
								 .wclk(wclk));
								 
rptr_empty #(ASIZE) rptr_empty (.rempty(rempty),			//read pointer (gray code) and empty status check
								.raddr(raddr),
								.rptr(rptr), 
								.rq2_wptr(rq2_wptr),
								.rinc(rinc), 
								.rclk(rclk),
								.rrst_n(rrst_n));

wptr_full #(ASIZE) wptr_full (.wfull(wfull),			//write pointer (gray code) and full status check 
							  .waddr(waddr),
							  .wptr(wptr), 
							  .wq2_rptr(wq2_rptr),
							  .winc(winc), 
							  .wclk(wclk),
							  .wrst_n(wrst_n));

endmodule