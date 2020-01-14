###############################################
### Declarations of variables and equations ###
### used in GET 6.0                         ###
###############################################

variables
tot_cost
C_emission(t_a)
tax(t)
;

positive variables

marg(trsp_mode,t)
supply_1(primary, t)
en_conv(energy, en_out, type, t)
supply_2(energy, t)
energy_prod(energy, t)
energy_deliv(energy, t)
extra_elec(energy,t)

supply_sec(energy,t)

trsp_energy(trsp_fuel, engine_type, trsp_mode, t)
elec_trsp(end_and_trsp,t)
engines(trsp_fuel, engine_type, car_or_truck, t)
extra_ship_fuel(trsp_fuel, IC_FC, heavy_mode, t)

elec_decarb(t)
capital(energy, en_out, type, t)
infra(new_trsp_fuel, t)

cap_invest(energy, en_out, type, t)
eng_invest(trsp_fuel, engine_type, car_or_truck, t)
infra_invest(trsp_fuel, t)

cost_fuel(t)
dist_cost(t)
cost_cap(t)
OM_cost(t)
cost_C_bio_trsp(t)
cost_C_strg(t)
salvage

annual_cost(t)

C_capt_tot(t)
C_capt_agg

agg_emis

 ;

equations

supply_pot_Q(primary, t)
reserves_Q(fossil1)
supply_1_Q(primary, t)
supply_2_Q(second_in, t)
supply_loop_Q(second_in,t)

energy_prod_Q(en_out, t)
energy_deliv_Q(en_out, t)
supply_sec_Q(energy,t)

trsp_nonelec_Q(trsp_fuel_nonel, t)
trsp_elec_Q(end_and_trsp, t)
trsp_demand_Q(trsp_mode, t)
vehicle_lim_Q(trsp_fuel, non_phev, car_or_truck, t)
vehicle_lim_PHEV_Q(road_fuel_liquid, engine_type, car_or_truck, t)
elec_frac_PHEV_Q(car_or_truck,engine_type,t)
lim_elec_veh(car_or_truck,elec_veh,t)
q_sea (engine_type, heavy_mode , t)
#interm_trsp_max_Q(elec_veh, car_or_truck, t)
Deliv_Q(sector, t)

capital_lim_Q(energy, en_out, type, t)
infra_lim_Q(new_trsp_fuel, t)

init_invest_Q(energy, en_out, type, init_year)
capital_Q(en_in, en_out, type, t)
engines_Q(trsp_fuel, engine_type, car_or_truck, t)
infra_Q(trsp_fuel, t)

cost_fuel_Q(t)
cost_cap_Q(t)
cost_C_strg_Q(t)
tax_Q(t)
OM_cost_Q(t)
dist_cost_Q(t)
C_bio_trsp_Q(t)
Salvage_value
annual_cost_Q(t)
tot_cost_Q

cogen_e_Q(t)
#interm_elec_max_Q(t)
#interm_max_Q(sector,t)
interm_max_Q(t)
CSP_max_Q(t)
max_nuclear_q(t)
max_solar_q(heat,t)
max_chips(t)
max_feed_stock(feed,t)
max_heat_pump(heat,t)
infra_lim1_Q(new_trsp_fuel, t)
infra_lim2_Q(new_trsp_fuel, t)
cap_g_lim_Q(en_in, en_out, type, t)
cap_g2_lim_Q(en_in, sector, type, t)
eng_g_lim_Q( engine_type,car_or_truck, t)
supp_lim_Q(fuels, t)
supp_lim2_Q(fossil, t)
supp_lim3_Q(t)

emission_Q(t)
hist_emission(t_h)
agg_emis_Q
annual_emis(t)

C_capt_tot_Q(t)
C_capt_agg_Q
C_stor_maxgr_eq(t)
elec_dec_Q(t)
heat_dec_Q(energy, t)
q_max_beccs(t)

transp_q(trsp_fuel,t)

;