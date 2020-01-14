set
	GAS			/ CO2, CH4, N2O, H2O, O3 /
	nonCO2(GAS)	/ CH4, N2O /
	COEFFS  	/ a, b /
	GHGsource	/ nonenergy, gas, oil, coal, bio /
	UDlayer		/ L1*L15 /
	OCEANBOX	/ 1*6 /
	BIOBOX		/ 1*4 /
	DICTERM		/ 1*5 /	
;

alias (GHGsource, GHGsource2);

scalar
#	lambda			/0.8/		# climate sensitivity in [oC per Wm-2]
	k				/1.5/		# thermal diffusivity of deep ocean
	w				/4/			# upwelling rate m yr-1
	pol_wat_temp	/0.2/
	h				/70.0/		# depth of mixed layer
	rho				/1026/		# density of seawater
	c				/3996/		# specific heat capacity of seawater
	lo				/0.71/		# factor depending on land sea exchange and fraction of land
#	RF_calib		/4/
	lambda_L
	lambda_O
	k_L_O_exch
	a_L_O_exch		/0.31/
	b_L_O_exch		/1.59/
	depth			#/130/		# the depth of each discrete layer below the surface layer
	yearseconds		/31536000/
;

depth = 130*30/card(UDlayer);

# In this model we assume that the marine surface air warming enhancement is equal to the climate sensitivity
# over land enhancement, both are equal to 1.3!!!!!

lambda_L = lambda;
lambda_O = lambda/1.3;
k_L_O_exch = 1 + 0*(b_L_O_exch - a_L_O_exch*lambda_L);



# see Non-CO2 GHG MACs.xlsx
# CH4 from EPA (2006) "Global Mitigation of Non-CO2 Greenhouse Gases"
# N2O from Reilly et al (2002) "The Kyoto Protocol and non-CO2 greenhouse gases and carbon sinks"
table coeffMAC(GAS,COEFFS,GHGsource)
            nonenergy   gas     oil     coal    bio
    CH4.a    9          55      1       0.01    0
    CH4.b    0.15       0.03    0.15    0.12    1
    N2O.a    1.417398   0       0       0       0
    N2O.b    0.1611     1       1       1       1
;

# MtCO2eq
# EPA baseline emissions in 2020, used for allocating RCP baseline emissions by source
# N2O is *far* too low, but only relative emissions in different sectors matter here
table maxAbatement(GAS,GHGsource)
            nonenergy   gas     oil     coal    bio
    CH4     5410        1695    131     449     0
    N2O     966         0       0       0       eps
;

# MtCH4/EJ, MtN/EJ
# CH4:  EPA emissions in 2010 / WEO2010 primary energy in 2008, see Non-CO2 GHG MACs.xlsx
# N2O:  bio emissions from Christian (10 g N2O-N/GJ)
table emissionFactor(nonCO2,GHGsource)
            gas      oil      coal     bio
    CH4     0.557    0.023    0.140    0
    N2O     0        0        0        0.01
;




# Baseline emissions of GHGs (A2r or B2r scenario)
$include Emissions_B2r_mod.gms

#totalbaseline('N2O',t) = totalbaseline('N2O',t) - baselineN2Oenergy(t);		# nonenergy only, N2O from bioenergy is endogenous
totalbaseline('N2O',t) = totalbaseline('N2O',t) * 28/44;					# convert MtN2O to MtN

display totalbaseline,deforest_CO2;
parameter SRESbaseline(nonCO2,GHGsource,t);
	SRESbaseline(nonCO2,GHGsource,t) = max(1e-12, totalbaseline(nonCO2,t) *
			maxAbatement(nonCO2,GHGsource) / sum(GHGsource2, maxAbatement(nonCO2,GHGsource2))
	);
display SRESbaseline;




$include CarbonEmissionHistory.gms

