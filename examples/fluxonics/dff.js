*========================================
* DFF5b with 7 junctions
* Thomas Ortlepp 
* 9.11.2007 Rel. Q
* (c) RSFQ design group TU Ilmenau
*========================================
.SUBCKT DFF   0    1    11    8
*            GND  D_IN  CLK  D_OUT

L1   1     2         2.003pH
L2a  2     23        0.994pH
L2b  23    3         1.912pH
L3   4     5         1.503pH
L4   5     6         5.913pH
L5a  6     67        3.045pH
L5b  67    7         0.932pH
L6   7     8         2.034pH
L7   9     10        2.771pH
L8   11    10        2.163pH

B1   2     16        jjtr1
RB1  2     101       1.024  
LB1  101   16        1.0pH
Lp1  16    0         0.22pH

B2   3     4         jjtr2
RB2  3     201       0.931   
LB2  201   4         0.977pH

B3   4     17        jjtr3
RB3  4     301       1.280  
LB3  301   17        1.093pH
Lp3  17    0         0.049pH

B4   6     18        jjtr4
RB4  6     401       1.280   
LB4  401   18        1.093pH
Lp4  18    0         0.181pH

B5   9     6         jjtr5
RB5  9     501       1.707   
LB5  501   6         1.235pH

B6   10    20        jjtr6
RB6  10    601       1.024  
LB6  601   20        1.0pH
Lp6  20    0         0.115pH

B7   7     19        jjtr7
RB7  7     701       1.024  
LB7  701   19        1.0pH
Lp7  19     0        0.155pH

rvb1 100 191      9.62  
lvb1 191   23      10pH
rvb2 100 291      26.04  
lvb2 291   5      10pH
rvb3 100 391      15.34 
lvb3 391   67      10pH
rvb4 100 491      17.48  
lvb4 491   10      10pH
vb1  100   0      pwl (0 0 5p 2.5mV 100ns 2.5mV)   

.MODEL jjtr1 JJ(RTYPE=1, ICRIT= 250.000uA CAP= 1.257PF RN=90)
.MODEL jjtr2 JJ(RTYPE=1, ICRIT= 275.000uA CAP= 1.382PF RN=90)
.MODEL jjtr3 JJ(RTYPE=1, ICRIT= 200.000uA CAP= 1.005PF RN=90)
.MODEL jjtr4 JJ(RTYPE=1, ICRIT= 200.000uA CAP= 1.005PF RN=90)
.MODEL jjtr5 JJ(RTYPE=1, ICRIT= 150.000uA CAP= 0.754PF RN=90)
.MODEL jjtr6 JJ(RTYPE=1, ICRIT= 250.000uA CAP= 1.257PF RN=90)
.MODEL jjtr7 JJ(RTYPE=1, ICRIT= 250.000uA CAP= 1.257PF RN=90)

.ENDS
*========================================
