***********************************************************
***** GET version 8.0                                  *****
*****              *****
************************************************************

************************************************************

*execseed = 1+gmillisec(jnow);

$ include "sets.gms";

$ include "params.gms";

************************************************************
******************** EQUATIONS *****************************
************************************************************

$ include "declare.gms";

*supply_2.up("non_solid_heat",reg, "2000")=0;
************************************************************
***** supply and conversion to delivered energy forms ******
************************************************************
supply_pot_Q(primary, reg,t)..
    supply_pot(primary, reg,t) =G= supply_1(primary,reg, t);

supply_1_Q(primary,reg, t)..
    supply_1(primary, reg,t)  =E= sum( (type, en_out), en_conv(primary, en_out, type, reg, t) );

export_import_balance(second_in, t)..
         sum(reg, export(second_in, reg,t))=e=sum(reg, import( second_in, reg, t));

supply_2_Q(second_in,reg, t)..
    supply_2(second_in, reg,t)-export(second_in, reg,t)+import(second_in,reg,t) =e= sum( (type, en_out), en_conv(second_in, en_out, type,reg, t) ) ;

supply_loop_Q(second_in,reg,t)..
    supply_2(second_in, reg,t) =L= energy_prod(second_in, reg,t);

energy_prod_Q(en_out,reg,t) $ (not sameas(en_out,"elec"))..
    energy_prod(en_out,reg,t) =E=
        sum((type,en_in), en_conv(en_in,en_out,type,reg, t) * effic(en_in, en_out, type, reg,t))
        + supply_sec(en_out,reg,t);

energy_prod_elec_Q(reg,t)..
    energy_prod("elec",reg,t) =E=
        sum((type,en_in) $ (not sameas(en_in,"solar") and not sameas(en_in,"wind")),
                            en_conv(en_in,"elec",type,reg,t) * effic(en_in,"elec",type,reg,t))
        + supply_sec("elec",reg,t) - elec_losses(reg,t);

energy_prod2_Q(en_in, en_out, type, reg,t)..
    energy_prod2(en_in, en_out, type,reg,t) =E=
         en_conv(en_in, en_out, type,reg, t) * effic(en_in, en_out, type, reg,t)+supply_sec2(en_in, en_out, type, reg,t);

reserves_Q(stock, reg).. sum(t, t_step*supply_1(stock, reg,t) )=L= supply_pot_0(stock, reg);

no_stock_Q(no_stock,reg,t) ..
energy_prod(no_stock, reg,t)=e= sum( (type, en_out), en_conv(no_stock, en_out, type,reg, t) ) ;

waste_fl_Q(wastes, reg, t) ..
waste_fl(wastes, reg, t)  =e= (sum((en_in), en_conv (en_in, wastes, "0", reg, t)* effic(en_in, wastes, "0", reg, t))) ;

q_Saved_pu(reg,t)$(year(t)>=2000)..
         Pu_stock(reg, t+1)=e= Pu_stock(reg, t)+en_conv ("Rep2", "PuR", "0", reg, t)* effic("Rep2","PuR", "0", reg, t)-sum(en_out, en_conv ("PuR", en_out, "0", reg, t)  )    ;

q_start_pu(reg,t)..
         Pu_stock(reg, "2010")=e= Pu_start( reg);

agg_waste_Q(wastes)..
    agg_waste(wastes) =E= sum((t,reg), t_step * waste_fl(wastes, reg, t));
************************************************************
*** energy delivered                                     ***
************************************************************

energy_deliv_Q(en_out, reg,t)..
    energy_deliv(en_out, reg,t) =e= energy_prod(en_out,reg, t)  -supply_2(en_out,reg, t);

supply_sec_Q(energy,reg,t)  ..
supply_sec(energy,reg,t)=e= sum( (en_in, type, en_out), en_conv(en_in, en_out, type,reg, t)*heat_effic(en_in, type, en_out, energy) );

supply_sec2_Q(en_in, energy,type, reg,t)  ..
supply_sec2(en_in, energy, type,reg,t)=e= sum( ( en_out), en_conv(en_in, en_out, type,reg, t)*heat_effic(en_in, type, en_out, energy) );

