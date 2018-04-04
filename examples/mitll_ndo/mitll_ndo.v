// ---------------------------------------------------------------------------
// Automatically extracted verilog file, created with TimEx v2.00.12
// Timing description and structural design for IARPA-BAA-14-03 via
// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and
// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016-2018 Stellenbosch University
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module mitll_ndo (set, reset, clk, out, resout);

input
  set, reset, clk;

output
  out, resout;

reg
  out, resout;

parameter
  bias = 1.0;

real
  delay_state1_reset_resout = 7.0,
  delay_state1_clk_out = 8.2,
  ct_state0_reset_set = 0.5,
  ct_state1_reset_set = 3.1,
  ct_state1_reset_clk = 2.1,
  ct_state1_clk_reset = 5.2,
  ct_state1_clk_clk = 9.8;

reg
   errorsignal_set,
   errorsignal_reset,
   errorsignal_clk;

integer
   outfile,
   cell_state; // internal state of the cell

initial
   begin
      errorsignal_set = 0;
      errorsignal_reset = 0;
      errorsignal_clk = 0;
      cell_state = 0; // Startup state
      out = 0; // All outputs start at 0
      resout = 0; // All outputs start at 0
    if (bias < 0.6)
      begin
        out <= 1'bX;
        resout <= 1'bX;
      end
    if ((bias >= 0.6) && (bias < 0.7))
      begin
        out <= 1'bX;
        resout <= 1'bX;
      end
    if ((bias >= 0.7) && (bias < 0.8))
      begin
        out <= 1'bX;
        resout <= 1'bX;
      end
    if ((bias >= 0.8) && (bias < 0.9))
      begin
        out <= 1'bX;
        resout <= 1'bX;
      end
    if ((bias >= 0.9) && (bias < 1))
      begin
        delay_state1_reset_resout = 7.2 + (-0.2/0.1)*(bias-0.9);
        delay_state1_clk_out = 11.2 + (-3.0/0.1)*(bias-0.9);
        ct_state0_reset_set = 0.3 + (0.2/0.1)*(bias-0.9);
        ct_state1_reset_set = 3.5 + (-0.4/0.1)*(bias-0.9);
        ct_state1_reset_clk = 2.0 + (0.2/0.1)*(bias-0.9);
        ct_state1_clk_reset = 5.1 + (0.1/0.1)*(bias-0.9);
        ct_state1_clk_clk = 14.2 + (-4.5/0.1)*(bias-0.9);
      end
    if ((bias >= 1) && (bias < 1.1))
      begin
        delay_state1_reset_resout = 7.0 + (-0.5/0.1)*(bias-1.0);
        delay_state1_clk_out = 8.2 + (-1.2/0.1)*(bias-1.0);
        ct_state0_reset_set = 0.5 + (0.3/0.1)*(bias-1.0);
        ct_state1_reset_set = 3.1 + (-0.5/0.1)*(bias-1.0);
        ct_state1_reset_clk = 2.1 + (0.0/0.1)*(bias-1.0);
        ct_state1_clk_reset = 5.2 + (-0.4/0.1)*(bias-1.0);
        ct_state1_clk_clk = 9.8 + (-1.7/0.1)*(bias-1.0);
      end
    if ((bias >= 1.1) && (bias < 1.2))
      begin
        delay_state1_reset_resout = 6.5 + (-0.5/0.1)*(bias-1.1);
        delay_state1_clk_out = 7.0 + (-1.0/0.1)*(bias-1.1);
        ct_state0_reset_set = 0.8 + (0.3/0.1)*(bias-1.1);
        ct_state1_reset_set = 2.7 + (-0.5/0.1)*(bias-1.1);
        ct_state1_reset_clk = 2.1 + (-0.1/0.1)*(bias-1.1);
        ct_state1_clk_reset = 4.8 + (-0.2/0.1)*(bias-1.1);
        ct_state1_clk_clk = 8.0 + (-0.5/0.1)*(bias-1.1);
      end
    if ((bias >= 1.2) && (bias <= 1.4))
      begin
        out <= 1'bX;
        resout <= 1'bX;
      end
    if (bias > 1.4)
      begin
        out <= 1'bX;
        resout <= 1'bX;
      end
   end

always @(posedge set or negedge set) // execute at positive and negative edges of input
   begin
      if ($time>4) // arbitrary steady-state time)
         begin
            if (errorsignal_set == 1'b1)  // A critical timing is active for this input
               begin
                  outfile = $fopen("errors.txt", "a");
                  $fdisplay(outfile, "Violation of critical timing in module %m; %0d ps.\n", $stime);
                  $fclose(outfile);
                  out <= 1'bX;  // Set all outputs to unknown
                  resout <= 1'bX;  // Set all outputs to unknown
               end
            if (errorsignal_set == 0)
               begin
                  case (cell_state)
                     0: begin
                           cell_state = 1;  // Blocking statement -- immediately
                        end
                     1: begin
                        end
                  endcase
               end
         end
   end

always @(posedge reset or negedge reset) // execute at positive and negative edges of input
   begin
      if ($time>4) // arbitrary steady-state time)
         begin
            if (errorsignal_reset == 1'b1)  // A critical timing is active for this input
               begin
                  outfile = $fopen("errors.txt", "a");
                  $fdisplay(outfile, "Violation of critical timing in module %m; %0d ps.\n", $stime);
                  $fclose(outfile);
                  out <= 1'bX;  // Set all outputs to unknown
                  resout <= 1'bX;  // Set all outputs to unknown
               end
            if (errorsignal_reset == 0)
               begin
                  case (cell_state)
                     0: begin
                           errorsignal_set = 1;  // Critical timing on this input; assign immediately
                           errorsignal_set <= #(ct_state0_reset_set) 0;  // Clear error signal after critical timing expires
                        end
                     1: begin
                           resout <= #(delay_state1_reset_resout) !resout;
                           cell_state = 0;  // Blocking statement -- immediately
                           errorsignal_set = 1;  // Critical timing on this input; assign immediately
                           errorsignal_set <= #(ct_state1_reset_set) 0;  // Clear error signal after critical timing expires
                           errorsignal_clk = 1;  // Critical timing on this input; assign immediately
                           errorsignal_clk <= #(ct_state1_reset_clk) 0;  // Clear error signal after critical timing expires
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
                  resout <= 1'bX;  // Set all outputs to unknown
               end
            if (errorsignal_clk == 0)
               begin
                  case (cell_state)
                     0: begin
                        end
                     1: begin
                           out <= #(delay_state1_clk_out) !out;
                           errorsignal_reset = 1;  // Critical timing on this input; assign immediately
                           errorsignal_reset <= #(ct_state1_clk_reset) 0;  // Clear error signal after critical timing expires
                           errorsignal_clk = 1;  // Critical timing on this input; assign immediately
                           errorsignal_clk <= #(ct_state1_clk_clk) 0;  // Clear error signal after critical timing expires
                        end
                  endcase
               end
         end
   end

endmodule
