report_supply1(primary,t) = supply_1.l(primary, t) + eps;
report_c("CO2 emissions",t) = c_emission.l(t) + eps;
#report_c("CO2 concentration",t) = Concentration.l('CO2',t) + eps;
report_c("CO2 concentration",t) = sum(t_c $ (year_c(t_c) = year(t)), CO2concentration.l(t_c)) + eps;
report_c("CO2 capture",t) = C_capt_tot.l(t) + eps;
report_c("GET-emission.M",t) = price_emission(t) * (1+R)**(year(t)-2010) / timestep + eps;
report_c("annual cost",t) = annual_cost.l(t);
report_c("Emissions_CO2.m",t) = sum(t_c $ (year_c(t_c) = year(t)), Emissions_CO2.m(t_c)) * (1+R)**(year(t)-2010);
report_c("Emissions_CH4.m",t) = Emissions_CH4.m(t) * (1+R)**(year(t)-2010) / timestep;
report_c("Emissions_N2O.m",t) = Emissions_N2O.m(t) * (1+R)**(year(t)-2010) / timestep;
report_c("Temperature.m",t) = Temperature_global.m(t) * (1+R)**(year(t)-2010);

energy_system_cost = sum(t, t_step*(cost_fuel.l(t) + cost_cap.l(t) + OM_cost.l(t) + cost_C_strg.l(t) +
						cost_C_bio_trsp.l(t) + tax.l(t))/((1+r)**(t_step*(ord(t)-1))));
total_system_cost = tot_cost.l;
report_capital(en_in, en_out, type, t) = capital.l(en_in, en_out, type, t);
report_engines(car_or_truck, engine_type,trsp_fuel,t) = engines.l(trsp_fuel,engine_type,car_or_truck,t) + eps;
report_invest(en_in, en_out, type, t) = cap_invest.l(en_in, en_out, type, t) + eps;
report_transport_fuels(trsp_fuel_nonel, t) = energy_deliv.l(trsp_fuel_nonel, t) + eps;
report_transport_fuels("elec", t) = extra_elec.l("elec",t) + eps;
report_transport_fuels("H2", t) = extra_elec.l("H2",t) + eps;
report_transport_fuels("MeOH", t) = extra_elec.l("MeOH",t) + eps;
report_transport_carriers(trsp_fuel,t)
	= sum((trsp_mode,engine_type), trsp_energy.l(trsp_fuel, engine_type, trsp_mode, t)) + eps;
report_transport_modes(trsp_mode,t)
	= sum((trsp_fuel,engine_type), trsp_energy.l(trsp_fuel, engine_type, trsp_mode, t)) + eps;
report_transport_car_energy(trsp_fuel,t)
	= sum(engine_type, trsp_energy.l(trsp_fuel, engine_type, "p_car", t)) + eps;
report_transport_car_type(engine_type,t)
	= sum(trsp_fuel, trsp_energy.l(trsp_fuel, engine_type, "p_car", t)) + eps;
report_transport_airfuel(en_in,type, t) $ effic(en_in, "air_fuel", type, t) =
		en_conv.l(en_in, "air_fuel", type, t) * effic(en_in, "air_fuel", type, t) + eps;
end_use_price(sector,t) =-price_deliv(sector,t) * (1+R)**(year(t)-2010);
trsp_price(trsp_mode,t) = price_marg(trsp_mode, t) * (1+R)**(year(t)-2010);

report_transport_energy(trsp_fuel,trsp_mode,engine_type, t) =
			trsp_energy.l(trsp_fuel, engine_type, trsp_mode, t) + eps;
transp_energy(trsp_mode, trsp_fuel,t) =
			sum(engine_type, trsp_energy.l(trsp_fuel, engine_type, trsp_mode, t)) + eps;
transp_km(trsp_fuel,trsp_mode, t) =
		sum(engine_type,
			trsp_energy.l(trsp_fuel, engine_type, trsp_mode, t) * trsp_conv(trsp_fuel, engine_type, trsp_mode)
		) + eps;
report_en_conv(en_in, en_out, type, t) = en_conv.l(en_in, en_out, type, t);

