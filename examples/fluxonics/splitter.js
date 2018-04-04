*=========================================
*  Splitter  JeSEF Technology 
*  25.05.2004 Thomas Ortlepp new
*  05.07.2004 final version
*  14.11.2005 check for Rev-O: final version Thomas Ortlepp
* (c) RSFQ design group TU Ilmenau
*=========================================
.SUBCKT SPLITTER  0   11   1    7 
*               GND IN1  Out1  Out2
L1  1      2        2.003pH
L2  2      4        1.898pH
L3  4      8        0.364pH
L4  8      10       1.958pH
L5  11     10       1.387pH
L6  4      5        1.874pH
L7  7      5        2.003pH

B1   10    12       jspl1
Lp1  10    110      0.923pH
RB1  110   12       0.788 
L10 12     0        0.222pH

B2   2     3       jspl2
Lp2  2     31      1.0pH
RB2  31    3       1.024 
L8   3     0       0.222pH

B3   5     6       jspl3
Lp3  5     61      1.0pH
RB3  61    6       1.024 
L9   6     0       0.211pH

rvb1 300 301      4.4  
lvb1 301   8      10pH
vb1  300   0      pwl (0 0 5p 2.5mV 100ns 2.5mV)   

.MODEL jspl1 JJ(RTYPE=0, ICRIT= 325.000uA CAP= 1.634PF RN=90)
.MODEL jspl2 JJ(RTYPE=0, ICRIT= 250.000uA CAP= 1.257PF RN=90)
.MODEL jspl3 JJ(RTYPE=0, ICRIT= 250.000uA CAP= 1.257PF RN=90)
.ENDS
*=========================================
