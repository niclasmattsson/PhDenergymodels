set temps /atmosphere, int_ocean, deep_ocean/;

parameters

report_c(*,t)
report_capital(en_in, en_out, type, t)
report_supply1(primary,t)
report_elec(en_in,type, t)
report_engines(car_or_truck, engine_type,trsp_fuel,  t)               
report_invest(en_in, en_out, type, t)
report_transport_fuels(trsp_fuel, t)
report_transport_carriers(trsp_fuel, t)
report_transport_modes(trsp_mode, t)
report_transport_car_energy(trsp_fuel, t)
report_transport_car_type(engine_type, t)
report_transport_airfuel(en_in,type, t)
infrastruc(road_fuel, t)
report_transport_energy(trsp_fuel,trsp_mode,engine_type, t)
report_en_conv(en_in, en_out, type, t)
report_marginals(*,primary,t)
end_use_price
trsp_price(trsp_mode,t)
invest_gdp(*,t)
total_cap(t)
demand_out(*,t)


feed_stock(en_in,type,t)
non_solid_heat(en_in,type, t)
solid_heat(en_in,type,t)
rural_heat(en_in,type,t)
urban_heat(en_in,*,t)
elec(en_in,type,t)
intelec(en_in,type,t)
H2(en_in,type,t)
MeOH(en_in,type,t)
MeOHuse(en_out,t)
biomass(en_out,t)
h2_use(en_out,t)
prices(*,t)
ccs(en_out,t)
ccs_source(ccs_fuel,t)
ccs_primary_energy(ccs_fuel,t)
transp_energy(trsp_mode, trsp_fuel,t)
transp_km(trsp_fuel,trsp_mode, t)
emission(en_out,t)
GHGemissions(t,gas)
GHGanthro(t,gas)
GHGabatement(t,nonCO2,GHGsource)
GHGbaseline(t,nonCO2,GHGsource)
GHGabatementfactor(t,nonCO2,GHGsource)
GHGconc(t,gas)
GHGrf(t,*)
GHG_1(t_a_1,*)
parTemperature(t_a,temps)
parTemperature_1(t_a_1,*)
energy_system_cost
total_system_cost
beccs_use(en_out,t)
balances(en_out,t)

emis_count(en_in) /
	CH4   15.4
	petro 22
	oil   20
	coal  24.7
	bio   0		/

price_emission(t)
price_deliv(sector,t)
price_marg(trsp_mode,t)
price_supply(primary,t)

;

alias (en_out, en_out2);
