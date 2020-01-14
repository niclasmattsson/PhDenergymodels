*****************************************************
**** scenario constraints **************************
*****************************************************



C_capt_agg.up = 2000000;
*high 5000000
*normal 2000000
* 2000000  MtCO2 from IPCC CCSreport  at least that much expected
* 1000000 low

*****Carbon constraint****************
trajec(reg,t)=
scenario("400",reg,t);
*1000000;


********** Nuclear scenario constraints******************************
*cap_invest.fx(nuclear_fuel,en_out,type,"OECD",t)$(year(t)>2010) = 0;
*en_conv.up(nuclear_fuel,en_out,type,"OECD",t)$(year(t)>2040) = 0.0001;
*cap_invest.fx(nuclear_fuel,en_out,type,"ROW",t)$(year(t)>2010) = 0;
*en_conv.up(nuclear_fuel,en_out,type,"ROW",t)$(year(t)>2040) = 0.0001;
*cap_invest.fx(nuclear_fuel,en_out,type,reg,t)$(year(t)>2020) = 0;
*en_conv.up(nuclear_fuel,en_out,type,reg,t)$(year(t)>2040) = 0.0001;

*cap_invest.fx("uranium5",en_out,type,reg,t)$(year(t)>2010) = 0;
*cap_invest.fx("FBF",en_out,type,reg,t)$(year(t)>2010) = 0;
*cap_invest.fx("MOX",en_out,type,reg,t)$(year(t)>2010) = 0;
*cap_invest.fx(storage_tech,"elec","0",reg,t)=0;

**************Technology constraints**********************

*peak load
EN_CONV.lo("CH4","elec","0",reg,t)$(year(t)<=2040) = 0.2*dem("elec",reg,t)/effic("CH4","elec","0",reg,t);

*Pulp and paper industry
EN_CONV.lo("bio","solid_heat","0",reg,t) =0.2*dem("solid_heat",reg,t);

capital.up( "solar","central_heat",type, reg, t)$(year(t)< 2020)=0;
capital.up( "solar","dist_heat" ,type, reg, t)$(year(t)< 2020)=0;
capital.fx(ccs_fuel, en_out, C_capt,reg, t)$(year(t)<2020)= 0;
cap_invest.fx(storage_tech,"elec","0",reg,t)$(year(t)<2020)=0;

*Max 10 new reactors built 2020 to 2030 per region
cap_invest.up(nuclear_fuel,"elec",type,reg,t)$(year(t)= 2020)= 0.0001;

*cars
engines.FX(trsp_fuel, engine_type, car_or_truck, reg,init_year) = 0;
engines.FX("petro", "0", "p_car", reg,init_year) = num_veh("p_car", reg,init_year)+0.001 ;
engines.FX("petro", "0", "f_road", reg,init_year) =  num_veh("f_road", reg,init_year)+0.001;
engines.FX("petro", "0", "p_bus", reg,init_year) =  num_veh("p_bus", reg,init_year)+0.001 ;
infra.up(trsp_fuel, reg,init_year)$((not sameas(trsp_fuel,'petro')) and (not sameas(trsp_fuel,'elec')) and(not sameas(trsp_fuel,'air_fuel')) ) = 0.001;
engines.fx(trsp_fuel, "BEV", car_or_truck, reg,t)$(year(t)<2020)=0;
engines.fx(trsp_fuel, "PHEV", car_or_truck, reg,t)$(year(t)<2020)=0;
engines.fx(trsp_fuel, "FC", car_or_truck, reg,t)$(year(t)<2030)=0;
engines.fx(trsp_fuel, "hyb", car_or_truck, reg,t)$(year(t)<2020)=0;
engines.fx("CH4", engine_type, car_or_truck, reg,t)$(year(t)<2020)=0;
engines.fx("MeOH", engine_type, car_or_truck, reg,t)$(year(t)<2020)=0;
engines.fx("H2", engine_type, car_or_truck, reg,t)$(year(t)<2030)=0;

*****************************************************

trsp_energy.fx(trsp_fuel, engine_type, trsp_mode, reg,t)$(trsp_conv(trsp_fuel, engine_type, trsp_mode)=0) =  0;
capital.fx(en_in,en_out,type,reg,t) $ (effic_0(en_in,type,en_out) eq 0) = 0;
EN_CONV.fx(en_in,en_out,type,reg,t) $ (effic_0(en_in,type,en_out) eq 0) = 0;


