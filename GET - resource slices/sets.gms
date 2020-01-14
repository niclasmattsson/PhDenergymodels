***************************************
***** Set definitions for GET 6.0 *****
***************************************

sets

t_a     / 1800, 1810, 1820, 1830, 1840, 1850, 1860, 1870, 1880, 1890,
          1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990,
          2000, 2010, 2020, 2030, 2040, 2050, 2060, 2070, 2080, 2090,
          2100, 2110, 2120, 2130, 2140 ,2150 /

t (t_a) /  2010, 2020, 2030, 2040, 2050, 2060, 2070, 2080,
          2090, 2100, 2110, 2120, 2130, 2140, 2150 /

t_h(t_a) / 1800, 1810, 1820, 1830, 1840, 1850, 1860, 1870, 1880, 1890,
           1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980 ,1990, 2000/

t_1 (t) / 2010, 2020, 2030, 2040, 2050, 2060, 2070, 2080,
          2090, 2100, 2110, 2120, 2130 /

t_ext (t) / 2140, 2150 /

init_year (t) / 2010/

scen/ 400, 450, 500/

reg /EUR, NAM, PAO, FSU, LAM, CPA, AFR, SAS, PAS, MEA/
OECD(reg)/EUR, NAM, PAO/
MIC(reg) /FSU, LAM, CPA/
ROW(reg) /AFR, SAS, PAS, MEA/

* NNN the star syntax defines a sequence of elements: /c1*c5/ = /c1,c2,c3,c4,c5/
class /c1*c5/



* use this for k-means clusters
$ontext
allslices /s01*s99/
;

scalar numclusters /64/;

set slice(allslices);
slice(allslices) $ (ord(allslices) <= numclusters) = yes;
$offtext



* use this for solar & wind slices
*$ontext
allslices /s10,s11*s19,s1A,s1B,s1C,s1D,s1E,s1F,
              s21*s29,s2A,s2B,s2C,s2D,s2E,s2F,
              s31*s39,s3A,s3B,s3C,s3D,s3E,s3F,
              s41*s49,s4A,s4B,s4C,s4D,s4E,s4F,
              s51*s59,s5A,s5B,s5C,s5D,s5E,s5F,
              s61*s69,s6A,s6B,s6C,s6D,s6E,s6F,
              s71*s79,s7A,s7B,s7C,s7D,s7E,s7F,
              s81*s89,s8A,s8B,s8C,s8D,s8E,s8F,
              s91*s99,s9A,s9B,s9C,s9D,s9E,s9F,
              sA1*sA9,sAA,sAB,sAC,sAD,sAE,sAF,
              sB1*sB9,sBA,sBB,sBC,sBD,sBE,sBF,
              sC1*sC9,sCA,sCB,sCC,sCD,sCE,sCF,
              sD1*sD9,sDA,sDB,sDC,sDD,sDE,sDF,
              sE1*sE9,sEA,sEB,sEC,sED,sEE,sEF,
              sF1*sF9,sFA,sFB,sFC,sFD,sFE,sFF /
;

scalar numsolarslices /3/;
scalar numwindslices /3/;

set slice(allslices);
slice(allslices) $ ((mod(ord(allslices)-2, 15) < numwindslices) and (floor((ord(allslices)-2)/15) < numsolarslices)) = yes;
slice('s10') = no;
*$offtext





sets

energy /oil1,oil2,oil3, bio, bio1, bio2, bio3,hydro, wind, solar, gas1, gas2, gas3, oil, coal1,coal2, coal,
          MeOH, H2,  elec, petro, air_fuel,trsp, pellets, CH4 , central_heat, dist_heat, solid_heat
         non_solid_heat, feed-stock,  uranium1, uranium2, uranium3, uranium4, uranium5, biogas, ethanol, biodiesel,
          PuR, EU4, EU1, Pu,FBF, MOX, Rep1, Rep2, Rep3, sLWRf, BrProd, sCANDUf, sMoxf, waste, CANDUw, MOXw, Brwaste,
          windonshoreA, windonshoreB, windoffshore, pvrooftop, pvplantA, pvplantB, cspplantA, cspplantB,
          storage_12h, storage_24h, storage_48h, storage_96h /

sector(energy) /elec, central_heat, dist_heat, solid_heat
         non_solid_heat, feed-stock ,h2,  MeOH, biogas, ethanol, biodiesel,oil   /

en_in (energy)  / oil2, oil1,oil3, coal1, coal2,  bio1, bio2, bio3, bio, hydro, wind, solar, gas1, gas2, gas3, oil, coal,
                   MeOH, biogas, ethanol, biodiesel, H2, elec, petro, air_fuel, CH4, pellets, uranium1, uranium2, uranium3, uranium4, uranium5,
                  PuR, EU4, EU1, Pu, FBF, MOX, Rep1, Rep2, Rep3, sLWRf, BrProd, sCANDUf, sMoxf,
                  windonshoreA, windonshoreB, windoffshore, pvrooftop, pvplantA, pvplantB, cspplantA, cspplantB,
                  storage_12h, storage_24h, storage_48h, storage_96h /