feed_stock(en_in,type,t) $ effic(en_in, "feed-stock", type, t) =
		en_conv.l(en_in, "feed-stock", type, t) * effic(en_in, "feed-stock", type, t) + eps;
non_solid_heat(en_in,type, t) $ effic(en_in, "non_solid_heat", type, t) =
		en_conv.l(en_in, "non_solid_heat", type, t) * effic(en_in, "non_solid_heat", type, t) + eps;
solid_heat(en_in, type,t) $ effic(en_in, "solid_heat", type, t) = 
		en_conv.l(en_in, "solid_heat", type,t) * effic(en_in, "solid_heat", type, t) + eps;
rural_heat(en_in,type,t) $ effic(en_in, "dist_heat", type, t) =
		en_conv.l(en_in, "dist_heat", type, t) * effic(en_in, "dist_heat", type, t) + eps;
urban_heat(en_in,type,t) $ effic(en_in, "central_heat", type, t) =
		en_conv.l(en_in, "central_heat", type, t) * effic(en_in, "central_heat", type, t) + eps;
urban_heat(en_in,"CHPheat_0",t) $ heat_effic(en_in, "cg", "elec","central_heat") = 
		en_conv.l(en_in, "elec", "cg", t) * heat_effic(en_in, "cg", "elec","central_heat") + eps;
urban_heat(en_in,"CHPheat_dec",t) $ heat_effic(en_in, "cg_dec", "elec","central_heat") = 
		en_conv.l(en_in, "elec", "cg_dec", t) * heat_effic(en_in, "cg_dec", "elec","central_heat") + eps;

elec(en_in, type, t) $ effic(en_in, "elec", type, t) =
		en_conv.l(en_in, "elec", type, t) * effic(en_in, "elec", type, t) + eps;

intelec(en_in, type, t) $ effic(en_in, "intelec", type, t) =		
		+ en_conv.l(en_in, "intelec", type, t) * effic(en_in, "intelec", type, t) + eps;

elec("wind","0",t) = intelec("wind","0",t);
elec("solar","0",t) = max(0,
		min(intelec("solar","0",t), elec("intelec","0",t)-elec("wind","0",t))
	);

#		+ en_conv.l(en_in, "intelec", type, t) * effic(en_in, "intelec", type, t) * (
#			(en_conv.l("intelec", "elec", "0", t) * effic("intelec", "elec", "0", t) +
#				en_conv.l("intelec", "elec", "cg", t) * effic("intelec", "elec", "cg", t)) /
#				(en_conv.l("intelec", "elec", "0", t)+en_conv.l("intelec", "elec", "cg", t))
#		) + eps;

h2(en_in, type, t) $ effic(en_in, "H2", type, t) = en_conv.l(en_in, "H2", type, t) * effic(en_in, "H2", type, t) + eps;
h2_use(en_out,t) $ effic("H2", en_out, "0", t) = sum(type, en_conv.l("H2", en_out, type, t) ) + eps;
MeOH(en_in,type, t) $ effic(en_in, "MeOH", type, t) =
		en_conv.l(en_in, "MeOH", type, t) * effic(en_in, "MeOH", type, t) + eps;
MeOHuse(en_out,t) $ effic("MeOH", en_out, "0", t) = sum(type, en_conv.l("MeOH", en_out, type, t)) + eps;
biomass(en_out,t) $ (not sameas(en_out,'pellets')) =
		sum(type, en_conv.l("bio", en_out, type, t) ) + sum(type, en_conv.l("pellets", en_out, type, t) );

prices(primary,t) = price_supply(primary, t)*((1+R)**((ord(t)-1)*t_step))/t_step + eps;
ccs(en_out,t) $ capt_effic('coal','dec',en_out) =
	sum((C_capt,ccs_fuel),
		en_conv.l(ccs_fuel, en_out, C_capt, t) * emis_fact(ccs_fuel) * capt_effic(ccs_fuel,c_capt,en_out)
	) / 1000 + eps;

ccs_source(ccs_fuel,t) =
	sum((C_capt,en_out),
		en_conv.l(ccs_fuel, en_out, C_capt, t) * emis_fact(ccs_fuel) * capt_effic(ccs_fuel,c_capt,en_out)
	) / 1000 + eps;

