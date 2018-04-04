// ---------------------------------------------------------------------------
// Verilog testbench file, created with TimEx v1.00.02
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module tb_mitll_dff_old;
   reg set = 0;
   reg reset = 0;
   initial
      begin
         $dumpfile("tb_mitll_dff_old.vcd");
         $dumpvars;
         // Now in state 0
         #20 set = !set;
         // Now in state 1
         // Input "set" leads to error state; not fired.
         // Now in state 1
         #10 reset = !reset;
         // Now in state 0
         #10 reset = !reset;
         // Now in state 0
      end

   initial
      begin
         $display("\t\ttime,\tset,\treset,\tout");
         $monitor("%d,\t%b,\t%b,\t%b",$time,set,reset,out);
      end

   mitll_dff_old DUT (set, reset, out);

   initial
      #50 $finish;
endmodule