parameter emissionHistory(t_c);
	emissionHistory(t_c) $ (year_c(t_c) < 2010) =
		tstep_cc * sum(t_h_1 $ (year_1(t_h_1) = floor(year_c(t_c))), emissionData(t_h_1, 'CDIAC')/1000);

scalar
	conc_CO2_preind			/ 278 /		# ppm
	conc_CH4_preind			/ 710 /		# ppb	
	conc_N2O_preind			/ 273 /		# ppb
	MtCH4_per_ppb			/ 2.746 /
	MtN_per_ppb				/ 4.8 /
	lifetime_CH4_strat		/ 120 /
	lifetime_CH4_soil		/ 160 /
	natural_CH4 			/ 270 /		# background emissions of CH4 in [MtCH4]
	natural_N2O 			/ 10.7 /	# background emissions of N2O in [MtN] from TAR p253
	GWP_CH4 				/ 23 /		# 100yr GWP on mass basis relative to CO2 from TAR p388
	GWP_N2O 				/ 296 /		# 100yr GWP on mass basis relative to CO2 from TAR p388
	lifetime_N2O			/ 120 /		# global mean atmospheric lifetime for N2O
	lifetime_CH4_2000		/ 9.6 /		# years
	conc_CH4_2000			/ 1700 /	# ppb
	abateLimit				/ 2 /		# limit to changes in abatement factor [%/year]
#	conc_O3_preind			/ 25 /		# DU (Dobson Units)
#	conc_O3_2000			/ 34 /		# DU (Dobson Units)
	target_year				/ 2150 /
	ocean_feedback			/ 1 /		# set to 0 for no feedback, 1 for feedback
	bioQ10factor			/ 2 /		# set to 0 for no feedback, 2 for feedback
#	biosphere_feedback		/ 0 /	
	fertilization			/ 0.60 /	# overwritten in CalibrateForcing!  perhaps change with feedback, to 0.40 (?), don't remember how runs were made
;

parameter MtCeq_per_baseline(nonCO2);
	MtCeq_per_baseline('CH4') = GWP_CH4 * 12/44;
	MtCeq_per_baseline('N2O') = GWP_N2O * 12/44 * 44/28;




############ Setup carbon cycle module, based on Joos (1996) ##############

scalar
	equilibriumCO2		/278/			# ppm (usually but not necessarily same as preindustrial concentration)
	ppm_per_GtC			/0.4689/		# ppm/GtC
	DICconstant			/1.722e17/		# µmol*m3/(ppm*kg)
	mixedLayerDepth		/50.9/			# m
	oceanSurfaceArea	/3.55e14/		# m2  (alt 3.62e14)
	oceanTemp			/17.7/			# degC
	baseNPP				/60/			# GtC/year
;

# DERIVATION of ppm_per_GtC:
# http://en.wikipedia.org/wiki/Atmosphere_of_Earth
# composition:		78.084% N2, 20.946% O2, 0.9340% Ar, 0.039% CO2	=>	28.957 g/mol  (28.96 if CO2 ignored)
# dry air mass:		5.1352 * 10^18 kg  =  0.17734 * 10^18 "kmol air"
# ideal gas => volume% = molar%, so:	1 GtC = 1/12 * 10^12 kmol C = 0.4689 * 10^-6 (kmol C / kmol air)

parameter gasExchangeRate;
	gasExchangeRate = 1/7.66;			# 1/year

parameter micromol_per_kg_per_GtC;
	micromol_per_kg_per_GtC = DICconstant / (mixedLayerDepth * oceanSurfaceArea) * ppm_per_GtC;

parameter
	oceanBoxWeight(OCEANBOX)
	oceanBoxTime(OCEANBOX)
	bioBoxWeight(BIOBOX)
	bioBoxTime(BIOBOX)
	DICcoeff(DICTERM)
	DICcoeffTemp(DICTERM)
	DeltaDICstart
	oceanCO2start
;

table oceanboxdata(OCEANBOX,*)
	 	weight  		time
