@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:  19 December 2017

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\mitll_dfft\mitll_dfft.js -d .\definitions\definitions_dfft_jtlt.txt -x
del mitll_dfft_jtlt.v 
rename mitll_dfft.v mitll_dfft_jtlt.v
TimEx .\mitll_dfft\mitll_dfft.js -d .\definitions\definitions_dfft_splitt.txt -x
del mitll_dfft_splitt.v
rename mitll_dfft.v mitll_dfft_splitt.v
TimEx .\mitll_dfft\mitll_dfft.js -d .\definitions\definitions_dfft_dfft.txt -x
del mitll_dfft_dfft.v
rename mitll_dfft.v mitll_dfft_dfft.v
TimEx .\mitll_dfft\mitll_dfft.js -d .\definitions\definitions_dfft_ort.txt -x
del mitll_dfft_ort.v
rename mitll_dfft.v mitll_dfft_ort.v
TimEx .\mitll_dfft\mitll_dfft.js -d .\definitions\definitions_dfft_xort.txt -x
del mitll_dfft_xort.v
rename mitll_dfft.v mitll_dfft_xort.v

