@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  27 December 2017

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_and\mitll_and.js -d .\definitions\definitions.txt -x

REM gtkwave tb_mitll_and.vcd

