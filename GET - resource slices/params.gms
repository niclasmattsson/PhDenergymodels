************************************************************
***** Parameter definitions and setting                *****
***** Initilisation of parameter values                *****
***** GET version 8.0                                  *****
************************************************************


scalars

Msec_per_year / 31.6 /
t_step        / 10   /

parameters
supply_pot(primary, reg,t)                           max supply potential
effic(energy, en_out, type,reg, t)                    energy conv effic
*lf(en_in, type, en_out)                          loadfactor
life_plant(en_in, en_out, type)                  life time
life_eng(trsp_fuel, engine_type, car_or_truck)   life time
lf_infra(trsp_fuel)                          loadfactor
vehicle_cost(car_or_truck)                       basic cost for vehicle w gasoline IC engine
t_tech_plant(en_in, en_out, type)                technology developm time
t_tech_eng(road_fuel, engine_type, car_or_truck) technology developm time
t_tech_effic(en_in, type, en_out)
effic_current(en_in, type, en_out)
max_beccs


OM_cost_fr(en_in, en_out)  operation & maintanance cost as fraction of capital cost

year(t)  ;
year(t)=2010+(ord(t)-1)*10;



table price(fuels, reg)               basic fuel prices USD per GJ (GUSD per EJ)
          AFR        CPA        EUR        FSU        LAM        MEA        NAM        PAO        PAS        SAS
bio1      1.6        2.2        2.4        2.1        2.4        2.5        2.7        2.7        1.9        1.5
bio2      2.7        3.7        3.0        2.3        2.0        12.7        3.1       3.5        2.9        3.1
bio3      3.9        6.5        4.2        3.6        3.1        13.9        5.4       4.5        3.7        4.8
coal1     1.5        1.5        1.5        1.5        1.5        1.5        1.5        1.5        1.5        1.5
coal2     3          3          3          3          3          3          3          3          3          3
oil1      4          4          4          4          4          4          4          4          4          4
oil2      6          6          6          6          6          6          6          6          6          6
oil3      10         10         10         10         10         10         10         10         10         10
gas1      2.5        2.5        2.5        2.5        2.5        2.5        2.5        2.5        2.5        2.5
gas2      5          5          5          5          5          5          5          5          5          5
gas3      7          7          7          7          7          7          7          7          7          7
uranium1  0.07       0.07       0.07       0.07       0.07       0.07       0.07       0.07       0.07       0.07
uranium2  0.14       0.14       0.14       0.14       0.14       0.14       0.14       0.14       0.14       0.14
uranium3  0.23       0.23       0.23       0.23       0.23       0.23       0.23       0.23       0.23       0.23
uranium4  0.4        0.4        0.4        0.4        0.4        0.4        0.4        0.4        0.4        0.4
uranium5  1.3        1.3        1.3        1.3        1.3        1.3        1.3        1.3        1.3        1.3

*PuR      0.07   0.07  0.07
;
table supply_pot_0 (primary, reg)     max supply potential (EJ) - annual (and aggreg for fossils)
            AFR        CPA        EUR        FSU        LAM        MEA        NAM        PAO        PAS        SAS
bio1        3          5          4          1          4          1          4          1          1          4
bio2        18         2          3          5          11         0          8          4          5          1
bio3        16         2          3          5          9          0          5          4          4          1
coal1       744        3795       408        2952       240        48         5520       1080       360        2325
coal2       1080       18305      1680       13920      600        240        14280      2880       960        8614
oil1        677        188        153        927        903        4203       628        37         140        44
oil2        1708       904        671        2257       2196       6405       1525       183        458        246
oil3        427        649        183        2196       2745       61         7869       793        31         123
gas1        507        73         234        2379       351        296        351        156        351        123
gas2        1755       176        975        3705       1170       4095       1170       390        975        214
gas3        1365       714        122        1170       2145       780        2535       780        585        846
uranium1    140        21         0          29         82         0          214        0          0          0
uranium2    314        72         4          452        143        65         284        0          942        0
uranium3    606        82         50         789        176        76         404        7          977        47
uranium4    612        86         78         1014       178        79         594        7          981        47
uranium5    10000      10000      10000      10000      10000      10000      10000      10000      10000      10000
wind        100        100        100        100        100        100        100        100        100        100
*not really used for wind and solar
hydro       2.6        3.8        2.8        8.0        7.7        0.4        3.0        0.6        2.7        1.6
solar       200        200        200        200        200        200        200        200        200        200
$ontext
            AFR        CPA        EUR        FSU        LAM        MEA        NAM        PAO        PAS        SAS
