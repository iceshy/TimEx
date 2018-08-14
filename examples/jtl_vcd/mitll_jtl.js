******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* ColdFlux project under IARPA-BAA-16-03 *
* Authored 2 Nov 2015, CJ Fourie, SU     *
* Modified 5 Jan 2018, CJ Fourie, SU     *
* Last mod 31 Jan 2018, CJ Fourie, SU    *
*   (added bias parameterization)        * 
******************************************
*$Parameters
*IT=350e-6
*$End
******************************************
* Variables
.PARAM bias=1.0
******************************************
*               in out
*$Ports  in_in  out_out
.SUBCKT jtl 2  5 
B1  1 6 jjmitll100 area=2.5 
B2  4 8 jjmitll100 area=2.5 
IB1 0 3 pwl(0 0 5p {bias*350e-6})
L1  2 1 2p  
L2  1 3 2p  
L3  3 4 2p  
L4  4 5 2p  
LB1 7 6 1p  
LB2 9 8 1p  
Lp1 6 0 0.2p  
Lp2 8 0 0.2p  
RB1 1 7 2.74  
RB2 4 9 2.74  
.model jjmitll100 jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends jtl
*******************************
