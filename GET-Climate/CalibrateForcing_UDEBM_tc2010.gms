# starting values, to help nonlinear solver
ForcingMult.l = 1;
TotalRadiativeForcing.l(t_a_1) = sum(gas, hist_RF(gas,t_a_1))
								+ defaultForcing(t_a_1) + ForcingMult.l * fitForcing(t_a_1);

Temp.lo(UDlayer,t_a_1) = -2;
Temp.fx(UDlayer,'1770') = 0;

option qcp = cplex;
display lambda_L;
solve ForcingFit using QCP minimizing Sumsquares;





alias (t_c, t_c2);
parameter concentration_1(nonCO2,t_a_1);
parameter lifetime_CH4_by_OH_1(t_a_1);
parameter lifetime_CH4_1(t_a_1);
parameter RadiativeForcing_1(GAS,t_a_1);
parameter CO2concentration_1(t_a_1);
parameter lastTemp, lastTempLand;
parameter emis2009, emis2050, negemis;
parameter emissionForecast(t_c);
	emissionForecast(t_ch) = emissionHistory(t_ch);
	emis2009 = sum(t_ch $ (year_c(t_ch) = 2009), emissionHistory(t_ch));
	emissionForecast(t_cf) = emis2009*(1-0.0035)**(year_cf(t_cf)-2009);
	negemis = -4 * tstep_cc;
	emis2050 = sum(t_cf $ (year_cf(t_cf) = 2050), emissionForecast(t_cf));
	emissionForecast(t_cf) $ (year_cf(t_cf) >= 2050) = 
		max(negemis, emis2050 - (emis2050 - negemis)*(year_cf(t_cf)-2050)/60);
parameter horizon, fertdiff;

display emissionForecast;

#$ontext

parameter concdiff, error_center, error_newcenter, center, newcenter, fert1, fert2;

fert1 = 0.2;
fert2 = 0.8;

# Find fertilization that minimizes concentration error (calc-hist)^2, use golden section search method
center = (fert1 + fert2)/2;
fertilization = center;
horizon = 2010;
$include CalculateTemperatureHistory.gms
error_center = sqrt(sum(t_h_1 $ (year_1(t_h_1) >= 1960),
		sqr(CO2concentration_1(t_h_1) - hist_conc('CO2',t_h_1))/(2010-1960+1)));
repeat(
	fertdiff = fert2 - fert1;
	display fert1, fert2, fertdiff;
	if (fert2 - center > center - fert1,
		newcenter = center + (3 - sqrt(5))/2 * (fert2 - center);
	else
		newcenter = center - (3 - sqrt(5))/2 * (center - fert1);
	);	
	fertilization = newcenter;
$include CalculateTemperatureHistory.gms		# Fucking GAMS crap can't indent $include-commands
	error_newcenter = sqrt(sum(t_h_1 $ (year_1(t_h_1) >= 1960),
			sqr(CO2concentration_1(t_h_1) - hist_conc('CO2',t_h_1))/(2010-1960+1)));
	if (error_newcenter < error_center,
		if (fert2 - center > center - fert1,
			fert1 = center;
			center = newcenter;
			error_center = error_newcenter;
		else
			fert2 = center;
			center = newcenter;
			error_center = error_newcenter;			
		);
	else
		if (fert2 - center > center - fert1,
			fert2 = newcenter;
		else
			fert1 = newcenter;		
		);
	);
until (fert2-fert1 < 0.0001)
);
fertilization = (fert1 + fert2)/2;

horizon = 2180;
$include CalculateTemperatureHistory.gms

#$offtext

#parameter aero(t_a_1);
#aero(t_a_1) = defaultForcing(t_a_1) + ForcingMult.l * fitForcing(t_a_1);
#display ForcingMult.l, fertilization, CO2concentration.l, Temp_global.l, aero, TotalRadiativeForcing.l;
#display emissionForecast, netfluxBiosphere.l;


#display concentration_1, CO2concentration.l, Temp_global.l, RadiativeForcing_1, TotalRadiativeForcing.l;

CO2concentration.fx(t_ch) = CO2concentration.l(t_ch);
deltaDICbox.fx(OCEANBOX, t_ch) = deltaDICbox.l(OCEANBOX, t_ch);
deltaDIC.fx(t_ch) = deltaDIC.l(t_ch);
deltaCO2ocean.fx(t_ch) = deltaCO2ocean.l(t_ch);
netfluxOcean.fx(t_ch) = netfluxOcean.l(t_ch);
bioNPP.fx(t_ch) = bioNPP.l(t_ch);
bioReservoir.fx(BIOBOX, t_ch) = bioReservoir.l(BIOBOX, t_ch);
netfluxBiosphere.fx(t_ch) = netfluxBiosphere.l(t_ch);

RadiativeForcing_CO2.fx(t_h_1) = RadiativeForcing_1('CO2',t_h_1);
TotalRadiativeForcing.fx(t_h_1) = TotalRadiativeForcing.l(t_h_1);
Temp.fx(UDlayer, t_h_1) = Temp.l(UDlayer, t_h_1);
Temp_land.fx(t_h_1) = Temp_land.l(t_h_1);
Temp_global.fx(t_h_1) = Temp_global.l(t_h_1);






results_2.pc = 6;

put results_2;
put "Forcing multiplier:", ForcingMult.l:12:8 /;
put /;
put /;
put "year", "real temp", "model temp" /;

parameter output_Temp_global(t_h_1);
parameter output_TotalRadiativeForcing(t_h_1);
output_Temp_global(t_h_1) = Temp_global.l(t_h_1);
output_TotalRadiativeForcing(t_h_1) = TotalRadiativeForcing.l(t_h_1);

loop(t_h_1,
	put year_1(t_h_1):4:0, histTempGISS(t_h_1), output_Temp_global(t_h_1)/
);
put /;
put /;
put "year", "real RF", "model RF" /;
loop(t_h_1,
	put year_1(t_h_1):4:0, RF_RCP_3PD(t_h_1,'RFtotal'), output_TotalRadiativeForcing(t_h_1)/
);
putclose;

display defaultForcing, fitForcing, histNonCO2forcing, lambda_L;