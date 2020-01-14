CO2concentration.l('tc1') = conc_CO2_preind + ppm_per_GtC * emissionHistory('tc1');		# ppm
deltaDICbox.l(OCEANBOX, 'tc1') = 0;														# µmol/kg
deltaDIC.l('tc1') = 0;																	# µmol/kg
deltaCO2ocean.l('tc1') = 0;																# ppm
netfluxOcean.l('tc1') = tstep_cc * gasExchangeRate * emissionHistory('tc1');			# GtC
bioNPP.l('tc1') = tstep_cc*baseNPP;														# GtC
# bioReservoir starts at equilibrium (Tanaka equation 2.1.57, dC/dt = 0)
bioReservoir.l(BIOBOX, 'tc1') = bioBoxWeight(BIOBOX) * bioBoxTime(BIOBOX)**2 * baseNPP;	# GtC
netfluxBiosphere.l('tc1') = 0;															# GtC
concentration_1('CH4','1770') = conc_CH4_preind;
concentration_1('N2O','1770') = conc_N2O_preind;
lifetime_CH4_by_OH_1('1770') = lifetime_CH4_2000 * (conc_CH4_preind/conc_CH4_2000)**0.28;
lifetime_CH4_1('1770') = 1 / (1/lifetime_CH4_strat + 1/lifetime_CH4_soil + 1/lifetime_CH4_by_OH_1('1770'));
RadiativeForcing_1('CO2','1770') = 3.71/log(2) * log(CO2concentration.l('tc1')/conc_CO2_preind);
TotalRadiativeForcing.l('1770') = RadiativeForcing_1('CO2','1770') +
			defaultForcing('1770') + ForcingMult.l * fitForcing('1770');
Temp.l(UDlayer, '1770') = 0;
Temp_land.l('1770') = 0;
Temp_global.l('1770') = 0;

