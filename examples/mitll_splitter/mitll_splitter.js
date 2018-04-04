******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* Authored 3 Nov 2015, CJ Fourie, SU     *
* Modified 8 Nov 2016, CJ Fourie, SU     *
*   Added TimEx port descriptors         *
* Last mod 31 Jan 2018, CJ Fourie, SU    *
*   (added bias parameterization)        * 
******************************************
*$Parameters
*IT=569e-6
*$EndP
******************************************
* Variables
.PARAM bias=1.0
******************************************
*                      in out1 out2
*$Ports                in_in  out_out1  out_out2
.SUBCKT mitll_splitter 7      10        11 
B1   1  2  jjmitll100 area=3.25 
B2   3  4  jjmitll100 area=2.5 
B3   5  6  jjmitll100 area=2.5 
IB1  0  8  pwl(0 0 5p {669uA*bias})
L1   7  1  1.4p  
L2   1  8  2p  
L3   8  9  0.4p  
L4   9  3  1.9p  
L5   3  10 2p  
L6   9  5  1.9p  
L7   5  11 2p  
Lp1  2  0  0.2p  
Lp2  4  0  0.2p  
Lp3  6  0  0.2p  
LRB1 12 2  1p  
LRB2 14 4  1p  
LRB3 13 6  1p  
RB1  1  12 2.98  
RB2  3  14 3.88  
RB3  5  13 3.88  
.model jjmitll100 jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends mitll_splitter
*******************************
