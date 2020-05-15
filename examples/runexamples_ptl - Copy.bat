@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  4 February 2018

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_jtlt\mitll_jtlt.js -d .\definitions\definitions_ptl.txt -x

REM gtkwave tb_mitll_jtl.vcd

TimEx .\mitll_dfft\mitll_dfft.js -d .\definitions\definitions_ptl.txt -x
TimEx .\mitll_splittert\mitll_splittert.js -d .\definitions\definitions_ptl.txt -x
TimEx .\mitll_ort\mitll_ort.js -d .\definitions\definitions_ptl.txt -x
TimEx .\mitll_andt\mitll_andt.js -d .\definitions\definitions_ptl.txt -x
TimEx .\mitll_xort\mitll_xort.js -d .\definitions\definitions_ptl_largerpulses.txt -x