ccs_primary_energy(ccs_fuel,t) =
	sum((C_capt,en_out),
		en_conv.l(ccs_fuel, en_out, C_capt, t)
	) + eps;

emission(en_out,t) =
	sum((C_capt,ccs_fuel),
		en_conv.l(ccs_fuel, en_out, C_capt, t) * emis_fact(ccs_fuel) * (1 - capt_effic(ccs_fuel,c_capt,en_out) )
	) - sum(C_capt,
		en_conv.l("bio", en_out, C_capt, t) * emis_fact("bio")
	) + sum((non_ccs,en_in),
		en_conv.l(en_in, en_out, non_CCS, t) * emis_count(en_in)
	) + eps;

demand_out(energy,t) = dem(energy,t);

#GHGemissions(t,gas) = Emissions.l(gas,t);
GHGemissions(t,'CO2') = sum(t_c $ (year_c(t_c) >= year(t) and year_c(t_c) < year(t)+timestep),
							1/timestep * CO2emissions.l(t_c));
GHGemissions(t,nonCO2) = Emissions.l(nonCO2,t);
#GHGanthro(t,'CO2') = Emissions.l('CO2',t);
GHGanthro(t,'CO2') = GHGemissions(t,'CO2');
GHGanthro(t,'CH4') = Emissions.l('CH4',t) - natural_CH4;
GHGanthro(t,'N2O') = Emissions.l('N2O',t) - natural_N2O;
GHGabatement(t,nonCO2,GHGsource) = AbatementFactor.l(nonCO2,GHGsource,t)/100 * Baseline.l(nonCO2,GHGsource,t);
GHGbaseline(t,nonCO2,GHGsource) $ maxAbatement(nonCO2,GHGsource) = Baseline.l(nonCO2,GHGsource,t);
GHGabatementfactor(t,nonCO2,GHGsource) = AbatementFactor.l(nonCO2,GHGsource,t);
#GHGconc(t,gas) = Concentration.l(gas,t);
GHGconc(t,'CO2') = sum(t_c $ (year_c(t_c) = year(t)), CO2concentration.l(t_c));
GHGconc(t,nonCO2) = Concentration.l(nonCO2,t);
GHGrf(t,gas) = RadiativeForcing.l(gas,t);
GHGrf(t,'CO2') = RadiativeForcing_CO2.l(t);
GHGrf(t,'aerosols') = sum(t_a_1 $ (year_1(t_a_1) >= year(t) and year_1(t_a_1) < year(t)+timestep),
							1/timestep * forcingScale * fitForcing(t_a_1));
GHGrf(t,'nonenergy') = sum(t_a_1 $ (year_1(t_a_1) >= year(t) and year_1(t_a_1) < year(t)+timestep),
							1/timestep * defaultForcing(t_a_1));
GHG_1(t_a_1,'CO2emissions') = sum(t_c $ (year_c(t_c) >= year_1(t_a_1) and year_c(t_c) < year_1(t_a_1)+1),CO2emissions.l(t_c));
GHG_1(t_a_1,'CO2conc') = sum(t_c $ (year_1(t_a_1) = year_c(t_c)), CO2concentration.l(t_c));
GHG_1(t_a_1,'RFtot') = TotalRadiativeForcing.l(t_a_1);
GHG_1(t_a_1,'Temperature') = Temp_global.l(t_a_1);
GHG_1(t_a_1,"Price_CO2.m") = sum(t_c $ (year_1(t_a_1) = year_c(t_c)), Emissions_CO2.m(t_c)) * (1+R)**(year_1(t_a_1)-2010);
GHG_1(t_a_1,"Price_CH4.m") = 1/timestep *
	sum(t $ (year_1(t_a_1) >= year(t) and year_1(t_a_1) < year(t)+timestep),
				(timestep+year(t)-year_1(t_a_1)) * Emissions_CH4.m(t) * (1+R)**(year(t)-2010) / timestep
				+ (year_1(t_a_1)-year(t)) * Emissions_CH4.m(t+1) * (1+R)**(year(t+1)-2010) / timestep
		);