Breeder_lag_Q(en_in, en_out, type,reg, "2030") ..
en_conv("Rep3", "FBF", type,reg, "2030")=l=en_conv("Rep2", "FBF", type,reg, "2030")*effic("Rep2", "FBF", type, reg,"2030")+ en_conv("Pu", "FBF", type,reg, "2030")*effic("Pu", "FBF", type, reg,"2030")+ en_conv("EU4", "FBF", type,reg, "2030")*effic("EU4", "FBF", type, reg,"2030")  ;

Breeder_lag_Q2(en_in, en_out, type,reg, t) $(year(t)>2030) ..
en_conv("Rep3", "FBF", type,reg, t)=l=en_conv("Rep2", "FBF", type,reg, t)*effic("Rep2", "FBF", type, reg,t)+ en_conv("Pu", "FBF", type,reg, t)*effic("Pu", "FBF", type, reg,t)+ en_conv("EU4", "FBF", type,reg, t)*effic("EU4", "FBF", type, reg,t)+ en_conv("Rep3", "FBF", type,reg, t-1)  ;

$ontext

supply_sec_Q(energy,reg,t) $ ((not sameas(energy, 'BrProd')) and ( not sameas (energy, "sLWRf"))) ..
   supply_sec(energy,reg,t)=e= sum( (en_in, type, en_out), en_conv(en_in, en_out, type,reg, t)*heat_effic(en_in, type, en_out, energy) );

supply_sec2_Q(en_in, energy,type, reg,t) $ ((not sameas(energy, 'BrProd')) and ( not sameas (energy, "sLWRf"))) ..
supply_sec2(en_in, energy, type,reg,t)=e= sum( ( en_out), en_conv(en_in, en_out, type,reg, t)*heat_effic(en_in, type, en_out, energy) );

supply_sec_breeder_lag_Q(reg,t) ..
   supply_sec('BrProd',reg,t)=e= sum( (en_in, type, en_out), en_conv(en_in, en_out, type,reg, t-1)*heat_effic(en_in, type, en_out, 'BrProd') );

supply_sec_breeder_lag2_Q(en_in,type, reg,t) ..
supply_sec2(en_in, "BrProd",type, reg,t)=e= sum( ( en_out), en_conv(en_in, en_out, type,reg, t-1)*heat_effic(en_in, type, en_out, "BrProd") );

supply_sec_rep_lag_Q(reg,t) ..
   supply_sec('sLWRf',reg,t)=e= sum( (en_in, type, en_out), en_conv(en_in, en_out, type,reg, t-1)*heat_effic(en_in, type, en_out, 'sLWRf') );

supply_sec_rep_lag2_Q(en_in,type, reg,t) ..
supply_sec2(en_in, "sLWRf",type,reg,t)=e= sum( (  en_out), en_conv(en_in, en_out, type,reg, t-1)*heat_effic(en_in, type, en_out, "sLWRf") );
$offtext

************************************************************
*** transportation module                                ***
************************************************************

transp_q(trsp_fuel,reg,t)..
         sum( (trsp_mode, engine_type), trsp_energy(trsp_fuel, engine_type, trsp_mode, reg,t) )=e=
         sum(type, en_conv(trsp_fuel, "trsp", type, reg,t)*effic(trsp_fuel, "trsp", type,reg,t));

trsp_demand_Q(trsp_mode, reg,t)..
    trsp_demand(trsp_mode, reg,t) =e= sum( (trsp_fuel, engine_type),
    trsp_energy(trsp_fuel, engine_type, trsp_mode,reg, t)*trsp_conv(trsp_fuel, engine_type, trsp_mode) );

vehicle_lim_Q(trsp_fuel, non_phev, car_or_truck, reg,t)..
    trsp_energy(trsp_fuel, non_phev, car_or_truck, reg,t) =l=
        engines(trsp_fuel, non_phev, car_or_truck, reg, t)/num_veh(car_or_truck,reg, t)*
        (trsp_demand(car_or_truck, reg,t))/(trsp_conv(trsp_fuel, non_phev, car_or_truck)+0.0001);