bio1        3          5          4          1          4          1          4          1          1          4
bio2        34         4          6          10         20         0          13         8          9          2
coal1       744        3795       408        2952       240        48         5520       1080       360        2325
coal2       1080       18305      1680       13920      600        240        14280      2880       960        8614
oil1        677        188        153        927        903        4203       628        37         140        44
oil2        1708       904        671        2257       2196       6405       1525       183        458        246
oil3        427        649        183        2196       2745       61         7869       793        31         23
gas1        507        73         234        2379       351        296        351        156        351        123
gas2        3110       890        1097       4875       3315       4875       3705       1270       1560       1060
uranium1    140        21         0          29         82         0          214        0          0          0
uranium2    314        72         4          452        143        65         284        0          942        0
uranium3    606        82         50         789        176        76         404        7          977        47
uranium4    612        86         78         1014       178        79         594        7          981        47
uranium5    10000      10000      10000      10000      10000      10000      10000      10000      10000      10000
wind        57         126        320        126        126        57         320        320        57         57
hydro       2          7          3          5          7          1          3          0          0          2
solar       216        142        94         142        142        216        94         94         216        216
$offtext
;

supply_pot(primary, reg,t) = supply_pot_0(primary,reg);

table min_bio(reg, t)
           2010        2020        2030        2040        2050        2060        2070        2080        2090        2100
AFR        1.09        1.12        0.80        0.56        0.40        0.37        0.35        0.32        0.30        0.28
CPA        0.80        0.44        0.37        0.32        0.27        0.25        0.22        0.20        0.19        0.17
EUR        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00
FSU        0.02        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00
LAM        0.22        0.32        0.10        0.06        0.05        0.03        0.03        0.02        0.02        0.02
MEA        0.05        0.05        0.04        0.03        0.02        0.02        0.02        0.01        0.01        0.01
NAM        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00
PAO        0.01        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00        0.00
PAS        0.28        0.17        0.11        0.07        0.03        0.00        0.00        0.00        0.00        0.00
SAS        1.17        1.10        0.85        0.65        0.50        0.46        0.42        0.39        0.36        0.33
;

table el_2010(reg, calibration_set)
           bio         coal           EU4         CH4        hydro        oil         wind           solar
AFR        0.00        1.13251        0.04        0.13        0.30        0.04        0.00553        0.005
CPA        0.00        10.19588       0.24        0.21        2.47        0.16        0.13962        0.000
EUR        0.26        3.55821        3.62        2.82        2.16        0.29        0.59749        0.000
FSU        0.01        0.93831        0.83        2.39        0.77        0.09        0              0.000
LAM        0.01        0.12           0.10        0.51        2.44        0.72        0              0.000
MEA        0.00        0.24045        0.00        2.25        0.19        1.14        0.01122        0.003
NAM        0.34        8.17594        3.30        2.56        2.34        0.11        0.33385        0.020
PAO        0.13        1.83545        1.17        0.86        0.49        0.32        0.03784        0.020
PAS        0.00        2.07964        0.67        1.27        0.18        0.31        0              0.003
SAS        0.01        2.49357        0.08        0.44        0.66        0.18        0.0812         0.000

;
PARAMETERS
r         discount rate
    / 0.05 /
r_invest  interest rate applied to investments
    / 0.05 /
