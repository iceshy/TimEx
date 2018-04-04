*=========================================
*  JTL2c  JeSEF Technology 
*  27.05.2004 Thomas Ortlepp
*  01.07.2004 resistor shift
*  25.05.2005 bias level 0.7
*  19.12.2011 InductEx extraction by Coenrad Fourie
* (c) RSFQ design group TU Ilmenau
*=========================================
*$Ports      in_in  out_out
.SUBCKT JTL  1      2
L1  1      4        2.080pH
L2  4      8        2.059pH
L3  8      5        2.059pH
L4  5      2        2.080pH
B1   4      6       jjtl1
RB1  4      9       1.0  
Lp1  9      6       1.0pH
L6   6      0       0.214pH
B2   5      7       jjtl2
RB2  5     10       1.0  
Lp2 10      7       1.0pH
L7   7      0       0.214pH
* Bias source 2.5mV and 7.41 Ohm
ib1  0     8        pwl (0 0 5p 350uA 100n 350uA)   
.MODEL jjtl1 JJ(RTYPE=0, ICRIT= 250uA CAP=1.262PF RN=90)
.MODEL jjtl2 JJ(RTYPE=0, ICRIT= 250uA CAP=1.262PF RN=90)
.ENDS
*========================================
