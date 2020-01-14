############################################################
##### GET version 7.0                                  #####
#####                                                  #####
############################################################


option iterlim = 1000000;
option reslim = 1000000;
option limrow = 0;
option limcol = 0;

option nlp = conopt;

############################################################

$include "sets_tc2010.gms";
#$include "sets.gms";

$include "params.gms";

scalar elast /1/

############################################################
#################### EQUATIONS #############################
############################################################

$include "declare.gms";

# OTHER EQUATIONS MOVED TO BEGINNING OF constraints.gms


############################################################
##### supply and conversion to delivered energy forms ######
############################################################
supply_pot_Q(primary, t)..
    supply_pot(primary, t) =G= supply_1(primary, t);

supply_1_Q(primary, t)..
    supply_1(primary, t)   =E= sum( (type, en_out), en_conv(primary, en_out, type, t) );

supply_2_Q(second_in, t)..
    supply_2(second_in, t) =e= sum( (type, en_out_not_trsp), en_conv(second_in, en_out_not_trsp, type, t) );

supply_loop_Q(second_in,t)..
    supply_2(second_in, t) =L= energy_prod(second_in, t);

energy_prod_Q(en_out, t)..
    energy_prod(en_out, t) =E= sum( (type, en_in),
         en_conv(en_in, en_out, type, t) * effic(en_in, en_out, type, t) )+supply_sec(en_out,t);

*aggregate fossil supply lim
reserves_Q(fossil1)..
	sum(t, t_step*supply_1(fossil1, t)) =L= supply_pot_0(fossil1);

############################################################
### energy delivered                                     ###
############################################################

energy_deliv_Q(en_out, t)..
    energy_deliv(en_out, t) =e= energy_prod(en_out, t) - supply_2(en_out, t) - extra_elec(en_out,t) ;

supply_sec_Q(energy,t)..
   supply_sec(energy,t) =e=
   		sum( (en_in, type, en_out), en_conv(en_in, en_out, type, t)*heat_effic(en_in, type, en_out, energy) );

############################################################
### transportation module                                ###
############################################################
trsp_nonelec_Q(trsp_fuel_nonel, t)..
    sum( (trsp_mode, engine_type), trsp_energy(trsp_fuel_nonel, engine_type, trsp_mode, t) ) =e=
#         energy_deliv(trsp_fuel_nonel, t);					# bug here!
			sum(type, energy_deliv(trsp_fuel_nonel, t) * effic(trsp_fuel_nonel, "trsp", type, t));

transp_q(trsp_fuel,t)..
         sum( (trsp_mode, engine_type), trsp_energy(trsp_fuel, engine_type, trsp_mode, t) )=e=
         sum(type, en_conv(trsp_fuel, "trsp", type, t) * effic(trsp_fuel, "trsp", type, t));

trsp_elec_Q(end_and_trsp,t)..
    sum( (trsp_mode, engine_type), trsp_energy(end_and_trsp, engine_type, trsp_mode, t) ) =E=
#        extra_elec(end_and_trsp,t);						# bug here!
			sum(type, extra_elec(end_and_trsp,t) * effic(end_and_trsp, "trsp", type, t));

trsp_demand_Q(trsp_mode, t)..
    trsp_demand(trsp_mode, t)+marg(trsp_mode,t) =e= sum( (trsp_fuel, engine_type),
   	    trsp_energy(trsp_fuel, engine_type, trsp_mode, t)*trsp_conv(trsp_fuel, engine_type, trsp_mode) );

vehicle_lim_Q(trsp_fuel, non_phev, car_or_truck, t)..
    trsp_energy(trsp_fuel, non_phev, car_or_truck, t) =l=
        engines(trsp_fuel, non_phev, car_or_truck, t)/num_veh(car_or_truck, t)*
        (trsp_demand(car_or_truck, t))/(trsp_conv(trsp_fuel, non_phev, car_or_truck)+1e-8);

vehicle_lim_PHEV_Q(road_fuel_liquid,engine_type, car_or_truck, t)..
    trsp_energy(road_fuel_liquid, "PHEV", car_or_truck, t) =e=
        engines(road_fuel_liquid, "PHEV", car_or_truck, t)/
           num_veh(car_or_truck, t)*(1-elec_frac_PHEV(car_or_truck))*
              trsp_demand(car_or_truck, t)/(trsp_conv(road_fuel_liquid, "PHEV", car_or_truck)+1e-8);

elec_frac_PHEV_Q(car_or_truck,  engine_type,t)..
     sum(road_fuel_liquid, trsp_energy(road_fuel_liquid, "PHEV", car_or_truck, t)*
         trsp_conv (road_fuel_liquid, "PHEV", car_or_truck))/(1-elec_frac_PHEV(car_or_truck)) =e=
