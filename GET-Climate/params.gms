############################################################
##### Parameter definitions and setting                #####
##### Initilisation of parameter values                #####
##### GET version 6.0                                  #####
############################################################


scalars

Msec_per_year / 31.6 /
t_step        / 10   /

parameters
supply_pot(primary, t)                           max supply potential
effic(energy, en_out, type, t)                   energy conv effic
lf(en_in, type, en_out)                          loadfactor
life_plant(en_in, en_out, type)                  life time
life_eng(trsp_fuel, engine_type, car_or_truck)   life time
lf_infra(new_trsp_fuel)                          loadfactor
vehicle_cost(car_or_truck)                       basic cost for vehicle w gasoline IC engine
t_tech_plant(en_in, en_out, type)                technology developm time
t_tech_eng(road_fuel, engine_type, car_or_truck) technology developm time

OM_cost_fr(en_in, en_out)  operation & maintenance cost as fraction of capital cost

# GET7 fuel prices, converted from $(1990) to $(2010), factor 1.668
#$ontext
price(fuels)               basic fuel prices
    / bio1    3.3
      bio2    4.2
      coal1   2.5
      coal2   3.3
      oil1    5
      oil2    8.3
      gas1    4.2
      gas2    8.4
      nuclear 1.7    /
#$offtext

# IEA fuel prices, "Projected costs of generating electricity" (2010)
$ontext
price(fuels)               basic fuel prices
    / bio1    4.4
      bio2    4.9
      coal1   3.6
      coal2   4.1
      oil1    6
      oil2    8
      gas1    9.8
      gas2    12.3
      nuclear 2.6    /
$offtext

# hydro increased from 15 to 20 EJ (WEO 2011 has 5500 TWh hydro in 2035); the IEA is always conservative
supply_pot_0 (primary)     max supply potential (EJ) - annual (and aggreg for fossils)
    / bio1     50
      bio2     150
      coal1    33000
      coal2    700000
      oil1     12000
      oil2     800
      gas1     10000
      gas2     1000
      nuclear  40000
      wind     40
      hydro    20
      solar    10000 /

# bio changed from 32 to 30 gC/MJ  (IPCC)
emis_fact(energy)           MtonC per EJ
    / bio    30
      coal1  24.7
      coal2  24.7
      oil1   20.5
      oil2   23
      gas1   15.4
      gas2   15.4
      oil    20.5
      CH4    15.4
      coal   24.7  /


# GAS:
# US EPA data: CH4 from natural gas use in 2000 = 972 MtCO2eq = 42.3 MtCH4
# 88.21 Tfeet^3 gas consumption in 2000 = 95.7 EJ, so 42.3/95.7 = 0.442 gCH4/MJgas on average
# check using Howarth (2011, shale gas paper), CH4 emissions = 1.7-6% of total gas used,
# energy density of gas = 55 MJ/kgCH4, so emissions = 0.442*0.055 = 2.4% of consumption, OK!

# COAL:
# US EPA data: CH4 from coal mining in 2000 = 377 MtCO2eq = 16.4 MtCH4
# 4931 Mt coal mined in 2000 = 133 EJ, so 16.4/133 = 0.123 gCH4/MJcoal on average
# check using Howarth (2011, supplement), 0.045*16/12 = 0.06 gCH4/MJ for surface coal,
# nearly 4 times more for coal from deep mines ~= 0.22 gCH4/MJ, so 0.123 gCH4/MJcoal is OK!

# OIL:
# US EPA data: CH4 from oil production in 2000 = 57.4 MtCO2eq = 2.5 MtCH4
# 75.9 Mbarrels/day in 2000 = 162 EJ/yr, so 2.5/162 = 0.015 gCH4/MJoil on average
# check using Howarth (2011, supplement), 0.07*16/12 = 0.093 gCH4/MJ oil use. Inconsistent, use EPA for now!

# BIO:
# find something for both CH4 and N2O!

ch4_emis_fact(energy)		# lifecycle emissions (kton CH4 per EJ)
    / bio    0
      coal1  123
      coal2  123
      oil1   15
      oil2   15
      gas1   442
      gas2   442
      oil    15
      CH4    442
      coal   123  /