#	1	0.70367			0.70177			# Joos t > 1 response
#	1	0.6113			0.70177			# Daniel fix year 1
	1	0.611253		0.812465		# Niclas optimized for step=0.01 & 25 year horizon
	2	0.24966			2.3488
	3	0.066485		15.281
	4	0.038344		65.359
	5	0.019439		347.55
	6	0.014819		999999999		;
#	6	0.01481			999999999		;
oceanBoxWeight(OCEANBOX) = oceanboxdata(OCEANBOX, 'weight');
oceanBoxTime(OCEANBOX) = oceanboxdata(OCEANBOX, 'time');

table bioboxdata(BIOBOX,*)
	 	weight  		time
	1	-0.71846		2.181818				# detritus
#	1	-0.71846		2.18					# detritus
	2	0.70211			2.85714					# ground vegetation
#	2	0.70211			2.86					# ground vegetation
	3	0.013414		20						# wood
	4	0.0029323		100				;		# soil organic carbon
bioBoxWeight(BIOBOX) = bioboxdata(BIOBOX, 'weight');
bioBoxTime(BIOBOX) = bioboxdata(BIOBOX, 'time');

table DICdata(DICTERM,*)
	 	coeff      		temp
	1	15.568e-1		-0.13993e-1
	2	7.4706e-3		-0.20207e-3
	3	-1.2748e-5		0.12015e-5
	4	2.4491e-7		-0.12639e-7
	5	-1.5468e-10		0.15326e-10		;
DICcoeff(DICTERM) = DICdata(DICTERM,'coeff');
DICcoeffTemp(DICTERM) = DICdata(DICTERM,'temp');






equations
	Emissions_CO2(t_c)
	Emissions_CH4(t)
	Emissions_N2O(t)
	Concentration_CO2(t_cf)
	OceanDIC_box(OCEANBOX,t_cf)
	OceanDIC_total(t_cf)
	CO2ocean(t_cf)
	TotalFluxToOcean(t_cf,t_a_1)
	NetPrimaryProduction(t_cf)
	TerrestrialBiosphere_box(BIOBOX,t_cf,t_a_1)
	TotalFluxToBiosphere(t_cf)
	Concentration_CH4(t)
	Concentration_N2O(t)
	Decay_hydroxyl(t)
	Lifetime_CH4_total(t)
	RF_CO2(t_a_1, t_c)
	RF_CH4(t)
	RF_N2O(t)
	RF_strat_H2O(t)
	RF_Ozone_CH4(t)
	RF_tot(t_a_1)
	Temperature_L1(t_a_1)
	Temperature_L2(t_a_1)
	Temperature_other(UDlayer,t_a_1)
	Temperature_L15(t_a_1)
	Temperature_land(t_a_1)
	Temperature_global(t_a_1)
	Total_cost_abate(t)
	Model_baseline(nonCO2,GHGsource,t)
	Abatement_constraint_1(nonCO2,GHGsource,t)
	Abatement_constraint_2(nonCO2,GHGsource,t)
	Emission_SecondDerivative_1(t_c)
	Emission_SecondDerivative_2(t_c)
	dummy
;

variables
	CO2emissions(t_c)				# GtC
	Emissions(nonCO2,t)				# MtCH4, MtN
	RadiativeForcing_CO2(t_a_1)		# W/m2
	RadiativeForcing(GAS,t)			# W/m2
	TotalRadiativeForcing(t_a_1)	# W/m2
	AbatementCost(t)				# G$ (2000)
	Temp(UDlayer,t_a_1)				# ocean layer temperatures
	Temp_land(t_a_1)				# land temperature	
	Temp_global(t_a_1)				# average land & ocean temperature
	DeltaCO2ocean(t_c) 				# ppm
	NetfluxOcean(t_c)				# GtC
	NetfluxBiosphere(t_c)			# GtC
	DeltaDIC(t_c) 					# µmol/kg
	DeltaDICbox(OCEANBOX,t_c) 		# µmol/kg
	BioNPP(t_c) 					# GtC
	BioReservoir(BIOBOX,t_c) 		# GtC
	dummyconc2010
