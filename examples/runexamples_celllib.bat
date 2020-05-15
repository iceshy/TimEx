@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  15 May 2020

REM You need in the path: josim, iverilog and vvp

@ECHO ON

TimEx .\lib115\NOTT.cir -d .\definitions\definitions_ptl.txt -x
TimEx .\lib115\NDROT.cir -d .\definitions\definitions_ptl.txt -x
