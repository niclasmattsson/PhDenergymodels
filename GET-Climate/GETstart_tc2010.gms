$eolcom #
$offsymxref offsymlist offuellist offuelxref offlisting offmargin
$lines 0
option solprint = off;
#$onlisting

$set RESULTSFILE latestresults

# Prepare the result spreadsheet and make sure it can be written (it can't if it's open).
$call 'copy /y "results - template.xlsx" %RESULTSFILE%.xlsx'
$if errorlevel 1 $abort "ERROR: Can't copy results-template.xlsx to %RESULTSFILE%.xlsx."

############################################################
# SCENARIO DATA
############################################################

scalar lambda;
lambda = 0.8;

$include GET_7.gms
$include output_declarations.gms

r = 0.05;
csp_fr = 0.20;
max_beccs = 1;
max_nuclear = 0.15;
bio_potential = 200;
C_capt_agg.up = 2000*12/44;

target_year = 2010;					# 2150 for overshoot, 2010 for ceiling target

CO2concentration.up(t_c) = 1500;		# ALWAYS USE THIS  (Joos not valid higher)
final_temp.up = 2;
#tot_cost.up = 826674.680026108 + 1000*209*5;	# B2, dr = 2%
#tot_cost.up = 817891.236252049 + 1000*132*5;	# B2, dr = 2% (with 1% GDP growth after 2100 instead of 1.5%)
#tot_cost.up = 259256.580819488 + 1000*6*1; #+25000; # B2
#tot_cost.up = 257583.708417856 + 1000*25*1.6; #+25000; # A2r

en_conv.lo("coal", "solid_heat", "0", t) $ (year(t) >= 2030) = 20;
en_conv.lo("coal", "elec", "0", t) $ (year(t) >= 2030) = 30;
en_conv.fx("nuclear", "elec", "0", t) = 2700/0.33*3.6/1000;		# fix nuclear at today's level, 2700 TWh
#en_conv.up(en_in, "H2", type, t) $ (year(t) >= 2020) = 0;
en_conv.up("H2", "trsp", type, t) $ (year(t) >= 2020) = 10000;
en_conv.up("H2", "air_fuel", type, t) $ (year(t) >= 2020) = 10000;
#cap_invest.up("nuclear", en_out, type, t) $ (year(t) >= 2020) = 0;
#cap_invest.up("hydro", en_out, type, t) $ (year(t) >= 2020) = 0;
#cap_invest.up("solar", en_out, 'cg', t) $ (year(t) >= 2020) = 0;
#cap_invest.up("solar", en_out, type, t) $ (year(t) >= 2020) = 0;
#cap_invest.up("wind", en_out, type, t) $ (year(t) >= 2020) = 0;
#cap_invest.up("bio", en_out, type, t) $ (year(t) >= 2020) = 0;

supply_pot_0("bio1") = bio_potential * 0.25;
supply_pot_0("bio2") = bio_potential * 0.75;
supply_pot(primary, t) = supply_pot_0(primary);

#capital.fx('solar', 'H2', 'cg', t) = 0;
capital.fx('nuclear', en_out, 'cg', t) = 0;

C_capt_tot.up('2020') = 0.2;
supply_1.lo('coal1','2020') = 166;
supply_1.lo('gas1','2020') = 131;
supply_1.lo('oil1','2020') = 182;
en_conv.lo('coal','elec','0','2020') = (38 - 3.5)/.45;
en_conv.lo('CH4','elec','0','2020') = 15.5/.55;
en_conv.lo('oil','elec','0','2020') = (2.5 - 0.3)/.5;



#$ontext

############################################################
# COLD START
############################################################

# first run the linear GET version (without new climate equations) to get a good starting point
# for the non-linear solver

# Add some quick-and-dirty emission limits so the solution is closer to the second nonlinear run.
#parameter maxemissions(t) / 2010 11.5, 2020 11.5, 2030 11.5, 2040 10, 2050 8.3, 2060 3.2, 2070 2, 2080 1.5 /;
#maxemissions(t) $ (year(t) > 2080) = maxemissions('2080');
#ATM_CCONT.up(t_a) $ (year(t_a) >= 2100) = 420;