end_use(energy)    / central_heat, dist_heat, solid_heat
                 non_solid_heat, feed-stock/

en_out (energy)  / oil,  elec, MeOH, biogas, ethanol, biodiesel, H2,  petro, air_fuel ,trsp, CH4, coal, central_heat, dist_heat, solid_heat
                 non_solid_heat, feed-stock, pellets, bio, EU4, EU1, Pu, FBF, MOX, Rep1, Rep2, Rep3, sLWRf, BrProd, sCANDUf, sMoxf, waste, CANDUw, MOXw, PuR, Brwaste/

elecsector(en_out) / h2, trsp, central_heat, dist_heat, solid_heat, non_solid_heat /

thermalelec(en_in) / bio, oil, CH4, coal, EU4, EU1, FBF, MOX, hydro /

class_tech(en_in) / windonshoreA, windonshoreB, windoffshore, pvrooftop, pvplantA, pvplantB, cspplantA, cspplantB /

storage_tech(energy) / storage_12h, storage_24h, storage_48h, storage_96h /

no_stock(energy) /sLWRf, BrProd, sMoxf, sCanduf,Rep1, Rep2, Rep3/

nuclear_fuel(energy) /  sLWRf, BrProd, sMoxf, sCanduf,FBF, MOX, Rep1, Rep2, Rep3 ,EU4, EU1, Pu, PuR ,uranium1, uranium2, uranium3, uranium4, uranium5   /

no_stock1(en_in) /sLWRf, BrProd, sMoxf, sCanduf, Rep1, Rep2, Rep3 /

wastes(en_out) /waste, MOXw, CANDUw, Brwaste/

Rep(en_in) /Rep1, Rep2, Rep3/

sector1(en_out) /elec, central_heat, dist_heat, solid_heat
         non_solid_heat, feed-stock/

solid(en_in) /bio, pellets, coal/
dec_heat(en_out) /central_heat, solid_heat, non_solid_heat/

heat(en_out) /central_heat, dist_heat/

cg_fuel (en_in)  / bio, CH4,biogas, oil, coal, H2 /

primary (en_in) / bio1, bio2, bio3, hydro, wind, solar, gas1, gas2, gas3, oil2,  oil1,oil3, coal1, coal2,
                  uranium1, uranium2, uranium3, uranium4, uranium5 /

second_in (energy) / bio, oil, H2, elec, MeOH, biogas, ethanol, biodiesel, petro, air_fuel, CH4, coal, pellets, EU4, EU1, Pu, FBF, MOX, Rep1, Rep2, Rep3, sLWRf, BrProd, sCANDUf, sMoxf /

calibration_set (energy) / bio, hydro, wind, solar, oil, H2, elec, MeOH, biogas, ethanol, biodiesel, petro, air_fuel, CH4, coal, pellets, EU4, EU1, Pu, FBF, MOX, Rep1, Rep2, Rep3, sLWRf, BrProd, sCANDUf, sMoxf /

fuels (primary) / bio1, bio2, bio3, coal1, coal2, oil1, oil2,oil3, gas1, gas2, gas3, uranium1, uranium2, uranium3, uranium4, uranium5 /

stock (primary) /coal1, coal2, oil1, oil2,oil3, gas1, gas2, gas3, uranium1, uranium2, uranium3, uranium4, uranium5/

oil_fuel(energy) /oil1, oil2, oil3, petro, oil/

c_fuel (energy) /  coal, oil, CH4 /
ccs_fuel (energy) /  coal, oil, CH4 , bio/
feed(energy) /coal, petro, MeOH, biogas, ethanol, biodiesel, CH4, oil/

type           /  0, cg, dec, cg_dec /
C_capt (type)  / dec, cg_dec/
CG_type (type) / cg, cg_dec /


trsp_fuel (energy)              / elec, MeOH, biogas, ethanol, biodiesel, H2, petro, air_fuel , CH4/

*new_trsp_fuel (trsp_fuel) / MeOH, biogas, ethanol, biodiesel, H2, CH4 /
road_fuel(trsp_fuel)            / MeOH, biogas, ethanol, biodiesel, H2, CH4, petro,elec /
road_fuel_liquid(road_fuel)    / MeOH, biogas, ethanol, biodiesel,  petro, H2, CH4 /


engine_type   / 0, FC , hyb, BEV, PHEV/
elec_veh(engine_type) /BEV, PHEV/
non_phev(engine_type) /   0, FC , hyb, BEV/
IC_FC(engine_type) /0, FC/

trsp_mode   / p_car, p_air, p_bus, p_rail,  f_road, f_air, f_sea, f_isea, f_rail /
car_or_truck (trsp_mode) / p_car, f_road, p_bus/
heavy_mode (trsp_mode) /  f_sea, f_isea  /
frgt_mode (trsp_mode)   / f_road, f_air, f_sea, f_isea, f_rail /
freight_bus_mode (trsp_mode)  / f_road, p_bus, f_sea, f_isea /
air_mode (trsp_mode) / p_air, f_air /

;

alias (t_a, t_b);
alias (slice, slice2);
