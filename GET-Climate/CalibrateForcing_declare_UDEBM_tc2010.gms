$include RCP_concentrations.gms
$include RCP_radiative_forcing.gms

parameters
	hist_conc(gas,t_a_1)
	hist_RF(gas,t_a_1)
	fitForcing(t_a_1)
	defaultForcing(t_a_1)
	histNonCO2forcing(t_a_1)
	solarRF(t_a_1)
;

hist_conc(gas,t_a_1) = conc_RCP_3PD(t_a_1,gas);

hist_RF('CO2',t_a_1) = 3.71/log(2) * log(hist_conc('CO2',t_a_1)/conc_CO2_preind);

hist_RF('CH4',t_a_1) =
	0.036 * (sqrt(hist_conc('CH4',t_a_1)) - sqrt(conc_CH4_preind))
	- 0.47 * log(1 + 2.01e-5*(hist_conc('CH4',t_a_1)*conc_N2O_preind)**0.75
					+ 5.31e-15*hist_conc('CH4',t_a_1)*(hist_conc('CH4',t_a_1)*conc_N2O_preind)**1.52)
	+ 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*conc_N2O_preind)**0.75
					+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*conc_N2O_preind)**1.52);
hist_RF('N2O',t_a_1) =
	0.12 * (sqrt(hist_conc('N2O',t_a_1)) - sqrt(conc_N2O_preind))
	- 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*hist_conc('N2O',t_a_1))**0.75
					+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*hist_conc('N2O',t_a_1))**1.52)
	+ 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*conc_N2O_preind)**0.75
					+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*conc_N2O_preind)**1.52);

hist_RF('H2O',t_a_1) = 0.15 * hist_RF('CH4',t_a_1);

hist_RF('O3',t_a_1) = 0.042 * 5.0 * log(hist_conc('CH4',t_a_1)/conc_CH4_preind);

fitForcing(t_a_1) = RF_RCP_3PD(t_a_1,'RFaerosol') + RF_RCP_3PD(t_a_1,'RFcloud') + RF_RCP_3PD(t_a_1,'RFbcsnow');

# solar RF:  average over one cycle is 0.103756
solarRF(t_a_1) = RF_RCP_3PD(t_a_1,'RFsolar');
solarRF(t_a_1) $ (year_1(t_a_1) >= 2010) = 0.103756;

# about 50% of RF from tropospheric O3 is due to CH4, the rest is here
defaultForcing(t_a_1) = RF_RCP_3PD(t_a_1,'RFflour') + RF_RCP_3PD(t_a_1,'RFhalo')
							+ RF_RCP_3PD(t_a_1,'RFvolcan') + solarRF(t_a_1)
							+ RF_RCP_3PD(t_a_1,'RFo3strat') + 0.5 * RF_RCP_3PD(t_a_1,'RFo3trop')
							+ RF_RCP_3PD(t_a_1,'RFlanduse');

histNonCO2forcing(t_a_1) $ (year_1(t_a_1) <= 2009) = sum(gas $ (not sameas(gas,'CO2')), hist_RF(gas,t_a_1));
#	RF_RCP_3PD(t_h_1,'RFch4') + RF_RCP_3PD(t_h_1,'RFn2o') + RF_RCP_3PD(t_h_1,'RFh2o')
#			+ 0.5 * RF_RCP_3PD(t_h_1,'RFo3trop');

#	RF_RCP_3PD(t_h_1,'RFghg3') + RF_RCP_3PD(t_h_1,'RFh2o') + 0.5 * RF_RCP_3PD(t_h_1,'RFo3trop');
#histGHGforcing_1(t_h_1) = sum(gas, hist_RF(gas,t_h_1));

$include AnnualTemperatures.gms

parameter histTempGISS(t_h_1);
	histTempGISS(t_h_1) = temperatureAnomaly(t_h_1,'GISS') + 0.25;
	histTempGISS(t_h_1) $ (year_1(t_h_1) < 1880) = 0;

variables
	ForcingMult
	Sumsquares
;

equations
	RF_tot_hist(t_a_1)
	Error
;


RF_tot_hist(t_a_1)..
	TotalRadiativeForcing(t_a_1) =e=
		sum(gas, hist_RF(gas,t_a_1)) + defaultForcing(t_a_1) + ForcingMult * fitForcing(t_a_1);

Error..
	Sumsquares =e= sum(t_h_1 $ (year_1(t_h_1) >= 1960 and year_1(t_h_1) <= 2009),
							sqr(histTempGISS(t_h_1) - Temp_global(t_h_1)));

model ForcingFit		/ RF_tot_hist, Temperature_L1, Temperature_L2, Temperature_other, Temperature_L15,
						Temperature_land, Temperature_global, Error /;

file results_2 / RESULTS_forcing_calibration.txt /;


parameter forcingScale;