GHG_1(t_a_1,"Price_N2O.m") = 1/timestep *
	sum(t $ (year_1(t_a_1) >= year(t) and year_1(t_a_1) < year(t)+timestep),
				(timestep+year(t)-year_1(t_a_1)) * Emissions_N2O.m(t) * (1+R)**(year(t)-2010) / timestep
				+ (year_1(t_a_1)-year(t)) * Emissions_N2O.m(t+1) * (1+R)**(year(t+1)-2010) / timestep
		);
GHG_1(t_a_1,"Price_Temperature.m") = Temperature_L1.m(t_a_1)*(1+R)**(year_1(t_a_1)-2010);
#GHG_1(t_a_1,"Price_Temperature2.m") = TempLimit.m(t_a_1)*(1+R)**(year_1(t_a_1)-2010);
#GHG_1(t_a_1,"discount annual") = TempLimit.m(t_a_1)*(1+R)**(year_1(t_a_1)-2010);
#GHG_1(t_a_1,"discount 10year") = TempLimit.m(t_a_1)*(1+R)**(year_1(t_a_1)-2010);

parTemperature(t_a,'atmosphere') = Temp_global.l(t_a);
parTemperature(t_a,'int_ocean') = Temp.l('L3',t_a);
parTemperature(t_a,'deep_ocean') = Temp.l('L15',t_a);
Temp.l('L3','1770') = eps;
Temp.l('L15','1770') = eps;
#Temp.l('L15','1780') = eps;
parTemperature_1(t_a_1,'atmosphere') = Temp_global.l(t_a_1);
parTemperature_1(t_a_1,'int_ocean') = Temp.l('L3',t_a_1);
parTemperature_1(t_a_1,'deep_ocean') = Temp.l('L15',t_a_1);
parTemperature_1(t_a_1,'equilibrium') = TotalRadiativeForcing.l(t_a_1) * lambda;
parTemperature_1('1770','atmosphere') = eps;
parTemperature_1('1770','int_ocean') = eps;
parTemperature_1('1770','deep_ocean') = eps;

beccs_use(en_out,t) $ effic("bio", en_out, "dec", t) =
		en_conv.l("bio", en_out, "dec", t) + en_conv.l("bio", en_out, "cg_dec", t) + eps;

balances(en_out, t) = sum((energy,type), en_conv.l(energy, en_out, type, t) * effic(energy, en_out, type, t))
		+ sum((en_in,type,en_out2), en_conv.l(en_in, en_out2, type, t) * heat_effic(en_in, type, en_out2, en_out))
		- sum((en_out2,type), en_conv.l(en_out, en_out2, type, t)) - dem(en_out, t);
;
balances('trsp', t) = balances('trsp', t)
		- sum((trsp_fuel,trsp_mode,engine_type), trsp_energy.l(trsp_fuel, engine_type, trsp_mode, t));
#		- sum((trsp_fuel_nonel,type), energy_deliv.l(trsp_fuel_nonel, t) * effic(trsp_fuel_nonel, "trsp", type, t))
#		- sum((end_and_trsp,type), extra_elec.l(end_and_trsp,t)* effic(end_and_trsp, "trsp", type, t));

execute_unload "%RESULTSFILE%.gdx" report_supply1 report_c report_capital report_engines report_invest
	report_transport_fuels report_en_conv urban_heat elec h2 MeOH report_transport_energy feed_stock
	non_solid_heat solid_heat rural_heat end_use_price trsp_price demand_out biomass h2_use prices ccs
	transp_energy transp_km emission GHGemissions GHGanthro GHGabatement GHGbaseline GHGabatementfactor
	GHGconc GHGrf GHG_1 parTemperature parTemperature_1 MeOHuse energy_system_cost beccs_use balances
	report_transport_carriers report_transport_modes report_transport_car_energy report_transport_car_type
	report_transport_airfuel total_system_cost ccs_source ccs_primary_energy fertilization

execute 'gdxxrw.exe %RESULTSFILE%.gdx @output_parameters.txt'