n2o_emis_fact(energy)		# lifecycle emissions (kton N2O per EJ)
	/ bio	0	/




C_capt_heat(dec_heat)  max fraction of heat sector using C_capt (CHECK THIS! What have we used before??)
/central_heat     0.7
solid_heat      0.5
non_solid_heat  0.5  /

max_feed(feed)
/CH4      0.1
coal      0.1
oil       0.1
petro     1
MeOH      1/

C_tax(t)  (kUSD per ton C)

r         discount rate
    / 0.05 /
r_invest  interest rate applied to investments
    / 0.05 /

cost_strg_fos   carbon storage cost from fossils (kUSD per ton C)
    / 0.037 /
cost_strg_bio   carbon storage cost from bio energy (kUSD per ton C)
    / 0.073 /
c_bio_trspcost  extra transportation cost applied to bio fuels for BECS (USD per GJ)
    / 0.5 /

C_stor_maxgr  annual growth limit on C storage capacity (Mton per year)
    / 600 /




cogen_fr_h   max fraction of urban heat from cogeneration
    / 0.80 /

interm_fr(en_out)	max fraction of intermittent electricity to different sectors - in addition to 30% in elec
	/	elec			0.30
		H2				0.10
		trsp			0
		central_heat	0
		dist_heat		0
		solid_heat		0
		non_solid_heat	0	/


cost_inv(en_in, en_out, type, t)      time dependent plant investment cost
cost_inv_mod(en_in, en_out, type, t)  d:o adjusted for different investm and discount rates

cost_eng(road_fuel, engine_type, car_or_truck, t)     time dependent vehicle investment cost (vehicle + engine)
cost_eng_0(road_fuel, engine_type, car_or_truck)      initial vehicle investment cost (vehicle + engine)
cost_eng_mod(road_fuel, engine_type, car_or_truck, t) d:o adjusted for different investm and discount rates

# converted from $(1990) to $(2010), factor 1.668
# with life=50, dr=5%, LF=0.7, then cost_infra = 2000 $/kW <=> 5 $/GJ
# Harvey p454:  H2 distribution costs = 8-10 $/GJ  (plus dispensing costs 4-8 $/GJ)
cost_infra(new_trsp_fuel)  infrastr costs (USD per kW)
    / MeOH   830
      H2    4800		# was 2000
      CH4   2500   /

# converted from $(1990) to $(2010), factor 1.668
district_cost  cost to distribute wasteheat to central_heat
         /5/

life_infra(new_trsp_fuel)  life time for infrastructure
    / MeOH    50
      H2      50
      CH4     50   /
cost_infra_mod(new_trsp_fuel)  d:o adjusted for different investm and discount rates

elec_frac_PHEV(car_or_truck)/
p_car   0.65
f_road 0.53
p_bus   0.53/

cap_g_lim   / 0.14 /
init_plant  / 0.06 /
max_exp_p(en_in, en_out, type)

max_inv_infra  infrastructure growth limit (TW per decade)
    / 1 /
infra_g_lim    infrastr relative growth limit
    / 0.15 /
init_infra     initial unrestricted infrastr growth (TW per decade)
    / 0.02 /
eng_g_lim  / 0.075 /

csp_fr  maximum fraction of electrcity demand supplied by CSP
   /0.45/

max_exp_bio bio energy growth limit (TW per decade )
    / 10.0 /
max_exp    primary fuel supply growth limit (TW per decade)
    / 10.0 /

max_solar(heat) maximum solar
/central_heat 0.2
dist_heat  0.5/

max_pump(heat)   maximum heat pumps
/central_heat 0.4
dist_heat  0.6/

max_chip maximum wood chips in industry
   /0.67/

dec_elec(en_in)   electricity requirements for heat generation with C capture
/     bio   0.04
      coal  0.04
      oil   0.03
      CH4   0.025  /

;

scalar
	max_beccs
	max_nuclear
	bio_potential
;

table frac_engine(engine_type, car_or_truck)
         p_car   f_road   p_bus
