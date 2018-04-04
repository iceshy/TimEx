@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  19 December 2017

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_dff\mitll_dff.js -d .\definitions\definitions_nobias.txt -x

gtkwave tb_mitll_dff.vcd

