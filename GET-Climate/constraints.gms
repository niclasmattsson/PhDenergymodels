#####################################################
#### scenario constraints and parameter settings ####
#####################################################


# moved from GET_7.gms (top)

marg.up(trsp_mode,t)=0;


cap_invest.up("h2", "air_fuel", type, t) $ (year(t) <= 2040) = 0;
#cap_invest.up("petro", "air_fuel", type, t_late)=0;
#capital.up("petro", "air_fuel", type, "2070")=0.3;


*C_tax(t_soon)=0.07*(ord(t_soon)) ;
*C_tax(t_far) =0.5 ;


engines.up(trsp_fuel, engine_type, car_or_truck, t)=trsp_conv(trsp_fuel, engine_type, car_or_truck)*10;
trsp_energy.up(trsp_fuel, engine_type, trsp_mode, t)=trsp_conv (trsp_fuel, engine_type, trsp_mode)* trsp_demand(trsp_mode, t) ;

# WHAT THE FUCK???!!!!!
#annual_cost.lo(t)=2000;
#annual_cost.up(t)=50000;
#en_conv.up(en_in, en_out, type, t)=2000;

# IMPORTANT: these are redefined in GETstart.gms!!! (still here because needed as defaults for the linear model)
max_beccs = 1;
max_nuclear = 1;
bio_potential = 200;

supply_2.up("central_heat", "2010")=0;
supply_2.up("non_solid_heat", "2010")=0;



# moved from GET_7.gms (bottom)


############################################################
###* initialization of capital                          ###*
############################################################

engines.FX(trsp_fuel, engine_type, car_or_truck, init_year) = 0;
engines.FX("petro", "0", "p_car", init_year) = num_veh("p_car", init_year)+0.001 ;
engines.FX("petro", "0", "f_road", init_year) =  num_veh("f_road", init_year)+0.001;
engines.FX("petro", "0", "p_bus", init_year) =  num_veh("p_bus", init_year)+0.001 ;
infra.up(new_trsp_fuel, init_year) = 0.01;

############################################################

trsp_energy.up("air_fuel", engine_type, non_avi, t) =  0    ;
* transportation electricity only for personal trsp w high-speed-train
trsp_energy.FX("elec", "0", "p_air", t) =
     high_speed_train(t)*trsp_demand("p_air", t)/trsp_conv("elec", "0", "p_air");









#####################################################
### technology constraints


#C_capt_agg.up = 600000;
#C_capt_agg.up = 1500000;

* NUCLEAR LIMIT

*EN_CONV.fx("nuclear","elec","0", t) = 2580*3.6/1000/ effic_0("nuclear","0","elec");
*capital.up("nuclear", en_out, "cg", t)=0;

*C_tax(t)=0.500  ;

*atm_ccont.up(t_ext_2100) = 400;
*atm_ccont.up(t)$(ord(t)>7) = 400;

trajec(t)=
*100000
scenario("450ppm",t)
;
#####################################################
### parameter modifications ###

*cost_strg_fos = 0.037;


#####################################################
### initial constraints taken from get5 ###

*MAX_EXP_P("solar", "h2", "0")=6;
init_plant = 0.3;

* minimum f bioenergi som gaar till heat
EN_CONV.lo("BIO","dist_heat","0","2010") = 30;
EN_CONV.lo("BIO","dist_heat","0","2020") = 30;
EN_CONV.lo("BIO","dist_heat","0","2030") = 30;
EN_CONV.lo("BIO","dist_heat","0","2040") = 30;
EN_CONV.lo("BIO","dist_heat","0","2050") = 30;
EN_CONV.lo("BIO","dist_heat","0","2060") = 30;
EN_CONV.lo("BIO","dist_heat","0","2070") = 24;
EN_CONV.lo("BIO","dist_heat","0","2080") = 20;
EN_CONV.lo("BIO","dist_heat","0","2090") = 16;
EN_CONV.lo("BIO","dist_heat","0","2100") = 12;
EN_CONV.lo("BIO","dist_heat","0","2110") = 8;
EN_CONV.lo("BIO","dist_heat","0","2120") = 4;
EN_CONV.lo("BIO","dist_heat","0","2130") = 0;

* figures from IEA, minus högre eff
supply_1.lo("coal1","2010") = 120;
supply_1.lo("oil1","2010") = 163;
supply_1.lo("gas1","2010") = 108;



* INITIAL ENERGY CONVERSION LEVELS

#C_capt_tot.up(t) = 0;

capital.up("MeOH","feed-stock",type,"2010") = 0;
capital.up("bio","MeOH",type,"2010") = 0;
capital.up("solar", en_out, type, "2010")=0;
capital.up("nuclear", en_out, "cg", "2010")=0;
capital.up("nuclear", en_out, "cg", "2020")=0;
capital.up("H2", en_out, type, "2010")=0;
capital.up("pellets",en_out,type,"2010") = 0;
capital.up(en_in,en_out,c_capt,"2010") = 0;

en_conv.lo(en_in, en_out, type, "2010") = init_energy(en_in, en_out, type);


EN_CONV.up("hydro","elec","0","2010") = 12/ effic_0("hydro","0","elec");

* wind
EN_CONV.up("wind","intelec","0","2010") = 1/ effic_0("wind","0","intelec");
EN_CONV.up("wind","intelec","0","2020") = 10/ effic_0("wind","0","intelec");

*cars
engines.up(road_fuel, "hyb", car_or_truck, "2010")=0; #num_veh(car_or_truck,"2010")/20;
engines.up(road_fuel, "BEV", car_or_truck, "2010")=0;
engines.up(road_fuel, "BEV", car_or_truck, "2020")=0;
engines.up(road_fuel, "PHEV", car_or_truck, "2010")=0;
engines.up(road_fuel, "FC", car_or_truck, "2010")=0;
engines.up(road_fuel, "FC", car_or_truck, "2020")=0;
#####################################################


# Upper bound for pumped hydro and CAES (assume pumped hydro 20 EJ, CAES 20 EJ)
# source ETSAP (ref to Taylor 2007, pumped hydro max 1000 GWe), wild guess for CAES
# assume no bound for batteries (backstop)
en_conv.up("intelec","storage","0",t) = 40;
