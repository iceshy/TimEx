* JSIM deck file generated with TimEx
* === DEVICE-UNDER-TEST ===
******************************************
* Begin .SUBCKT model                    *
* spice-sdb ver 4.28.2007                *
*                                        *
* RSFQ generic cell for MITLL sfq5ee     *
* Seedling project under IARPA-BAA-14-03 *
* ColdFlux project under IARPA-BAA-16-03 *
* Authored 2 Nov 2015, CJ Fourie, SU     *
* Last mod 7 Jan 2018, CJ Fourie, SU     *
******************************************
*$Parameters
*IT=350e-6
*$End
******************************************
* Variables
*.PARAM bias=2.5
*.PARAM vc = 1.0
******************************************
*               in out
*$Ports  in_in  out_out
.SUBCKT jtl 2  5 
B1  1 6 jjmitll100 area=2.5 
B2  4 8 jjmitll100 area=2.5 
IB1 0 3 pwl(0 0 5p 0.000630252)
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
* === SOURCE DEFINITION ===
.SUBCKT SOURCECELL  8 11
b1   1  2  jjmitll100 area=2.25
b2   3  4  jjmitll100 area=2.25
b3   5  6  jjmitll100 area=2.5
ib1  0  2  pwl(0 0 5p 275ua)
ib2  0  5  pwl(0 0 5p 175ua)
l1   8  7  1p
l2   7  0  3.9p
l3   7  1  0.6p
l4   2  3  1.1p
l5   3  5  4.5p
l6   5  11 2p
lp2  4  0  0.2p
lp3  6  0  0.2p
lrb1 9  2  1p
lrb2 10 4  1p
lrb3 12 6  1p
rb1  1  9  4.31
rb2  3  10 4.31
rb3  5  12 3.88
.model jjmitll100 jj(rtype=1, vg=2.8mv, cap=0.07pf, r0=160, rn=16, icrit=0.1ma)
.ENDS SOURCECELL
* === INPUT LOAD DEFINITION ===
.SUBCKT LOADINCELL  2 5
b1 1 6 jjmitll100 area=2.5
b2 4 8 jjmitll100 area=2.5
ib1 0 3 pwl(0 0 5p 350ua)
l1 2 1 2p
l2 1 3 2p
l3 3 4 2p
l4 4 5 2p
lb1 7 6 1p
lb2 9 8 1p
lp1 6 0 0.2p
lp2 8 0 0.2p
rb1 1 7 3.88
rb2 4 9 3.88
.model jjmitll100 jj(rtype=1, vg=2.8mv, cap=0.07pf, r0=160, rn=16, icrit=0.1ma)
.ENDS LOADINCELL
* === OUTPUT LOAD DEFINITION ===
.SUBCKT LOADOUTCELL  2 5
b1 1 6 jjmitll100 area=2.5
b2 4 8 jjmitll100 area=2.5
ib1 0 3 pwl(0 0 5p 350ua)
l1 2 1 2p
l2 1 3 2p
l3 3 4 2p
l4 4 5 2p
lb1 7 6 1p
lb2 9 8 1p
lp1 6 0 0.2p
lp2 8 0 0.2p
rb1 1 7 3.88
rb2 4 9 3.88
.model jjmitll100 jj(rtype=1, vg=2.8mv, cap=0.07pf, r0=160, rn=16, icrit=0.1ma)
.ENDS LOADOUTCELL
* === SINK DEFINITION ===
.SUBCKT SINKCELL  1
r1 1 0 2
.ENDS SINKCELL
* ===== MAIN =====
I_in 0 1 pwl(0 0 5p 0 2E-11 0 2.1E-11 0.001 2.2E-11 0 6E-11 0 6.1E-11 0.001 6.2E-11 0)
XSOURCEINin SOURCECELL 1 2
XLOADINin LOADINCELL 2 3
XLOADOUTout LOADOUTCELL 4 5
XSINKOUTout SINKCELL 5
XDUT jtl 3 4
.tran 0.25p 1.4E-10 0 0.25p
.PRINT NODEV 3 0
.PRINT NODEV 4 0
.PRINT DEVI XDUT_LP1
.PRINT DEVI XDUT_B1
.PRINT DEVI XDUT_L2
.PRINT DEVI XDUT_L3
.PRINT DEVI XDUT_B2
.PRINT DEVI XDUT_LP2
.end