vehicle_lim_PHEV_Q(road_fuel_liquid,engine_type, car_or_truck, reg,t)..
    trsp_energy(road_fuel_liquid, "PHEV", car_or_truck, reg,t) =e=
        engines(road_fuel_liquid, "PHEV", car_or_truck, reg,t)/
           num_veh(car_or_truck,reg, t)*(1-elec_frac_PHEV(car_or_truck))*
              trsp_demand(car_or_truck,reg, t)/(trsp_conv(road_fuel_liquid, "PHEV", car_or_truck)+0.001);

elec_frac_PHEV_Q(car_or_truck,  engine_type,reg,t)..
     sum(road_fuel_liquid, trsp_energy(road_fuel_liquid, "PHEV", car_or_truck,reg, t)*
         trsp_conv (road_fuel_liquid, "PHEV", car_or_truck))/(1-elec_frac_PHEV(car_or_truck)) =e=
            trsp_energy( "elec", "PHEV", car_or_truck,reg, t)*
               trsp_conv ("elec", "PHEV", car_or_truck)/(elec_frac_PHEV(car_or_truck));

lim_elec_veh(car_or_truck,elec_veh,reg,t)..
         sum(trsp_fuel, engines(trsp_fuel, elec_veh, car_or_truck, reg,t))=l=
          frac_engine(elec_veh, car_or_truck)*num_veh(car_or_truck, reg,t) ;

q_sea( engine_type, heavy_mode , reg,t)$(year(t)<2050)..
         trsp_energy("H2", engine_type, heavy_mode , reg,t)=e=0;


************************************************************
*** balance demand and supply                            ***
************************************************************

Deliv_Q(sector,reg,t) $ (not sameas(sector,"elec")) ..
    energy_deliv(sector,reg,t) =e= dem(sector,reg,t);

************************************************************
*** electricity sector                                   ***
************************************************************

* to do:
* hydro - split between storage & run of river, annual inflow, put x% of hydro storage in run of river to reflect regulations
* sliced central_heat sector (may overinvest in capacity to profit from low elec prices)
* timeshifting of demand in central_heat, solid_heat, non_solid_heat, trsp (implement as a storage technology)
* BUT only central_heat and trsp matter, other sectors phase out electricity
* storage technologies with characteristic timescales (pumped hydro, compressed air, batteries)
* hydrogen - how long can it be stored etc.


Elec_Deliv_Dem_Q(reg,slice,t)..
    elec_deliv(reg,slice,t) =e= elec_dem(reg,slice,t);

elec_deliv_Q(reg,slice,t)..
    elec_deliv(reg,slice,t) =e= energy_deliv("elec",reg, t) * slice_lng(reg,slice) * sliced_demand(reg,slice);

elec_use_Q(elecsector,reg,slice,t)..
    elec_use(elecsector,reg,slice,t) =e=
        en_conv("elec",elecsector,"0",reg,t) * slice_lng(reg,slice) * sliced_demand(reg,slice);

sliced_elec_balance(reg,slice,t)..
* avoid double counting solar & wind (subtechs represented both individually & collectively)
    sum((en_in,type) $ (not sameas(en_in,"solar") and not sameas(en_in,"wind")), elec_gen(en_in,type,reg,slice,t)) =e=
        elec_dem(reg,slice,t)
        + sum(elecsector, elec_use(elecsector,reg,slice,t))
        - sum((storage_tech, slice2), storage_slice_transfer(storage_tech,reg,slice2,slice,t) * effic(storage_tech,"elec","0",reg,t))
        + sum((storage_tech, slice2), storage_slice_transfer(storage_tech,reg,slice,slice2,t));

total_losses_Q(reg,t)..
    elec_losses(reg,t) =E= sum((storage_tech,slice,slice2), storage_slice_transfer(storage_tech,reg,slice2,slice,t) * (1-effic(storage_tech,"elec","0",reg,t)));

