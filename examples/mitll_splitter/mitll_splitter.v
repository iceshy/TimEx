// ---------------------------------------------------------------------------
// Automatically extracted verilog file, created with TimEx v2.00.12
// Timing description and structural design for IARPA-BAA-14-03 via
// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and
// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016-2018 Stellenbosch University
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module mitll_splitter (in, out1, out2);

input
  in;

output
  out1, out2;

reg
  out1, out2;

parameter
  bias = 1.0;

real
  delay_state0_in_out1 = 4.0,
  delay_state0_in_out2 = 4.0,
  ct_state0_in_in = 3.3;

reg
   errorsignal_in;

integer
   outfile,
   cell_state; // internal state of the cell

initial
   begin
      errorsignal_in = 0;
      cell_state = 0; // Startup state
      out1 = 0; // All outputs start at 0
      out2 = 0; // All outputs start at 0
    if (bias < 0.6)
      begin
        out1 <= 1'bX;
        out2 <= 1'bX;
      end
    if ((bias >= 0.6) && (bias < 0.7))
      begin
        delay_state0_in_out1 = -1E12 + (1E12/0.1)*(bias-0.6);
        delay_state0_in_out2 = -1E12 + (1E12/0.1)*(bias-0.6);
        ct_state0_in_in = 26.2 + (-15.9/0.1)*(bias-0.6);
      end
    if ((bias >= 0.7) && (bias < 0.8))
      begin
        delay_state0_in_out1 = 7.2 + (-2.0/0.1)*(bias-0.7);
        delay_state0_in_out2 = 7.2 + (-2.0/0.1)*(bias-0.7);
        ct_state0_in_in = 10.3 + (-7.0/0.1)*(bias-0.7);
      end
    if ((bias >= 0.8) && (bias < 0.9))
      begin
        delay_state0_in_out1 = 5.2 + (-0.8/0.1)*(bias-0.8);
        delay_state0_in_out2 = 5.2 + (-0.8/0.1)*(bias-0.8);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-0.8);
      end
    if ((bias >= 0.9) && (bias < 1))
      begin
        delay_state0_in_out1 = 4.5 + (-0.5/0.1)*(bias-0.9);
        delay_state0_in_out2 = 4.5 + (-0.5/0.1)*(bias-0.9);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-0.9);
      end
    if ((bias >= 1) && (bias < 1.1))
      begin
        delay_state0_in_out1 = 4.0 + (-0.5/0.1)*(bias-1.0);
        delay_state0_in_out2 = 4.0 + (-0.5/0.1)*(bias-1.0);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-1.0);
      end
    if ((bias >= 1.1) && (bias < 1.2))
      begin
        delay_state0_in_out1 = 3.5 + (-0.5/0.1)*(bias-1.1);
        delay_state0_in_out2 = 3.5 + (-0.5/0.1)*(bias-1.1);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-1.1);
      end
    if ((bias >= 1.2) && (bias <= 1.4))
      begin
        delay_state0_in_out1 = 3.0 + (-0.8/0.2)*(bias-1.2);
        delay_state0_in_out2 = 3.0 + (-0.8/0.2)*(bias-1.2);
        ct_state0_in_in = 3.3 + (-0.1/0.2)*(bias-1.2);
      end
    if (bias > 1.4)
      begin
        out1 <= 1'bX;
        out2 <= 1'bX;
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
                  out1 <= 1'bX;  // Set all outputs to unknown
                  out2 <= 1'bX;  // Set all outputs to unknown
               end
            if (errorsignal_in == 0)
               begin
                  case (cell_state)
                     0: begin
                           out1 <= #(delay_state0_in_out1) !out1;
                           out2 <= #(delay_state0_in_out2) !out2;
                           errorsignal_in = 1;  // Critical timing on this input; assign immediately
                           errorsignal_in <= #(ct_state0_in_in) 0;  // Clear error signal after critical timing expires
                        end
                  endcase
               end
         end
   end

endmodule