;

positive variables
	CO2concentration(t_c)			# ppm
	Concentration(nonCO2,t)			# ppb
	Lifetime_CH4_by_OH(t)			# years
	Lifetime_CH4(t)					# years
	Baseline(nonCO2,GHGsource,t)	# MtCH4, MtN
	AbatementFactor(nonCO2,GHGsource,t)
;


$include CalibrateForcing_declare_UDEBM_tc2010.gms

# Starting values for Joos carbon cycle
#DeltaCO2ocean.fx('tc1') = 0;
#CO2concentration.fx('tc1') = conc_CO2_preind + ppm_per_GtC * emissionHistory('tc1');
###NetfluxOcean.fx('tc1') = gasExchangeRate * emissionHistory('tc1');
#NetfluxBiosphere.fx('tc1') = 0;
#DeltaDICbox.fx(OCEANBOX,'tc1') = 0;
#BioReservoir.fx(BIOBOX,'tc1') = bioBoxWeight(BIOBOX) * bioBoxTime(BIOBOX)**2 * baseNPP;
# BioReservoir starts at equilibrium (Tanaka equation 2.1.57, dC/dt = 0)

#display CO2concentration.l;



# Historic emissions + GET emissions + deforestation, latter two interpolated from 10-year to annual emissions
Emissions_CO2(t_c)..
	CO2emissions(t_c) =e= emissionHistory(t_c) + 
		tstep_cc/timestep * sum(t $ (year(t) = timestep*floor(year_c(t_c)/timestep)),
				(timestep+year(t)-year_c(t_c)) * (C_emission(t) + deforest_CO2(t))
				+ (year_c(t_c)-year(t)) * (C_emission(t+1) + deforest_CO2(t+1))
		);

# add partial emissions from GET later
Emissions_CH4(t)..
	Emissions('CH4',t) =e= natural_CH4 +
		sum(GHGsource, (1 - AbatementFactor('CH4',GHGsource,t)/100) * Baseline('CH4',GHGsource,t) );

# add partial emissions from GET later
Emissions_N2O(t)..
	Emissions('N2O',t) =e= natural_N2O +
		sum(GHGsource, (1 - AbatementFactor('N2O',GHGsource,t)/100) * Baseline('N2O',GHGsource,t) );





# Joos (1996) carbon cycle (next 8 equations)
# Atmosphere carbon balance
Concentration_CO2(t_cf+1)..
	CO2concentration(t_cf+1) =e= CO2concentration(t_cf) +
						ppm_per_GtC * (CO2emissions(t_cf+1) - NetfluxOcean(t_cf+1) - NetfluxBiosphere(t_cf+1));

# Mixed layer pulse response function (6-box model)
OceanDIC_box(OCEANBOX,t_cf+1)..
	DeltaDICbox(OCEANBOX,t_cf+1) =e= exp(-tstep_cc/oceanBoxTime(OCEANBOX)) *
		(DeltaDICbox(OCEANBOX,t_cf) + micromol_per_kg_per_GtC * NetfluxOcean(t_cf+1) * oceanBoxWeight(OCEANBOX));

# DIC = Dissolved Inorganic Carbon
OceanDIC_total(t_cf)..
	DeltaDIC(t_cf) =e= sum(OCEANBOX, DeltaDICbox(OCEANBOX,t_cf));

# Nonlinear parametrization of ocean carbonate chemistry (Revelle buffer)
CO2ocean(t_cf)..
	DeltaCO2ocean(t_cf) =e= sum(DICTERM,
			(DICcoeff(DICTERM) + DICcoeffTemp(DICTERM)*oceanTemp) * power(DeltaDIC(t_cf), ord(DICTERM))
		);
