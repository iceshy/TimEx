******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* Authored 5 March 2016, JA Delport, SU  *
* Modified 28 Nov 2016, CJ Fourie, SU    *
*   (Deleted current sources, altered    *
*    circuit to make functional;         *
*    optimized)                          *
* Last mod 31 Jan 2018, CJ Fourie, SU    *
*   (added bias parameterization)        * 
******************************************
*$Parameters
*IT=675e-6
*$EndP
******************************************
* Variables
.PARAM bias=1.0
******************************************
*                 IN_IN    CLK     OUT
*$Ports           in_in    in_clk  out_out
.SUBCKT mitll_not 34       2       22 
*==============  Begin SPICE netlist of main design ============
B01        14         15         jmitll     area=1.85
B02        10         12         jmitll     area=1.1
B03        23         10         jmitll     area=1.35
B04        5          6          jmitll     area=1.21
B05        7          8          jmitll     area=1.05
B06        17         18         jmitll     area=1.3
B07        1          3          jmitll     area=2
B08        29         30         jmitll     area=2.1
B09        20         21         jmitll     area=1.75
B10        26         27         jmitll     area=2.38
B11        32         33         jmitll     area=2.16
IB02       0          11         pwl(0      0 5p {125u*bias})
IB03       0          35         pwl(0      0 5p {230u*bias})
IB04       0          44         pwl(0      0 5p {210u*bias})
IB06       0          45         pwl(0      0 5p {110u*bias})
L01        4          15         3p        
L03        7          9          8.3p      
L04        9          10         0.4p      
L05        4          5          3p        
L06        5          7          3.6p      
L07        14         12         0.734p    
L08        25         23         1.186p    
L09        14         17         0.239p    
L10        17         19         5.53p     
L12        29         25         2.95p     
L13        2          1          1.53p     
L14        31         29         2.583p    
L15        20         22         1.846p    
L16        34         32         2.577p    
L17        1          4          1.01p     
L18        25         26         0.359p    
L19        26         28         2.571p    
L20        32         31         1p        
L21        19         20         1p        
LP04       0          6          0.234p    
LP05       0          8          0.567p    
LP06       0          18         0.27p     
LP07       0          3          0.328p    
LP08       0          30         0.133p    
LP09       0          21         0.12p     
LP10       0          27         0.239p    
LP11       0          33         0.109p    
LPR02      9          11         0.023p    
LPR03      1          35         0.208p    
LPR04      31         44         0.216p    
LPR06      19         45         0.13p     
LRB01      16         14         1p        
LRB02      12         13         1p        
LRB03      23         24         1p        
LRB04      6          37         1p        
LRB05      8          38         1p        
LRB06      18         39         1p        
LRB07      3          36         1p        
LRB08      30         42         1p        
LRB09      21         40         1p        
LRB10      27         43         1p        
LRB11      33         41         1p        
RB01       16         15         5.24      
RB02       13         10         8.8       
RB03       24         10         7.2       
RB04       37         5          8.0       
RB05       38         7          9.2       
RB06       39         17         7.46      
RB07       36         1          4.85      
RB08       42         29         4.62      
RB09       40         20         5.54      
RB10       43         26         4.08      
RB11       41         32         4.5       
RD         28         0          3.54      
.model jmitll jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_not
*******************************
