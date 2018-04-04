// ---------------------------------------------------------------------------
// Automatically extracted verilog file, created with TimEx v2.00.10
// Timing description and structural design for IARPA-BAA-14-03 via
// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and
// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016-2018 Stellenbosch University
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module jtl_vc075 (in, out);

input
  in;

output
  out;

reg
  out;

parameter
  bias = 2.5;

real
  delay_state0_in_out = 4.5,
  ct_state0_in_in = 5.0;

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
    if (bias < 1.5)
      begin
        out <= 1'bX;
      end
    if ((bias >= 1.5) && (bias < 1.75))
      begin
        delay_state0_in_out = 7.5 + (-1.2/0.3)*(bias-1.5);
        ct_state0_in_in = 9.5 + (-1.5/0.3)*(bias-1.5);
      end
    if ((bias >= 1.75) && (bias < 2))
      begin
        out <= 1'bX;
      end
    if ((bias >= 2) && (bias < 2.25))
      begin
        out <= 1'bX;
      end
    if ((bias >= 2.25) && (bias < 2.5))
      begin
        out <= 1'bX;
      end
    if ((bias >= 2.5) && (bias < 2.75))
      begin
        out <= 1'bX;
      end
    if ((bias >= 2.75) && (bias < 3))
      begin
        out <= 1'bX;
      end
    if ((bias >= 3) && (bias < 3.25))
      begin
        out <= 1'bX;
      end
    if ((bias >= 3.25) && (bias < 3.5))
      begin
        out <= 1'bX;
      end
    if ((bias >= 3.5) && (bias < 3.75))
      begin
        out <= 1'bX;
      end
    if ((bias >= 3.75) && (bias < 4))
      begin
        out <= 1'bX;
      end
    if ((bias >= 4) && (bias < 4.25))
      begin
        out <= 1'bX;
      end
    if ((bias >= 4.25) && (bias < 4.5))
      begin
        out <= 1'bX;
      end
    if ((bias >= 4.5) && (bias < 4.75))
      begin
        out <= 1'bX;
      end
    if ((bias >= 4.75) && (bias <= 5))
      begin
        out <= 1'bX;
      end
    if (bias > 5)
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