# Air-sea flux
TotalFluxToOcean(t_cf,t_a_1) $ (year_1(t_a_1) = floor(year_cf(t_cf)-tstep_cc)) ..
	NetfluxOcean(t_cf) =e= tstep_cc * gasExchangeRate / ppm_per_GtC * (
		CO2concentration(t_cf)
		- (conc_CO2_preind + DeltaCO2ocean(t_cf))*exp(ocean_feedback*0.0423*Temp('L1',t_a_1))
#		- (conc_CO2_preind + DeltaCO2ocean(t_cf))*(1 + ocean_feedback*0.0423*Temp('L1',t_a_1))
	);

# NPP increases with CO2 concentrations (fertilization)
NetPrimaryProduction(t_cf)..
	BioNPP(t_cf) =e= tstep_cc * baseNPP * (1 + fertilization*log(CO2concentration(t_cf)/conc_CO2_preind));

# tau (=bioBoxTime) appears in second term because this is the time derivative of the box model response
# (see Tanaka p36)
TerrestrialBiosphere_box(BIOBOX,t_cf+1,t_a_1) $ (year_1(t_a_1) = floor(year_cf(t_cf)-tstep_cc)) ..
	BioReservoir(BIOBOX,t_cf+1) =e= BioReservoir(BIOBOX,t_cf) * (
		(1 - tstep_cc/bioBoxTime(BIOBOX)) $ (not bioQ10factor)
		+ (1 - tstep_cc/bioBoxTime(BIOBOX)*bioQ10factor**(Temp_land(t_a_1)/10)) $ bioQ10factor
#		+ (1 - tstep_cc/bioBoxTime(BIOBOX)*(1 + bioQ10factor**(1.233/10)*log(bioQ10factor)/10*Temp_land(t_a_1))) $ bioQ10factor		# linearized around 1.233 degrees (to reproduce Daniel's factor 0.0755)
	) + bioBoxWeight(BIOBOX) * bioBoxTime(BIOBOX) * BioNPP(t_cf+1);

# Net increase of terrestrial biomass
TotalFluxToBiosphere(t_cf+1)..
	NetfluxBiosphere(t_cf+1) =e= sum(BIOBOX, BioReservoir(BIOBOX,t_cf+1) - BioReservoir(BIOBOX,t_cf));





# Simple 1-box decay, with decay considered within each timestep (instead of just emissions*timestep) 
Concentration_CH4(t+1)..
	Concentration('CH4',t+1) =e=
		Emissions('CH4',t) / MtCH4_per_ppb * sum(t_steps, power(1 - 1/Lifetime_CH4(t), ord(t_steps)-1))
		+ Concentration('CH4',t) * power(1 - 1/Lifetime_CH4(t), timestep);

# Ditto for N2O.
Concentration_N2O(t+1)..
	Concentration('N2O',t+1) =e= 
		Emissions('N2O',t) / MtN_per_ppb * sum(t_steps, power(1-1/lifetime_N2O, ord(t_steps)-1))
		+ Concentration('N2O',t) * power(1 - 1/lifetime_N2O, timestep);

# CH4 loss from tropospheric OH (CH4 feedback on its own lifetime), from IPCC TAR WG1 4.2.1.1 (p250)
Decay_hydroxyl(t+1)..
	Lifetime_CH4_by_OH(t) =e= lifetime_CH4_2000 * (Concentration('CH4',t)/conc_CH4_2000)**0.28;

# All components of CH4 lifetime, from IPCC TAR WG1 4.2.1.1 (p248)
Lifetime_CH4_total(t)..
	Lifetime_CH4(t) =e= 1 / (1/lifetime_CH4_strat + 1/lifetime_CH4_soil + 1/Lifetime_CH4_by_OH(t));





# IPCC TAR WG1 table 6.2 (p358), or Tanaka eq 2.1.73
# const = RF{2xCO2}/log(2) = 3.7 W/m2 / log(2),  
RF_CO2(t_a_1,t_c) $ (year_c(t_c) = year_1(t_a_1)) ..
	RadiativeForcing_CO2(t_a_1) =e= 3.71/log(2) * log(CO2concentration(t_c)/conc_CO2_preind);