C_tax(reg,t)  (kUSD per ton C)
growth_factor    growth rate to the power of 10  (currently 15%)
         /0.1/

emissions_2010(reg)/
AFR        1379
CPA        4714
EUR        4669
FSU        2604
LAM        3611
MEA        1431
NAM        7293
PAO        1574
PAS        2141
SAS        860
/

Pu_start/
AFR   0
CPA   0
EUR   0
FSU   0
LAM   0
MEA   0
NAM   0
PAO   0
PAS   0
SAS   0
 /
*OECD      16
*MIC        17 /


*****CCS parameters*******

cost_strg_fos   carbon storage cost from fossils (kUSD per ton CO2)
    / 0.010 /

*For co-firing with coal
cost_strg_bio   carbon storage cost from bio energy (kUSD per ton CO2)
    / 0.010 /

max_beccs
 /0.2/

dec_elec(en_in)   electricity requirements for heat generation with C capture
/     bio   0.04
      coal  0.04
      oil   0.03
      CH4   0.025  /;

***Technology and sector paramaters******
parameters

district_cost  cost to distribute wasteheat to central_heat
         /5/
cogen_fr_h   max fraction of urban heat from cogeneration
    / 0.6 /
$ontext
interm_fr(reg)    max fraction of wind and solar PV to electr.
/OECD 0.25
MIC   0.25
ROW   0.30 /

/OECD 0.25
MIC   0.25
ROW   0.30 /

wind_fr   max fraction of wind to electr.
   /0.20/
*   /0.20/
$offtext
C_capt_heat(dec_heat)  max fraction of sector that can use C_capt
/central_heat     0.7
solid_heat      0.5
non_solid_heat  0.5  /

max_feed(feed)  Feedstock fractions
/CH4     0.1
biogas   0.1
ethanol   1
biodiesel 1
coal      0.1
oil       0.1
petro     1
MeOH      1/

csp_fr(reg) maximum fraction of electrcity demand supplied by CSP
/
AFR   0.5
CPA   0.3
EUR   0.3
FSU   0.3
LAM   0.5
MEA   0.5
NAM   0.3
PAO   0.3
PAS   0.5
SAS   0.5
/

max_chip maximum wood chips in industry
   /0.67/   ;

table max_solar(heat,reg) maximum solar
                    AFR        CPA        EUR        FSU        LAM        MEA        NAM        PAO        PAS        SAS
central_heat        0.2        0.2        0.2        0.2        0.2        0.2        0.2        0.2        0.2        0.2
dist_heat           0.4        0.4        0.4        0.4        0.4        0.4        0.4        0.4        0.4        0.4
 ;

table max_pump(heat,reg)   maximum heat pumps
                 AFR        CPA        EUR        FSU        LAM        MEA        NAM        PAO        PAS        SAS
central_heat     0.2        0.2        0.2        0.2        0.2        0.2        0.2        0.2        0.2        0.2
dist_heat        0.6        0.6        0.6        0.6        0.6        0.6        0.6        0.6        0.6        0.6
;

table ramp_lim(thermalelec,type)
        0    cg   dec   cg_dec
bio     0.5  0.5  0.5   0.5
oil     0.2  0.2  0.2   0.2
CH4     0.2  0.2  0.2   0.2
coal    0.5  0.5  0.5   0.5
EU4     0.7  0.7  0.7   0.7
EU1     0.7  0.7  0.7   0.7
FBF     0.7  0.7  0.7   0.7
MOX     0.7  0.7  0.7   0.7
hydro   0.2  0.2  0.2   0.2;

$ontext
        0    cg   dec   cg_dec
bio     0.35 0.35 0.35  0.35
oil     0.1  0.1  0.1   0.1
CH4     0.1  0.1  0.1   0.1
coal    0.35 0.35 0.35  0.35
EU4     0.7  0.7  0.7   0.7
EU1     0.7  0.7  0.7   0.7
FBF     0.7  0.7  0.7   0.7
MOX     0.7  0.7  0.7   0.7
hydro   0.1  0.1  0.1   0.1;
$offtext

