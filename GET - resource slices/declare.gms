***********************************************
*** Declarations of variables and equations ***
*** used in GET 6.0                         ***
***********************************************

variables
tot_cost
C_emission(reg,t_a);

positive variables


marg(trsp_mode,reg,t)
supply_1(primary,reg, t)
en_conv(energy, en_out, type, reg,t)
supply_2(energy,reg, t)
energy_prod(energy,reg, t)
energy_prod2(en_in, en_out, type, reg,t)
energy_deliv(energy,reg, t)
elec_decarb(reg,t)
export(second_in, reg,t)
import(second_in, reg,t)
waste_fl (wastes, reg, t)
agg_waste
pu_stock(reg,t)

supply_sec(energy,reg,t)
supply_sec2(en_in,energy,type,reg,t)

trsp_energy(trsp_fuel, engine_type, trsp_mode, reg,t)
engines(trsp_fuel, engine_type, car_or_truck, reg,t)
extra_ship_fuel(trsp_fuel, IC_FC, heavy_mode, reg,t)

capital(energy, en_out, type,reg, t)
infra(trsp_fuel,reg, t)

cap_invest(energy, en_out, type,reg, t)
eng_invest(trsp_fuel, engine_type, car_or_truck, reg,t)
infra_invest(trsp_fuel, reg,t)

elec_deliv(reg,allslices,t)
elec_gen(en_in,type,reg,allslices,t)
elec_use(elecsector,reg,allslices,t)
storage_slice_transfer(storage_tech,reg,allslices,allslices,t)
elec_losses(reg,t)
capital_class(class_tech,class,reg,t)
elec_gen_class(class_tech,class,reg,allslices,t)

cost_fuel(reg,t)
dist_cost(t)
cost_cap(reg,t)
tax(reg,t)
OM_cost(t)
cost_C_bio_trsp(t)
cost_C_strg(t)

annual_cost(t)

C_capt_tot(reg,t)
C_capt_agg

agg_emis
Tot_emis(t_a)
 ;

equations

supply_pot_Q(primary,reg, t)
reserves_Q(stock, reg)
supply_1_Q(primary, reg,t)
export_import_balance(second_in, t)
supply_2_Q(second_in, reg,t)
supply_loop_Q(second_in,reg,t)
no_stock_Q(no_stock,reg,t)
waste_fl_Q(wastes, reg, t)
agg_waste_Q(wastes)
q_Saved_pu(reg,t)
q_start_pu(reg,t)

energy_prod_Q(en_out,reg,t)
energy_prod_elec_Q(reg,t)
energy_prod2_Q(en_in, en_out, type, reg,t)
energy_deliv_Q(en_out,reg ,t)
supply_sec_Q(energy,reg,t)
supply_sec2_Q(en_in,energy,type, reg,t)
*supply_sec_breeder_lag_Q(reg,t)
*supply_sec_breeder_lag2_Q(en_in,type,reg,t)
*supply_sec_rep_lag_Q(reg,t)
*supply_sec_rep_lag2_Q(en_in,type,reg,t)
Breeder_lag_Q(en_in, en_out, type,reg,t)
Breeder_lag_Q2(en_in, en_out, type,reg,t)

trsp_demand_Q(trsp_mode, reg,t)
vehicle_lim_Q(trsp_fuel, non_phev, car_or_truck, reg, t)
vehicle_lim_PHEV_Q(road_fuel_liquid, engine_type, car_or_truck,reg, t)
elec_frac_PHEV_Q(car_or_truck,engine_type,reg, t)
lim_elec_veh(car_or_truck,elec_veh,reg, t)
q_sea (engine_type, heavy_mode ,reg, t)
Deliv_Q(sector,reg, t)

Elec_Deliv_Dem_Q(reg,allslices,t)
*elec_deliv_Q(reg,t)
elec_deliv_Q(reg,allslices,t)
elec_use_Q(elecsector,reg,allslices,t)
sliced_elec_balance(reg,allslices,t)
total_losses_Q(reg,t)
elec_gen_Q(en_in, type,reg, t)
thermal_limit(thermalelec,type,reg,allslices,allslices,t)
elec_capital_lim_class(class_tech,class,reg,allslices,t)
elec_capital_lim_Q(en_in,type,reg,allslices,t)
storage_capital_lim_Q(storage_tech,reg,allslices,allslices,t)
capital_class_limit(class_tech,class,reg,t)
elec_class_aggregation(class_tech,reg,allslices,t)
capital_class_aggregation(class_tech,reg,t)
wind_elec_aggregation(reg,allslices,t)
wind_capital_aggregation(reg,t)
pv_elec_aggregation(reg,allslices,t)
pv_capital_aggregation(reg,t)
csp_elec_aggregation(reg,allslices,t)
csp_capital_aggregation(en_in,reg,t)

capital_lim_Q(energy, en_out, type,reg, t)
infra_lim_Q(trsp_fuel,reg, t)

init_invest_Q(energy, en_out, type,reg, init_year)
capital_Q(en_in, en_out, type, reg,t)
engines_Q(trsp_fuel, engine_type, car_or_truck,reg, t)
infra_Q(trsp_fuel,reg, t)

cost_fuel_Q(reg, t)
cost_cap_Q(reg,t)
cost_C_strg_Q(t)
tax_Q(reg,t)
OM_cost_Q(t)
dist_cost_Q(t)
annual_cost_Q(t)
tot_cost_Q

cogen_e_Q(reg,t)
*interm_max_Q(reg,t)
*interm_max_Q2(reg,t)
CSP_max_Q(reg,t)
max_solar_q(heat,reg,t)
max_chips(reg,t)
max_feed_stock(feed,reg,t)
max_heat_pump(heat,reg,t)
q_max_beccs(c_capt,en_out,reg,t)


infra_lim1_Q(trsp_fuel,reg, t)
cap_g_lim_Q(en_in, en_out, type,reg, t)
*capacity_lim_Q (en_in, sector1, type, reg, t)
*capacity_lim2_Q (en_in, sector1, type, reg, t)
*energy_lim_Q(sector1, type, reg, t)
*energy_lim2_Q(en_in, sector1, type, reg, t)
*market_share_lim_Q (en_in, sector1, type, reg, t)
*market_share_lim2_Q (en_in, sector1, type, reg, t)
*market_share_lim3_Q (en_in, sector1, type, reg, t)
coal_lim_Q(sector1, type, reg, t)
bio_lim_Q(second_in, en_out, type, reg, t)
eng_g_lim_Q( trsp_fuel,engine_type,car_or_truck,reg, t)
eng_g_lim_Q2( trsp_fuel,engine_type,car_or_truck,reg, t)
eng_g_lim_Q4(  engine_type,car_or_truck,reg, t)
Q_car_balance(car_or_truck,reg,t)
supp_lim_Q(fuels,reg, t)

*breeder_input(en_in,en_out,type,reg,t)

emission_Q(reg,t)
hist_emission(t_h)
agg_emis_Q
annual_emis(reg,t)
q_global_cap(t)
q_tot_emis(t_a)

C_capt_tot_Q(reg,t)
C_capt_agg_Q
elec_dec_Q(reg,t)


transp_q(trsp_fuel,reg,t)

*slicetest(en_in,type,reg,slice,t)
;
