#######################################
##### Set definitions for GET 6.0 #####
#######################################

scalar timestep		/ 10 /;
set t_steps			/ s1*s10 /;

#$ontext
scalar tstep_cc		/ 1 /;
set
t_c				/ tc1*tc410 /		# 5 time steps per year from 1770-2179.999	[410 years]
t_ch(t_c)		/ tc1*tc240 /		# [240 years]
t_cf(t_c)		/ tc240*tc410 /		# important to have tc240=2009.99 in both t_ch and t_cf (as a "seed")
;
#$offtext

$ontext
scalar tstep_cc		/ 0.2 /;
set
t_c				/ tc1*tc2050 /		# 5 time steps per year from 1770-2179.999	[410 years]
t_ch(t_c)		/ tc1*tc1200 /		# [240 years]
t_cf(t_c)		/ tc1200*tc2050 /	# important to have tc1200=2009.99 in both t_ch and t_cf (as a "seed")
;
$offtext

set
t_RCP			/	1765*2500	/
t_a_1(t_RCP)	/	1770*2179	/
t_h_1(t_a_1)	/	1770*2009	/
t_f_1(t_a_1)	/	2009*2179	/		# important to have 2009 in both t_h_1 and t_f_1 (as a "seed")

t_a(t_a_1)		/	1770, 1780, 1790,
					1800, 1810, 1820, 1830, 1840, 1850, 1860, 1870, 1880, 1890,
					1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990,
					2000, 2010, 2020, 2030, 2040, 2050, 2060, 2070, 2080, 2090,
					2100, 2110, 2120, 2130, 2140 ,2150, 2160, 2170	/

t(t_a)			/	2010, 2020, 2030, 2040, 2050, 2060, 2070, 2080,
					2090, 2100, 2110, 2120, 2130, 2140, 2150, 2160, 2170	/

t_h(t_a)		/	1770, 1780, 1790,
					1800, 1810, 1820, 1830, 1840, 1850, 1860, 1870, 1880, 1890,
					1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980 ,1990, 2000	/

init_year(t)	/ 2010 /

scen /400ppm, 450ppm, 500ppm/

energy / oil1, oil2, bio, bio1, bio2, hydro, wind, solar, gas1, gas2, oil, coal1,coal2, coal,
         nuclear, petro, air_fuel, elec, CH4, MeOH, H2, trsp, pellets, central_heat, dist_heat,
         solid_heat, non_solid_heat, feed-stock, intelec, storage /

en_in (energy)  / oil2, oil1, coal1, coal2, bio1, bio2, bio, hydro, wind, solar, gas1, gas2, oil, coal,
                  nuclear, MeOH, H2, elec, intelec, storage, petro, air_fuel, CH4, pellets/

end_use(energy)    / central_heat, dist_heat, solid_heat
                 non_solid_heat, feed-stock/

en_out (energy)  / oil,  elec, intelec, storage, MeOH, H2,  petro, air_fuel ,trsp, CH4, coal,
				central_heat, dist_heat, solid_heat, non_solid_heat, feed-stock, pellets, bio/

sector(en_out) /elec, central_heat, dist_heat, solid_heat
         non_solid_heat, feed-stock ,H2,  MeOH   /

sector1(en_out) /elec, central_heat, dist_heat, solid_heat
         non_solid_heat, feed-stock/

en_out_not_trsp (en_out )  / oil, elec, intelec, storage, MeOH, H2,  petro, air_fuel , CH4, coal, central_heat,
				dist_heat, solid_heat, non_solid_heat, feed-stock, pellets, bio/

solid(en_in) /bio, pellets, coal/
dec_heat(en_out) /central_heat, solid_heat, non_solid_heat/

heat(en_out) /central_heat, dist_heat/

cg_fuel (en_in)  / bio, CH4, oil, coal, H2 /

primary (en_in) / bio1, bio2, hydro, wind, solar, gas1, gas2, oil2, oil1, coal1, coal2, nuclear /

renew(primary) / bio1, bio2, hydro, wind, solar/

second_in (energy) / bio, oil, H2, elec, intelec, storage, MeOH, petro, air_fuel, CH4, coal, pellets /

fuels (primary)  / bio1, bio2, coal1, coal2, oil1, oil2, gas1, gas2, nuclear /

fossil (primary) /coal1, coal2, oil1, oil2, gas1, gas2/

fossil1 (primary) /coal1, coal2, oil1, oil2, gas1, gas2, nuclear/

c_fuel (energy) /  coal, oil, CH4 /
ccs_fuel (energy) /  coal, oil, CH4 , bio/
feed(energy) /coal, petro, MeOH, CH4, oil/

type           /  0, cg, dec, cg_dec /
C_capt (type)  / dec, cg_dec /
CG_type (type) / cg, cg_dec /
non_ccs(type) / 0, cg /

sec_out(energy) /central_heat,oil/

trsp_fuel (energy)              / elec, MeOH, H2, petro, air_fuel , CH4/
trsp_fuel_nonel (trsp_fuel)     / petro, air_fuel, CH4 /

new_trsp_fuel (trsp_fuel) / MeOH, H2, CH4 /

road_fuel(trsp_fuel)            / MeOH, H2, CH4, petro, elec /
road_fuel_liquid(road_fuel)    / MeOH, petro, H2, CH4 /
end_and_trsp(trsp_fuel) /elec, H2, MeOH/

engine_type   / 0, FC , hyb, BEV, PHEV/
elec_veh(engine_type) /BEV, PHEV/
non_phev(engine_type) /   0, FC , hyb, BEV/
HEV_PHEV_BEV(engine_type) / BEV, PHEV, hyb/
IC_FC(engine_type) /0, FC/

trsp_mode   / p_car, p_air, p_bus, p_rail,  f_road, f_air, f_sea, f_isea, f_rail /
car_or_truck (trsp_mode) / p_car, f_road, p_bus/
heavy_mode (trsp_mode) /  f_sea, f_isea  /
ptrs_mode (trsp_mode)   / p_car, p_air, p_bus, p_rail /
frgt_mode (trsp_mode)   / f_road, f_air, f_sea, f_isea, f_rail /
freight_bus_mode (trsp_mode)  / f_road, p_bus, f_sea, f_isea /
rail_mode (trsp_mode) / p_rail, f_rail /
air_mode (trsp_mode) / p_air, f_air /
non_avi(trsp_mode) / p_car,  p_bus, p_rail,  f_road,  f_sea, f_isea, f_rail /

regions / NAM, WEU, PAO,
          FSU, EEU, AFR, PAS,
          LAM, MEA, CPA, SAS /
;

alias (t_a, t_b);

parameter year(t_a);
	year(t_a) = 1770 + timestep*(ord(t_a)-1);

parameter year_1(t_a_1);
	year_1(t_a_1) = 1770 + ord(t_a_1)-1;

parameter year_c(t_c);
	year_c(t_c) = 1770 + (ord(t_c)-1)*tstep_cc;

parameter year_f(t_f_1);
	year_f(t_f_1) = 2010 + ord(t_f_1)-2;

parameter year_cf(t_cf);
	year_cf(t_cf) = 2010 + (ord(t_cf)-2)*tstep_cc;