loop (t_c $ (ord(t_c) > 1 and year_c(t_c) < 2010),
	lastTemp = sum(t_a_1 $ (year_1(t_a_1) = floor(year_c(t_c)-tstep_cc)), Temp.l('L1',t_a_1));
	lastTempLand = sum(t_a_1 $ (year_1(t_a_1) = floor(year_c(t_c)-tstep_cc)), Temp_land.l(t_a_1));
	CO2concentration.l(t_c) = CO2concentration.l(t_c-1)  +
			ppm_per_GtC * (emissionForecast(t_c) - netfluxOcean.l(t_c-1) - netfluxBiosphere.l(t_c-1));
	deltaDICbox.l(OCEANBOX,t_c) = exp(-tstep_cc/oceanBoxTime(OCEANBOX)) *
		(deltaDICbox.l(OCEANBOX,t_c-1) + micromol_per_kg_per_GtC * netfluxOcean.l(t_c-1) * oceanBoxWeight(OCEANBOX));
	deltaDIC.l(t_c) = sum(OCEANBOX, deltaDICbox.l(OCEANBOX,t_c));
	deltaCO2ocean.l(t_c) =
		sum(DICTERM, (DICcoeff(DICTERM) + DICcoeffTemp(DICTERM)*oceanTemp) * deltaDIC.l(t_c)**ord(DICTERM));
	netfluxOcean.l(t_c) = tstep_cc * gasExchangeRate / ppm_per_GtC * (
		CO2concentration.l(t_c)
		- (conc_CO2_preind + deltaCO2ocean.l(t_c)) * exp(ocean_feedback*0.0423*lastTemp)
#		- (conc_CO2_preind + deltaCO2ocean.l(t_c)) * (1 + ocean_feedback*0.0423*lastTemp)
	);
	bioNPP.l(t_c) = tstep_cc*baseNPP * (1 + fertilization*log(CO2concentration.l(t_c)/conc_CO2_preind));
	bioReservoir.l(BIOBOX,t_c) = bioReservoir.l(BIOBOX,t_c-1) * (
			(1 - tstep_cc/bioBoxTime(BIOBOX)) $ (not bioQ10factor)
			+ (1 - tstep_cc/bioBoxTime(BIOBOX)*bioQ10factor**(lastTempLand/10)) $ bioQ10factor
#			+ (1 - tstep_cc/bioBoxTime(BIOBOX)*(1 + bioQ10factor**(1.233/10)*log(bioQ10factor)/10*lastTempLand)) $ bioQ10factor
		) + bioBoxWeight(BIOBOX) * bioBoxTime(BIOBOX) * bioNPP.l(t_c);
	netfluxBiosphere.l(t_c) = sum(BIOBOX, bioReservoir.l(BIOBOX,t_c) - bioReservoir.l(BIOBOX,t_c-1));

	loop (t_a_1 $ (year_1(t_a_1) = year_c(t_c)),		# always zero or one iterations
		lifetime_CH4_by_OH_1(t_a_1) = lifetime_CH4_2000 * (concentration_1('CH4',t_a_1-1)/conc_CH4_2000)**0.28;
		lifetime_CH4_1(t_a_1) = 1 / (1/lifetime_CH4_strat + 1/lifetime_CH4_soil + 1/lifetime_CH4_by_OH_1(t_a_1));
		concentration_1('CH4',t_a_1) = hist_conc('CH4',t_a_1);
		concentration_1('N2O',t_a_1) = hist_conc('N2O',t_a_1);
		RadiativeForcing_1('CH4',t_a_1) =
			0.036 * (sqrt(concentration_1('CH4',t_a_1)) - sqrt(conc_CH4_preind))
			- 0.47 * log(1 + 2.01e-5*(concentration_1('CH4',t_a_1)*conc_N2O_preind)**0.75
							+ 5.31e-15*concentration_1('CH4',t_a_1)*(concentration_1('CH4',t_a_1)*conc_N2O_preind)**1.52)
			+ 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*conc_N2O_preind)**0.75
							+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*conc_N2O_preind)**1.52);
		RadiativeForcing_1('N2O',t_a_1) =
			0.12 * (sqrt(concentration_1('N2O',t_a_1)) - sqrt(conc_N2O_preind))
			- 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*concentration_1('N2O',t_a_1))**0.75
							+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*concentration_1('N2O',t_a_1))**1.52)
			+ 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*conc_N2O_preind)**0.75
							+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*conc_N2O_preind)**1.52);
		RadiativeForcing_1('H2O',t_a_1) = 0.15 * RadiativeForcing_1('CH4',t_a_1);
		RadiativeForcing_1('O3',t_a_1) = 0.042 * 5.0 * log(concentration_1('CH4',t_a_1)/conc_CH4_preind);
		RadiativeForcing_1('CO2',t_a_1) = 3.71/log(2) * log(sum(t_c2 $ (year_c(t_c2)=year_1(t_a_1)), CO2concentration.l(t_c2))/conc_CO2_preind);
		TotalRadiativeForcing.l(t_a_1) = sum(GAS, RadiativeForcing_1(GAS,t_a_1)) +
							defaultForcing(t_a_1) + ForcingMult.l * fitForcing(t_a_1);
		

		Temp.l('L1',t_a_1) = Temp.l('L1',t_a_1-1) + 1 * (
			+ TotalRadiativeForcing.l(t_a_1-1) / (rho*h*c/yearseconds)
			- 1/Lambda_O * Temp.l('L1',t_a_1-1) / (rho*h*c/yearseconds)
			- K*yearseconds/10000 * (Temp.l('L1',t_a_1-1) - Temp.l('L2',t_a_1-1)) / (0.5*h*depth)
			+ w * (Temp.l('L2',t_a_1-1) - Temp.l('L1',t_a_1-1) * pol_wat_temp) / h
			- K_L_O_exch/LO * (
				1.3*Temp.l('L1',t_a_1-1)
				- (TotalRadiativeForcing.l(t_a_1-1) + K_L_O_exch/(1-LO)*1.3*Temp.l('L1',t_a_1-1))
						/ (1/Lambda_L + K_L_O_exch/(1-LO))
			) / (rho*h*c/yearseconds)
		);
		Temp.l('L2',t_a_1) = Temp.l('L2',t_a_1-1) + 1 * (
			+ K*yearseconds/10000 * (Temp.l('L1',t_a_1-1) - Temp.l('L2',t_a_1-1)) / (0.5*depth**2)
			- K*yearseconds/10000 * (Temp.l('L2',t_a_1-1) - Temp.l('L3',t_a_1-1)) / (depth**2)
			+ w * (Temp.l('L3',t_a_1-1) - Temp.l('L2',t_a_1-1)) / depth
		);
		Temp.l(UDlayer,t_a_1) $ (ord(UDlayer) >= 3 and ord(UDlayer) < 15) = Temp.l(UDlayer,t_a_1-1) + 1 * (
			+ K*yearseconds/10000 * (Temp.l(UDlayer-1,t_a_1-1) - Temp.l(UDlayer,t_a_1-1)) / (depth**2)
			- K*yearseconds/10000 * (Temp.l(UDlayer,t_a_1-1) - Temp.l(UDlayer+1,t_a_1-1)) / (depth**2)
			+ w * (Temp.l(UDlayer+1,t_a_1-1) - Temp.l(UDlayer,t_a_1-1)) / depth
		);
		Temp.l('L15',t_a_1) = Temp.l('L15',t_a_1-1) + 1 * (
			+ K*yearseconds/10000 * (Temp.l('L14',t_a_1-1) - Temp.l('L15',t_a_1-1)) / (depth**2)
			+ w * (Temp.l('L1',t_a_1-1)*pol_wat_temp - Temp.l('L15',t_a_1-1)) / depth
		);
		Temp_land.l(t_a_1) = (TotalRadiativeForcing.l(t_a_1) + K_L_O_exch/(1-LO)*1.3*Temp.l('L1',t_a_1))
													/ (1/lambda_L + K_L_O_exch/(1-LO));
		Temp_global.l(t_a_1) = 1.3*Temp.l('L1',t_a_1)*LO + Temp_land.l(t_a_1)*(1-LO);
	);
);

CO2concentration_1(t_h_1) = sum(t_c $ (year_c(t_c)=year_1(t_h_1)), CO2concentration.l(t_c));
