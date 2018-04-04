@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  19 December 2017

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_dff\mitll_dff.js -d .\definitions\definitions_dff_jtl.txt -x
del mitll_dff_jtl.v 
rename mitll_dff.v mitll_dff_jtl.v
TimEx .\mitll_dff\mitll_dff.js -d .\definitions\definitions_dff_split.txt -x
del mitll_dff_split.v
rename mitll_dff.v mitll_dff_split.v
TimEx .\mitll_dff\mitll_dff.js -d .\definitions\definitions_dff_dff.txt -x
del mitll_dff_dff.v
rename mitll_dff.v mitll_dff_dff.v
TimEx .\mitll_dff\mitll_dff.js -d .\definitions\definitions_dff_or.txt -x
del mitll_dff_or.v
rename mitll_dff.v mitll_dff_or.v
TimEx .\mitll_dff\mitll_dff.js -d .\definitions\definitions_dff_not.txt -x
del mitll_dff_not.v
rename mitll_dff.v mitll_dff_not.v
TimEx .\mitll_dff\mitll_dff.js -d .\definitions\definitions_dff_xor.txt -x
del mitll_dff_xor.v
rename mitll_dff.v mitll_dff_xor.v

