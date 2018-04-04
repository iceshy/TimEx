******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* Authored 1 March 2016, JA Delport, SU  *
* Modified 4 Nov 2016, CJ Fourie, SU     *
*   (Added B10, optimized)               *
* Last mod 31 Jan 2018, CJ Fourie, SU    *
*   (added bias parameterization)        * 
******************************************
*$Parameters
*IT=870e-6
*$EndP
******************************************
* Variables
.PARAM bias=1.0
******************************************
*                 IN_A   IN_B   CLK   OUT
*$Ports          in_a  in_b  in_clk  out_out
.SUBCKT mitll_or 26     28   12      9 
*==============  Begin SPICE netlist of main design ============
B01        18         19         jmitll     area=2.5
B02        18         22         jmitll     area=2
B03        20         21         jmitll     area=2.5
B04        20         23         jmitll     area=2
B05        24         25         jmitll     area=3
B06        11         13         jmitll     area=2.6
B07        15         2          jmitll     area=2
B08        1          3          jmitll     area=2
B09        6          7          jmitll     area=2.5
B10        35         24         jmitll     area=3.25
IB01       0          29         pwl(0      0 5p {440u*bias})
IB02       0          10         pwl(0      0 5p {110u*bias})
IB03       0          16         pwl(0      0 5p {200u*bias})
IB04       0          5          pwl(0      0 5p {120u*bias})
L01        26         18         3p        
L02        22         27         1.9p      
L03        28         20         3p        
L04        23         27         1.9p      
L05        27         29         0.6p      
L06        29         35         2.1p      
L07        24         10         0.4p      
L08        10         2          7.362p    
L09        2          1          2.27p     
L10        16         15         1.43p     
L11        11         16         3.13p     
L12        12         11         2.5p      
L13        1          5          3.2p      
L14        5          6          1.1p      
L15        6          9          3.291p    
LP01       19         0          0.2p      
LP03       21         0          0.2p      
LP05       25         0          0.2p      
LP06       0          13         0.122p    
LP08       0          3          0.117p    
LP09       0          7          0.151p    
LRB01      31         19         1p        
LRB02      33         22         1p        
LRB03      30         21         1p        
LRB04      34         23         1p        
LRB05      32         25         1p        
LRB06      14         13         1p        
LRB07      17         2          1p        
LRB08      4          3          1p        
LRB09      8          7          1p        
LRB10      36         24         1p        
RB01       18         31         3.88      
RB02       18         33         4.85      
RB03       20         30         3.88      
RB04       20         34         4.85      
RB05       24         32         3.23      
RB06       14         11         3.73      
RB07       17         15         4.85      
RB08       4          1          4.85      
RB09       8          6          3.88      
RB10       35         36         2.98      
.model jmitll jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_or
*******************************