C_emission.lo(t_h) = -inf;
C_emission.up(t_h) = inf;
#C_emission.up(t) = maxemissions(t);
C_tax(t) = 10;		# USD per ton C
AbatementCost.fx(t) = 0;

#parameter upper_cost_limit;		# relax cost bound for the linear solution and restore it later
#upper_cost_limit = tot_cost.up;
#tot_cost.up = inf;

option solprint = off;
GET7lin.optfile = 1;
solve GET7lin using LP minimizing tot_cost;

#tot_cost.up = upper_cost_limit;
#display upper_cost_limit, tot_cost.up;

display effic;
abort $ (GET7lin.modelstat > 2) "Bad solve";
display init_capital, capital.l;

# Load a previously saved solution to use as some starting values. A different one, but it often helps anyway.
#execute_load 'savedClimateVariables_UD_feedback_min', CO2emissions, Emissions, CO2concentration, Concentration,
#		RadiativeForcing_CO2, RadiativeForcing, TotalRadiativeForcing, AbatementCost, Temp, Temp_land, Temp_global,
###		RadiativeForcing_CO2, RadiativeForcing, TotalRadiativeForcing, AbatementCost, TempAUO, TempIO, TempDO,
#		lifetime_CH4_by_OH, lifetime_CH4, AbatementFactor, Baseline,
#		deltaCO2ocean, netfluxOcean, netfluxBiosphere, deltaDIC, deltaDICbox, bioNPP, bioReservoir;

#execute_load 'emission_paths', CO2emissions, Emissions;
#CO2emissions.fx(t_a_1) = CO2emissions.l(t_a_1);
#Emissions.fx(nonCO2,t_a) = Emissions.l(nonCO2,t_a);

#AbatementFactor.fx('N2O',GHGsource,tc) = AbatementFactor.l('N2O',GHGsource,tc);
#AbatementFactor.fx('CH4',GHGsource,tc) = AbatementFactor.l('CH4',GHGsource,tc);

############################################################
# RUN MAIN MODEL
############################################################

#Concentration.up('CO2',tc) $ (year(t) >= 2100) = conc_limit;
#CO2concentration.up(t_a_1) $ (year_1(t_a_1) >= 2100) = conc_limit;


#$offtext



# recalibrate ocean temperature response and historic radiative forcing from aerosols,
# if climate sensitivity (lambda) has changed
# comment out for UDEBM
$ontext
$include CalibrateTemperatureFaster.gms
	thermCapAUO = ThermCap_AUO.l;
	thermCapIO = ThermCap_IO.l;
	transRateIO = TransRate_IO.l;
	thermCapDO = ThermCap_DO.l;
	transRateDO = TransRate_DO.l;
$include CalibrateForcing_UDEBM_tc2010.gms
	forcingScale = ForcingMult.l;
display thermCapAUO, thermCapIO, transRateIO, thermCapDO, transRateDO, forcingScale;
$offtext

# now solve the full GET model with non-linear climate equations
ATM_CCONT.up(t_a) $ (year(t_a) >= 2100) = inf;
C_emission.fx(t_h) = 0;
C_emission.up(t) = inf;
C_tax(t) = 0;
AbatementCost.lo(t) = -inf;
AbatementCost.up(t) = inf;
Baseline.l(nonCO2,GHGsource,t) =
		SRESbaseline(nonCO2,GHGsource,t) $ sameas(GHGsource, 'nonenergy') +
		emissionFactor(nonCO2,GHGsource) * (
			(supply_1.l('gas1',t) + supply_1.l('gas2',t)) $ sameas(GHGsource, 'gas') +	
			(supply_1.l('oil1',t) + supply_1.l('oil2',t)) $ sameas(GHGsource, 'oil') + 
			(supply_1.l('coal1',t) + supply_1.l('coal2',t)) $ sameas(GHGsource, 'coal') + 
			(supply_1.l('bio1',t) + supply_1.l('bio2',t)) $ sameas(GHGsource, 'bio')
		);