# Saturation of CH4 absorption bands minus overlap with N2O
# IPCC TAR WG1 table 6.2 (p358), or Tanaka eq 2.2.4 & 2.2.5 (sign error in 2.2.4)
# Can skip the entire 5e-15*() terms, error ~0.1% for 2400 ppb
RF_CH4(t)..
	RadiativeForcing('CH4',t) =e=
		0.036 * (sqrt(Concentration('CH4',t)) - sqrt(conc_CH4_preind))
		- 0.47 * log(1 + 2.01e-5*(Concentration('CH4',t)*conc_N2O_preind)**0.75
						+ 5.31e-15*Concentration('CH4',t)*(Concentration('CH4',t)*conc_N2O_preind)**1.52)
		+ 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*conc_N2O_preind)**0.75
						+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*conc_N2O_preind)**1.52);

# Ditto for N2O.
RF_N2O(t)..
	RadiativeForcing('N2O',t) =e=
		0.12 * (sqrt(Concentration('N2O',t)) - sqrt(conc_N2O_preind))
		- 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*Concentration('N2O',t))**0.75
						+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*Concentration('N2O',t))**1.52)
		+ 0.47 * log(1 + 2.01e-5*(conc_CH4_preind*conc_N2O_preind)**0.75
						+ 5.31e-15*conc_CH4_preind*(conc_CH4_preind*conc_N2O_preind)**1.52);

# Stratospheric H2O = 15% of radiative forcing from CH4, see IPCC AR4 WG1 sections 2.3.7 and 2.10.3.1
# Large uncertainty here - it was judged to be 2-5% in TAR (see WG1 section 6.6.4 and Tanaka 2.2.29).
RF_strat_H2O(t)..
	RadiativeForcing('H2O',t) =e= 0.15 * RadiativeForcing('CH4',t);

# Tropospheric O3 from CH4, Tanaka eq 2.2.21, based on IPCC TAR WG1 tables 4.11 (footnote p269) & 4.9 (p261)
# Forcing due to ozone precursors (NOx, CO, VOC) is aggregated with RF_other.
RF_Ozone_CH4(t)..
	RadiativeForcing('O3',t) =e=
		0.042 * 5.0 * log(Concentration('CH4',t)/conc_CH4_preind);									# MiMiC
#		0.042 * (5.0*log(Concentration('CH4',t)/conc_CH4_2000) + conc_O3_2000 - conc_O3_preind);	# Tanaka
#		0.25 * RadiativeForcing('CH4',t);					# see comment in IPCC AR4 WG1 section 2.10.3.1

# otherForcing is a catch-all, forcingScale is fit to history in CalibrateForcing.gms
# linear interpolation between RF(t) and RF(t+1) to compensate for large timesteps
# [use RF(t+1) instead of RF(t) to avoid delay issues, because RF(t+1) ~ Conc(t+1) ~ Emissions(t) ]
RF_tot(t_f_1)..
	TotalRadiativeForcing(t_f_1) =e= RadiativeForcing_CO2(t_f_1) +
		1/timestep * sum((GAS,t) $ (year(t) = timestep*floor(year_f(t_f_1)/timestep)),
				(timestep+year(t)-year_f(t_f_1)) * RadiativeForcing(GAS,t)
				+ (year_f(t_f_1)-year(t)) * RadiativeForcing(GAS,t+1)
		) + histNonCO2forcing(t_f_1) + defaultForcing(t_f_1) + forcingScale * fitForcing(t_f_1);