#            (trsp_energy( "elec", "PHEV", car_or_truck, t) + trsp_energy( "intelec", "PHEV", car_or_truck, t)) *
             trsp_energy( "elec", "PHEV", car_or_truck, t) *
               	trsp_conv ("elec", "PHEV", car_or_truck)/(elec_frac_PHEV(car_or_truck));

lim_elec_veh(car_or_truck,elec_veh,t)..
         sum(trsp_fuel, engines(trsp_fuel, elec_veh, car_or_truck, t))=l=
          frac_engine(elec_veh, car_or_truck)*num_veh(car_or_truck, t) ;

q_sea( engine_type, heavy_mode , t) $ (year(t) <= 2040) ..
         trsp_energy("H2", engine_type, heavy_mode , t) =e= 0;

#interm_trsp_max_Q(elec_veh, car_or_truck, t) ..
#    trsp_energy("intelec", elec_veh, car_or_truck, t) =L= interm_fr("trsp") *
#    	(trsp_energy("intelec", elec_veh, car_or_truck, t) + trsp_energy("elec", elec_veh, car_or_truck, t));

# WHAT THE FUCK!!!!!!
#q_sea_petrol( engine_type, heavy_mode , t_late)..
#         trsp_energy("petro", engine_type, heavy_mode , t_late)=e=0;


############################################################
### balance heat and electr demands                      ###
############################################################

Deliv_Q(sector, t)..
    energy_deliv(sector, t) =e= dem(sector, t);

############################################################
### use limited by capital                               ###
############################################################

capital_lim_Q(en_in, en_out, type, t)..
    en_conv(en_in, en_out, type, t) * effic(en_in, en_out, type, t) =L=
    	capital(en_in, en_out, type, t) * lf(en_in, type, en_out) * Msec_per_year;
#    	+ sum((elec_veh, car_or_truck), trsp_energy("elec", elec_veh, car_or_truck, t))
#    			$ (sameas(en_in,"intelec") and sameas(en_out,"elec") and sameas(type,"cg"));

infra_lim_Q(new_trsp_fuel, t)..
    sum(type, en_conv(new_trsp_fuel, "trsp", type, t)* effic(new_trsp_fuel, "trsp", type, t))
          =L= infra(new_trsp_fuel, t)*lf_infra(new_trsp_fuel)*Msec_per_year;


############################################################
### investments and depreciation                         ###
### investments are available directly                   ###
############################################################

init_invest_Q(en_in, en_out, type, init_year)..
    capital(en_in, en_out, type, init_year) =E= init_capital(en_in, en_out, type)
                                       + cap_invest(en_in, en_out, type, init_year);

capital_Q(en_in, en_out, type, t+1)..
    capital(en_in, en_out, type, t+1) =E= t_step * cap_invest(en_in, en_out, type, t+1)
           + capital(en_in, en_out, type, t)*exp(t_step*log(1-1/life_plant(en_in, en_out, type)));
#	capital(en_in, en_out, type, t) =E= t_step * cap_invest(en_in, en_out, type, t)
#           + capital(en_in, en_out, type, t)*(1 - 1/life_plant(en_in, en_out, type))**t_step;
#           + init_capital(en_in, en_out, type)*(1 - (1 - 1/life_plant(en_in, en_out, type))**t_step);

engines_Q(trsp_fuel, engine_type, car_or_truck, t+1)..
    engines(trsp_fuel, engine_type, car_or_truck, t+1) =E= t_step * eng_invest(trsp_fuel, engine_type, car_or_truck, t+1)
           + engines(trsp_fuel, engine_type, car_or_truck, t)*
             exp(t_step*log(1-1/life_eng(trsp_fuel, engine_type, car_or_truck)));

infra_Q(new_trsp_fuel, t+1)..
    infra(new_trsp_fuel, t+1) =E= t_step * infra_invest(new_trsp_fuel, t+1)
           + infra(new_trsp_fuel, t) * exp(t_step*log(1-1/life_infra(new_trsp_fuel)));


############################################################
### C cycle model                                        ###
############################################################

#$include "climate.gms";
#$include "climate-Joos.gms";
$include "climate-Joos-UDEBM-feedback-tc2010-implicit.gms";
#$include "climate-Joos-UDEBM-feedback.gms";
$include "c_mod.gms";

############################################################
### annual and total costs                               ###
############################################################

cost_fuel_Q(t)..
    cost_fuel(t) =E= sum(fuels, supply_1(fuels, t)*price(fuels))+dist_cost(t);