elec_gen_Q(en_in,type,reg,t)..
    sum(slice, elec_gen(en_in,type,reg,slice,t)) =e= en_conv(en_in,"elec",type,reg,t) * effic(en_in,"elec",type,reg,t);

* equation rearranged to avoid division-by-zero error if a slice has zero length
thermal_limit(thermalelec,type,reg,slice,slice2,t)..
*        elec_gen(thermalelec,type,reg,slice,t) / slice_lng(reg,slice) =G= ramp_lim(thermalelec,type) * elec_gen(thermalelec,type,reg,slice2,t) / slice_lng(reg,slice2);
        elec_gen(thermalelec,type,reg,slice,t) * slice_lng(reg,slice2) =G= ramp_lim(thermalelec,type) * elec_gen(thermalelec,type,reg,slice2,t) * slice_lng(reg,slice);

elec_capital_lim_class(class_tech,class,reg,slice,t) ..
    elec_gen_class(class_tech,class,reg,slice,t) =L= capital_class(class_tech,class,reg,t) *
                                       lfsl(class_tech,class,reg,slice) * Msec_per_year * slice_lng(reg,slice);

* make exception for hydro
elec_capital_lim_Q(en_in,type,reg,slice,t) $ (not is_class_tech(en_in)) ..
    elec_gen(en_in,type,reg,slice,t) =L= capital(en_in,"elec",type,reg,t) *
                                       lfs(en_in,type,reg,slice,"elec") * Msec_per_year * slice_lng(reg,slice);

* above constraint invalid for storage techs (lfs = 0), here's the real one
* unit of storage_slice_transfer_times is hours/year, capital is TW and all energy units are EJ
storage_capital_lim_Q(storage_tech,reg,slice,slice2,t)..
    storage_slice_transfer(storage_tech,reg,slice,slice2,t) =L= capital(storage_tech,"elec","0",reg,t) *
                                        storage_slice_transfer_times(storage_tech,reg,slice,slice2) * 3600 / 1e6;

capital_class_limit(class_tech,class,reg,t)..
    capital_class(class_tech,class,reg,t) =L= class_capacity_limit(class_tech, class, reg);

elec_class_aggregation(class_tech,reg,slice,t)..
    sum(class, elec_gen_class(class_tech,class,reg,slice,t)) =E= elec_gen(class_tech,"0",reg,slice,t);

capital_class_aggregation(class_tech,reg,t)..
    sum(class, capital_class(class_tech,class,reg,t)) =E= capital(class_tech,"elec","0",reg,t);

wind_elec_aggregation(reg,slice,t)..
    elec_gen("windonshoreA","0",reg,slice,t) + elec_gen("windonshoreB","0",reg,slice,t) +
                elec_gen("windoffshore","0",reg,slice,t) =E= elec_gen("wind","0",reg,slice,t);

wind_capital_aggregation(reg,t)..
    capital("windonshoreA","elec","0",reg,t) + capital("windonshoreB","elec","0",reg,t) +
                capital("windoffshore","elec","0",reg,t) =E= capital("wind","elec","0",reg,t);

pv_elec_aggregation(reg,slice,t)..
    elec_gen("pvrooftop","0",reg,slice,t) + elec_gen("pvplantA","0",reg,slice,t) +
                elec_gen("pvplantB","0",reg,slice,t) =E= elec_gen("solar","0",reg,slice,t);

pv_capital_aggregation(reg,t)..
    capital("pvrooftop","elec","0",reg,t) + capital("pvplantA","elec","0",reg,t) +
                capital("pvplantB","elec","0",reg,t) =E= capital("solar","elec","0",reg,t);

csp_elec_aggregation(reg,slice,t)..
    elec_gen("cspplantA","0",reg,slice,t) + elec_gen("cspplantB","0",reg,slice,t)
                                                    =E= elec_gen("solar","cg",reg,slice,t);

csp_capital_aggregation(en_in,reg,t)..
    capital("cspplantA","elec","0",reg,t) + capital("cspplantB","elec","0",reg,t)
                                                    =E= capital("solar","elec","cg",reg,t);

