set TECH;
set FUEL;
set TIME ordered;
set REGION;
set SCEN;

param years;	# years per period
param eps;	# small number
param dr;	# discount rate
param market_growth;	# maximum yearly market growth
param max_intermittent;	# maximum intermittent energy contribution
param dist_efficiency;	# world consumption/generation
param peak_multiplier;	# later regional
param fuel_tech {FUEL,TECH} >= 0;		# 0,1
param lifetime {TECH} >= 0;			# years
param base_invcost {TECH} >= 0;			# $/kW
param fixed_cost {TECH} >= 0;			# $/(kW*year)
param var_cost {TECH} >= 0;			# $/MWh
param efficiency {TECH} >= 0;			# [0,1]
param progress_ratio {TECH,SCEN} >= 0;		# [0,1]
param intermittent {TECH} >= 0;			# [0,1]
param start_capac {TECH,REGION} >= 0;		# GW
param demand_start {REGION} >= 0;    		# TWh
param demand_growth1 {REGION} >= 0;    		# [0,1]
param demand_growth2 {REGION} >= 0;    		# [0,1]
param demand_growth3 {REGION} >= 0;    		# [0,1]
param savings >= 0;    				# [0,1]
param other_availability {TECH,REGION} >= 0;	# [0,1]
param p1 {FUEL} >= 0;				# $/MWh
param p2 {FUEL} >= 0;				# $/MWh
param fuel_reserves {FUEL,REGION} >= 0;		# PWh
param non_electric_start {FUEL,REGION} >= 0;	# TWh
param non_electric_growth1 {FUEL,REGION} >= 0;	# [0,1]
param non_electric_growth2 {FUEL,REGION} >= 0;	# [0,1]
param non_electric_growth3 >= 0;		# [0,1]
param fuel_co2 {FUEL} >= 0;			# ton/MWh
param total_CO2_limit >= 0;			# Gton CO2
param potential {TECH,REGION} >= 0;		# TWh
param high_exper {TECH} >= 0;
param max_exper {TECH} >= 0;
param npieces {TECH} >= 0;
param max_fueluse {FUEL} >= 0;
param nfuel >= 0;
param max_cuminvcost >= 0;
param probability {SCEN} >= 0;
param infoyear >= 0;
param regret {SCEN} >= 0;
param biginvest >= 0;
param threshold {TECH} >= 0;
param knee {TECH} >= 0;

param time0 := first(TIME);
param time1 := last(TIME);

param learning_index {k in TECH, s in SCEN} := -log(progress_ratio[k,s]) / log(2);
param demand {r in REGION, t in TIME} :=			# TWh
  demand_start[r] / dist_efficiency *
	if t < 2020 then (1+demand_growth1[r])^(t-time0)
	else if t < 2050 then
		(1+demand_growth1[r])^(2020-time0) * (1+demand_growth2[r])^(t-2020)
	else (1+demand_growth1[r])^(2020-time0) * (1+demand_growth2[r])^(2050-2020) *
		(1+demand_growth3[r])^(t-2050);
param peak_demand {r in REGION, t in TIME} := 				# GW
	peak_multiplier * demand[r,t] / 8760 * 1000;
param non_electric_use {f in FUEL, r in REGION, t in TIME} :=		# TWh
  non_electric_start[f,r] *
	if t < 2020 then (1+non_electric_growth1[f,r])^(t-time0)
	else if t < 2050 then (1+non_electric_growth1[f,r])^(2020-time0) *
		(1+non_electric_growth2[f,r])^(t-2020)
	else (1+non_electric_growth1[f,r])^(2020-time0) *
	(1+non_electric_growth2[f,r])^(2050-2030) * (1+non_electric_growth3)^(t-2050);
param non_electric_resources_used {f in FUEL, r in REGION, t in TIME} := 1/1000 *
    if f = 'oil' or f = 'uran' then
	years * (sum {R in REGION, T in TIME: T <= t} non_electric_use[f,R,T]) /
		(sum {R in REGION} fuel_reserves[f,R])
    else if f = 'gas' and (r = 'north' or r = 'west') then
	years * sum {R in REGION, T in TIME: (R='north' or R='west') and T <= t} non_electric_use['gas',R,T] /
		(fuel_reserves['gas','north']+fuel_reserves['gas','west'])
    else
	years * (sum {T in TIME: T <= t} non_electric_use[f,r,T]) / fuel_reserves[f,r];
param base_fuel_cost {f in FUEL, r in REGION, t in TIME} :=
    if t > time0 then
	p1[f] + (p2[f]-p1[f]) * (non_electric_resources_used[f,r,t]+non_electric_resources_used[f,r,t-years]) / 2
    else
	p1[f] + (p2[f]-p1[f]) * non_electric_resources_used[f,r,t] / 2;
param start_exper {k in TECH} := sum {R in REGION} start_capac[k,R];
param resid_capac {k in TECH, r in REGION, t in TIME} := 		# GW
                        start_capac[k,r] * max(0, 1-(t-time0)/lifetime[k]);
param availability {k in TECH, r in REGION} := other_availability[k,r];
param salvage {k in TECH, t in TIME} := 1/(1+dr)^(time1-t+years) *
    (1-1/(1+dr)^max(0, t+lifetime[k]-time1-years)) / (1-1/(1+dr)^lifetime[k]);
param discount := sum {T in 0..years-1} 1/(1+dr)^T;


# The following is a fairly complicated scheme for setting the breakpoints of
# the experience curves so that the segmentation is as efficient as possible.
#
#param bpexper {k in TECH, p in 0..npieces[k]} :=	#breakpoints
#	start_exper[k]+(max_exper[k]-start_exper[k])*(p/npieces[k]);
#	start_exper[k]*(max_exper[k]/start_exper[k])^(p/npieces[k]);
param firstcuminvcost {k in TECH} := 
	base_invcost[k]*start_exper[k]/(1-learning_index[k,'hihi']);
param highcuminvcost {k in TECH} :=
	firstcuminvcost[k]*(high_exper[k]/start_exper[k])^(1-learning_index[k,'hihi']);
param lastcuminvcost {k in TECH} :=
        firstcuminvcost[k]*(max_exper[k]/start_exper[k])^(1-learning_index[k,'hihi']);
param bpindex {k in TECH} := floor(2/3*npieces[k]);
param bptemp {k in TECH, p in npieces[k]-bpindex[k]..npieces[k]} :=
        if p = npieces[k] then lastcuminvcost[k]-firstcuminvcost[k]
        else (p+bpindex[k]+1-npieces[k])/bpindex[k] *
                        (highcuminvcost[k]-firstcuminvcost[k]);
param bpexper {k in TECH, p in 0..npieces[k]} :=	#breakpoints
  if p <= npieces[k]-bpindex[k]-1 then
    ( (bptemp[k,npieces[k]-bpindex[k]]+firstcuminvcost[k]) /
        base_invcost[k]/start_exper[k]*(1-learning_index[k,'hihi']) )
         ^ (p/(npieces[k]-bpindex[k])/(1-learning_index[k,'hihi'])) * start_exper[k]
  else ( (bptemp[k,p]+firstcuminvcost[k]) /
        base_invcost[k]/start_exper[k]*(1-learning_index[k,'hihi']) )
        ^ (1/(1-learning_index[k,'hihi'])) * start_exper[k];
param bpcuminvcost {k in TECH, p in 0..npieces[k], s in SCEN} :=
  if knee[k] = 0 then
	base_invcost[k]*start_exper[k]/(1-learning_index[k,s]) * 
		( (bpexper[k,p]/start_exper[k])^(1-learning_index[k,s]) - 1 )
  else if bpexper[k,p] <= knee[k] then
	base_invcost[k]*start_exper[k]/(1-learning_index[k,'hihi']) * 
		( (bpexper[k,p]/start_exper[k])^(1-learning_index[k,'hihi']) - 1 )
  else
	base_invcost[k]*start_exper[k]/(1-learning_index[k,'hihi']) * 
		( (knee[k]/start_exper[k])^(1-learning_index[k,'hihi']) - 1 ) +
	(base_invcost[k]/(knee[k]/start_exper[k])^learning_index[k,'hihi'])*knee[k]/(1-learning_index[k,s]) * 
		( (bpexper[k,p]/knee[k])^(1-learning_index[k,s]) - 1 );
param bpinvcost {k in TECH, p in 1..npieces[k], s in SCEN} :=
	(bpcuminvcost[k,p,s]-bpcuminvcost[k,p-1,s])/(bpexper[k,p]-bpexper[k,p-1]);
param bpfueluse {f in FUEL, p in 0..nfuel} := p/nfuel*max_fueluse[f];
param bpcumfuelcost {f in FUEL, p in 0..nfuel} := 
    (p2[f]-p1[f])/2*bpfueluse[f,p]^2;
param bpfuelcost {f in FUEL, p in 1..nfuel} :=
    (bpcumfuelcost[f,p]-bpcumfuelcost[f,p-1])/(bpfueluse[f,p]-bpfueluse[f,p-1]);

var exper {k in TECH,TIME,SCEN}; # <= max_exper[k];	# GW
var invest {TECH,REGION,TIME,SCEN} >= 0;		# GW
var capacity {TECH,REGION,TIME,SCEN};			# GW	
var electricity {TECH,REGION,TIME,SCEN} >= 0;		# TWh
var fuel_use {FUEL,REGION,TIME,SCEN};			# TWh
var resources_used {FUEL,REGION,TIME,SCEN};		# reserve units
#var fueldelta {FUEL,REGION,TIME,0..nfuel,SCEN} >= 0, <= 1;
var co2_emissions {TIME,SCEN};				# Gton CO2
var cum_fuelcost {FUEL,REGION,TIME,SCEN};		# M$
var cum_invcost {TECH,TIME,SCEN} <= max_cuminvcost;	# M$
var cost {TIME,SCEN};					# G$
var total_cost {SCEN};					# G$
var lambda {k in TECH, TIME, p in 1..npieces[k], SCEN} >= 0, <= bpexper[k,p];
							# breakpoint weight
var delta {k in TECH, TIME, 1..npieces[k], SCEN} binary;	# segment indicator
#var theta >= 0;
var gamma {k in TECH, TIME, SCEN} binary;


#subject to Fix_scen_invest {k in TECH, r in REGION, t in TIME, s in SCEN: s != 'hihi' and t > time0 and t <= infoyear}:
#  invest[k,r,t,s] = invest[k,r,t,'hihi'];

#subject to Fix_scen_electricity {k in TECH, r in REGION, t in TIME, s in SCEN: s != 'hihi' and t > time0 and t <= infoyear}:
#  electricity[k,r,t,s] = electricity[k,r,t,'hihi'];

#subject to Fix_scen_lambda {k in TECH, t in TIME, p in 1..npieces[k], s in SCEN: s != 'hihi' and t > time0 and t <= infoyear}:
#  lambda[k,t,p,s] = lambda[k,t,p,'hihi'];

#subject to Fix_scen_delta {k in TECH, t in TIME, p in 1..npieces[k], s in SCEN: s != 'hihi' and t > time0 and t <= infoyear}:
#  delta[k,t,p,s] = delta[k,t,p,'hihi'];

subject to Gamma {k in TECH, t in TIME, s in SCEN: k='pv' or k='fc'}:
  exper[k,t,s] >= threshold[k] * gamma[k,t,s];

subject to Set_gamma_1 {k in TECH, t in TIME: (k='pv' or k='fc') and ord(t) > 1}:
  gamma[k,t,'hilo'] <= (if k='pv' then gamma[k,t,'lohi'] else gamma[k,t,'hihi']) +
				sum {S in SCEN} (gamma['pv',prev(t),S] + gamma['fc',prev(t),S]);

subject to Set_gamma_2 {k in TECH, t in TIME: (k='pv' or k='fc') and ord(t) > 1}:
  (if k='pv' then gamma[k,t,'lohi'] else gamma[k,t,'hihi']) <= gamma[k,t,'hilo'] +
				sum {S in SCEN} (gamma['pv',prev(t),S] + gamma['fc',prev(t),S]);

subject to Fix_gamma_1 {k in TECH, t in TIME: k='pv' or k='fc'}:
  gamma[k,t,'hihi'] = (if k='pv' then gamma[k,t,'hilo'] else gamma[k,t,'lohi']);

subject to Fix_gamma_2 {k in TECH, t in TIME: k='pv' or k='fc'}:
  gamma[k,t,'lolo'] = (if k='pv' then gamma[k,t,'lohi'] else gamma[k,t,'hilo']);

#subject to Fix_scen_exper_1 {k in TECH, t in TIME, p in 1..npieces[k], pvfc in 1..2, z in 1..2}:
#  (if pvfc = z then exper[k,t,p,'lohi'] else exper[k,t,p,'hilo']) <=
#	(if z = 1 then exper[k,t,p,'hihi'] else exper[k,t,p,'lolo']) +
#	(if pvfc = 1 then biginvest * gamma['pv',t] else biginvest * gamma['fc',t]);

#subject to Fix_scen_exper_2 {k in TECH, t in TIME, p in 1..npieces[k], pvfc in 1..2, z in 1..2}:
#  (if z = 1 then exper[k,t,p,'hihi'] else exper[k,t,p,'lolo']) <=
#	(if pvfc = z then exper[k,t,p,'lohi'] else exper[k,t,p,'hilo']) +
#	(if pvfc = 1 then biginvest * gamma['pv',t] else biginvest * gamma['fc',t]);

#subject to Fix_scen_lambda_1 {k in TECH, t in TIME, p in 1..npieces[k], s in SCEN: s != 'hihi' and (k='pv' or k='fc' or k='pvh2')}:
#  lambda[k,t,p,s] <= lambda[k,t,p,'hihi'] +
#	if k = 'pv' or k = 'pvh2' then biginvest * gamma['pv',t] else biginvest * gamma['fc',t];

#subject to Fix_scen_lambda_2 {k in TECH, t in TIME, p in 1..npieces[k], s in SCEN: s != 'hihi' and (k='pv' or k='fc' or k='pvh2')}:
#  lambda[k,t,p,'hihi'] <= lambda[k,t,p,s] +
#	if k = 'pv' or k = 'pvh2' then biginvest * gamma['pv',t] else biginvest * gamma['fc',t];

subject to Fix_scen_lambda_1 {k in TECH, t in TIME, p in 1..npieces[k], pvfc in 1..2, z in 1..2}:
  (if pvfc = z then lambda[k,t,p,'lohi'] else lambda[k,t,p,'hilo']) <=
	(if z = 1 then lambda[k,t,p,'hihi'] else lambda[k,t,p,'lolo']) +
	(if z = 1 then biginvest * (if pvfc = 1 then gamma['pv',t,'hihi'] else gamma['fc',t,'hihi'])
		else biginvest * (if pvfc = 1 then gamma['pv',t,'lolo'] else gamma['fc',t,'lolo']));

subject to Fix_scen_lambda_2 {k in TECH, t in TIME, p in 1..npieces[k], pvfc in 1..2, z in 1..2}:
  (if z = 1 then lambda[k,t,p,'hihi'] else lambda[k,t,p,'lolo']) <=
	(if pvfc = z then lambda[k,t,p,'lohi'] else lambda[k,t,p,'hilo']) +
	(if z = 1 then biginvest * (if pvfc = 1 then gamma['pv',t,'hihi'] else gamma['fc',t,'hihi'])
		else biginvest * (if pvfc = 1 then gamma['pv',t,'lolo'] else gamma['fc',t,'lolo']));

#subject to Fix_scen_lambda_3 {k in TECH, t in TIME, p in 1..npieces[k]}:
#  lambda[k,t,p,'lolo'] <= lambda[k,t,p,'hihi'] + biginvest * (gamma['pv',t] + gamma['fc',t]);

#subject to Fix_scen_lambda_4 {k in TECH, t in TIME, p in 1..npieces[k]}:
#  lambda[k,t,p,'hihi'] <= lambda[k,t,p,'lolo'] + biginvest * (gamma['pv',t] + gamma['fc',t]);

#subject to Fix_scen_delta_1 {k in TECH, t in TIME, p in 1..npieces[k], pvfc in 1..2, z in 1..2}:
#  (if pvfc = z then delta[k,t,p,'lohi'] else delta[k,t,p,'hilo']) <=
#	(if z = 1 then delta[k,t,p,'hihi'] else delta[k,t,p,'lolo']) +
#	(if pvfc = 1 then biginvest * gamma['pv',t] else biginvest * gamma['fc',t]);

#subject to Fix_scen_delta_2 {k in TECH, t in TIME, p in 1..npieces[k], pvfc in 1..2, z in 1..2}:
#  (if z = 1 then delta[k,t,p,'hihi'] else delta[k,t,p,'lolo']) <=
#	(if pvfc = z then delta[k,t,p,'lohi'] else delta[k,t,p,'hilo']) +
#	(if pvfc = 1 then biginvest * gamma['pv',t] else biginvest * gamma['fc',t]);

#subject to Extra_gamma {k in TECH, t in TIME, T in TIME: (k='pv' or k='fc') and ord(T)=ord(t)+1}:
#  gamma[k,t] <= gamma[k,T];

# Some basic (bottom-up) energy system model relations:

subject to Fix_start {k in TECH, r in REGION, s in SCEN}:
  invest[k,r,time0,s] = 0;

subject to Capacity {k in TECH, r in REGION, t in TIME, s in SCEN}:
  capacity[k,r,t,s] = resid_capac[k,r,t] + 
      sum {T in TIME: max(t-lifetime[k]+years, time0) <= T <= t} invest[k,r,T,s];

subject to Growth {k in TECH, r in REGION, t in TIME, s in SCEN}:
  capacity[k,r,t,s] <= (1+market_growth)^years *
	if ord(t) > 1 then capacity[k,r,t-years,s] else start_capac[k,r];

subject to Electricity {k in TECH, r in REGION, t in TIME, s in SCEN}:
  electricity[k,r,t,s] <= capacity[k,r,t,s] * availability[k,r] * 8760/1000;

subject to Energy_balance {r in REGION, t in TIME, s in SCEN}:
  sum {K in TECH} electricity[K,r,t,s] >= demand[r,t];

subject to Peak_capacity {r in REGION, t in TIME, s in SCEN}:
   sum {K in TECH: intermittent[K] = 0} capacity[K,r,t,s] >= peak_demand[r,t];

subject to Potential {r in REGION, t in TIME, s in SCEN, k in TECH: potential[k,'north'] > 0}:
  electricity[k,r,t,s] <= potential[k,r];

# Intermittent technologies are limited individually and collectively.

subject to Individual_limit {r in REGION, t in TIME, s in SCEN, k in TECH: intermittent[k] > 0}:
  electricity[k,r,t,s] <= intermittent[k] * demand[r,t];

subject to Intermittent_limit {r in REGION, t in TIME, s in SCEN}:
  sum {K in TECH: intermittent[K] > 0} electricity[K,r,t,s] <= max_intermittent * demand[r,t];

subject to CO2_emissions {t in TIME, s in SCEN}:
  co2_emissions[t,s] = 1/1000 * sum {F in FUEL, R in REGION} fuel_use[F,R,t,s] * fuel_co2[F];

subject to CO2_limit {s in SCEN}:
  years * sum {T in TIME} co2_emissions[T,s] <= total_CO2_limit;

subject to Fuel_use {f in FUEL, r in REGION, t in TIME, s in SCEN}:
  fuel_use[f,r,t,s] = sum {K in TECH: fuel_tech[f,K] > 0} electricity[K,r,t,s] / efficiency[K];

subject to Resources_used {f in FUEL, r in REGION, t in TIME, s in SCEN}:
  resources_used[f,r,t,s] = 1 / 1000 *
    if f = 'oil' or f = 'uran' then
	years * (sum {R in REGION, T in TIME: T <= t} fuel_use[f,R,T,s]) /
		(sum {R in REGION} fuel_reserves[f,R])
    else if f = 'gas' and (r = 'north' or r = 'west') then
	years * (sum {R in REGION, T in TIME: (R='north' or R='west') and T <= t} fuel_use['gas',R,T,s]) /
		(fuel_reserves['gas','north']+fuel_reserves['gas','west'])
    else
	years * (sum {T in TIME: T <= t} fuel_use[f,r,T,s]) / fuel_reserves[f,r];

# This is a piecewise linearization of the convex fuel supply cost curves.
# I.e., fuel costs increase as fuel supplies are used.

subject to Cum_fuelcost {f in FUEL, r in REGION, t in TIME, s in SCEN}:
  cum_fuelcost[f,r,t,s] >= << {P in 1..nfuel-1} bpfueluse[f,P];
	{P in 1..nfuel} bpfuelcost[f,P] * fuel_reserves[f,r] * 1000 >> resources_used[f,r,t,s];

#subject to PL_resourcesused {f in FUEL, r in REGION, t in TIME, s in SCEN}:
#  resources_used[f,r,t,s] = sum {P in 0..nfuel} bpfueluse[f,P] * fueldelta[f,r,t,P,s];
#  resources_used[f,r,t,s] = sum {P in 1..nfuel} (bpfueluse[f,P]-bpfueluse[f,P-1]) * fueldelta[f,r,t,P,s];

#subject to Cum_fuelcost {f in FUEL, r in REGION, t in TIME, s in SCEN}:
#  cum_fuelcost[f,r,t,s] = sum {P in 0..nfuel} bpcumfuelcost[f,P] * fuel_reserves[f,r] * 1000 * #fueldelta[f,r,t,P,s];
#  cum_fuelcost[f,r,t,s] = sum {P in 1..nfuel} (bpcumfuelcost[f,P]-bpcumfuelcost[f,P-1]) * 
#						fuel_reserves[f,r] * 1000 * fueldelta[f,r,t,P,s];

#subject to fueldeltasum {f in FUEL, r in REGION, t in TIME, s in SCEN}:
#  sum {P in 0..nfuel} fueldelta[f,r,t,P,s] = 1;

# Definition of experience.
# (1 Wp of PV-H2 consists of 1 Wp PV and 1/7 W fuel cells in addition to the
# 1 W of electrolysis included in the investment costs.)

subject to Exper {k in TECH, t in TIME, s in SCEN}:
  exper[k,t,s] = start_exper[k] + 
	sum {R in REGION, T in TIME: T <= t}
	  (invest[k,R,T,s] + if k = 'pv' then invest['pvh2',R,T,s]		# OBS!!! 1.062 bort!
		else if k = 'fc' then 1/7*invest['pvh2',R,T,s]);

# The next five constraints define the piecewise linear experience curves.

subject to PL_exper {k in TECH, t in TIME, s in SCEN}:
  exper[k,t,s] = sum {P in 1..npieces[k]} lambda[k,t,P,s];

subject to Cum_invcost {k in TECH, t in TIME, s in SCEN}:
  cum_invcost[k,t,s] = sum {P in 1..npieces[k]} (
	(bpcuminvcost[k,P-1,s] - bpinvcost[k,P,s]*bpexper[k,P-1])/1000 * delta[k,t,P,s] +
		bpinvcost[k,P,s]/1000*lambda[k,t,P,s]	);

subject to Lambda_delta_1 {k in TECH, t in TIME, p in 1..npieces[k], s in SCEN}:
  lambda[k,t,p,s] <= bpexper[k,p] * delta[k,t,p,s];

subject to Lambda_delta_2 {k in TECH, t in TIME, p in 1..npieces[k], s in SCEN}:
  lambda[k,t,p,s] >= bpexper[k,p-1] * delta[k,t,p,s];

subject to Delta_sum {k in TECH, t in TIME, s in SCEN}:
  sum {P in 1..npieces[k]} delta[k,t,P,s] = 1;

# The next two constraints are not necessary, but they can reduce solution times
# considerably. Including them does not change the solution in any way.

subject to Exper_grows_1 {k in TECH, t in TIME, p in 1..npieces[k], s in SCEN, T in TIME: ord(T)=ord(t)+1}:
  sum {P in 1..p} delta[k,t,P,s] >= sum {P in 1..p} delta[k,T,P,s];

subject to Exper_grows_2 {k in TECH, t in TIME, p in 1..npieces[k], s in SCEN, T in TIME: ord(T)=ord(t)+1}:
  sum {P in p..npieces[k]} delta[k,t,P,s] <= sum {P in p..npieces[k]} delta[k,T,P,s];

#subject to Extra_exper {k in TECH, t in TIME, s in SCEN}:
#  exper[k,t,s] = sum {P in 1..npieces[k]} lambda[k,t,P,s];

#subject to Extra_invest_1 {r in REGION, t in TIME}:
#  invest['pv',r,t,'lohi'] <= invest['pv',r,t,'hihi'];

#subject to Extra_invest_2 {r in REGION, t in TIME}:
#  invest['pv',r,t,'lolo'] <= invest['pv',r,t,'hilo'];

#subject to Extra_invest_3 {r in REGION, t in TIME}:
#  invest['fc',r,t,'hilo'] <= invest['fc',r,t,'hihi'];

#subject to Extra_invest_4 {r in REGION, t in TIME}:
#  invest['fc',r,t,'lolo'] <= invest['fc',r,t,'lohi'];

#subject to Extra_invest_5 {r in REGION, t in TIME}:
#  invest['pvh2',r,t,'lohi'] <= invest['pvh2',r,t,'hihi'];

#subject to Extra_invest_6 {r in REGION, t in TIME}:
#  invest['pvh2',r,t,'lolo'] <= invest['pvh2',r,t,'hilo'];

#subject to Extra_exper_1 {t in TIME}:
#  exper['pv',t,'lohi'] <= exper['pv',t,'hihi'];

#subject to Extra_exper_2 {t in TIME}:
#  exper['pv',t,'lolo'] <= exper['pv',t,'hilo'];

#subject to Extra_exper_3 {t in TIME}:
#  exper['fc',t,'hilo'] <= exper['fc',t,'hihi'];

#subject to Extra_exper_4 {t in TIME}:
#  exper['fc',t,'lolo'] <= exper['fc',t,'lohi'];

#subject to Extra_exper_5 {t in TIME}:
#  exper['pvh2',t,'lohi'] <= exper['pvh2',t,'hihi'];

#subject to Extra_exper_6 {t in TIME}:
#  exper['pvh2',t,'lolo'] <= exper['pvh2',t,'hilo'];

#subject to Extra_exper_1 {t in TIME, p in 1..npieces['pv']}:
#  sum {P in 1..p} delta['pv',t,P,'lohi'] >= sum {P in 1..p} delta['pv',t,P,'hihi'];

#subject to Extra_exper_2 {t in TIME, p in 1..npieces['pv']}:
#  sum {P in 1..p} delta['pv',t,P,'lolo'] >= sum {P in 1..p} delta['pv',t,P,'hilo'];

#subject to Extra_exper_3 {t in TIME, p in 1..npieces['fc']}:
#  sum {P in 1..p} delta['fc',t,P,'hilo'] >= sum {P in 1..p} delta['fc',t,P,'hihi'];

#subject to Extra_exper_4 {t in TIME, p in 1..npieces['fc']}:
#  sum {P in 1..p} delta['fc',t,P,'lolo'] >= sum {P in 1..p} delta['fc',t,P,'lohi'];

#subject to Extra_exper_1 {t in TIME, p in 1..npieces['pv']}:
#  sum {P in 1..p} lambda['pv',t,P,'lohi'] <= sum {P in 1..p} lambda['pv',t,P,'hihi'];

#subject to Extra_exper_2 {t in TIME, p in 1..npieces['pv']}:
#  sum {P in 1..p} lambda['pv',t,P,'lolo'] <= sum {P in 1..p} lambda['pv',t,P,'hilo'];

#subject to Extra_exper_3 {t in TIME, p in 1..npieces['fc']}:
#  sum {P in 1..p} lambda['fc',t,P,'hilo'] <= sum {P in 1..p} lambda['fc',t,P,'hihi'];

#subject to Extra_exper_4 {t in TIME, p in 1..npieces['fc']}:
#  sum {P in 1..p} lambda['fc',t,P,'lolo'] <= sum {P in 1..p} lambda['fc',t,P,'lohi'];

#subject to Extra_exper_5 {t in TIME, p in 1..npieces['pvh2']}:
#  sum {P in 1..p} lambda['pvh2',t,P,'lohi'] <= sum {P in 1..p} lambda['pvh2',t,P,'hihi'];

#subject to Extra_exper_6 {t in TIME, p in 1..npieces['pvh2']}:
#  sum {P in 1..p} lambda['pvh2',t,P,'lolo'] <= sum {P in 1..p} lambda['pvh2',t,P,'hilo'];

# Finally the total system costs. Notice that late investments are salvaged.

subject to Cost {t in TIME, s in SCEN}:
   cost[t,s] =
	1e-3 * discount * sum {R in REGION} (
	    sum {K in TECH} (
		fixed_cost[K] * capacity[K,R,t,s] +
		var_cost[K] * electricity[K,R,t,s] ) +
	    sum {F in FUEL: F != 'ren'} (
		base_fuel_cost[F,R,t] * fuel_use[F,R,t,s] +
		1 / years * if ord(t)=1 then cum_fuelcost[F,R,t,s] else
			cum_fuelcost[F,R,t,s] - cum_fuelcost[F,R,prev(t),s]  )
	) + sum {K in TECH} (1-salvage[K,t]) *
		if ord(t) = 1 then cum_invcost[K,t,s] else
		cum_invcost[K,t,s] - cum_invcost[K,prev(t),s];

subject to Total_cost {s in SCEN}:
  total_cost[s] = sum {T in TIME} cost[T,s] / (1+dr)^(T-time0);

minimize weighted_cost:
  sum {S in SCEN} probability[S] * (sum {T in TIME} cost[T,S] / (1+dr)^(T-time0));

#subject to Theta {s in SCEN}:
#  theta >= total_cost[s] - regret[s];

#minimize maxregret:
#  theta;