cost_cap_Q(t)..
    cost_cap(t) =E=
    sum( (en_in, en_out, type),
        cap_invest(en_in, en_out, type, t)*cost_inv_mod(en_in, en_out, type, t) )+
    sum( (road_fuel, engine_type, car_or_truck),
        eng_invest(road_fuel, engine_type, car_or_truck, t)*cost_eng(road_fuel, engine_type, car_or_truck, t) )+
    sum( new_trsp_fuel,
        infra_invest(new_trsp_fuel, t)*cost_infra_mod(new_trsp_fuel) );

cost_C_strg_Q(t)..
    cost_C_strg(t) =E=   sum( (c_fuel, en_out, C_capt),
    	en_conv(c_fuel, en_out, C_capt, t)*emis_fact(c_fuel)*capt_effic(c_fuel,c_capt,en_out) ) * cost_strg_fos
         + sum( ( en_out, C_capt),
         en_conv("bio", en_out, C_capt, t)*emis_fact("bio")*capt_effic("bio",c_capt,en_out) ) * cost_strg_bio;

tax_Q(t)..
    tax(t) =E= C_emission(t)*C_tax(t);

OM_cost_Q(t)..
    OM_cost(t) =E= sum( (en_in, en_out, type), OM_cost_fr(en_in, en_out) * cost_inv_mod(en_in, en_out, type, t) *
        en_conv(en_in, en_out, type, t) * effic(en_in, en_out, type, t) / Msec_per_year/(lf(en_in, type, en_out)+1e-8)) ;

dist_cost_Q(t)..
      dist_cost(t)=e=sum( (en_in, type, en_out), en_conv(en_in, en_out, type, t)*infra_cost(en_in, type, en_out) )
         +supply_sec("central_heat",t)*district_cost;

C_bio_trsp_Q(t)..
    cost_C_bio_trsp(t) =E= sum( (en_out, C_capt), en_conv("bio", en_out, C_capt, t) ) * c_bio_trspcost;

Salvage_value..
    salvage =E= 1 * 1/t_step * sum((en_in, en_out, type, t) $ (ord(t) eq card(t)),
    		capital(en_in, en_out, type, t) * (1 - 1/life_plant(en_in, en_out, type))**t_step *
    		cost_inv_mod(en_in, en_out, type, t) / (1+r)**t_step
    	);

annual_cost_Q(t)..
    annual_cost(t) =E= cost_fuel(t) + cost_cap(t) + OM_cost(t) + cost_C_strg(t) +
						cost_C_bio_trsp(t) + tax(t) + AbatementCost(t) - salvage $ (ord(t) eq card(t));

tot_cost_Q..
    tot_cost =E= sum(t, t_step * annual_cost(t)/((1+r)**(t_step*(ord(t)-1))));


############################################################
############ various restrictions ##########################
############################################################
cogen_e_Q(t)..
    sum( (cg_fuel, cg_type), en_conv(cg_fuel, "elec", cg_type, t)*
                 heat_effic (cg_fuel, cg_type, "elec", "central_heat")) =L= cogen_fr_h * dem("central_heat",t);

interm_max_Q(t)..
    en_conv("intelec", "elec", "0", t) =L= interm_fr("elec") * energy_prod("elec", t);

#interm_max_Q(sector, t) $ (not sameas(sector,"elec")) ..
#    en_conv("intelec", sector, "0", t) =L= 
#    	interm_fr(sector) * (en_conv("intelec", sector, "0", t) + en_conv("elec", sector, "0", t));

CSP_max_Q(t)..
    en_conv("solar", "elec", "cg", t)  =L= csp_fr * energy_prod("elec", t);
#        csp_fr *(sum((en_in, type),en_conv(en_in, "elec", type,t)*effic(en_in, "elec", type,t)));

max_nuclear_q(t) $ (year(t) >= 2020)..
    sum(type, en_conv("nuclear","elec",type,t)*effic("nuclear","elec",type,t)) =l= max_nuclear * dem("elec",t);

max_solar_q(heat, t)..
    en_conv("solar", heat, "0",t)=l=dem(heat,t)*max_solar(heat)     ;

max_heat_pump(heat,t)..
    en_conv("elec", heat, "0",t)=l=dem(heat,t)*max_pump(heat)     ;

max_chips(t)..
     sum(type,  en_conv("bio", "solid_heat", type,t)*effic("bio", "solid_heat", type, t))=l=dem("solid_heat",t)*max_chip  ;

max_feed_stock(feed,t)..
     sum(type,  en_conv(feed, "feed-stock", type,t))=l=dem("feed-stock",t)*max_feed(feed)  ;

