# TimEx
Netlist-to-Verilog extraction for SFQ circuits

TimEx was developed under IARPA contracts FA8750-15-C-0203-IARPA-BAA-14-03 and SuperTools/ColdFlux (via the U.S. Army Research Office grant W911NF-17-1-0120).

TimEx takes a JSIM deck file as the first command line parameter and considers this as the Device-Under-Test (DUT). The DUT needs to be described as a subcircuit in the deck file, and input and output ports must be specified. TimEx then constructs a simulation test bench consisting of specified load cells at each input and output as well as specified source and sink cells.

Through the variation of input sequences, all states and all input-to-output delays for the DUT are found. Critical Timing parameters and illegal inputs are then identified through iterative methods, and a Verilog model of the DUT is constructed that defines all states, output delay times and critical timing parameters. A Verilog test bench is also created to verify the operation of the DUT model.

TimEx also writes a .gv file (the DOT format) for viewing a Mealy Finite State Machine diagram of the DUT with GraphViz.
