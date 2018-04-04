*=========================================
*  DCSFQ  JeSEF Technology 
*  26.04.2004 Thomas Ortlepp new
*  11.05.2004 small modifications T.O.
*  02.07.2004 Version for Release M
*  15.02.2005 Version 2
*  16.11.2005 Thomas Ortlepp modification
*  input current: 650uA pulse
* (c) RSFQ design group TU Ilmenau
*=============================================
.SUBCKT DCSFQ  0  30  2

L10 30     3        0.1pH
L1  3      0        3.904pH
L2a  3      4       0.604H
L2b  11    5        1.126pH
L3  5      6        4.484pH
L4  6      7        0.000pH
L5  7      2        2.080pH

B1   11    4        jdcsfq1
RB1  4     51       1.111   
Lp1  51    11        1.037pH

B2   5     8        jdcsfq2
RB2  5     81       1.111   
Lp2  81    8        1.037pH
L6   8     0        0.198pH

B3   7      9       jdcsfq3
RB3  7     91       1.000 
Lp3  91     9       1.0pH
L7   9      0       0.110pH

ib1  0     11       pwl (0 0 5p 275.000uA 100n 275.000uA)   
ib2  0     7       pwl (0 0 5p 175.000uA 100n 175.000uA)   

rvb1 100 101      9.09  
lvb1 101  11      10pH
rvb2 100 102     14.29  
lvb2 102   7      10pH
vb1  100   0      pwl (0 0 5p @X mV 100ns @X mV)   


.MODEL jdcsfq1 JJ(RTYPE=0, ICRIT= 225.000uA CAP= 1.186PF RN=90)
.MODEL jdcsfq2 JJ(RTYPE=0, ICRIT= 225.000uA CAP= 1.186PF RN=90)
.MODEL jdcsfq3 JJ(RTYPE=0, ICRIT= 250.000uA CAP= 1.318PF RN=90)
.ENDS
*========================================
