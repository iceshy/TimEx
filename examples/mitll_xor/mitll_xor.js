******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* Authored 1 March 2016, JA Delport, SU  *
* Modified 27 Nov 2016, CJ Fourie, SU    *
*   (Added IB06, L16, optimized)         *
* Last mod 31 Jan 2018, CJ Fourie, SU    *
*   (added bias parameterization)        * 
******************************************
*$Parameters
*IT=910e-6
*$EndP
******************************************
* Variables
.PARAM bias=1.0
******************************************
*                 IN_A  IN_B  CLK     OUT
*$Ports           in_a  in_b  in_clk  out_out
.SUBCKT mitll_xor 2     6     10      27 
*==============  Begin SPICE netlist of main design ============
B01        3          31         jmitll     area=2.5
B02        1          32         jmitll     area=1.75
B03        3          12         jmitll     area=1.69
B04        7          29         jmitll     area=2.5
B05        5          30         jmitll     area=1.75
B06        7          14         jmitll     area=1.69
B07        21         16         jmitll     area=1.85
B08        22         23         jmitll     area=1.63
B09        9          28         jmitll     area=1.69
B10        9          33         jmitll     area=2.17
B11        25         26         jmitll     area=2.18
IB01       0          42         pwl(0      0 5p {225u*bias})
IB02       0          43         pwl(0      0 5p {225u*bias})
IB03       0          18         pwl(0      0 5p {60u*bias})
IB04       0          19         pwl(0      0 5p {60u*bias})
IB05       0          41         pwl(0      0 5p {180u*bias})
IB06       0          45         pwl(0      0 5p {160u*bias})
L01        2          1          2.53p     
L02        4          3          2.1p    
L03        12         17         1.6p    
L04        6          5          2.53p     
L05        8          7          2.1p    
L06        14         15         1.6p     
L07        17         16         1.9p    
L08        15         16         1.9p    
L09        21         22         1.422p    
L10        22         28         3.07p     
L11        10         9          2.436p    
L12        22         24         4.047p    
L13        25         27         2.213p    
L14        1          4          1p        
L15        5          8          1p        
L16        24         25         1.047p    
LP01       0          31         0.13p     
LP02       0          32         0.146p    
LP03       0          29         0.127p    
LP04       0          30         0.138p    
LP05       0          23         0.307p    
LP06       0          33         0.159p    
LP07       0          26         0.153p    
LPR01      4          42         0.211p    
LPR02      8          43         0.211p    
LPR03      17         18         0.351p    
LPR04      15         19         0.361p    
LPR05      9          41         0.208p    
LPR06      24         45         0.361p    
LRB01      31         36         1p        
LRB02      32         35         1p        
LRB03      11         12         1p        
LRB04      29         37         1p        
LRB05      30         38         1p        
LRB06      13         14         1p        
LRB07      20         21         1p        
LRB08      23         39         1p        
LRB09      44         9          1p        
LRB10      33         34         1p        
LRB11      26         40         1p        
RB01       36         3          3.88      
RB02       35         1          5.54       
RB03       11         3          5.4       
RB04       37         7          3.88      
RB05       38         5          5.54       
RB06       13         7          5.4       
RB07       16         20         5.25      
RB08       39         22         6         
RB09       28         44         5.4       
RB10       34         9          4.45      
RB11       40         25         4.45      
.model jmitll jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_xor
*******************************
