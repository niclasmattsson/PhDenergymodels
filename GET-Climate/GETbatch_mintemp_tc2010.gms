$eolcom #


# IMPORTANT!!! Run this using GETbatch_start.gms



############################################################
# INITIALIZATION AND CALIBRATION
############################################################

# Read externally generated input data
$include scenario_data.gms

# Make special compile-time variables for results filename
$eval hhh input_use_H2
$eval ccc input_max_cost
$eval sss input_max_storage
$eval bbb input_max_beccs
$eval ppp input_bio_potential
$eval lll input_lambda
$eval ttt input_max_temp
$eval xxx input_tax_start
$eval ggg input_tax_growth

$set RESULTSFILE tax_H%hhh%_S%sss%_C%ccc%_B%bbb%_P%ppp%_L%lll%_T%ttt%_X%xxx%_G%ggg%
display "Filename: %RESULTSFILE%";

# Prepare the result spreadsheet and make sure it can be written (it can't if it's open).
$call 'copy /y "results - template.xlsx" %RESULTSFILE%.xlsx'
$if errorlevel 1 $abort "ERROR: Can't copy results-template.xlsx to %RESULTSFILE%.xlsx."

############################################################
# SCENARIO DATA
############################################################

scalar lambda;
lambda = input_lambda;

$include GET_7.gms
$include output_declarations.gms

max_beccs = max(0, input_max_beccs);
bio_potential = input_bio_potential;
C_tax(t) = input_tax_start * (1+input_tax_growth)**(year(t)-2010);
target_year = 2010 + 140 $ (input_max_temp ge 0);
#target_year = 2010 + 90 $ (input_max_temp ge 0);
CO2concentration.up(t_c) = 1500;		# ALWAYS USE THIS  (Joos not valid higher)
final_temp.up = abs(input_max_temp);
tot_cost.up = 259256.580819488 + 1000*input_max_cost;	# B2
#tot_cost.up = 826674.680026108 + 1000*input_max_cost/25*209;	# B2, dr = 2%
#tot_cost.up = 817891.236252049 + 1000*input_max_cost/25*132;	# B2, dr = 2% (with 1% GDP growth after 2100 instead of 1.5%)
#tot_cost.up = 619653.906385909 + 1000*input_max_cost/25*84.5;	# B2, dr = 2.5% (with 1% GDP growth after 2100 instead of 1.5%)
#tot_cost.up = 489644.38078591 + 1000*input_max_cost/25*59.5;	# B2, dr = 3% (with 1% GDP growth after 2100 instead of 1.5%)
#tot_cost.up = 257583.708417856 + 1000*input_max_cost;	# A2r

#en_conv.lo("coal", "solid_heat", "0", t) $ (year(t) >= 2030) = 20;
#en_conv.lo("coal", "elec", "0", t) $ (year(t) >= 2030) = 30;
#TempAUO.up(t_a_1) $ (year_1(t_a_1) >= 2150) = input_max_temp;
C_capt_agg.up = input_max_storage*12/44 * min(1, input_max_beccs + 1);
en_conv.fx("nuclear", "elec", "0", t) = 2700/0.33*3.6/1000;		# fix nuclear at today's level, 2700 TWh
en_conv.up(en_in, "H2", type, t) $ (year(t) >= 2020) = input_use_H2*10000;
en_conv.up("H2", "trsp", type, t) $ (year(t) >= 2020) = (input_use_H2 ne 0.5)*10000;
en_conv.up("H2", "air_fuel", type, t) $ (year(t) >= 2020) = (input_use_H2 ne 0.5)*10000;

r = 0.05;
csp_fr = 0.20;
max_nuclear = 0.15;

supply_pot_0("bio1") = bio_potential * 0.25;
supply_pot_0("bio2") = bio_potential * 0.75;
supply_pot(primary, t) = supply_pot_0(primary);

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
#C_tax(t) = %carbontaxmult% * 10 * input_max_cost/1000;	#scale tax to avoid infeasibility in LP with low tot_cost.up
AbatementCost.fx(t) = 0;

#parameter upper_cost_limit;		# relax cost bound for the linear solution and restore it later
#upper_cost_limit = tot_cost.up;
#tot_cost.up = inf;

option solprint = off;
GET7lin.optfile = 1;
solve GET7lin using LP minimizing tot_cost;

#tot_cost.up = upper_cost_limit;

abort $ (GET7lin.modelstat > 2) "Bad solve";

# starting values
#execute_load 'savedClimateVariables', Emissions, RadiativeForcing, TotalRadiativeForcing, AbatementCost,
#		Concentration, lifetime_CH4_by_OH, lifetime_CH4, AbatementFactor, Baseline;