### primary supply growth lim
supp_lim_Q(fuels, t+1)..  supply_1(fuels, t+1) =L=
    supply_1(fuels, t) * exp(t_step*log(1+cap_g_lim)) + init_plant*Msec_per_year;

supp_lim2_Q(fossil, t+1)..  supply_1(fossil, t+1) =L=
    supply_1(fossil, t) + max_exp*Msec_per_year;

supp_lim3_Q(t+1)..  supply_1("bio2", t+1) =L=
    supply_1("bio2", t) + max_exp_bio*Msec_per_year;

### infrastructure restriction ###
infra_lim1_Q(new_trsp_fuel, t+1).. infra(new_trsp_fuel, t+1) =L=
    infra(new_trsp_fuel, t) * exp(t_step*log(1+infra_g_lim))+init_infra ;

infra_lim2_Q(new_trsp_fuel, t+1).. infra(new_trsp_fuel, t+1) =L=
    infra(new_trsp_fuel, t) + max_inv_infra/lf_infra(new_trsp_fuel);


eng_g_lim_Q(engine_type,car_or_truck, t+1)..
         sum((trsp_fuel),eng_invest(trsp_fuel, engine_type, car_or_truck, t)) =L=
     sum((trsp_fuel),eng_invest(trsp_fuel, engine_type, car_or_truck, t-1))
         * exp(t_step*log(1+eng_g_lim))+num_veh(car_or_truck,t)/50  ;

### capital growth limitations

cap_g_lim_Q(en_in, en_out, type, t+1)..  capital(en_in, en_out, type, t+1) =L=
#    capital(en_in, en_out, type, t) * exp(t_step*log(1+cap_g_lim))+init_plant ;
    capital(en_in, en_out, type, t) * exp(t_step*log(1+cap_g_lim)) + min_growth(en_out,t);

cap_g2_lim_Q(en_in, sector, type, t+1)..  capital(en_in, sector, type, t+1) =L=
#    capital(en_in, sector1, type, t) * exp(t_step*log(1+cap_g_lim))+dem(sector1,t)/Msec_per_year/20  ;
    capital(en_in, sector, type, t) + max_exp;


############################################################
### emissions, capture and storage                       ###
############################################################

emission_Q(t)..
    C_emission(t) =E= 1/1000 * sum( fossil, emis_fact(fossil) * supply_1(fossil, t)) - C_capt_tot(t);

hist_emission(t_h)..
    C_emission(t_h) =E= 1/1000 * hist_fos_emis(t_h);

#agg_emis_Q..
#    agg_emis =E= sum(t, t_step * C_emission(t));

#annual_emis(t) $ (year(t) >= 2060) ..
#    C_emission(t) =l= trajec(t);

### carbon capture and storage ###

C_capt_tot_Q(t)..
    C_capt_tot(t) =E=  1/1000 * sum( (ccs_fuel, en_out, C_capt),
            en_conv(ccs_fuel, en_out, C_capt, t)*emis_fact(ccs_fuel)*capt_effic(ccs_fuel,c_capt,en_out) )  ;

C_capt_agg_Q..
    C_capt_agg =E= sum(t, C_capt_tot(t))*t_step;

C_stor_maxgr_eq(t+1)..
    C_capt_tot(t+1) =L= C_capt_tot(t) + C_stor_maxgr * t_step;

q_max_beccs(t)..
     sum((c_capt,en_out), en_conv("bio", en_out,c_capt,t)) =l=
     				(supply_pot_0("bio1") + supply_pot_0("bio2")) * max_beccs  ;

elec_dec_Q(t)..
     elec_decarb(t) =E= sum( (fuels, dec_heat) , en_conv(fuels, dec_heat,"dec", t) * dec_elec(fuels) );

heat_dec_Q(dec_heat, t)..
     sum( (en_in, C_capt ), en_conv(en_in, dec_heat, C_capt, t)*effic(en_in, dec_heat, C_capt, t))
     							=l= dem(dec_heat,t) * C_capt_heat(dec_heat);


#parameter coallimit(t);
#coallimit(t) = 999;
#coallimit('2030') = 159;
#coallimit('2040') = 120;
#coallimit('2050') = 81;

#equation extra_coal_limit(t);
#extra_coal_limit(t)..
#		sum((en_out,non_ccs), en_conv('coal', en_out, non_ccs, t)) =l= coallimit(t);

##############################################################################

