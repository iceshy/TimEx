@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  19 December 2017

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_jtl\mitll_jtl.js -d .\definitions\definitions_nobias.txt -x

REM gtkwave tb_mitll_jtl.vcd

TimEx .\mitll_dff\mitll_dff.js -d .\definitions\definitions_nobias.txt -x
TimEx .\mitll_splitter\mitll_splitter.js -d .\definitions\definitions_nobias.txt -x
TimEx .\mitll_or\mitll_or.js -d .\definitions\definitions_nobias.txt -x
TimEx .\mitll_and\mitll_and.js -d .\definitions\definitions_nobias.txt -x
TimEx .\mitll_xor\mitll_xor.js -d .\definitions\definitions_nobias.txt -x
TimEx .\mitll_ndro\mitll_ndro.js -d .\definitions\definitions_nobias.txt -x
TimEx .\mitll_ndo\mitll_ndo.js -d .\definitions\definitions_nobias.txt -x
TimEx .\mitll_not\mitll_not.js -d .\definitions\definitions_nobias.txt -x

REM Examples that show extreme cases

REM dff_old has an error state
REM TimEx .\mitll_dff_old\mitll_dff_old.js -d definitions.txt -x

REM xor_fail_5states enters stage 4 and 5 when either INA or INB is fired twice in a clock period
REM   this requires two clocks to return to initial state, leading to 2 outputs instead of 1
REM TimEx .\mitll_xor_fail_5states\mitll_xor_fail_5states.js -d definitions.txt -x
