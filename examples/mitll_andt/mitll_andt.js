******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* Authored 1 March 2016, JA Delport, SU  *
* Modified 16 Oct 2016, CJ Fourie, SU    *
*   (Optimized)  						 *
* PTL drivers and receivers added 		 *
*  8 Nov 2017, L Schindler, SU           *
* Last mod 01 Feb 2018, CJ Fourie, SU    *
*   (TimEx support and Bias variable) 	 *
******************************************
* Variables
.PARAM bias=1.0
******************************************
*		        	INA  INB  CLK    OUT
*$Ports             in_A in_B in_CLK out_out
.subckt mitll_and   12   29   7      19
*==============  Begin SPICE netlist of main design ============
B01        36         40         jmitll     area=1.28357
B01_rx1    6          8          jmitll     area=0.971493
B01_rx2    11         13         jmitll     area=1.14285
B01_rx3    28         30         jmitll     area=1.03637
B01_tx1    16         20         jmitll     area=1.80396
B02        63         67         jmitll     area=1.03052
B03        37         48         jmitll     area=1.09857
B04        68         64         jmitll     area=0.949829
B05        49         50         jmitll     area=1.26652
B06        50         69         jmitll     area=1.39233
B07        51         52         jmitll     area=1.06489
B08        43         47         jmitll     area=1.09899
B09        54         55         jmitll     area=2.04878
B10        34         39         jmitll     area=1.7939
B11        61         66         jmitll     area=2.13491
B14        41         46         jmitll     area=0.964065
IB01       0          38         pwl(0      0 5p {9.01959e-005*bias})
IB01_rx1   0          9          pwl(0      0 5p {0.000138118*bias})
IB01_rx2   0          14         pwl(0      0 5p {0.000153047*bias})
IB01_rx3   0          31         pwl(0      0 5p {0.000126252*bias})
IB01_tx1   0          22         pwl(0      0 5p {0.000191804*bias})
IB02       0          65         pwl(0      0 5p {0.000108526*bias})
IB03       0          56         pwl(0      0 5p {5.9829e-005*bias})
IB07       0          45         pwl(0      0 5p {0.000103119*bias})
L01        37         49         2.56014e-012    
L01_rx1    7          6          2.05436e-013
L01_rx2    12         11         2.69941e-013
L01_rx3    29         28         2.14785e-013
L01_tx1    17         16         1.78236e-012
L02        69         64         3.04871e-012    
L02_tx1    16         18         2.19509e-012
L03        34         35         2.09255e-012    
L04        61         62         1.6372e-012    
L05        44         48         2.38769e-012    
L06        68         44         1.93249e-012    
L07        42         43         1.46749e-012    
L08        51         53         3.78682e-014    
L09        53         54         2.84422e-012    
L10        54         17         2.21176e-012    
L13        28         34         2.37702e-012    
L14        11         61         2.10171e-012    
L15        35         36         9.0928e-012    
L16        62         63         9.60782e-012    
L17        6          41         2.13896e-012    
L19        41         42         2.44493e-013    
L20        50         51         4.81276e-013    
L21        36         37         1.88674e-013    
L22        63         64         1.95753e-013    
L23        43         44         6.53629e-015    
LP01       0          40         2.55e-013   
LP01_rx1   0          8          3.4e-013
LP01_rx2   0          13         3.4e-013
LP01_rx3   0          30         3.4e-013
LP01_tx1   0          20         5e-014
LP02       0          67         2.29e-013   
LP07       0          52         2.99e-013   
LP08       0          47         2.11e-013   
LP09       0          55         1.74e-013   
LP10       0          39         2.21e-013   
LP11       0          66         2.03e-013   
LP14       0          46         1.87e-013   
LPR01_rx1  6          9          2e-013
LPR01_rx2  11         14         2e-013
LPR01_rx3  28         31         2e-013
LPR01_tx1  16         22         2e-013
LPR1       35         38         1.3e-014   
LPR2       62         65         1e-014   
LPR3       53         56         1.901e-012   
LPR4       42         45         8.5e-013   
LRB01      58         0          1e-012  
LRB01_rx1  0          10         5e-013
LRB01_rx2  0          15         5e-013
LRB01_rx3  0          32         5e-013
LRB01_tx1  0          21         1e-012
LRB02      71         0          1e-012  
LRB03      59         48         1e-012  
LRB04      68         72         1e-012  
LRB05      60         50         1e-012  
LRB06      50         75         1e-012  
LRB07      76         0          1e-012  
LRB08      74         0          1e-012  
LRB09      77         0          1e-012  
LRB10      57         0          1e-012  
LRB11      70         0          1e-012  
LRB14      73         0          1e-012  
RB01       58         36         5.34439   
RB01_rx1   10         6          7.0612
RB01_rx2   15         11         6.00247
RB01_rx3   32         28         6.61914
RB01_tx1   21         16         3.80269
RB02       71         63         6.65674   
RB03       59         37         6.24441   
RB04       64         72         7.22225   
RB05       60         49         5.41633   
RB06       69         75         4.92693   
RB07       76         51         6.44186   
RB08       74         43         6.24199   
RB09       77         54         3.34828   
RB10       57         34         3.82401   
RB11       70         61         3.21321   
RB14       73         41         7.1156   
RINS_tx1   18         19         1.36      
.model jmitll jj(rtype=1, vg=2.6mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_andt