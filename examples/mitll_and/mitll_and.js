******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* Authored 1 March 2016, JA Delport, SU  *
* Modified 9 Oct 2016, CJ Fourie, SU     *
*   (optmized)                           *
* Last mod 31 Jan 2018, CJ Fourie, SU    *
*   (added bias parameterization)        * 
******************************************
*$Parameters
*IT=1.11e-3
*$EndP
******************************************
* Variables
.PARAM bias=1.0
******************************************
*                 IN_A   IN_B   CLK     OUT
*$Ports           in_a   in_b   in_clk  out_out
.SUBCKT gen_and   2      40     14      32 
*
*==============  Begin SPICE netlist of main design ============
B01        6          12         jmitll     area=1.21
B02        44         49         jmitll     area=1.21
B03        7          24         jmitll     area=1.05
B04        50         45         jmitll     area=1.05
B05        25         26         jmitll     area=1.5
B06        26         51         jmitll     area=1.5
B07        27         28         jmitll     area=1.5
B08        18         23         jmitll     area=1.38
B09        30         31         jmitll     area=2.25
B10        3          11         jmitll     area=1.755
B11        41         48         jmitll     area=1.755
B12        1          9          jmitll     area=2.175
B13        39         47         jmitll     area=2.175
B14        15         22         jmitll     area=1.265
B15        13         21         jmitll     area=2.175
IB01       0          8          pwl(0      0 5p {120u*bias})
IB02       0          46         pwl(0      0 5p {120u*bias})
IB03       0          33         pwl(0      0 5p {70u*bias})
IB05       0          34         pwl(0      0 5p {230u*bias})
IB06       0          52         pwl(0      0 5p {230u*bias})
IB07       0          20         pwl(0      0 5p {120u*bias})
IB08       0          57         pwl(0      0 5p {220u*bias})
L01        7          25         2.844p    
L02        51         45         2.904p    
L03        3          5          2.054p    
L04        41         43         2.057p    
L05        19         24         2.132p    
L06        50         19         2.171p    
L07        17         18         1.924p    
L08        27         29         0.039p    
L09        29         30         2.6p      
L10        30         32         2.47p     
L11        4          3          2.5375p   
L12        42         41         2.4p      
L13        2          1          2p        
L14        40         39         2p        
L15        5          6          9.521p    
L16        43         44         9.547p    
L17        14         13         2p        
L18        16         15         2.511p    
L19        15         17         0.239p    
L20        26         27         0.499p    
L21        6          7          0.148p    
L22        44         45         0.179p    
L23        18         19         0.01p     
L24        1          4          2.5375p   
L25        39         42         2.4p      
L26        13         16         2.511p    
LP01       0          12         0.255p    
LP02       0          49         0.229p    
LP07       0          28         0.299p    
LP08       0          23         0.211p    
LP09       0          31         0.174p    
LP10       0          11         0.221p    
LP11       0          48         0.203p    
LP12       0          9          0.203p    
LP13       0          47         0.195p    
LP14       0          22         0.187p    
LP15       0          21         0.19p     
LPR1       5          8          0.013p    
LPR2       43         46         0.01p     
LPR3       29         33         1.901p    
LPR4       17         20         0.85p     
LPR5       4          34         0.166p    
LPR6       42         52         0.172p    
LPR8       16         57         0.166p    
LRB01      36         12         1p        
LRB02      55         49         1p        
LRB03      37         24         1p        
LRB04      50         56         1p        
LRB05      38         26         1p        
LRB06      26         61         1p        
LRB07      62         28         1p        
LRB08      60         23         1p        
LRB09      63         31         1p        
LRB10      35         11         1p        
LRB11      54         48         1p        
LRB12      10         9          1p        
LRB13      53         47         1p        
LRB14      59         22         1p        
LRB15      58         21         1p        
RB01       36         6          7.8       
RB02       55         44         7.8       
RB03       37         7          9.6       
RB04       45         56         9.6       
RB05       38         25         6.5       
RB06       51         61         6.5       
RB07       62         27         6.5       
RB08       60         18         6.7       
RB09       63         30         4.3       
RB10       35         3          5.5       
RB11       54         41         5.5       
RB12       10         1          4.4       
RB13       53         39         4.4       
RB14       59         15         7.7       
RB15       58         13         4.4       
.model jmitll jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends gen_and
*******************************
