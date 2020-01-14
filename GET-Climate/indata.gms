$CALL GDXXRW.EXE indata_B2_base.xls @import_indata.txt
#parameter  population ( regions, t_1 ) ;
parameter dem_base(energy, t)  ;
parameter init_capital ( energy, en_out, type) ;
parameter init_energy( energy, en_out, type) ;
parameter trsp_demand_base(trsp_mode, t);
#parameter ptrsp( regions, ptrs_mode, t) ;
parameter num_veh(car_or_truck, t) ;
#parameter frgt(regions, frgt_mode, t);
#parameter num_trucks( regions, t_1) ;
#parameter C_conc_trajectory(t)  ;
#parameter GDP(t);
#parameter price_dem(sector, t_1);
#parameter trsp_price(trsp_mode,t_1);
parameter scenario(scen, t);
$GDXIN indata_B2_base.gdx
#$LOAD population
$LOAD dem_base
$LOAD init_capital
$LOAD init_energy
#$LOAD ptrsp
$LOAD trsp_demand_base
$LOAD num_veh
#$LOAD frgt
#$LOAD C_conc_trajectory
#$LOAD GDP
#$LOAD price_dem
#$LOAD trsp_price
$LOAD scenario
$GDXIN


parameters
dem(energy, t)
trsp_demand(trsp_mode, t)   demand given in EJ
freight_demand(car_or_truck, t)
trajec(t);

#dem_base(sector, t) $ (year(t) >= 2140) = dem_base(sector, "2130");
#num_veh(car_or_truck, t) $ (year(t) >= 2140) = num_veh(car_or_truck, "2130");
#ptrsp(regions, ptrs_mode, t) $ (year(t) >= 2140) = ptrsp(regions, ptrs_mode, "2130");
#frgt(regions, frgt_mode, t) $ (year(t) >= 2140) = frgt(regions, frgt_mode, "2130");
#scenario(scen, t) $ (year(t) >= 2140) = scenario(scen, "2130");

#trsp_demand_base(ptrs_mode, t) =sum( regions, ptrsp(regions, ptrs_mode, t) ) ;
#trsp_demand_base(frgt_mode, t) =sum( regions, frgt(regions, frgt_mode, t) ) ;

dem(sector, t) = dem_base(sector,t);
trsp_demand(trsp_mode, t) = trsp_demand_base(trsp_mode, t) ;
freight_demand("f_road",t)=sum(heavy_mode, trsp_demand(heavy_mode,t));



$CALL GDXXRW.EXE tech-data-GET7.xls @import.txt
#$CALL GDXXRW.EXE tech-data-DOE.xls @import.txt
Parameter cost_inv_base (en_in, type, en_out) ;
Parameter cost_inv_0 (en_in, type, en_out) ;
Parameter cost_eng_base(road_fuel, engine_type, car_or_truck) ;
parameter effic_0(energy, type, en_out);
Parameter heat_effic (en_in, type, en_out, energy);
Parameter capt_effic (energy, type, en_out);
parameter lf(en_in, type, en_out);
parameter infra_cost(en_in, type, en_out);
parameter trsp_conv (trsp_fuel, engine_type, trsp_mode)  ;
$GDXIN tech-data-GET7.gdx
#$GDXIN tech-data-DOE.gdx
$LOAD cost_inv_base
$LOAD cost_inv_0
$LOAD cost_eng_base
$LOAD effic_0
$LOAD heat_effic
$LOAD capt_effic
$LOAD lf
$LOAD infra_cost
$LOAD trsp_conv
$GDXIN