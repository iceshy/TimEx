@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:   4 January 2018

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_jtl\mitll_jtl.js -d .\definitions\definitions.txt -x

gtkwave tb_mitll_jtl.vcd

