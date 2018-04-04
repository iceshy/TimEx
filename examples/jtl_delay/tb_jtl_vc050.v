// ---------------------------------------------------------------------------
// Verilog testbench file, created with TimEx v2.00.10
// Timing description and structural design for IARPA-BAA-14-03 via
// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and
// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016-2018 Stellenbosch University
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module tb_jtl_vc050;
   reg in = 0;
parameter
  bias = 2.5;

   initial
      begin
         $dumpfile("tb_jtl_vc050.vcd");
         $dumpvars;
         // Now in state 0
         #20 in = !in;
         // Now in state 0
      end

   initial
      begin
         $display("\t\ttime,\tin,\tout");
         $monitor("%d,\t%b,\t%b",$time,in,out);
      end

   jtl_vc050 #(bias) DUT (in, out);

   initial
      #30 $finish;
endmodule