0          1        1        1
FC         1        1        1
hyb        1        1        1
PHEV       1       0.2      0.3
BEV        0.3      0      0.1  ;

############################################################
$ include "indata.gms";

parameter min_growth(en_out,t);
	min_growth(en_out,t) = init_plant;
	min_growth(sector1,t) = min(init_plant, dem(sector1,t)/Msec_per_year/20);

############################################################

lf_infra(new_trsp_fuel) = 0.7;
life_infra(new_trsp_fuel) = 50;
life_plant(en_in, en_out, type) = 25;
life_plant("hydro", "elec", "0") = 40;
life_eng(trsp_fuel, engine_type, car_or_truck) = 15;

C_tax(t) = 0;
OM_cost_fr(en_in, en_out) = 0.04;

max_exp_p(en_in, en_out, type) = 4;

supply_pot(primary, t) = supply_pot_0(primary);


# converted from $(1990) to $(2010), factor 1.668
vehicle_cost("p_car")  = 33400;
vehicle_cost("f_road") = 133400;
vehicle_cost("p_bus") = 133400;

parameter high_speed_train(t)  fraction of hsp mode using electricity
        / 2010  0.04
          2020  0.04
          2030  0.06
          2040  0.10
          2050  0.14
          2060  0.20
          2070  0.24
          2080  0.26
          2090  0.28
          2100  0.30  /;
high_speed_train(t) $ (year(t) > 2100) = high_speed_train("2100");

########################################################
### time dependent technology costs and efficiencies ###
########################################################

* tech developm time, now all set to 50 years
t_tech_plant(en_in, en_out, type) = 50;
t_tech_eng(road_fuel, engine_type, car_or_truck) = 50;

* time depend costs now disabled
*cost_inv_0(en_in, en_out, type) = cost_inv_base(en_in, type, en_out);
cost_eng_0(road_fuel, engine_type, car_or_truck) = cost_eng_base(road_fuel, engine_type, car_or_truck);

* time dependent efficiency not implemented
effic(en_in, en_out, type, t) = effic_0(en_in, type, en_out);

* Calc of time-dep invest costs, linear decrease from yr 2000 over t_tech yrs,
* from level given by cost_0 to final level cost_base.
cost_inv(en_in, en_out, type, t) = 
#cost_inv_base(en_in, type, en_out);
	max(	cost_inv_base(en_in, type, en_out),
		cost_inv_0(en_in, type, en_out) -
			(cost_inv_0(en_in, type, en_out)-cost_inv_base(en_in, type, en_out)) *
			((ord(t)-1)*t_step/t_tech_plant(en_in, en_out, type))
	);

* D:o, and basic vehicle cost added
cost_eng(road_fuel, engine_type, car_or_truck, t) =cost_eng_base(road_fuel, engine_type, car_or_truck)
             + vehicle_cost(car_or_truck) ;

* max( cost_eng_base(road_fuel, engine_type, car_or_truck),
*    cost_eng_0(road_fuel, engine_type, car_or_truck) -
*    (cost_eng_0(road_fuel, engine_type, car_or_truck)-cost_eng_base(road_fuel, engine_type, car_or_truck))*
*    ((ord(t)-1)*t_step/t_tech_eng(road_fuel, engine_type, car_or_truck)) )
*    + vehicle_cost(car_or_truck);

* modified costs for different discount and investm interest rates
cost_inv_mod(en_in, en_out, type, t) = cost_inv(en_in, en_out, type, t);
*    (r_invest + 1/life_plant(en_in, en_out, type))/(r+1/life_plant(en_in, en_out, type));

cost_eng_mod(road_fuel, engine_type, car_or_truck, t) = cost_eng(road_fuel, engine_type, car_or_truck, t)          ;
*    (r_invest + 1/life_eng(road_fuel, engine_type, car_or_truck))/(r+1/life_eng(road_fuel, engine_type, car_or_truck));

cost_infra_mod(new_trsp_fuel) = cost_infra(new_trsp_fuel)         ;
*    (r_invest + 1/life_infra(new_trsp_fuel)) / (r + 1/life_infra(new_trsp_fuel))

###################################################
###################################################