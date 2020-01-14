############################################
### Carbon cycle model                   ###
### used in GET 6.0                      ###
############################################

set
    coeff / 0,1,2,3,4/;
*
parameters

PRE_IND_CCONT
/ 284 /


TAO(coeff)
/0 100000
1  171
2  18
3  2.57
4  0  /

CARB_RET(COEFF)
/0   0.152
1    0.253
2    0.279
3    0.316
4    0.0/


HIST_fos_EMIS(t_h)
/
1800 8
1810 10
1820 14
1830 24
1840 33
1850 54
1860 91
1870 147
1880 236
1890 356
1900 534
1910 819
1920 932
1930 1053
1940 1299
1950 1630
1960 2578
1970 4075
1980 5297
1990 6144
2000 6735
/

* landanvaendningsemissioner fraan Annual Net flux of Carbon to the Atmosphere from Land-Use Change
* 1850-1990
* Version corresponding to R.A. Houghton, 1999, Tellus 51B 298-313
* http://cdiac.esd.ornl.gov/ftp/ndp050/ndp050.dat
*
* KOLSAENKA I TERRESTRA SYSTEM VERKAR INTE FINNAS MED!!
*
* prognos foer 2000 och framaat
*
*
*
HIST_luc_EMIS(T_H)
/
1800 8
1810 10
1820 14
1830 24
1840 33
1850 400
1860 420
1870 430
1880 500
1890 580
1900 580
1910 760
1920 640
1930 710
1940 710
1950 850
1960 1192
1970 1197
1980 1025
1990 1319
2000 1149
/


FUT_luc_EMIS(t_a)
/
2010 1200
2020 1130
2030 1070
2040 920
2050 770
2060 520
2070 270
2080  80
 /





FUT_biota_SINKS(t_a);
FUT_biota_SINKS(t_a)=0;

parameters
    GFUNC
;



GFUNC(t_a, t_b) = SUM(COEFF, ((sign(ORD(t_a)-ORD(t_b)+1/2)+1)/2)*CARB_RET(COEFF)*
            EXP(-10*((sign(ORD(t_a)-ORD(t_b)+1/2)+1)/2)*(ORD(t_a)-ORD(t_b))/TAO(COEFF)));



variables
CARB_CTRB(t_a, t_b)
ATM_CCONT(t_a)
;

equations

CTRBE(t_a, t_b)
ATM_CCONTE(t_a)

;

CTRBE(t_a, t_b)..
    CARB_CTRB(t_a, t_b) =E= ( C_EMISSION(t_b) + FUT_LUC_EMIS(t_b)/1000  )*GFUNC(t_a, t_b);

ATM_CCONTE(t_a)..
    ATM_CCONT(t_a)=E=PRE_IND_CCONT+SUM(t_b,CARB_CTRB(t_a, t_b))*0.28/600*10;