Temperature_L1(t_a_1+1)..
	Temp('L1',t_a_1+1) =e= Temp('L1',t_a_1) + 1 * (
			+ TotalRadiativeForcing(t_a_1) / (rho*h*c/yearseconds)
			- 1/Lambda_O * Temp('L1',t_a_1) / (rho*h*c/yearseconds)
			- k*yearseconds/10000 * (Temp('L1',t_a_1) - Temp('L2',t_a_1)) / (0.5*h*depth)
			+ w * (Temp('L2',t_a_1) - Temp('L1',t_a_1) * pol_wat_temp) / h
			- k_L_O_exch/lo * (
				1.3*Temp('L1',t_a_1)
				- (TotalRadiativeForcing(t_a_1) + k_L_O_exch/(1-lo)*1.3*Temp('L1',t_a_1))
						/ (1/lambda_L + k_L_O_exch/(1-lo))
			) / (rho*h*c/yearseconds)
	);

Temperature_L2(t_a_1+1)..
	Temp('L2',t_a_1+1) =e= Temp('L2',t_a_1) + 1 * (
		+ k*yearseconds/10000 * (Temp('L1',t_a_1) - Temp('L2',t_a_1)) / (0.5*depth**2)
		- k*yearseconds/10000 * (Temp('L2',t_a_1) - Temp('L3',t_a_1)) / (depth**2)
		+ w * (Temp('L3',t_a_1) - Temp('L2',t_a_1)) / depth
	);

Temperature_other(UDlayer,t_a_1+1) $ (ord(UDlayer) >= 3 and ord(UDlayer) < 15) ..
	Temp(UDlayer,t_a_1+1) =e= Temp(UDlayer,t_a_1) + 1 * (
		+ k*yearseconds/10000 * (Temp(UDlayer-1,t_a_1) - Temp(UDlayer,t_a_1)) / (depth**2)
		- k*yearseconds/10000 * (Temp(UDlayer,t_a_1) - Temp(UDlayer+1,t_a_1)) / (depth**2)
		+ w * (Temp(UDlayer+1,t_a_1) - Temp(UDlayer,t_a_1)) / depth
	);

Temperature_L15(t_a_1+1)..
	Temp('L15',t_a_1+1) =e= Temp('L15',t_a_1) + 1 * (
		+ k*yearseconds/10000 * (Temp('L14',t_a_1) - Temp('L15',t_a_1)) / (depth**2)
		+ w * (Temp('L1',t_a_1)*pol_wat_temp - Temp('L15',t_a_1)) / depth
	);

Temperature_land(t_a_1)..
	Temp_land(t_a_1) =e= (TotalRadiativeForcing(t_a_1) + k_L_O_exch/(1-lo)*1.3*Temp('L1',t_a_1))
													/ (1/lambda_L + k_L_O_exch/(1-lo));

Temperature_global(t_a_1)..
	Temp_global(t_a_1) =e= 1.3*Temp('L1',t_a_1)*lo + Temp_land(t_a_1)*(1-lo);





# MarginalAbatementCost: a*(exp(b*x)-1) [1995$/tC-eq], "-1" to make MAC(0)=0
# x = AbatementFactor = 100*abatement/baseline, dx = 100/baseline * dA
# AbatementCost = integral of MAC = a/b*baseline/100 * (exp(b*x) - 1 - b*x), "-1" to make AbatementCost(0)=0
Total_cost_abate(t)..
	# 1.1111 = changing dollar value (data for different years)
	AbatementCost(t) =e= 1.1111/1e3 * sum( (nonCO2, GHGsource),
		coeffMAC(nonCO2,'a',GHGsource)/coeffMAC(nonCO2,'b',GHGsource) *
			MtCeq_per_baseline(nonCO2)*Baseline(nonCO2,GHGsource,t)/100 * (
				exp(coeffMAC(nonCO2,'b',GHGsource)*AbatementFactor(nonCO2,GHGsource,t))
				- 1 - coeffMAC(nonCO2,'b',GHGsource)*AbatementFactor(nonCO2,GHGsource,t)
			)
	);