************************************************************
*** use limited by capital                               ***
************************************************************

capital_lim_Q(en_in, en_out, type,reg, t) $ (not sameas(en_out, "elec")) ..
    en_conv(en_in, en_out, type, reg,t)* effic(en_in, en_out, type, reg,t) =L= capital(en_in, en_out, type,reg, t)
                                       *lf(en_in, type, en_out)*Msec_per_year;

infra_lim_Q(trsp_fuel, reg,t)..
    sum(type, en_conv(trsp_fuel, "trsp", type, reg,t)* effic(trsp_fuel, "trsp", type,reg, t))
          =L= infra(trsp_fuel,reg, t)*lf_infra(trsp_fuel)*Msec_per_year;


************************************************************
*** investments and depreciation                         ***
*** investments are available directly                   ***
************************************************************

init_invest_Q(en_in, en_out, type, reg,init_year)..
    capital(en_in, en_out, type, reg,init_year) =E= init_capital(en_in, en_out, type, reg)
                   + t_step *cap_invest(en_in, en_out, type,reg, init_year);

capital_Q(en_in, en_out, type, reg,t+1)..
    capital(en_in, en_out, type, reg,t+1) =E= t_step * cap_invest(en_in, en_out, type, reg,t+1)
           + capital(en_in, en_out, type, reg,t)*exp(t_step*log(1-1/life_plant(en_in, en_out, type)));

engines_Q(trsp_fuel, engine_type, car_or_truck, reg,t+1)..
    engines(trsp_fuel, engine_type, car_or_truck,reg, t+1) =E= t_step * eng_invest(trsp_fuel, engine_type, car_or_truck,reg, t+1)
           + engines(trsp_fuel, engine_type, car_or_truck, reg,t)*
             exp(t_step*log(1-1/life_eng(trsp_fuel, engine_type, car_or_truck)));

infra_Q(trsp_fuel,reg, t+1)..
    infra(trsp_fuel, reg,t+1) =E= t_step * infra_invest(trsp_fuel,reg, t+1)
           + infra(trsp_fuel,reg, t) * exp(t_step*log(1-1/life_infra(trsp_fuel)));

************************************************************
*** annual and total costs                               ***
************************************************************

cost_fuel_Q(reg,t)..
    cost_fuel(reg,t) =E= sum(fuels, supply_1(fuels, reg,t)*price(fuels, reg))+sum(second_in, import(second_in, reg,t)*import_cost(second_in))
        ;

cost_cap_Q(reg,t)..
    cost_cap(reg,t) =E=
    sum( (en_in, en_out, type),
        cap_invest(en_in, en_out, type,reg, t)*cost_inv(en_in, en_out, type, t) )+
    sum( (road_fuel, engine_type, car_or_truck),
        eng_invest(road_fuel, engine_type, car_or_truck, reg,t)*(cost_eng(road_fuel, engine_type, car_or_truck, t)) )+
    sum( trsp_fuel,
        infra_invest(trsp_fuel,reg, t)*cost_infra_mod(trsp_fuel) );

cost_C_strg_Q(t)..
    cost_C_strg(t) =E=   sum( (c_fuel, en_out, C_capt, reg),
            en_conv(c_fuel, en_out, C_capt, reg,t)*emis_fact(c_fuel)*capt_effic(c_fuel,c_capt,en_out) )* cost_strg_fos
         + sum( ( en_out, C_capt, reg), en_conv("bio", en_out, C_capt, reg,t)*emis_fact("bio")*capt_effic("bio",c_capt,en_out) )
          *cost_strg_bio;

tax_Q(reg,t)..
    tax(reg,t) =E= C_emission(reg,t)*C_tax(reg,t);

OM_cost_Q(t)..
    OM_cost(t) =E= sum( (en_in, en_out, type, reg), OM_cost_fr(en_in, en_out) * cost_inv(en_in, en_out, type, t) *
        en_conv(en_in, en_out, type,reg, t) * effic(en_in, en_out, type,reg, t) / Msec_per_year/(lf(en_in, type, en_out)+0.000001)) ;
