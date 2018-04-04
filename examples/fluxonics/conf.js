*=========================================
*  CONF  JeSEF Technology 
*  02.07.2004 Thomas Ortlepp: new design
*  10.11.2005 Thomas Ortlepp: new design
* (c) RSFQ design group TU Ilmenau
*=========================================
*=========================================
.SUBCKT CONFBUF   0   1    7    9 
*               GND IN1  IN2   OUT
******************************************
L1  1     2        2.007pH
L2  3     4        0.827pH
L3  7     6        2.028pH
L4  5     4        0.832pH
L5  14    8        1.772pH
L6  9     8        1.966pH
L11 4      14      0.270pH

L8  11     0        0.191pH
L9  12     0        0.188pH
L10 13     0        0.203pH

B1   2     11       jjtoa
Lp1  11   111       1.0pH
RB1  111    2       1.024 
B2   3     2        jjtob
Lp2  2    102       1.08pH
RB2  102    3       1.280 
B3   6     12       jjtoc
Lp3  12    112      1.0pH
RB3  112    6       1.024 
B4   5     6        jjtod
Lp4  6    106       1.08pH
RB4  106    5       1.280 
B5   8     13       jjtoe
Lp5  13    113      0.94pH
RB5  113    8       0.853 

rvb1 100 101      4.54  
lvb1 101   14      10pH
vb1  100   0      pwl (0 0 5p 2.5mV 100ns 2.5mV)   

.MODEL jjtoa JJ(RTYPE=0, ICRIT=250.000uA CAP=1.257PF RN=90)
.MODEL jjtob JJ(RTYPE=0, ICRIT=200.000uA CAP=1.005PF RN=90)
.MODEL jjtoc JJ(RTYPE=0, ICRIT=250.000uA CAP=1.257PF RN=90)
.MODEL jjtod JJ(RTYPE=0, ICRIT=200.000uA CAP=1.005PF RN=90)
.MODEL jjtoe JJ(RTYPE=0, ICRIT=300.000uA CAP=1.508PF RN=90)
.ENDS
*========================================