* INITIAL ENERGY CONVERSION LEVELS
capital.fx(en_in,"MeOH",type,reg,t)$(year(t)<2020) = 0;
capital.UP(en_in,"ethanol",type,reg,t)$(year(t)<2020) = 0;
capital.UP(en_in,"biogas",type,reg,t)$(year(t)<2020) = 0;
capital.UP(en_in,"biodiesel",type,reg,t)$(year(t)<2020) = 0;

capital.UP("MOX","elec",type,reg,t)$(year(t)< 2020)= 0;
capital.UP("EU4","H2",type,reg,t) $(year(t)< 2030)= 0;
capital.UP("FBF","elec",type,reg,t) $(year(t)< 2030)= 0;
*capital.up("EU4","elec",type,"OECD",t)$(year(t)< 2030)= 0.37;
*capital.up("EU4","elec",type,"MIC",t)$(year(t)< 2030)=0.26;
*capital.up("EU4","elec",type,"ROW",t)$(year(t)< 2030)=0.13;
*capital.UP("hydro","elec",type,"OECD","2020")= 0.32;
*capital.UP("hydro","elec",type,"MIC","2020")= 0.40;
*capital.UP("hydro","elec",type,"ROW","2020")= 0.18;
capital.UP("solar","elec","cg",reg,"2010")= 0;
capital.up(en_in, "H2", type,reg, t)$(year(t)< 2020)= 0;
capital.up("H2", en_out, type,reg, t)$(year(t)< 2020)= 0;
capital.UP("pellets",en_out,type,reg,t)$(year(t)< 2020)= 0;
capital.UP("EU1","elec",type,reg,t)= 0;
$ontext
*Calibration with IEA data
supply_1.lo (primary,reg, t) $(year(t)< 2020)= supply_1_imp(primary, t, reg)*0.9;
supply_1.up (primary,reg, t) $(year(t)< 2020)= supply_1_imp(primary, t, reg)*1.3;

en_conv.lo(second_in, "elec", type, reg, t)$(year(t)< 2020)  = elec_imp (second_in, t,"elec", type , reg) /(effic(second_in,  "elec", type ,reg, t)+ 0.000001)*0.70 ;
en_conv.up (second_in, "elec", type, reg, t)$(year(t)< 2020) = elec_imp (second_in, t, "elec", type, reg)/(effic(second_in,  "elec", type ,reg, t)+ 0.000001)*1.1;


*Calibration, ungefär samma värde som 2000, ej kollat exakt
EN_CONV.lo("petro","dist_heat","0","OECD",t)$(year(t)<=2020) = 4;
EN_CONV.lo("coal","dist_heat","0",reg,t)$( year(t)<=2020) = 1;
EN_CONV.lo("oil","non_solid_heat","0",reg,t)$( year(t)<=2020) = 0.2*dem("non_solid_heat",reg,t)/effic("oil","non_solid_heat","0",reg,t);
EN_CONV.fx("CH4","solid_heat","0","OECD",t)$ (year(t)<=2030) = 12;
EN_CONV.up("elec","solid_heat","0",reg,t)$(year(t)<=2020) = 1;
EN_CONV.lo("CH4","non_solid_heat","0",reg,t)$(year(t)<=2030) = 0.4*dem("non_solid_heat",reg,t)/effic("CH4","non_solid_heat","0",reg,t);
EN_CONV.lo("EU4","elec","0","OECD","2020") = 8.2;
EN_CONV.lo("EU4","elec","0","MIC","2020") = 2;
EN_CONV.lo("EU4","elec","0","ROW","2020") = 1.1;
$offtext
C_emission.lo(reg,"2010")=0.95*emissions_2010(reg);
en_conv.lo(calibration_set, "elec", "0", reg, "2010") = 0.95*el_2010(reg, calibration_set)/(effic(calibration_set, "elec", "0", reg, "2010")+0.000001);
en_conv.up(calibration_set, "elec", "0", reg, "2010") = 1.05*el_2010(reg, calibration_set)/(effic(calibration_set, "elec", "0", reg, "2010")+0.000001);
* minimum of bioenergi that goes to heat ROW from IIASA B2 480 scenario non-commercial demand
EN_CONV.fx("bio","dist_heat","0",reg,t) = min_bio(reg,t);
*EN_CONV.lo("elec","H2","0",reg,"2080") = 5;
*capital_class.lo("pvplantA","c3","NAM","2100") = 0.5;
