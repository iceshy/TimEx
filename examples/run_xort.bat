@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:   1 February 2018

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_xort\mitll_xort.js -d .\definitions\definitions_ptl.txt -x

gtkwave tb_mitll_xort.vcd