model GET7lin /	supply_pot_Q, supply_1_Q, supply_2_Q, supply_loop_Q, energy_prod_Q, reserves_Q,
				energy_deliv_Q, supply_sec_Q, trsp_nonelec_Q, transp_q, trsp_elec_Q, trsp_demand_Q,
				vehicle_lim_Q, vehicle_lim_PHEV_Q, elec_frac_PHEV_Q, lim_elec_veh, q_sea,
				Deliv_Q, capital_lim_Q, infra_lim_Q, init_invest_Q, capital_Q, engines_Q, infra_Q,
				cost_fuel_Q, cost_cap_Q, cost_C_strg_Q, tax_Q, OM_cost_Q, dist_cost_Q, C_bio_trsp_Q,
				annual_cost_Q, tot_cost_Q, cogen_e_Q, interm_max_Q, CSP_max_Q, max_solar_q, max_heat_pump,
				max_chips, max_feed_stock, supp_lim_Q, supp_lim2_Q, supp_lim3_Q, infra_lim1_Q, infra_lim2_Q,
				eng_g_lim_Q, cap_g_lim_Q, cap_g2_lim_Q, emission_Q, C_capt_tot_Q, Salvage_value,
				C_capt_agg_Q, C_stor_maxgr_eq, q_max_beccs, elec_dec_Q, heat_dec_Q, max_nuclear_q,
#				interm_elec_max_Q, interm_trsp_max_Q,
#				extra_coal_limit,
				hist_emission, CTRBE, ATM_CCONTE				# agg_emis_Q, annual_emis, 
			/;

model GET7full / supply_pot_Q, supply_1_Q, supply_2_Q, supply_loop_Q, energy_prod_Q, reserves_Q,
				energy_deliv_Q, supply_sec_Q, trsp_nonelec_Q, transp_q, trsp_elec_Q, trsp_demand_Q,
				vehicle_lim_Q, vehicle_lim_PHEV_Q, elec_frac_PHEV_Q, lim_elec_veh, q_sea,
				Deliv_Q, capital_lim_Q, infra_lim_Q, init_invest_Q, capital_Q, engines_Q, infra_Q,
				cost_fuel_Q, cost_cap_Q, cost_C_strg_Q, tax_Q, OM_cost_Q, dist_cost_Q, C_bio_trsp_Q,
				annual_cost_Q, tot_cost_Q, cogen_e_Q, interm_max_Q, CSP_max_Q, max_solar_q, max_heat_pump,
				max_chips, max_feed_stock, supp_lim_Q, supp_lim2_Q, supp_lim3_Q, infra_lim1_Q, infra_lim2_Q,
				eng_g_lim_Q, cap_g_lim_Q, cap_g2_lim_Q, emission_Q, C_capt_tot_Q, Salvage_value,
				C_capt_agg_Q, C_stor_maxgr_eq, q_max_beccs, elec_dec_Q, heat_dec_Q, max_nuclear_q,
#				interm_elec_max_Q, interm_trsp_max_Q,
				Emissions_CO2, Emissions_CH4, Emissions_N2O, Concentration_CO2, OceanDIC_box, OceanDIC_total,
				CO2ocean, TotalFluxToOcean, NetPrimaryProduction, TerrestrialBiosphere_box, 
				TotalFluxToBiosphere, Concentration_CH4, Concentration_N2O, Decay_hydroxyl, Lifetime_CH4_total,
				RF_CO2, RF_CH4, RF_N2O, RF_strat_H2O, RF_Ozone_CH4, RF_tot,
#				TemperatureAUO, TemperatureIO, TemperatureDO,
				Temperature_L1, Temperature_L2, Temperature_other, Temperature_L15,
				Temperature_land, Temperature_global,
				Total_cost_abate, Model_baseline, Abatement_constraint_1, Abatement_constraint_2,
                Emission_SecondDerivative_1, Emission_SecondDerivative_2, dummy,
#				extra_coal_limit,				
				final_temp_Q		#, TempLimit
			/;

#				Emissions_CO2, Emissions_CH4, Emissions_N2O, Concentration_CO2, Concentration_CH4,
#				Concentration_N2O, Decay_hydroxyl, Lifetime_CH4_total, RF_CO2, RF_CH4, RF_N2O, RF_strat_H2O,
#				RF_Ozone_CH4, RF_tot, TemperatureAUO, TemperatureIO, TemperatureDO, Total_cost_abate,
#				Model_baseline, Abatement_constraint_1, Abatement_constraint_2, final_temp_Q

##############################################################################

capital.fx(en_in, en_out, type, t) $ (effic_0(en_in, type, en_out) eq 0) = 0;
cap_invest.fx(en_in, en_out, type, t) $ (effic_0(en_in, type, en_out) eq 0) = 0;
en_conv.fx(en_in, en_out, type, t) $ (effic_0(en_in, type, en_out) eq 0) = 0;

$include "constraints.gms"
