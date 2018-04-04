******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* Authored 1 March 2016, JA Delport, SU  *
* Modified 4 Nov 2016, CJ Fourie, SU     *
* PTL drivers and receivers added 		 *
*  8 Nov 2017, L Schindler, SU           *
* Last mod 04 Feb 2018, CJ Fourie, SU    *
*   (TimEx support and Bias variable)    *
******************************************
* Variables
.PARAM bias=1.0
******************************************
*                  IN_A   IN_B   CLK     OUT
*$Ports            in_a   in_b   in_clk  out_out
.SUBCKT mitll_ort  55     62     5       17 
B01        32         33         jmitll     area=2.12585708
B01_rx1    4          9          jmitll     area=1.20323690
B01_rx2    42         56         jmitll     area=1.09849378
B01_rx3    40         63         jmitll     area=9.44861039e-01
B01_tx1    13         18         jmitll     area=1.91546871
B02        32         36         jmitll     area=1.36437275 
B02_rx1    7          8          jmitll     area=1.07937264
B03        34         35         jmitll     area=1.79686016
B04        34         37         jmitll     area=1.29977250
B05        38         39         jmitll     area=2.30013287 
B08        23         24         jmitll     area=1.43242277
B09        27         28         jmitll     area=1.39304606
B10        50         38         jmitll     area=2.51587814
IB01       0          49         pwl(0      0 5p {3.45002039e-04*bias})
IB01_rx1   0          10         pwl(0      0 5p {1.02633911e-04*bias})
IB01_rx2   0          57         pwl(0      0 5p {1.12559401e-04*bias})
IB01_rx3   0          64         pwl(0      0 5p {1.29362864e-04*bias})
IB01_tx1   0          20         pwl(0      0 5p {9.94964506e-05*bias})
IB02       0          31         pwl(0      0 5p {8.77034784e-05*bias})
IB04       0          52         pwl(0      0 5p {8.64511885e-05*bias})
L01        40         32         3.62017554e-12    
L01_rx1    5          4          1.63575366e-13
L01_rx2    55         42         1.76261290e-13
L01_rx3    62         40         1.94690888e-13
L01_tx1    14         13         2.47318157e-12
L02        36         41         1.85526397e-12    
L02_rx1    4          6          4.63853242e-12
L02_tx1    13         15         2.98154694e-12
L03        42         34         2.94098429e-12    
L03_rx1    6          7          2.82716333e-12
L03_tx1    15         16         3.20488846e-13
L04        37         41         1.70899205e-12    
L05        41         43         4.96373066e-13    
L06        43         50         2.28747983e-12    
L07        38         30         3.35330406e-13    
L08        30         8          9.50214447e-12    
L09        8          23         1.01824046e-12    
L13        23         26         2.07860894e-12    
L14        26         27         1.01340568e-12    
L15        27         14         2.82308943e-12     
LP01       33         0          2e-13   
LP01_rx1   0          9          3.4e-13
LP01_rx2   0          56         3.4e-13
LP01_rx3   0          63         3.4e-13
LP01_tx1   0          18         5e-14
LP03       35         0          2e-13  
LP05       39         0          2e-13  
LP08       0          24         1.17e-13 
LP09       0          28         1.51e-13   
LP_IB01    43         49         0.2p
LP_IB02    30         31         0.2p
LP_IB04    26         52         0.2p
LPR01_rx1  6          10         2e-13
LPR01_rx2  42         57         2e-13
LPR01_rx3  40         64         2e-13
LPR01_tx1  13         20         2e-13
LRB01      45         0          1e-12 
LRB01_rx1  0          11         5e-13 
LRB01_rx2  0          58         5e-13 
LRB01_rx3  0          65         5e-13 
LRB01_tx1  0          19         1e-12
LRB02      47         36         1e-12  
LRB02_rx1  8          12         1e-12
LRB03      44         0          1e-12
LRB04      48         37         1e-12
LRB05      46         0          1e-12
LRB08      25         0          1e-12
LRB09      29         0          1e-12
LRB10      51         38         1e-12
RB01       32         45         3.227   
RB01_rx1   11         4          5.70
RB01_rx2   58         42         6.2448
RB01_rx3   65         40         7.26
RB01_tx1   19         13         3.58
RB02       32         47         5.03
RB02_rx1   12         7          6.36
RB03       34         44         3.82
RB04       34         48         5.28
RB05       38         46         2.98
RB08       25         23         4.79
RB09       29         27         4.92   
RB10       50         51         2.73
RINS_tx1   16         17         1.36      
.model jmitll jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mittl_ort