#AbatementFactor.fx('N2O',GHGsource,tc) = AbatementFactor.l('N2O',GHGsource,tc);
#AbatementFactor.fx('CH4',GHGsource,tc) = AbatementFactor.l('CH4',GHGsource,tc);

############################################################
# RUN MAIN MODEL
############################################################

#$offtext



# recalibrate ocean temperature response and historic radiative forcing from aerosols,
# if climate sensitivity (lambda) has changed
# comment out temperature part for UDEBM
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
#C_tax(t) = 0;
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
#GET7full.optfile = 1;
#GET7full.scaleopt = 1;
#option solprint = on;
#GET7full.optfile = 1;

#execute_loadpoint 'Savepoint_B2base_B1_over1.2.gdx';
#execute_loadpoint 'Savepoint_B2base_B1_over1.2_DR2b.gdx';
#execute_loadpoint 'Savepoint_B2base_B1_over1.2_100EJ.gdx';
#execute_loadpoint 'Savepoint_A2r_B1_over1.4.gdx';

# Fix starting system at levels from linear model (quick hack, this should be in init_capital)
en_conv.fx(energy, en_out, type, '2010') = en_conv.l(energy, en_out, type, '2010');
capital.fx(en_in,en_out,type,'2010') = capital.l(en_in,en_out,type,'2010');

option nlp = conopt;
solve GET7full using NLP minimizing dummyconc2010;
option nlp = conopt4;
if (%conoptversion% < 4,
	option nlp = conopt;
);
if (abs(input_max_temp) < 8,
	solve GET7full using NLP minimizing tot_cost;
else
	solve GET7full using NLP minimizing final_temp;
);

scalar solvestatus;
solvestatus = GET7full.modelstat * sign(input_max_temp);

############################################################
#  FINAL RE-RUN
############################################################

# save some shadow prices before they get clobbered in the fixed-variable re-run
price_emission(t) = emission_Q.m(t);
price_deliv(sector,t) = deliv_q.m(sector,t);
price_marg(trsp_mode,t) = marg.m(trsp_mode,t);
price_supply(primary,t) = supply_1_Q.m(primary,t);

#$include monte_carlo.gms
$include output-UDEBM-tc2010.gms

parameter cumul_emissions2050, cumul_emissions2100, cumul_emissions2150, beccs_share, temp_max, ccs90_year;
parameter cum_ccs(t), cum_beccs(t);
parameter conc2150;
cumul_emissions2050 = sum(t_c $ (year_c(t_c) >= 2010 and year_c(t_c) < 2050), CO2emissions.l(t_c));
cumul_emissions2100 = sum(t_c $ (year_c(t_c) >= 2010 and year_c(t_c) < 2100), CO2emissions.l(t_c));
cumul_emissions2150 = sum(t_c $ (year_c(t_c) >= 2010 and year_c(t_c) < 2150), CO2emissions.l(t_c));
temp_max = smax(t_a_1 $ (year_1(t_a_1) <= 2150), Temp_global.l(t_a_1));
alias (t, tt);
beccs_share = sum(t, ccs_source("bio",t)) / max(0.01, sum((ccs_fuel,t), ccs_source(ccs_fuel,t)));
cum_ccs(t) = sum((ccs_fuel,tt) $ (year(tt) <= year(t)), ccs_source(ccs_fuel,tt));
cum_beccs(t) = sum(tt $ (year(tt) <= year(t)), ccs_source("bio",tt));
ccs90_year = smin(t $ (cum_ccs(t) >= 0.9*600/10), year(t));
conc2150 = sum(t_cf $ (year_cf(t_cf) = 2150), CO2concentration.l(t_cf));

file out /batch_summary_tax.txt/;
put out;
out.ap = 1

parameter totalemissions(t);
totalemissions(t) = c_emission.l(t) + deforest_CO2(t);

#put input_use_H2:6:2, input_max_storage:6:0, input_max_cost:8:2, input_max_beccs:6:2, input_bio_potential:6:0, input_lambda:6:2, final_temp.l:6:2, solvestatus:6:0, tot_cost.l:15:6, cumul_emissions2050:9:3, cumul_emissions2100:9:3, cumul_emissions2150:9:3, conc2150:8:2, beccs_share:8:4, temp_max:8:4, ccs90_year:6:0 /;
put input_tax_start:5:0, input_tax_growth:7:3, solvestatus:3:0;
loop(t, put totalemissions(t):8:3);

putclose;

abort $ (abs(solvestatus) > abort_solve_status or conc2150 = 1500) "Bad solve";
