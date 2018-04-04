@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:   25 January 2018

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx jtl_vc100.js -d definitions.txt -x
REM TimEx jtl_vc075.js -d definitions.txt -x
REM TimEx jtl_vc050.js -d definitions.txt -x

