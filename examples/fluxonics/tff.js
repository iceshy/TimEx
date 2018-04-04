*========================================
* TFF4
* Design: 23.05.2006 Thomas Ortlepp
* Rev. P
* new layout 21.06.2007 Thomas Ortlepp
* (c) RSFQ design group TU Ilmenau
*========================================
.SUBCKT TFF4   0    1     13 
*             GND  IN    OUT

L16 1  23 1.965pH
L17 23 24 1.372pH
L1 24   2 1.867pH
L2 2   3  1.003pH
L34 3   7 1.501pH
L5 3   5  1.436pH
L6 6  10  1.155pH
L7 10  9  4.519pH
L8 9   8  1.054pH
L9 10 11  2.383pH
L10 11 12 3.094pH
L18 12 25 1.264pH
L11 25 13 2.015pH
L12 17 0  0.153pH
L13 15 0  0.114pH
L14 16 0  0.172pH
L15 14 0  0.2pH
L23 26 0  0.2pH
L24 27 0  0.2pH

B1   2     17        jtff1
Lp1  2     31        1.08pH
RB1  31    17        1.024    

B2   8     16       jtff2
Lp2  8     91       0.9pH
RB2  91    16       0.853   

B3   6     15        jtff3
Lp3  6    110       1.08pH
RB3 110     15        1.024     

B4   7     8       jtff4
Lp4  7    51       1.22pH
RB4  51     8       1.280     

B5   5     6       jtff5
Lp5  5    111       1.5pH
RB5  111   6       1.707     

B6   11    14       jtff6
Lp6  11   114       1.22pH
RB6  114   14       1.280     

B7   23    26       jtff7
Lp7  23   234       1.08pH
RB7  234   26       1.024     

B8   25    27       jtff8
Lp8  25   254       1.08pH
RB8  254   27       1.024     


ib1  0    24        pwl (0 0 5p 360.000uA 100n 360.000uA)   
ib2  0     9        pwl (0 0 5p 310.000uA 100n 310.000uA)   
ib3  0    12        pwl (0 0 5p 260.000uA 100n 260.000uA)   

rvb1 100 191      6.94  
lvb1 191  24      10pH
rvb2 100 291      8.06  
lvb2 291   9      10pH
rvb3 100 391      9.61
lvb3 391  12      10pH
vb1  100   0      pwl (0 0 5p 2.5mV 100ns 2.5mV)   

.MODEL jtff1 JJ(RTYPE=1, ICRIT= 250.000uA CAP= 1.257PF RN=90)
.MODEL jtff2 JJ(RTYPE=1, ICRIT= 300.000uA CAP= 1.508PF RN=90)
.MODEL jtff3 JJ(RTYPE=1, ICRIT= 250.000uA CAP= 1.257PF RN=90)
.MODEL jtff4 JJ(RTYPE=1, ICRIT= 200.000uA CAP= 1.005PF RN=90)
.MODEL jtff5 JJ(RTYPE=1, ICRIT= 150.000uA CAP= 0.754PF RN=90)
.MODEL jtff6 JJ(RTYPE=1, ICRIT= 200.000uA CAP= 1.005PF RN=90)
.MODEL jtff7 JJ(RTYPE=1, ICRIT= 250.000uA CAP= 1.257PF RN=90)
.MODEL jtff8 JJ(RTYPE=1, ICRIT= 250.000uA CAP= 1.257PF RN=90)
.ENDS

*========================================
