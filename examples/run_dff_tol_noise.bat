@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  27 February 2018

REM Considers process tolerances and noise

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_dff_tol_noise\mitll_dff.js -d .\definitions\definitions_tol_noise.txt -x