*        en_conv(en_in, en_out, type,reg, t) * effic(en_in, en_out, type,reg, t) / Msec_per_year/(lf(en_in, type, en_out)+0.01)) ;

dist_cost_Q(t)..
      dist_cost(t)=e=sum( (en_in, type, en_out, reg), en_conv(en_in, en_out, type,reg, t)*infra_cost(en_in, type, en_out))
         +sum(reg, supply_sec("central_heat",reg,t)*district_cost);

annual_cost_Q(t)..
    annual_cost(t) =E= sum(reg, cost_fuel(reg, t)) +
                     sum(reg, cost_cap(reg, t)) +
                     OM_cost(t) +
                     dist_cost(t) +
                     cost_C_strg(t) +
                     cost_C_bio_trsp(t)  +
                     sum(reg, tax(reg,t)) ;

tot_cost_Q..
    tot_cost =E= sum(t, t_step * annual_cost(t)/((1+r)**(t_step*(ord(t)-1))));


************************************************************
************ technology restrictions ***********************
************************************************************
cogen_e_Q(reg,t)..
    sum( (cg_fuel, cg_type), en_conv(cg_fuel, "elec", cg_type,reg, t)*
                 heat_effic (cg_fuel, cg_type, "elec", "central_heat")) =L= cogen_fr_h * dem("central_heat",reg, t);
$ontext
interm_max_Q(reg,t)..
    en_conv("solar", "elec", "0", reg,t) + en_conv("wind", "elec", "0",reg, t) =L=
        interm_fr(reg) *(sum((en_in, type),en_conv(en_in, "elec", type,reg,t)*effic(en_in, "elec", type,reg,t))) ;

interm_max_Q2(reg,t)..
    en_conv("wind", "elec", "0",reg, t) =L=
        wind_fr *(sum((en_in, type),en_conv(en_in, "elec", type,reg,t)*effic(en_in, "elec", type,reg,t))) ;
$offtext
CSP_max_Q(reg,t)..
    en_conv("solar", "elec", "cg",reg, t)  =L=
        csp_fr(reg) *(sum((en_in, type),en_conv(en_in, "elec", type,reg,t)*effic(en_in, "elec", type,reg,t)));

max_solar_q(heat, reg,t)..
    en_conv("solar", heat, "0",reg,t)=l=dem(heat,reg,t)*max_solar(heat,reg)     ;

max_heat_pump(heat,reg,t)..
    en_conv("elec", heat, "0",reg,t)=l=dem(heat,reg,t)*max_pump(heat,reg)     ;

max_chips(reg,t)..
     sum(type,  en_conv("bio", "solid_heat", type,reg,t)*effic("bio", "solid_heat", type,reg, t))=l=dem("solid_heat",reg,t)*max_chip  ;

max_feed_stock(feed,reg, t)..
     sum(type,  en_conv(feed, "feed-stock", type,reg,t)*effic(feed, "feed-stock", type,reg, t))=l=dem("feed-stock",reg,t)*max_feed(feed)  ;


**************************************************************************
*** Expansion rate constraints********************************************
**************************************************************************

supp_lim_Q(fuels, reg,t+1)..  supply_1(fuels, reg,t+1) =L=
    supply_1(fuels, reg,t) * (1+supply_lim)**t_step + init_supply;

infra_lim1_Q(trsp_fuel, reg,t+1).. infra(trsp_fuel,reg, t+1) =L=
    infra(trsp_fuel, reg,t) * (1+infra_g_lim)**t_step+init_infra ;

eng_g_lim_Q(trsp_fuel, engine_type,car_or_truck,reg, t+1)..
         engines(trsp_fuel, engine_type, car_or_truck,reg, t+1)/num_veh(car_or_truck,reg,t+1)=L=
         marketshare_eng+engines(trsp_fuel, engine_type, car_or_truck,reg, t)/num_veh(car_or_truck,reg,t)   ;

