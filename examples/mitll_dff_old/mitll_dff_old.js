*******************************
* Begin .SUBCKT model         *
* spice-sdb ver 4.28.2007     *
*******************************
*$Ports           in_set  in_reset  out_out
.SUBCKT MITLL_DFF 17 19 8 
*==============  Begin SPICE netlist of main design ============
B01 23 2 jmitll area=1.62 
B02 14 15 jmitll area=2.16 
B03 10 11 jmitll area=2.34 
B04 1 3 jmitll area=1.69 
B05 20 21 jmitll area=2.16 
B06 5 6 jmitll area=1.85 
IB01 0 18 pwl(0 0 5p 121.3u)
IB02 0 27 pwl(0 0 5p 280u)
IB03 0 25 pwl(0 0 5p 280u)
L01 20 24 0.13p  
L02 10 9 1.433p  
L03 9 2 6.362p  
L04 1 5 4.623p  
L05 14 13 0.49p  
L06 19 20 2.501p  
L07 17 14 2.496p  
L08 5 8 2.291p  
L09 2 1 0.27p  
L10 24 23 3.13p  
L11 13 10 4.49p  
LP02 0 15 0.096p  
LP03 0 11 0.117p  
LP04 0 3 0.117p  
LP05 0 21 0.122p  
LP06 0 6 0.151p  
LPR01 9 18 0.174p  
LPR02 13 27 0.182p  
LPR03 24 25 0.182p  
LRB01 26 2 1p  
LRB02 16 15 1p  
LRB03 12 11 1p  
LRB04 4 3 1p  
LRB05 22 21 1p  
LRB06 7 6 1p  
RB01 26 23 6.975  
RB02 16 14 5.231  
RB03 12 10 4.829  
RB04 4 1 6.686  
RB05 22 20 5.231  
RB06 7 5 6.10  
.model jmitll jj(rtype=1, vg=2.8mV, cap=0.07pF, r0=160, rn=16, icrit=0.1mA)
.ends MITLL_DFF
*******************************
