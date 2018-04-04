@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  19 December 2017

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_dfft\mitll_dfft.js -d .\definitions\definitions_ptl.txt -x

gtkwave tb_mitll_dfft.vcd

