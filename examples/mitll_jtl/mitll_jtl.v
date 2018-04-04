// ---------------------------------------------------------------------------
// Automatically extracted verilog file, created with TimEx v2.00.12
// Timing description and structural design for IARPA-BAA-14-03 via
// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and
// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016-2018 Stellenbosch University
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module mitll_jtl (in, out);

input
  in;

output
  out;

reg
  out;

parameter
  bias = 1.0;

real
  delay_state0_in_out = 4.0,
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
      out = 0; // All outputs start at 0
    if (bias < 0.6)
      begin
        out <= 1'bX;
      end
    if ((bias >= 0.6) && (bias < 0.7))
      begin
        delay_state0_in_out = 6.0 + (-0.5/0.1)*(bias-0.6);
        ct_state0_in_in = 7.1 + (-3.8/0.1)*(bias-0.6);
      end
    if ((bias >= 0.7) && (bias < 0.8))
      begin
        delay_state0_in_out = 5.5 + (-0.8/0.1)*(bias-0.7);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-0.7);
      end
    if ((bias >= 0.8) && (bias < 0.9))
      begin
        delay_state0_in_out = 4.7 + (-0.5/0.1)*(bias-0.8);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-0.8);
      end
    if ((bias >= 0.9) && (bias < 1))
      begin
        delay_state0_in_out = 4.2 + (-0.3/0.1)*(bias-0.9);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-0.9);
      end
    if ((bias >= 1) && (bias < 1.1))
      begin
        delay_state0_in_out = 4.0 + (-0.5/0.1)*(bias-1.0);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-1.0);
      end
    if ((bias >= 1.1) && (bias < 1.2))
      begin
        delay_state0_in_out = 3.5 + (-0.5/0.1)*(bias-1.1);
        ct_state0_in_in = 3.3 + (0.0/0.1)*(bias-1.1);
      end
    if ((bias >= 1.2) && (bias <= 1.4))
      begin
        delay_state0_in_out = 3.0 + (-0.2/0.2)*(bias-1.2);
        ct_state0_in_in = 3.3 + (0.0/0.2)*(bias-1.2);
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
                           out <= #(delay_state0_in_out) !out;
                           errorsignal_in = 1;  // Critical timing on this input; assign immediately
                           errorsignal_in <= #(ct_state0_in_in) 0;  // Clear error signal after critical timing expires
                        end
                  endcase
               end
         end
   end

endmodule
