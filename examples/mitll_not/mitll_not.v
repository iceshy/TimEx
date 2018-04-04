// ---------------------------------------------------------------------------
// Automatically extracted verilog file, created with TimEx v2.00.12
// Timing description and structural design for IARPA-BAA-14-03 via
// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and
// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016-2018 Stellenbosch University
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module mitll_not (in, clk, out);

input
  in, clk;

output
  out;

reg
  out;

parameter
  bias = 1.0;

real
  delay_state0_clk_out = 9.2,
  ct_state0_clk_in = 1.9,
  ct_state0_clk_clk = 8.0;

reg
   errorsignal_in,
   errorsignal_clk;

integer
   outfile,
   cell_state; // internal state of the cell

initial
   begin
      errorsignal_in = 0;
      errorsignal_clk = 0;
      cell_state = 0; // Startup state
      out = 0; // All outputs start at 0
    if (bias < 0.6)
      begin
        out <= 1'bX;
      end
    if ((bias >= 0.6) && (bias < 0.7))
      begin
        delay_state0_clk_out = 18.0 + (-3.7/0.1)*(bias-0.6);
        ct_state0_clk_in = 11.2 + (-4.9/0.1)*(bias-0.6);
        ct_state0_clk_clk = 16.2 + (-4.4/0.1)*(bias-0.6);
      end
    if ((bias >= 0.7) && (bias < 0.8))
      begin
        delay_state0_clk_out = 14.2 + (-2.5/0.1)*(bias-0.7);
        ct_state0_clk_in = 6.2 + (-3.0/0.1)*(bias-0.7);
        ct_state0_clk_clk = 11.8 + (-1.6/0.1)*(bias-0.7);
      end
    if ((bias >= 0.8) && (bias < 0.9))
      begin
        delay_state0_clk_out = 11.7 + (-1.5/0.1)*(bias-0.8);
        ct_state0_clk_in = 3.2 + (-0.7/0.1)*(bias-0.8);
        ct_state0_clk_clk = 10.2 + (-1.3/0.1)*(bias-0.8);
      end
    if ((bias >= 0.9) && (bias < 1))
      begin
        delay_state0_clk_out = 10.2 + (-1.0/0.1)*(bias-0.9);
        ct_state0_clk_in = 2.5 + (-0.6/0.1)*(bias-0.9);
        ct_state0_clk_clk = 8.9 + (-0.9/0.1)*(bias-0.9);
      end
    if ((bias >= 1) && (bias < 1.1))
      begin
        delay_state0_clk_out = 9.2 + (-1.0/0.1)*(bias-1.0);
        ct_state0_clk_in = 1.9 + (-0.5/0.1)*(bias-1.0);
        ct_state0_clk_clk = 8.0 + (-0.3/0.1)*(bias-1.0);
      end
    if ((bias >= 1.1) && (bias < 1.2))
      begin
        delay_state0_clk_out = 8.2 + (-0.8/0.1)*(bias-1.1);
        ct_state0_clk_in = 1.4 + (-0.4/0.1)*(bias-1.1);
        ct_state0_clk_clk = 7.7 + (-1.6/0.1)*(bias-1.1);
      end
    if ((bias >= 1.2) && (bias <= 1.4))
      begin
        delay_state0_clk_out = 7.5 + (-1.2/0.2)*(bias-1.2);
        ct_state0_clk_in = 1.0 + (-0.8/0.2)*(bias-1.2);
        ct_state0_clk_clk = 6.2 + (-2.3/0.2)*(bias-1.2);
      end
    if (bias > 1.4)
      begin
        out <= 1'bX;
      end
   end

always @(posedge in or negedge in) // execute at positive and negative edges of input
   begin
      if ($time>4) // arbitrary steady-state time)
         begin
            if (errorsignal_in == 1'b1)  // A critical timing is active for this input
               begin
                  outfile = $fopen("errors.txt", "a");
                  $fdisplay(outfile, "Violation of critical timing in module %m; %0d ps.\n", $stime);
                  $fclose(outfile);
                  out <= 1'bX;  // Set all outputs to unknown
               end
            if (errorsignal_in == 0)
               begin
                  case (cell_state)
                     0: begin
                           cell_state = 1;  // Blocking statement -- immediately
                        end
                     1: begin
                           outfile = $fopen("errors.txt", "a");
                           $fdisplay(outfile, "Illegal in input in state %0d of module %m; %0d ps.\n", cell_state, $stime);
                           $fclose(outfile);
                           out <= 1'bX;  // Set all outputs to unknown
                        end
                  endcase
               end
         end
   end

always @(posedge clk or negedge clk) // execute at positive and negative edges of input
   begin
      if ($time>4) // arbitrary steady-state time)
         begin
            if (errorsignal_clk == 1'b1)  // A critical timing is active for this input
               begin
                  outfile = $fopen("errors.txt", "a");
                  $fdisplay(outfile, "Violation of critical timing in module %m; %0d ps.\n", $stime);
                  $fclose(outfile);
                  out <= 1'bX;  // Set all outputs to unknown
               end
            if (errorsignal_clk == 0)
               begin
                  case (cell_state)
                     0: begin
                           out <= #(delay_state0_clk_out) !out;
                           errorsignal_in = 1;  // Critical timing on this input; assign immediately
                           errorsignal_in <= #(ct_state0_clk_in) 0;  // Clear error signal after critical timing expires
                           errorsignal_clk = 1;  // Critical timing on this input; assign immediately
                           errorsignal_clk <= #(ct_state0_clk_clk) 0;  // Clear error signal after critical timing expires
                        end
                     1: begin
                           cell_state = 0;  // Blocking statement -- immediately
                        end
                  endcase
               end
         end
   end

endmodule