**** Transportation parameters********

parameters
cost_infra(trsp_fuel)  infrastr costs (USD per kW)
    / MeOH   830
      ethanol 830
      H2    3300
      CH4   2500
      biogas 2500
      biodiesel 20/

life_infra(trsp_fuel)  life time for infrastructure
    / MeOH    50
      H2      50
      CH4     50
      biogas  50
      ethanol 50
      biodiesel 50/

elec_frac_PHEV(car_or_truck)
/p_car   0.65
f_road 0.53
p_bus   0.53/;

parameter sliced_demand_baseline(allslices);
sliced_demand_baseline(allslices) = 1.15;
*sliced_demand_baseline(allslices) $ (ord(allslices) <= 15) = 1;

table frac_engine(engine_type, car_or_truck)
         p_car   f_road   p_bus
0          1        1        1
FC         1        1        1
hyb        1        1        1
PHEV       1       0.2      0.3
BEV        0.3      0      0.1  ;


table high_speed_train(t,reg)  fraction of hsp mode using electricity
             AFR        CPA         EUR        FSU          LAM        MEA          NAM        PAO          PAS        SAS
2010        0.04        0.04        0.04        0.04        0.04        0.04        0.04        0.04        0.04        0.04
2020        0.04        0.04        0.04        0.04        0.04        0.04        0.04        0.04        0.04        0.04
2030        0.04        0.04        0.06        0.04        0.04        0.04        0.06        0.06        0.04        0.04
2040        0.04        0.04        0.1         0.04        0.04        0.04        0.1         0.1         0.04        0.04
2050        0.04        0.04        0.14        0.04        0.04        0.04        0.14        0.14        0.04        0.04
2060        0.04        0.04        0.2         0.04        0.04        0.04        0.2         0.2         0.04        0.04
2070        0.04        0.04        0.24        0.04        0.04        0.04        0.24        0.24        0.04        0.04
2080        0.04        0.04        0.26        0.04        0.04        0.04        0.26        0.26        0.04        0.04
2090        0.04        0.04        0.28        0.04        0.04        0.04        0.28        0.28        0.04        0.04
2100        0.04        0.04        0.3         0.04        0.04        0.04        0.3         0.3         0.04        0.04
2110        0.04        0.04        0.3         0.04        0.04        0.04        0.3         0.3         0.04        0.04
2120        0.04        0.04        0.3         0.04        0.04        0.04        0.3         0.3         0.04        0.04
2130        0.04        0.04        0.3         0.04        0.04        0.04        0.3         0.3         0.04        0.04
   ;

*************************************
***Expansion constraints parameters**
*************************************
Parameters

cap_g_lim    /0.10/
*  / 0.30 /
init_plant   /0.0002/
*/ 0.0001 /

supply_lim /0.1/
init_supply /4/

infra_g_lim    infrastr relative growth limit
    / 0.10 /
init_infra     initial unrestricted infrastr growth (TW per decade)
    / 0.01 /
eng_g_lim  / 0.20 /
init_eng /0.01/

marketshare_fr(sector1)  Maxium change of marketshare within a sector over a 10 year period
    /elec                0.2
     central_heat        0.2
     dist_heat           0.2
     solid_heat          0.2
     non_solid_heat      0.2
     feed-stock          0.2/

marketshare_eng /0.25/ ;

************************************************************
$ include "indata.gms";
************************************************************

lf_infra(trsp_fuel)=0.7;
life_infra(trsp_fuel) = 50;
life_plant(en_in, en_out, type) = 25;
life_plant("hydro", "elec", "0") = 40;
life_plant("EU4", "elec", "0") = 40;
life_plant("EU1", "elec", "0") = 40;
life_plant("MOX", "elec", "0") = 40;
life_plant("FBF", "elec", "0") = 40;
life_plant("EU4", "H2", "cg") = 40;
life_eng(trsp_fuel, engine_type, car_or_truck) = 15;

