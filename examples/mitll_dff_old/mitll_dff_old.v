// ---------------------------------------------------------------------------
// Automatically extracted verilog file, created with TimEx v1.00.02
// Timing description and structural design for IARPA-BAA-14-03.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016 Stellenbosch University
// ---------------------------------------------------------------------------
`timescale 1ps/100fs
module mitll_dff_old (set, reset, out);

input
  set, reset;

output
  out;

reg
  out;

parameter
   delay_state1_reset_out = 6.7,
   ct_state0_set_reset = 1.3,
   ct_state1_reset_set = 0.6;

reg
   errorsignal_set,
   errorsignal_reset;

integer
   outfile,
   cell_state; // internal state of the cell

initial
   begin
      errorsignal_set = 0;
      errorsignal_reset = 0;
      cell_state = 0; // Startup state
      out = 0; // All outputs start at 0
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
               end
            if (errorsignal_set == 0)
               begin
                  if (cell_state == 0)
                     begin
                        cell_state <= 1;
                        errorsignal_reset = 1;  // Critical timing on this input; assign immediately
                        errorsignal_reset <= #(ct_state0_set_reset) 0;  // Clear error signal after critical timing expires
                     end
                  if (cell_state == 1)
                     begin
                        outfile = $fopen("errors.txt", "a");
                        $fdisplay(outfile, "Illegal set input in state %0d of module %m; %0d ps.\n", cell_state, $stime);
                        $fclose(outfile);
                        out <= 1'bX;  // Set all outputs to unknown
                     end
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
               end
            if (errorsignal_reset == 0)
               begin
                  if (cell_state == 0)
                     begin
                     end
                  if (cell_state == 1)
                     begin
                        out <= #(delay_state1_reset_out) !out;
                        cell_state <= 0;
                        errorsignal_set = 1;  // Critical timing on this input; assign immediately
                        errorsignal_set <= #(ct_state1_reset_set) 0;  // Clear error signal after critical timing expires
                     end
               end
         end
   end

endmodule