eng_g_lim_Q2(trsp_fuel, engine_type,car_or_truck,reg, t+1)..
         engines(trsp_fuel, engine_type, car_or_truck,reg, t+1)/num_veh(car_or_truck,reg,t+1)=G=
         engines(trsp_fuel, engine_type, car_or_truck,reg, t)/num_veh(car_or_truck,reg,t)-marketshare_eng   ;

eng_g_lim_Q4( engine_type,car_or_truck,reg, t+1)..
         sum (trsp_fuel, engines(trsp_fuel, engine_type, car_or_truck,reg, t+1))=L=
         sum(trsp_fuel, engines(trsp_fuel, engine_type, car_or_truck,reg, t))*(1+eng_g_lim)**t_step+init_eng;

Q_car_balance(car_or_truck,reg,t)..
     sum((engine_type,trsp_fuel),engines(trsp_fuel, engine_type, car_or_truck,reg, t))=l= num_veh(car_or_truck,reg,t)+0.01;

cap_g_lim_Q(en_in, en_out, type,reg, t+1)..
    cap_invest(en_in, en_out, type,reg, t+1) =L=
    cap_invest(en_in, en_out, type, reg,t) * (1+cap_g_lim)**t_step+init_plant;

*$ontext
*capacity_lim_Q(en_in, sector1, type, reg, t+1) $(year(t)>2010)..
*      capital(en_in, sector1, type,reg, t+1)=L= capital(en_in, sector1, type,reg, t)* (1+growth_factor)**10 + 0.002;

*capacity_lim2_Q(en_in, sector1, type, reg, t+1) $ (year(t)>2010)..
*       capital(en_in, sector1, type,reg, t+1)=g= capital(en_in, sector1, type,reg, t)*(1- growth_factor)**10 - 0.002;

coal_lim_Q(sector1, type, reg, t+1) $ (year(t)=2010)..
      energy_prod2("coal", sector1, type,reg, t+1)=g= energy_prod2("coal", sector1, type,reg, t)* 0.9;

bio_lim_Q(second_in, en_out, type, reg, t+1) $ (year(t)>=2050)..
      energy_prod2("bio", en_out, type, reg, t+1)=L= 1.2* energy_prod2("bio", en_out,type,reg, t) ;


*$offtext
$ontext
market_share_lim_Q(en_in, sector1, type, reg, t+1) $((not (sameas(sector1, 'central_heat')))and  (year(t)>2010))..
      energy_prod2(en_in, sector1, type, reg, t+1)/ dem(sector1, reg, t+1)=L= marketshare_fr(sector1) + energy_prod2(en_in, sector1,type,reg, t)/ dem(sector1, reg, t)  ;

market_share_lim2_Q(en_in, sector1, type, reg, t+1) $((not (sameas(sector1, 'central_heat') )) and (year(t)>2010))..
       energy_prod2(en_in, sector1, type, reg, t+1)/ dem(sector1, reg, t+1) =G= energy_prod2(en_in, sector1,type,reg, t)/ dem(sector1, reg, t) - marketshare_fr(sector1) ;

market_share_lim3_Q(en_in, sector1, type, reg, t+1) $((not (sameas(sector1, 'central_heat') )) and (year(t)<=2010))..
      energy_prod2(en_in, sector1, type, reg, t+1)/ dem(sector1, reg, t+1) =G= energy_prod2(en_in, sector1,type,reg, t)/ dem(sector1, reg, t) - 0.4 ;

bio_lim_Q(second_in, en_out, type, reg, t+1) $ (year(t)>=2050)..
      energy_prod2("bio", en_out, type, reg, t+1)=L= 1.2* energy_prod2("bio", en_out,type,reg, t) ;


$offtext
*breeder_input(en_in,en_out,type,reg,t)..  en_conv("Pu","elec",type,reg,t)*(1-Pu_frac_breeder) =e= en_conv("DU238","elec",type,reg,t)*Pu_frac_breeder ;

************************************************************
*** C cycle model                                        ***
************************************************************

$ include "c_mod.gms";

************************************************************
*** emissions, capture and storage                       ***
************************************************************

