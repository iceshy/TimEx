*******************************
* Begin .SUBCKT model         *
* spice-sdb ver 4.28.2007     *
*******************************
* Variables
.PARAM bias=1.0
******************************************
*			INA INB CLK OUT
*$Ports in_A in_B in_CLK out_out
.SUBCKT mitll_xort 59 16 7 26 
*==============  Begin SPICE netlist of main design ============
B01        43         44         jmitll     area=2.3
B01_rx1    6          11         jmitll     area=1
B01_rx2    58         63         jmitll     area=1
B01_rx3    15         20         jmitll     area=1
B02_rx1    9          10         jmitll     area=1
B02_rx2    61         62         jmitll     area=1
B02_rx3    18         19         jmitll     area=1
B02_tx1    25         27         jmitll     area=1.62
B03        43         72         jmitll     area=1.69
B03_rx1    34         74         jmitll     area=1
B03_rx2    52         78         jmitll     area=1
B03_rx3    53         76         jmitll     area=1
B04        41         42         jmitll     area=2.3
B06        41         70         jmitll     area=1.69
B07        37         36         jmitll     area=1.45
B08        38         39         jmitll     area=1.63
B09        33         40         jmitll     area=1.69
B10        33         45         jmitll     area=2.17
IB01       0          51         pwl(0      0 5p 0.0000751355)
IB01_rx1   0          12         pwl(0      0 5p 0.000155)
IB01_rx2   0          64         pwl(0      0 5p 0.000155)
IB01_rx3   0          21         pwl(0      0 5p 0.000155)
IB02       0          54         pwl(0      0 5p 0.0000751355)
IB02_tx1   0          29         pwl(0      0 5p 8.2e-005)
IB04       0          73         pwl(0      0 5p 0.000157547)
IB05       0          50         pwl(0      0 5p 0.00018)
L01_rx1    7          6          2e-013
L01_rx2    59         58         2e-013
L01_rx3    16         15         2e-013
L02_rx1    6          8          2e-012
L02_rx2    58         60         2e-012
L02_rx3    15         17         2e-012
L03        72         71         2.60547e-012    
L03_rx1    8          9          2e-012
L03_rx2    60         61         2e-012
L03_rx3    17         18         2e-012
L03_tx1    25         24         3.5e-013
L04_rx1    9          34         2e-012
L04_rx2    61         52         2e-012
L04_rx3    18         53         2.76641e-012
L06        70         71         2.6e-012    
L08        71         36         1.9e-012    
L09        37         38         1.422e-012    
L10        38         40         3.07e-012    
L11        34         33         2.436e-012    
L12        38         25         4.047e-012    
L14        52         43         2e-012    
L15        53         41         2e-012    
LP01       0          44         1.3e-013   
LP01_rx1   0          11         3.4e-013
LP01_rx2   0          63         3.4e-013
LP01_rx3   0          20         3.4e-013
LP02_rx1   0          10         6e-014
LP02_rx2   0          62         6e-014
LP02_rx3   0          19         6e-014
LP02_tx1   0          27         1.2e-013
LP03       0          42         1.27e-013   
LP03_rx1   0          74         3e-014
LP03_rx2   0          78         3e-014
LP03_rx3   0          76         3e-014
LP05       0          39         3.07e-013   
LP06       0          45         1.59e-013   
LPR01      43         51         2.11e-013  
LPR01_rx1  8          12         2e-013
LPR01_rx2  60         64         2e-013
LPR01_rx3  17         21         2e-013
LPR02      41         54         2.11e-013  
LPR02_tx1  25         29         1.3e-012
LPR04      73         71         3.61e-013  
LPR05      33         50         2.08e-013  
LRB01      0          47         1e-012  
LRB01_rx1  0          13         5e-013
LRB01_rx2  0          65         5e-013
LRB01_rx3  0          22         5e-013
LRB02_rx1  0          14         1e-012
LRB02_rx2  0          66         1e-012
LRB02_rx3  0          23         1e-012
LRB02_tx1  0          28         1e-012
LRB03      68         72         1e-012  
LRB03_rx1  0          75         1e-012
LRB03_rx2  0          79         1e-012
LRB03_rx3  0          77         1e-012
LRB04      0          48         1e-012  
LRB06      69         70         1e-012  
LRB07      35         37         1e-012  
LRB08      0          49         1e-012  
LRB09      55         33         1e-012  
LRB10      0          46         1e-012  
RB01       47         43         2.07876   
RB01_rx1   13         6          6.8599
RB01_rx2   65         58         6.8599
RB01_rx3   22         15         6.8599
RB02_rx1   14         9          6.8599
RB02_rx2   66         61         6.8599
RB02_rx3   23         18         6.8599
RB02_tx1   28         25         4.23451
RB03       68         43         4.05912   
RB03_rx1   75         34         6.8599
RB03_rx2   79         52         6.8599
RB03_rx3   77         53         6.8599
RB04       48         41         2.07876   
RB06       69         41         4.05912   
RB07       36         35         3.70806   
RB08       49         38         4.20853   
RB09       40         55         4.05912   
RB10       46         33         3.16125   
RINS_tx1   24         26         1.36      
.model jmitll jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_xort
********************************************************