C_tax(reg,t) = 0;
OM_cost_fr(en_in, en_out) = 0.04;
OM_cost_fr("EU1", "elec") = 0.015;
OM_cost_fr("EU4", "elec") = 0.015;
OM_cost_fr("MOX", "elec") = 0.015;
OM_cost_fr("FBF", "elec") = 0.015;
OM_cost_fr("storage_12h", "elec") = 0.015;
OM_cost_fr("storage_24h", "elec") = 0.015;
OM_cost_fr("storage_48h", "elec") = 0.015;
OM_cost_fr("storage_96h", "elec") = 0.015;

********************************************************
*** time dependent technology costs and efficiencies ***
********************************************************

effic_current(en_in, type, en_out)=effic_0(en_in, type, en_out);
t_tech_effic(en_in, type, en_out) = 40;

* time depend costs now disabled
*cost_inv_0(en_in, en_out, type) = cost_inv_base(en_in, type, en_out);
*$ontext
* time and region dependent efficiency
effic(en_in, en_out, type, reg,t) = effic_0(en_in, type, en_out);

*$ontext
effic(en_in, en_out, type, ROW,t)$(effic_0(en_in, type, en_out)>0.11 and effic_0(en_in, type, en_out)<0.95 ) = min(effic_0(en_in, type, en_out),
   (effic_0(en_in, type, en_out)-(effic_current(en_in, type, en_out)*0.7))/
      t_tech_effic(en_in, type, en_out)*((ord(t)-1)*t_step)+
        effic_current(en_in, type, en_out)*0.7 );

effic(en_in, en_out, type, ROW,t)$(effic_0(en_in, type, en_out)>=0.95 and effic(en_in, en_out, type, ROW,t)=0  )=effic_0(en_in, type, en_out);

effic(en_in, en_out, type, MIC,t)$(effic_0(en_in, type, en_out)>0.11 and effic_0(en_in, type, en_out)<0.95 ) = min(effic_0(en_in, type, en_out),
   (effic_0(en_in, type, en_out)-(effic_current(en_in, type, en_out)*0.8))/
      t_tech_effic(en_in, type, en_out)*((ord(t)-1)*t_step)+ effic_current(en_in, type, en_out)*0.8 );

effic(en_in, en_out, type, MIC,t)$(effic_0(en_in, type, en_out)>=0.95 and effic(en_in, en_out, type, MIC,t)=0  )=effic_0(en_in, type, en_out);

effic(en_in, en_out, type, OECD,t)$(effic_0(en_in, type, en_out)>0.11 and effic_0(en_in, type, en_out)<0.95  ) = min(effic_0(en_in, type, en_out),
   (effic_0(en_in, type, en_out)-(effic_current(en_in, type, en_out)*0.9))/
      t_tech_effic(en_in, type, en_out)*((ord(t)-1)*t_step)+
        effic_current(en_in, type, en_out)*0.9 );

effic(en_in, en_out, type, OECD,t)$(effic_0(en_in, type, en_out)>=0.95 and effic(en_in, en_out, type, OECD,t)=0  )=effic_0(en_in, type, en_out);
*$offtext

effic(nuclear_fuel, en_out , type, reg,t)= effic_0(nuclear_fuel, type, en_out);
*$offtext
**********************************************************************
* Calc of time-dep invest costs, linear decrease from yr 2000 over t_tech yrs, from level given by cost_0 to final level cost_base.
*************************************************************************************************************
Parameters
cost_infra_mod(trsp_fuel)  d:o adjusted for different investm and discount rates

cost_inv(en_in, en_out, type, t)      time dependent plant investment cost
cost_inv_mod(en_in, en_out, type, t)  d:o adjusted for different investm and discount rates