AbatementFactor.fx('N2O','bio',t) $ (year(t) > 2010) = 0;


#option limrow = 1e5;
#GET7full.scaleopt = 1;
#option solprint = on;

#GET7full.workfactor = 1.5;
#GET7full.optfile = 1;

$ontext
# Often faster with an extra solve step ...
# First solve with abatement fixed at max
AbatementFactor.fx(nonCO2,GHGsource,t) $ (year(t) > 2010) = min(85, (year(t)-2010) * abateLimit);
solve GET7full using NLP minimizing tot_cost;
# Then solve with unconstrained abatement
AbatementFactor.lo(nonCO2,GHGsource,t) = 0;
AbatementFactor.up(nonCO2,GHGsource,t) = 85;
AbatementFactor.fx(nonCO2,GHGsource,'2010') = eps;
$offtext

#execute_loadpoint 'Savepoint_B2base_B1_over1.2_100EJ.gdx';
#execute_loadpoint 'Savepoint_B2base_B1_over1.2_DR2b.gdx';
#execute_loadpoint 'Savepoint_B2base_DR2b_BAU.gdx';
#execute_loadpoint 'Savepoint_B2base_B1_over1.2.gdx';
#execute_loadpoint 'Savepoint_A2r_B1_over1.4.gdx';

# Fix starting system at levels from linear model (quick hack, this should be in init_capital)
en_conv.fx(energy, en_out, type, '2010') = en_conv.l(energy, en_out, type, '2010');
capital.fx(en_in,en_out,type,'2010') = capital.l(en_in,en_out,type,'2010');

#conopt3 is faster at finding a feasible solution, but conopt4 is much faster at finding the optimum
option nlp = conopt;
solve GET7full using NLP minimizing dummyconc2010;
#option savepoint = 1;
option nlp = conopt4;
solve GET7full using NLP minimizing tot_cost;
#solve GET7full using NLP minimizing final_temp;

display annual_cost.l,AbatementCost.l;
parameter totcost,abatecost;
totcost = sum(t $ (year(t) <= 2140), t_step * (cost_fuel.l(t) + cost_cap.l(t) + OM_cost.l(t) + cost_C_strg.l(t) +
						cost_C_bio_trsp.l(t) + tax.l(t))/((1+r)**(t_step*(ord(t)-1))));
abatecost = sum(t $ (year(t) <= 2140), t_step * (AbatementCost.l(t))/((1+r)**(t_step*(ord(t)-1))))

display totcost,abatecost;

#parameter Temp_ocean(t_a_1);
#Temp_ocean(t_a_1) = Temp.l('L1',t_a_1);
#display forcingScale, Temp.l, Temp_land.l, Temp_ocean, CO2concentration.l, deltaCO2ocean.l, netfluxOcean.l;

#parameter t_bal(t);
#t_bal(t) = sum((energy,type), en_conv.l(energy, 'trsp', type, t) * effic(energy, 'trsp', type, t)) - sum((trsp_fuel,trsp_mode,engine_type), trsp_energy.l(trsp_fuel, engine_type, trsp_mode, t));
#display t_bal;

$ontext
option solprint = on;
tot_cost.up = 147480.9 + 20000;
solve GET7full using NLP minimizing final_temp;
price_emission(t) = emission_Q.m(t);
price_deliv(sector,t) = deliv_q.m(sector,t);
price_marg(trsp_mode,t) = marg.m(trsp_mode,t);
price_supply(primary,t) = supply_1_Q.m(primary,t);
$include output.gms
$offtext

#execute_unload 'savedClimateVariables_UD_feedback_3', CO2emissions, Emissions, CO2concentration, Concentration,
#		RadiativeForcing_CO2, RadiativeForcing, TotalRadiativeForcing, AbatementCost, Temp, Temp_land, Temp_global,
###		RadiativeForcing_CO2, RadiativeForcing, TotalRadiativeForcing, AbatementCost, TempAUO, TempIO, TempDO,
#		lifetime_CH4_by_OH, lifetime_CH4, AbatementFactor, Baseline,
#		deltaCO2ocean, netfluxOcean, netfluxBiosphere, deltaDIC, deltaDICbox, bioNPP, bioReservoir;

