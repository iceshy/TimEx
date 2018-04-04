******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        * 
* RSFQ generic cell for MITLL sfq5ee     *
* Authored 3 Nov 2015, CJ Fourie, SU     *
* PTL drivers and receivers added 	     *
*  8 Nov 2017, L Schindler, SU           *
******************************************
* Variables
.PARAM bias=1.0
******************************************
*                  in out
*$Ports            in_in  out_out
.SUBCKT mitll_jtlt 5      16 
B01_rx2    4          9          jjmitll100 area=1.12954
B01_tx1    13         17         jjmitll100 area=2.99256
B02_rx2    7          8          jjmitll100 area=0.78114
B1         22         27         jjmitll100 area=1.70876
B2         24         28         jjmitll100 area=2.7911
IB01_rx2   0          10         pwl(0      0 5p {0.00013666*bias})
IB01_tx1   0          19         pwl(0      0 5p {0.000177613*bias})
*IB01_rx2   0          10         pwl(0      0 5p {0.000182*bias})
*IB01_tx1   0          19         pwl(0      0 5p {0.0001826*bias})
IB1        0          29         pwl(0      0 5p {0.000375826*bias})
L01_rx2    5          4          1.55745e-013
L01_tx1    14         13         2.42846e-012
L02_rx2    4          6          2.66011e-012
L03_rx2    6          7          2.7358e-012
L03_tx1    13         15         5.34553e-012
L1         7          22         1.67852e-012     
L2         22         23         2.21087e-012     
L3         23         24         1.53456e-012     
L4         24         14         1.60936e-012     
LB1        25         0          5.88047e-013    
LB2        26         0          8.18342e-013    
LP01       23         29         2e-013   
LP01_rx2   0          9          3.4e-013
LP01_tx1   0          17         5e-014
LP02_rx2   0          8          6e-014
Lp1        27         0          1.86042e-013    
Lp2        28         0          1.49303e-013    
LPR01_rx2  6          10         2e-013
LPR01_tx1  13         19         2e-013
LRB01_rx2  0          11         5e-013
LRB01_tx1  0          18         1e-012
LRB02_rx2  0          12         1e-012
RB01_rx2   11         4          6.07318
RB01_tx1   18         13         2.29232
RB02_rx2   12         7          8.78191
RB1        22         25         4.01455    
RB2        24         26         2.45778    
RINS_tx1   15         16         1.36      
.model jjmitll100 jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_jtlt