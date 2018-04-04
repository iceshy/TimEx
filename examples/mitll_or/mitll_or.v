// ---------------------------------------------------------------------------
// Automatically extracted verilog file, created with TimEx v2.00.12
// Timing description and structural design for IARPA-BAA-14-03 via
// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and
// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016-2018 Stellenbosch University
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module mitll_or (a, b, clk, out);

input
  a, b, clk;

output
  out;

reg
  out;

parameter
  bias = 1.0;

real
  delay_state1_clk_out = 7.2,
  ct_state0_a_clk = 0.6,
  ct_state0_b_clk = 0.6,
  ct_state1_a_clk = 4.2,
  ct_state1_b_clk = 4.2;

reg
   errorsignal_a,
   errorsignal_b,
   errorsignal_clk;

integer
   outfile,
   cell_state; // internal state of the cell

initial
   begin
      errorsignal_a = 0;
      errorsignal_b = 0;
      errorsignal_clk = 0;
      cell_state = 0; // Startup state
      out = 0; // All outputs start at 0
    if (bias < 0.6)
      begin
        out <= 1'bX;
      end
    if ((bias >= 0.6) && (bias < 0.7))
      begin
        out <= 1'bX;
      end
    if ((bias >= 0.7) && (bias < 0.8))
      begin
        out <= 1'bX;
      end
    if ((bias >= 0.8) && (bias < 0.9))
      begin
        delay_state1_clk_out = 9.2 + (-1.2/0.1)*(bias-0.8);
        ct_state0_a_clk = 1.8 + (-0.7/0.1)*(bias-0.8);
        ct_state0_b_clk = 1.8 + (-0.7/0.1)*(bias-0.8);
        ct_state1_a_clk = 9.7 + (-4.4/0.1)*(bias-0.8);
        ct_state1_b_clk = 9.7 + (-4.4/0.1)*(bias-0.8);
      end
    if ((bias >= 0.9) && (bias < 1))
      begin
        delay_state1_clk_out = 8.0 + (-0.7/0.1)*(bias-0.9);
        ct_state0_a_clk = 1.1 + (-0.5/0.1)*(bias-0.9);
        ct_state0_b_clk = 1.1 + (-0.5/0.1)*(bias-0.9);
        ct_state1_a_clk = 5.3 + (-1.1/0.1)*(bias-0.9);
        ct_state1_b_clk = 5.3 + (-1.1/0.1)*(bias-0.9);
      end
    if ((bias >= 1) && (bias < 1.1))
      begin
        delay_state1_clk_out = 7.2 + (-0.5/0.1)*(bias-1.0);
        ct_state0_a_clk = 0.6 + (-0.6/0.1)*(bias-1.0);
        ct_state0_b_clk = 0.6 + (-0.6/0.1)*(bias-1.0);
        ct_state1_a_clk = 4.2 + (-0.5/0.1)*(bias-1.0);
        ct_state1_b_clk = 4.2 + (-0.5/0.1)*(bias-1.0);
      end
    if ((bias >= 1.1) && (bias < 1.2))
      begin
        out <= 1'bX;
      end
    if ((bias >= 1.2) && (bias <= 1.4))
      begin
        out <= 1'bX;
      end
    if (bias > 1.4)
      begin
        out <= 1'bX;
      end
   end

always @(posedge a or negedge a) // execute at positive and negative edges of input
   begin
      if ($time>4) // arbitrary steady-state time)
         begin
            if (errorsignal_a == 1'b1)  // A critical timing is active for this input
               begin
                  outfile = $fopen("errors.txt", "a");
                  $fdisplay(outfile, "Violation of critical timing in module %m; %0d ps.\n", $stime);
                  $fclose(outfile);
                  out <= 1'bX;  // Set all outputs to unknown
               end
            if (errorsignal_a == 0)
               begin
                  case (cell_state)
                     0: begin
                           cell_state = 1;  // Blocking statement -- immediately
                           errorsignal_clk = 1;  // Critical timing on this input; assign immediately
                           errorsignal_clk <= #(ct_state0_a_clk) 0;  // Clear error signal after critical timing expires
                        end
                     1: begin
                           errorsignal_clk = 1;  // Critical timing on this input; assign immediately
                           errorsignal_clk <= #(ct_state1_a_clk) 0;  // Clear error signal after critical timing expires
                        end
                  endcase
               end
         end
   end

always @(posedge b or negedge b) // execute at positive and negative edges of input
   begin
      if ($time>4) // arbitrary steady-state time)
         begin
            if (errorsignal_b == 1'b1)  // A critical timing is active for this input
               begin
                  outfile = $fopen("errors.txt", "a");
                  $fdisplay(outfile, "Violation of critical timing in module %m; %0d ps.\n", $stime);
                  $fclose(outfile);
                  out <= 1'bX;  // Set all outputs to unknown
               end
            if (errorsignal_b == 0)
               begin
                  case (cell_state)
                     0: begin
                           cell_state = 1;  // Blocking statement -- immediately
                           errorsignal_clk = 1;  // Critical timing on this input; assign immediately
                           errorsignal_clk <= #(ct_state0_b_clk) 0;  // Clear error signal after critical timing expires
                        end
                     1: begin
                           errorsignal_clk = 1;  // Critical timing on this input; assign immediately
                           errorsignal_clk <= #(ct_state1_b_clk) 0;  // Clear error signal after critical timing expires
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
                        end
                     1: begin
                           out <= #(delay_state1_clk_out) !out;
                           cell_state = 0;  // Blocking statement -- immediately
                        end
                  endcase
               end
         end
   end

endmodule