Model_baseline(nonCO2,GHGsource,t)..
	Baseline(nonCO2,GHGsource,t) =e=
		SRESbaseline(nonCO2,GHGsource,t) $ sameas(GHGsource, 'nonenergy') +
		emissionFactor(nonCO2,GHGsource) * (
			(supply_1('gas1',t) + supply_1('gas2',t)) $ sameas(GHGsource, 'gas') +	
			(supply_1('oil1',t) + supply_1('oil2',t)) $ sameas(GHGsource, 'oil') + 
			(supply_1('coal1',t) + supply_1('coal2',t)) $ sameas(GHGsource, 'coal') + 
			(supply_1('bio1',t) + supply_1('bio2',t)) $ sameas(GHGsource, 'bio')
		);

Abatement_constraint_1(nonCO2,GHGsource,t+1)..
	AbatementFactor(nonCO2,GHGsource,t+1) - AbatementFactor(nonCO2,GHGsource,t) =l= timestep * abateLimit;

Abatement_constraint_2(nonCO2,GHGsource,t+1)..
	AbatementFactor(nonCO2,GHGsource,t+1) - AbatementFactor(nonCO2,GHGsource,t) =g= -timestep * 0.5; #abateLimit;

Emission_SecondDerivative_1(t_c) $ (year_c(t_c) >= 2012)..
	(CO2emissions(t_c) - CO2emissions(t_c-1)) - (CO2emissions(t_c-1) - CO2emissions(t_c-2)) =L= 1*12/44;

Emission_SecondDerivative_2(t_c) $ (year_c(t_c) >= 2012)..
	(CO2emissions(t_c) - CO2emissions(t_c-1)) - (CO2emissions(t_c-1) - CO2emissions(t_c-2)) =G= -1*12/44;


variable final_temp;
equations final_temp_Q(t_a_1);
final_temp_Q(t_a_1) $ (year_1(t_a_1) >= target_year) ..
	Temp_global(t_a_1) =l= final_temp;		#(TempAUO('2170') + TempAUO('2160'))/2;

dummy..
	dummyconc2010 =E= CO2concentration("tc240");

#equations TempLimit(t_c);
#TempLimit(t_c)..
#	TempAUO(t_c) =l= 2;






$include CalibrateForcing_UDEBM_tc2010.gms
	forcingScale = ForcingMult.l;



# RF for CO2 is accounted for in a variable with 1-year resolution, so disable this one
RadiativeForcing.fx('CO2',t) = 0;

# Can't abate more than 85% of baseline emissions
AbatementFactor.up(nonCO2,GHGsource,t) = 85;

# No abatement of non-CO2 from biomass
AbatementFactor.up(nonCO2,'bio',t) = 0;

# Constraints to help the nonlinear solver. These should all be non-binding.
CO2concentration.up(t_cf) = 1500;
CO2concentration.lo(t_cf) = 100;
DeltaDIC.up(t_cf) = 1000;
DeltaDIC.lo(t_cf) = 0;
Concentration.lo('CH4',t) = 500;
Concentration.lo('N2O',t) = 100;
Lifetime_CH4.lo(t) = 6;
Lifetime_CH4_by_OH.lo(t) = 7;
Temp.lo(UDlayer,t_a_1) = -2;
Temp_land.lo(t_a_1) = -2;
Temp_global.lo(t_a_1) = -2;
Temp.up(UDlayer,t_a_1) = 9;
Temp_land.up(t_a_1) = 9;
Temp_global.up(t_a_1) = 9;

# disable carbon emissions in GET outside 2010-2170 (zero CO2 after 2170 might actually be a good assumption)
C_emission.fx(t_h) = 0;
C_emission.fx(t_a) $ (year(t_a) > 2170) = 0;
supply_1.fx(fossil,t) $ (year(t) > 2170) = 0;

# start values
Concentration.fx('CH4','2010') = (1870 + 1745)/2;
Concentration.fx('N2O','2010') = 322.5;
Temp.fx(UDlayer,'1770') = 0;
#Temp_land.fx('1770') = 0;
#Temp_global.fx('1770') = 0;
AbatementFactor.fx(nonCO2,GHGsource,'2010') = eps;