#execute_unload 'emission_paths', CO2emissions, Emissions;
#$stop

############################################################
#  FINAL RE-RUN
############################################################

# save some shadow prices before they get clobbered in the fixed-variable re-run
price_emission(t) = emission_Q.m(t);
price_deliv(sector,t) = deliv_q.m(sector,t);
price_marg(trsp_mode,t) = marg.m(trsp_mode,t);
price_supply(primary,t) = supply_1_Q.m(primary,t);

# fix all variables at their current values (up to 2170) and force a continued emission decline to 2300,
# then solve one last time to get final results

#$include fix_get_variables.gms
##C_emission.fx(t_a) $ (year(t_a) > 2170) =
##		(0*C_emission.l('2140')+2*C_emission.l('2170'))/2 * 1;  #0.998**(year(t_a)-2170);
##Baseline.fx(nonCO2,GHGsource,tc) $ (year(tc) > 2170) = Baseline.l(nonCO2,GHGsource,'2170');
##AbatementFactor.fx(nonCO2,GHGsource,tc) $ (year(tc) > 2170) =
##		min(100, AbatementFactor.l(nonCO2,GHGsource,'2170') * 1); #1.0003**(year(tc)-2170));
#TempAUO.up(t_a_1) $ (year_1(t_a_1) > 2170) = inf;
##Concentration.up('CO2',tc) $ (year(tc) > 2170) = inf;
#CO2concentration.up(t_a_1) $ (year_1(t_a_1) > 2170) = inf;

#option limrow = 1e5;
#GET7full.optfile = 2;
#option solprint = on;
#solve GET7full using NLP minimizing tot_cost;
#solve GET7full using NLP minimizing final_temp;
#option solprint = off;


#max_beccs = 1;
#lambda = 1.2;
#final_temp.up = 9;
#CO2emissions.fx(t_a_1) = CO2emissions.l(t_a_1);
#Emissions.fx(nonCO2,tc) = Emissions.l(nonCO2,tc);
#solve GET7full using NLP minimizing tot_cost;


display GET7full.modelstat;

#$include monte_carlo.gms
#$include output.gms
$include output-UDEBM-tc2010.gms
display init_capital, capital.l;

display emissionHistory, deforest_CO2, CO2emissions.l;

parameter cumul_emissions, beccs_share, temp_max, ccs90_year;
parameter cum_ccs(t), cum_beccs(t);
cumul_emissions = sum(t_c $ (year_c(t_c) >= 2010 and year_c(t_c) < 2150), CO2emissions.l(t_c));
#cumul_emissions = sum(t_a_1 $ (year_1(t_a_1) >= 2010 and year_1(t_a_1) < 2150), CO2emissions.l(t_a_1));
#temp_max = smax(t_a_1 $ (year_1(t_a_1) <= 2150), TempAUO.l(t_a_1));
#temp_max = smax(t_a_1 $ (year_1(t_a_1) <= 2150), Temp_global.l(t_a_1));
temp_max = smax(t_a_1 $ (year_1(t_a_1) <= 2150), Temp_global.l(t_a_1));
alias (t, tt);
beccs_share = sum(t, ccs_source("bio",t)) / max(0.01, sum((ccs_fuel,t), ccs_source(ccs_fuel,t)));
cum_ccs(t) = sum((ccs_fuel,tt) $ (year(tt) <= year(t)), ccs_source(ccs_fuel,tt));
cum_beccs(t) = sum(tt $ (year(tt) <= year(t)), ccs_source("bio",tt));
ccs90_year = smin(t $ (cum_ccs(t) >= 0.9*600/10), year(t));
display cumul_emissions,temp_max,beccs_share,ccs90_year;