cost_eng(road_fuel, engine_type, car_or_truck, t)     time dependent vehicle investment cost (vehicle + engine)
cost_eng_0(road_fuel, engine_type, car_or_truck)      initial vehicle investment cost (vehicle + engine)
cost_eng_mod(road_fuel, engine_type, car_or_truck, t) d:o adjusted for different investm and discount rates;

vehicle_cost("p_car")  = 10000;
vehicle_cost("f_road") = 80000;
vehicle_cost("p_bus") = 80000;

cost_eng_0(road_fuel, engine_type, car_or_truck) = cost_eng_base(road_fuel, engine_type, car_or_truck)*1.5;

t_tech_plant(en_in, en_out, type) = 40;
t_tech_eng(road_fuel, engine_type, car_or_truck) = 40;


cost_inv(en_in, en_out, type, t) $ (((ord(t)-1)*t_step/t_tech_plant(en_in, en_out, type)) < 1) =
    cost_inv_0(en_in, type, en_out)-((cost_inv_0(en_in, type, en_out)-cost_inv_base(en_in, type, en_out))* (ord(t)-1)*t_step/t_tech_plant(en_in, en_out, type)) ;

cost_inv(en_in, en_out, type, t) $ (((ord(t)-1)*t_step/t_tech_plant(en_in, en_out, type)) >= 1) =
 cost_inv_base(en_in, type, en_out);

*cost_inv("FBF", "elec", type, t) =
*max( cost_inv_base("FBF", type, "elec"),
*    cost_inv_0("FBF", type, "elec")-
*   (cost_inv_0("FBF", type, "elec")-cost_inv_base("FBF", type, "elec"))*
*    ((ord(t)-3 $(ord(t)>= 3 ) )*t_step/t_tech_plant("FBF", "elec", type)) );
* For breeder to start moving towards mature cost later
*cost_inv("MOX", "elec", type, t) =
*max( cost_inv_base("MOX", type, "elec"),
*    cost_inv_0("MOX", type, "elec")-
*   (cost_inv_0("MOX", type, "elec")-cost_inv_base("MOX", type, "elec"))*
*    ((ord(t)-2 $(ord(t)>= 2 ) )*t_step/t_tech_plant("MOX", "elec", type)) );

*cost_inv("EU4", "H2", type, t) =
*max( cost_inv_base("EU4", type, "H2"),
*    cost_inv_0("EU4", type, "H2")-
*   (cost_inv_0("EU4", type, "H2")-cost_inv_base("EU4", type, "H2"))*
*    ((ord(t)-3 $(ord(t)>= 3 ) )*t_step/t_tech_plant("EU4", "H2", type)) );

* D:o, and basic vehicle cost added
cost_eng(road_fuel, engine_type, car_or_truck, t) =

*cost_eng_base(road_fuel, engine_type, car_or_truck)
*             + vehicle_cost(car_or_truck) ;

 max( cost_eng_base(road_fuel, engine_type, car_or_truck),
    cost_eng_0(road_fuel, engine_type, car_or_truck) -
    (cost_eng_0(road_fuel, engine_type, car_or_truck)-cost_eng_base(road_fuel, engine_type, car_or_truck))*
    ((ord(t)-1)*t_step/t_tech_eng(road_fuel, engine_type, car_or_truck)) )
    + vehicle_cost(car_or_truck);

cost_inv_mod(en_in, en_out, type, t) = cost_inv(en_in, en_out, type, t);
*    (r_invest + 1/life_plant(en_in, en_out, type))/(r+1/life_plant(en_in, en_out, type));

cost_eng_mod(road_fuel, engine_type, car_or_truck, t) = cost_eng(road_fuel, engine_type, car_or_truck, t)          ;
*    (r_invest + 1/life_eng(road_fuel, engine_type, car_or_truck))/(r+1/life_eng(road_fuel, engine_type, car_or_truck));

cost_infra_mod(trsp_fuel) = cost_infra(trsp_fuel)         ;
*    (r_invest + 1/life_infra(new_trsp_fuel)) / (r + 1/life_infra(new_trsp_fuel))
