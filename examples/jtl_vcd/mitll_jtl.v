// ---------------------------------------------------------------------------
// Automatically extracted verilog file, created with TimEx v2.03.00
// Timing description and structural design for IARPA-BAA-14-03 via
// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and
// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.
// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za
// (c) 2016-2018 Stellenbosch University
// ---------------------------------------------------------------------------
`ifndef begin_time
`define begin_time 8
`endif
`timescale 1ps/100fs

`celldefine
module mitll_jtl #(parameter begin_time = `begin_time) (in, out);

// Define inputs
input
  in;

// Define outputs
output
  out;

// Define internal output variables
reg
  internal_out;
assign out = internal_out;

// Define state
integer state;

wire
  internal_state_0;

assign internal_state_0 = state === 0;

specify
  specparam delay_state0_in_out = (3.8:3.8:3.8);  // Mean = 3.750  StdDev = 0.000

  specparam ct_state0_in_in = 3.4;

  if (internal_state_0) (in => out) = delay_state0_in_out;

  $hold( posedge in &&& internal_state_0, in, ct_state0_in_in);
  $hold( negedge in &&& internal_state_0, in, ct_state0_in_in);
endspecify

initial begin
   internal_out = 0; // All outputs start at 0
   end

always @(posedge in or negedge in)
case (state)
   0: begin
      internal_out = !internal_out;
   end
endcase

endmodule
`endcelldefine
