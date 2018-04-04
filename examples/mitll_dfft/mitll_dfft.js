*****************************************
* Begin .SUBCKT model                   *
* spice-sdb ver 4.28.2007               *
*                                       * 
* RSFQ generic cell for MITLL sfq5ee    *
* Authored 3 Nov 2015, CJ Fourie, SU    *
* PTL drivers and receivers added 	    *
*  8 Nov 2017, L Schindler, SU          *
*****************************************
* Variables
.PARAM bias=1.0
******************************************
*                 IN_SET   CLK      OUT
*$Ports           in_set   in_clk   out_out
.SUBCKT mitll_dfft      16       7        24
*
B01_rx1    6          11         jjmitll100 area=1.4296
B01_rx2    15         18         jjmitll100 area=1.15822
B01_tx1    22         25         jjmitll100 area=2.11698
B02_rx1    9          10         jjmitll100 area=1.17084
B1         31         32         jjmitll100 area=1.63621
B2         40         53         jjmitll100 area=1.83635
B3         46         52         jjmitll100 area=1.38465
B4         33         34         jjmitll100 area=1.78693
B5         44         33         jjmitll100 area=1.3525
B6         37         38         jjmitll100 area=2.33966
B7         35         36         jjmitll100 area=2.48599
IB01_rx1   0          12         pwl(0      0 5p {0.000196297*bias})
IB01_rx2   0          19         pwl(0      0 5p {0.000145649*bias})
IB01_tx1   0          27         pwl(0      0 5p {0.000220541*bias})
IB1        0          54         pwl(0      0 5p {0.000118915*bias})
IB2        0          55         pwl(0      0 5p {0.000104335*bias})
IB3        0          56         pwl(0      0 5p {0.000121316*bias})
IB4        0          57         pwl(0      0 5p {0.00020444*bias})
L01_rx1    7          6          2.21964e-013
L01_rx2    16         15         1.97663e-013
L02_rx1    6          8          3.41696e-012
L02_rx2    15         17         3.04569e-012
L02_tx1    22         21         2.54587e-012
L03_rx1    8          9          3.22035e-012
L03_tx1    21         23         4.34282e-013
L1         17         31         2.6658e-012     
L2a        31         49         7.20671e-013    
L2b        49         40         1.56119e-012    
L3         46         50         2.0193e-012     
L3a        53         46         1.56677e-012    
L4         50         33         6.33517e-012     
L5a        33         51         3.01478e-012    
L5b        51         35         8.06625e-013    
L6         35         22         1.79977e-012     
L7         37         44         2.03318e-012     
L8         9          37         3.04627e-012     
LP01_rx1   0          11         3.4e-013
LP01_rx2   0          18         3.4e-013
LP01_tx1   0          25         5e-014
LP02_rx1   0          10         6e-014
LP1        32         0          2e-013    
LP3        52         0          2e-013    
LP4        34         0          2e-013    
LP6        38         0          2e-013    
LP7        36         0          2e-013    
LPR01_rx1  8          12         2e-013
LPR01_rx2  17         19         2e-013
LPR01_tx1  22         27         2e-013
LPR_1      49         54         2e-013  
LPR_2      50         55         2e-013  
LPR_3      51         56         2e-013  
LPR_4      37         57         2e-013  
LRB01_rx1  0          13         5e-013
LRB01_rx2  0          20         5e-013
LRB01_tx1  0          26         1e-012
LRB02_rx1  0          14         1e-012
LRB1       42         0          1e-012   
LRB2       39         53         1e-012   
LRB3       45         0          1e-012   
LRB4       47         0          1e-012   
LRB5       43         33         1e-012   
LRB6       41         0          1e-012   
LRB7       48         0          1e-012   
RB01_rx1   13         6          4.79848
RB01_rx2   20         15         5.92278
RB01_tx1   26         22         3.24042
RB02_rx1   14         9          5.85895
RB1        31         42         4.19256    
RB2        40         39         3.73561    
RB3        46         45         4.95424    
RB4        33         47         3.83894    
RB5        44         43         5.07202    
RB6        37         41         2.93201    
RB7        35         48         2.75942    
RINS_tx1   23         24         1.36      
*
*In_B01_rx1   13         6           NOISE(1.50081E-11 0.0 1p)
*In_B01_rx2   20         15          NOISE(1.66738E-11 0.0 1p)
*In_B01_tx1   26         22          NOISE(1.23331E-11 0.0 1p)
*In_B02_rx1   14         9           NOISE(1.65837E-11 0.0 1p)
*In_B1        31         42          NOISE(1.40285E-11 0.0 1p)
*In_B2        40         39          NOISE(1.32420E-11 0.0 1p)
*In_B3        46         45          NOISE(1.52497E-11 0.0 1p)
*In_B4        33         47          NOISE(1.34239E-11 0.0 1p)
*In_B5        44         43          NOISE(1.54299E-11 0.0 1p)
*In_B6        37         41          NOISE(1.17316E-11 0.0 1p) 
*In_B7        35         48          NOISE(1.13810E-11 0.0 1p)
*
.model jjmitll100 jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_dfft
*************************************************************