emission_Q(reg,t)..
    C_emission(reg,t) =E= sum(en_out, (sum((en_in, type), en_conv(en_in,en_out, type,reg,t)
         *(emis_fact(en_in)-emis_fact(en_out)*effic(en_in, en_out, type,reg,t)) )))
                      - C_capt_tot(reg,t);

q_tot_emis(t)..
         sum(reg, C_emission(reg,t))=e=Tot_emis(t)     ;

hist_emission(t_h)..  Tot_emis(t_h) =E= (hist_fos_emis(t_h)+HIST_luc_EMIS(t_h))*3.7    ;

agg_emis_Q..
    agg_emis =E= sum((t,reg), t_step * C_emission(reg, t));

annual_emis(reg,t)$(year(t)<2060)..
         C_emission(reg,t)=l=trajec(reg,t);

q_global_cap(t)..
         sum(reg, C_emission(reg,t))=l=sum(reg,trajec(reg,t));

C_capt_tot_Q(reg,t)..
    C_capt_tot(reg,t) =E=  sum( (ccs_fuel, en_out, C_capt),
            en_conv(ccs_fuel, en_out, C_capt,reg, t)*emis_fact(ccs_fuel)*capt_effic(ccs_fuel,c_capt,en_out) )
            + sum( (en_out, C_capt), en_conv("bio", en_out, C_capt,reg, t)*110 *capt_effic("bio",c_capt,en_out))
            + sum( (en_out, C_capt), en_conv("biogas", en_out, C_capt,reg, t)*55 *capt_effic("biogas",c_capt,en_out))
            + sum( (en_out, C_capt), en_conv("pellets", en_out, C_capt,reg, t)*88 *capt_effic("pellets",c_capt,en_out))
;
*110gCO2 per MJ for BECCS
*ML not sure the numbers for biogas and pellets are correct
C_capt_agg_Q..
    C_capt_agg =E= sum((t,reg), C_capt_tot(reg,t))*t_step;

q_max_beccs(c_capt,en_out,reg,t)..
     en_conv("bio", en_out,c_capt,reg,t)=l=en_conv("coal", en_out,c_capt,reg,t)*max_beccs  ;

elec_dec_Q(reg,t)..
     elec_decarb(reg,t) =E= sum( (fuels, dec_heat) , en_conv(fuels, dec_heat,"dec",reg, t)*dec_elec(fuels) );

* NNN added to force equal slices, shouldn't change total costs in test model
*slicetest(en_in,type,reg,slice,t)..
*elec_gen(en_in,type,reg,slice,t) =E= elec_gen(en_in,type,reg,'s1',t);

******************************************************************************

model GET_7 /all/;

******************************************************************************


* transportation electricity only for personal trsp w high-speed-train
trsp_energy.FX("elec", "0", "p_air", reg,t) =
     high_speed_train(t,reg)*trsp_demand("p_air",reg, t)/trsp_conv("elec", "0", "p_air");

$ include "constraints.gms"

************************************************************

OPTION LIMROW = 0;
OPTION LIMCOL = 0;
OPTION ITERLIM = 999999999;
OPTION reslim = 999999999;
option solveopt=replace;
option sysout = off ;
option solprint = off   ;
$offlisting


option lp = cplex;
GET_7.optfile = 1;
solve GET_7 using LP minimizing tot_cost ;



*display cost_inv

*cost_inv_base, cost_inv_0, cost_inv, cost_eng_base, effic_0, heat_effic, capt_effic, lf, lfsl, lng, infra_cost, import_cost, trsp_conv, emis_fact, population, dem_base, init_capital, ptrsp, num_veh, frgt, scenario;
* cost_inv, cost_inv_base, effic, lf;
*trajec, scenario, effic, supply_2.l ;


***********************************

*$include monte_carlo2.gms
*$include costCCS_curve.gms
$include output1.gms
*display oils



*parameter techcost(*,t);
*techcost("solar",t) = cost_inv("solar", "elec", "0", t);
*techcost("wind",t) = cost_inv("wind", "elec", "0", t);
*display techcost;
