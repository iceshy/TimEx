@ECHO OFF

REM run example sequence for TimEx
REM Author:     Coenrad Fourie
REM Last mod:   12 February 2018

REM You need in the path: jsim_n, iverilog and vvp

@ECHO ON

TimEx .\jtl_delay\jtl_vc100.js -d .\definitions\definitions_delay.txt -c -x
copy jtl_vc100.v jtl_vc100_contained.v
TimEx .\jtl_delay\jtl_vc100.js -d .\definitions\definitions_delay.txt -x
TimEx .\jtl_delay\jtl_vc075.js -d .\definitions\definitions_delay.txt -c -x
copy jtl_vc075.v jtl_vc075_contained.v
TimEx .\jtl_delay\jtl_vc075.js -d .\definitions\definitions_delay.txt -x
TimEx .\jtl_delay\jtl_vc050.js -d .\definitions\definitions_delay.txt -c -x
copy jtl_vc050.v jtl_vc050_contained.v
TimEx .\jtl_delay\jtl_vc050.js -d .\definitions\definitions_delay.txt -x

