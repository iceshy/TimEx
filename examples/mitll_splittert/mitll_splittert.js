*******************************************
* Begin .SUBCKT model                     *
* spice-sdb ver 4.28.2007                 *
*                                         *
* RSFQ generic cell for MITLL sfq5ee      *
* Seedling project under IARPA-BAA-14-03  *
* Authored 3 Nov 2015, CJ Fourie, SU      *
* Modified 8 Nov 2016, CJ Fourie, SU      *
* PTL drivers and receivers added 	      *
*    Nov 2017, L Schindler, SU            *
* Last mod 04 Feb 2018, CJ Fourie, SU     *
*   (TimEx support and Bias variable)     *
*******************************************
* Variables
.PARAM bias=1.0
*******************************************
*                      in out1 out2
*$Ports                a      q0        q1
.SUBCKT mitllusplitter 5      13        36 
B01urx2    4          6          jjmitll100 area=0.68678
B01utx1    9          14         jjmitll100 area=0.903623
B01utx2    33         37         jjmitll100 area=0.847832
B1         19         20         jjmitll100 area=1.41662
B2         21         22         jjmitll100 area=0.996627
B3         23         24         jjmitll100 area=1.24135
IB01urx2   0          7          pwl(0      0 5p {9.11613e-005*bias})
IB01utx1   0          16         pwl(0      0 5p {5.26782e-005*bias})
IB01utx2   0          39         pwl(0      0 5p {5.65664e-005*bias})
IB1        0          31         pwl(0      0 5p {0.000280782*bias})
L01urx2    5          4          3.02326e-013
L01utx1    10         9          2.76033e-012
L01utx2    27         33         3.20104e-012
L02utx1    9          11         4.15712e-012
L02utx2    33         34         3.92355e-012
L03utx1    11         12         1.00518e-011
L03utx2    34         35         8.8248e-012
L1         4          19         3.03935e-012     
L2         19         25         3.69076e-012     
L3         25         26         5.3867e-013     
L4         26         21         2.88621e-012     
L5         21         10         2.95156e-012     
L6         26         23         1.80572e-012     
L7         23         27         3.21314e-012     
LP01urx2   0          6          3.4e-013
LP01utx1   0          14         5e-014
LP01utx2   0          37         5e-014
LP1        20         0          2e-013    
LP2        22         0          2e-013    
LP3        24         0          2e-013    
LPuIB1     25         31         2e-013 
LPR01urx2  4          7          2e-013
LPR01utx1  9          16         2e-013
LPR01utx2  33         39         2e-013
LRB01urx2  0          8          1e-012
LRB01utx1  0          15         2e-012
LRB01utx2  0          38         2e-012
LRB1       28         0          2e-012   
LRB2       30         0          2e-012   
LRB3       29         0          2e-012   
RB01urx2   8          4          9.98851
RB01utx1   15         9          7.59155
RB01utx2   38         33         8.09111
RB1        19         28         4.84243    
RB2        21         30         6.88312    
RB3        23         29         5.52618    
RINSutx1   12         13         1.36      
RINSutx2   35         36         1.36      
.model jjmitll100 jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends
