set TECH;
set FUEL;
set TIME ordered;
set REGION;

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
param progress_ratio {TECH} >= 0;		# [0,1]
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

param time0 := first(TIME);
param time1 := last(TIME);

param learning_index {k in TECH} := -log(progress_ratio[k]) / log(2);
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
	base_invcost[k]*start_exper[k]/(1-learning_index[k]);
param highcuminvcost {k in TECH} :=
	firstcuminvcost[k]*(high_exper[k]/start_exper[k])^(1-learning_index[k]);
param lastcuminvcost {k in TECH} :=
        firstcuminvcost[k]*(max_exper[k]/start_exper[k])^(1-learning_index[k]);
param bpindex {k in TECH} := floor(2/3*npieces[k]);
param bptemp {k in TECH, p in npieces[k]-bpindex[k]..npieces[k]} :=
        if p = npieces[k] then lastcuminvcost[k]-firstcuminvcost[k]
        else (p+bpindex[k]+1-npieces[k])/bpindex[k] *
                        (highcuminvcost[k]-firstcuminvcost[k]);
param bpexper {k in TECH, p in 0..npieces[k]} :=	#breakpoints
  if p <= npieces[k]-bpindex[k]-1 then
    ( (bptemp[k,npieces[k]-bpindex[k]]+firstcuminvcost[k]) /
        base_invcost[k]/start_exper[k]*(1-learning_index[k]) )
         ^ (p/(npieces[k]-bpindex[k])/(1-learning_index[k])) * start_exper[k]
  else ( (bptemp[k,p]+firstcuminvcost[k]) /
        base_invcost[k]/start_exper[k]*(1-learning_index[k]) )
        ^ (1/(1-learning_index[k])) * start_exper[k];
param bpcuminvcost {k in TECH, p in 0..npieces[k]} :=
	if p <= npieces[k]-bpindex[k]-1 then   
		base_invcost[k]*start_exper[k]/(1-learning_index[k]) * 
		( (bpexper[k,p]/start_exper[k])^(1-learning_index[k]) - 1 )
	else bptemp[k,p];
param bpinvcost {k in TECH, p in 1..npieces[k]} :=
	(bpcuminvcost[k,p]-bpcuminvcost[k,p-1])/(bpexper[k,p]-bpexper[k,p-1]);
param bpfueluse {f in FUEL, p in 0..nfuel} := p/nfuel*max_fueluse[f];
param bpcumfuelcost {f in FUEL, p in 0..nfuel} := 
	p1[f]*bpfueluse[f,p] + (p2[f]-p1[f])/2*bpfueluse[f,p]^2;
param bpfuelcost {f in FUEL, p in 1..nfuel} :=
   (bpcumfuelcost[f,p]-bpcumfuelcost[f,p-1])/(bpfueluse[f,p]-bpfueluse[f,p-1]);

var exper {k in TECH,TIME}; # <= max_exper[k];	# GW
var invest {TECH,REGION,TIME} >= 0;		# GW
var capacity {TECH,REGION,TIME};		# GW	
var electricity {TECH,REGION,TIME} >= 0;	# TWh
var fuel_use {FUEL,REGION,TIME};		# TWh
var resources_used {FUEL,REGION,TIME};		# reserve units
var co2_emissions {TIME};			# Gton CO2
var cum_fuelcost {FUEL,REGION,TIME};		# M$
var cum_invcost {TECH,TIME} <= max_cuminvcost;	# M$
var cost {TIME};				# G$
var lambda {k in TECH, TIME, 1..npieces[k]} >= 0, <= 1;	# breakpoint weight
var gamma {k in TECH, TIME, 1..npieces[k]-1} binary;	# segment indicator
var dummy {k in TECH, p in 1..npieces[k]-1} binary;	# gamma[k,T+1,p]


# First some basic (bottom-up) energy system model relations:

subject to Fix_start {k in TECH, r in REGION}:
  invest[k,r,time0] = 0;

subject to Capacity {k in TECH, r in REGION, t in TIME}:
  capacity[k,r,t] = resid_capac[k,r,t] + 
      sum {T in TIME: max(t-lifetime[k]+years, time0) <= T <= t} invest[k,r,T];

subject to Growth {k in TECH, r in REGION, t in TIME}:
  capacity[k,r,t] <= (1+market_growth)^years *
	if ord(t) > 1 then capacity[k,r,t-years] else start_capac[k,r];

subject to Electricity {k in TECH, r in REGION, t in TIME}:
  electricity[k,r,t] <= capacity[k,r,t] * availability[k,r] * 8760/1000;

subject to Energy_balance {r in REGION, t in TIME}:
  sum {K in TECH} electricity[K,r,t] >= demand[r,t];

subject to Peak_capacity {r in REGION, t in TIME}:
   sum {K in TECH: intermittent[K] = 0} capacity[K,r,t] >= peak_demand[r,t];

subject to Potential {r in REGION, t in TIME,
				k in TECH: potential[k,'north'] > 0}:
  electricity[k,r,t] <= potential[k,r];

# Intermittent technologies are limited individually and collectively.

subject to Individual_limit {r in REGION, t in TIME,
					k in TECH: intermittent[k] > 0}:
  electricity[k,r,t] <= intermittent[k] * demand[r,t];

subject to Intermittent_limit {r in REGION, t in TIME}:
  sum {K in TECH: intermittent[K] > 0} electricity[K,r,t] <= 
					max_intermittent * demand[r,t];

subject to CO2_emissions {t in TIME}:
  co2_emissions[t] = 1/1000 * sum {F in FUEL, R in REGION}
					fuel_use[F,R,t] * fuel_co2[F];

subject to CO2_limit:
  years * sum {T in TIME} co2_emissions[T] <= total_CO2_limit;

subject to Fuel_use {f in FUEL, r in REGION, t in TIME}:
  fuel_use[f,r,t] = sum {K in TECH: fuel_tech[f,K] > 0}
			electricity[K,r,t] / efficiency[K];

subject to Resources_used {f in FUEL, r in REGION, t in TIME}:
  resources_used[f,r,t] = 1 / 1000 *
    if f = 'oil' or f = 'uran' then
	years / (sum {R in REGION} fuel_reserves[f,R]) *
		sum {R in REGION, T in TIME: T <= t}
			(fuel_use[f,R,T] + non_electric_use[f,R,T])
    else if f = 'gas' and (r = 'north' or r = 'west') then
	years / (fuel_reserves['gas','north']+fuel_reserves['gas','west']) *
		sum {R in REGION, T in TIME: (R='north' or R='west') and T <= t}
			(fuel_use['gas',R,T] + non_electric_use['gas',R,T])
    else
	years / fuel_reserves[f,r] *
		sum {T in TIME: T <= t}
			(fuel_use[f,r,T] + non_electric_use[f,r,T]);

# This is a piecewise linearization of the convex fuel supply cost curves.
# I.e., fuel costs increase as fuel supplies are used.

subject to Cum_fuelcost {f in FUEL, r in REGION, t in TIME}:
  cum_fuelcost[f,r,t] >= << {P in 1..nfuel-1} bpfueluse[f,P];
	{P in 1..nfuel} bpfuelcost[f,P] * fuel_reserves[f,r] * 1000 >>
							resources_used[f,r,t];

# Definition of experience.
# (1 Wp of PV-H2 consists of 1 Wp PV and 1/7 W fuel cells in addition to the
# 1 W of electrolysis included in the investment costs.)

subject to Exper {k in TECH, t in TIME}:
  exper[k,t] = start_exper[k] + 
	sum {R in REGION, T in TIME: T <= t}
	  (invest[k,R,T] + if k = 'pv' then invest['pvh2',R,T]
		else if k = 'fc' then 1/7*invest['pvh2',R,T]);

# The next five constraints define the piecewise linear experience curves.


subject to PL_exper {k in TECH, t in TIME}:
  exper[k,t] = exper[k,time0] +
	sum {P in 1..npieces[k]} (bpexper[k,P]-bpexper[k,P-1])*lambda[k,t,P];

subject to Cum_invcost {k in TECH, t in TIME}:
  cum_invcost[k,t] = sum {P in 1..npieces[k]} 
		(bpcuminvcost[k,P]-bpcuminvcost[k,P-1])/1000*lambda[k,t,P];

subject to Gamma_sum {k in TECH, p in 1..npieces[k]-1}:
  sum {T in TIME} gamma[k,T,p] + dummy[k,p] = 1;

subject to Lambda_gamma_1 {k in TECH, t in TIME, p in 2..npieces[k]}:
  lambda[k,t,p] <= sum {T in TIME: T <= t} gamma[k,T,p-1];

subject to Lambda_gamma_2 {k in TECH, t in TIME, p in 1..npieces[k]-1}:
  lambda[k,t,p] >= sum {T in TIME: T <= t} gamma[k,T,p];

subject to Delta_decreases {k in TECH, t in TIME, p in 2..npieces[k]-1}:
  sum {T in TIME: T <= t} gamma[k,T,p-1] >= sum {T in TIME: T <= t} gamma[k,T,p];

# The next two constraints are not necessary, but they can reduce solution times
# considerably. Including them does not change the solution in any way.

#subject to Exper_grows_1 {k in TECH, t in TIME, 
#			p in 1..npieces[k], T in TIME: ord(T)=ord(t)+1}:
#  sum {P in 1..p} delta[k,t,P] >= sum {P in 1..p} delta[k,T,P];

#subject to Exper_grows_2 {k in TECH, t in TIME, 
#			p in 1..npieces[k], T in TIME: ord(T)=ord(t)+1}:
#  sum {P in p..npieces[k]} delta[k,t,P] <= sum {P in p..npieces[k]} delta[k,T,P];

# Finally the total system costs. Notice that late investments are salvaged.

subject to Cost {t in TIME}:
   cost[t] =
	1e-3 * discount * sum {R in REGION} (
	    sum {K in TECH} (
		fixed_cost[K] * capacity[K,R,t] +
		var_cost[K] * electricity[K,R,t] ) +
	    sum {F in FUEL: F != 'ren'} 1 / years *
		if ord(t)=1 then cum_fuelcost[F,R,t] else
		cum_fuelcost[F,R,t] - cum_fuelcost[F,R,prev(t)]  ) +
	sum {K in TECH} (1-salvage[K,t]) *
		if ord(t) = 1 then cum_invcost[K,t] else
		cum_invcost[K,t] - cum_invcost[K,prev(t)];

minimize total_cost:
  sum {T in TIME} cost[T] / (1+dr)^(T-time0);


