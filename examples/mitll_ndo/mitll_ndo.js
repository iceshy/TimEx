*********************************************
* Begin .SUBCKT model                       *
* spice-sdb ver 4.28.2007                   *
*                                           *
* RSFQ generic cell for MITLL sfq5ee        *
* ColdFlux project under IARPA-BAA-16-03    *
* Authored 27 December 2017, CJ Fourie, SU  *
* Modified 27 Dec 2017, CJ Fourie, SU       *
*   (Not optimized)                         *
* Last mod 31 Jan 2018, CJ Fourie, SU       *
*   (added bias parameterization)           * 
*********************************************
*$Parameters
*IT=1008e-6
*$EndP
******************************************
* Variables
.PARAM bias=1.0
******************************************
*                   SET     RESET     CLK     OUT       RESOUT
*$Ports             in_set  in_reset  in_clk  out_out   out_resout
.SUBCKT mitll_ndro  2       4         6       30        55
*==============  Begin SPICE netlist of main design ============
B01        5          35         jmitll     area=2.5
B02        16         17         jmitll     area=1.75
B03        3          33         jmitll     area=2.17
B04        11         14         jmitll     area=2.25
B05        14         37         jmitll     area=2.8
B06        1          8          jmitll     area=2.18
B07        10         12         jmitll     area=2.03
B08        12         20         jmitll     area=1.32
B09        23         25         jmitll     area=1
B10        28         41         jmitll     area=1.76
B11        31         42         jmitll     area=1.75
B12        53         54         jmitll     area=1
IB01       0          46         pwl(0      0 5p {260u*bias})
IB02       0          32         pwl(0      0 5p {180u*bias})
IB03       0          7          pwl(0      0 5p {220u*bias})
IB04       0          24         pwl(0      0 5p {108u*bias})
IB05       0          27         pwl(0      0 5p {100u*bias})
IB06       0          29         pwl(0      0 5p {70u*bias})
IB20       0          53         pwl(0      0 5p {70u*bias})
L01        6          5          2.158p    
L02        17         19         2.954p    
L03        4          3          2.623p    
L04        3          11         2.964p    
L05        2          1          2.158p    
L06        1          10         3.952p    
L07        23         22         3.546p    
L08        14         23         2.938p    
L09        26         25         0.468p    
L10        19         26         0.445p    
L11        28         29         3.051p    
L12        31         30         2.031p    
L13        19         28         0.939p    
L14        12         22         0.047p    
L15        5          45         1.5p      
L16        45         16         2p        
L17        29         31         1.5p      
L20        23         53         3.051p    
L21        53         55         2.031p    
LP01       0          35         0.156p    
LP03       0          33         0.135p    
LP05       0          37         0.146p    
LP06       0          8          0.133p    
LP08       0          20         0.216p    
LP10       0          41         0.146p    
LP11       0          42         0.135p    
LPR01      45         46         0.182p    
LPR02      3          32         0.153p    
LPR03      1          7          0.185p    
LPR04      22         24         2.506p    
LPR05      26         27         0.034p    
LRB01      35         36         1p        
LRB02      18         17         1p        
LRB03      33         34         1p        
LRB04      15         14         1p        
LRB05      37         38         1p        
LRB06      8          9          1p        
LRB07      13         12         1p        
LRB08      20         21         1p        
LRB09      25         39         1p        
LRB10      41         40         1p        
LRB11      42         43         1p        
LRB12      0          54         1p        
RB01       36         5          3.88      
RB02       16         18         5.54      
RB03       34         3          4.47      
RB04       11         15         4.31      
RB05       38         14         3.46      
RB06       9          1          4.45      
RB07       10         13         4.85      
RB08       21         12         7.35      
RB09       39         23         9.69      
RB10       40         28         5.54      
RB11       43         31         5.54      
RB12       54         53         9.69      
.model jmitll jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_ndo
**************************************************8
