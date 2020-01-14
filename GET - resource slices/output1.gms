
parameters

report_tot_cost
report_c(*,reg,t)
report_capital(reg, en_in, en_out, type, t)
report_supply1(reg, *,t)
report_import(reg, second_in, t)
report_export(reg, second_in, t)
report_engines(reg, car_or_truck, engine_type,trsp_fuel,  t)
report_invest(reg,en_in, en_out, type, t)
infrastruc(reg, road_fuel, t)
report_transport_energy(reg, trsp_fuel,trsp_mode,engine_type, t)
report_en_conv(reg, en_in, en_out, type, t)
report_marginals(*,reg, primary,t)
end_use_price(sector,reg,t)
invest_gdp(*,t)
total_cap(t)
demand_out(reg, *,t)
report_elec_gen(en_in,type,reg,allslices,t)
total_elec_gen(reg,allslices,t)
report_elec_use(reg,elecsector,allslices,t)
report_lfs(en_in, type,reg,allslices)
report_slice_lng(reg,allslices)
report_capital_region(en_in, type, reg, t)
report_elec_gen_slice(en_in,type,reg,t,allslices)
report_elec_gen_summedslices(en_in,type,reg,t)
report_storage_transfers_2100(storage_tech,reg,allslices,allslices)
report_from_storage(t,reg,allslices)
report_to_storage(t,reg,allslices)
report_capital_class(class_tech,class,reg,t)
report_elec_solarwind(class_tech,reg,allslices,t)
report_elec_class_slice(class_tech,class,reg,allslices,t)
potential_generation(en_in,type,reg,allslices,t)
curtailment(en_in,type,reg,t,allslices)

feed_stock(reg, en_in,type,t)
non_solid_heat(reg, en_in,type, t)
solid_heat(reg, en_in,type,t)
rural_heat(reg, en_in,type,t)
urban_heat(reg,en_in,*,t)
elec(reg,calibration_set,type,t)
nuclear(reg, nuclear_fuel, en_out,type,t)
H2(reg, en_in,type,t)
MeOH(reg, en_in,type,t)
biomass(reg, en_out,t)
h2_use(reg, en_out,t)
oils(reg, oil_fuel, en_out,type,t)
prices(*,reg,t)
ccs(reg, en_out,t)
transp_energy(reg, trsp_fuel,t)
transp_km(reg, trsp_fuel,trsp_mode, t)
emission(reg, en_out,t)
marginal_el_price(reg,allslices,t)
;

parameter emis_count(en_in) /
CH4   15.4
petro 22
oil   20
coal  24.7
bio   0
/;

report_tot_cost = tot_cost.l+eps;
report_supply1(reg, primary,t) = supply_1.L(primary,reg, t)+eps;
*report_supply1(reg, Rep1,t) = sum((en_out,type), en_conv.l(Rep,en_out, type, reg, t))+eps;
*report_supply1(reg, "PuR",t) = sum((en_out,type), en_conv.l("PuR",en_out, type, reg, t))+eps;
report_import(reg, second_in, t)=import.l(second_in, reg, t)+eps;
report_export(reg, second_in, t)=export.l(second_in, reg, t)+eps;
report_c("CO2 emissions",reg,t) = c_emission.L(reg,t)+eps;
report_c("CO2 concentration",reg,t) = ATM_CCONT.L(t)+eps;
report_c("CO2 capture",reg,t) = C_capt_tot.L(reg, t)+eps;
report_c("emission.M",reg,t) = emission_Q.M(reg,t)*((1+R)**((ord(t)-1)*t_step))/t_step+eps;
report_c("annual cost",reg, t) = annual_cost.l(t);
report_capital(reg, en_in, en_out, type, t)$effic(en_in, en_out, type, reg,t) = capital.L(en_in, en_out, type,reg, t)+eps;
report_engines(reg, car_or_truck, engine_type,trsp_fuel,  t)$trsp_conv(trsp_fuel, engine_type, car_or_truck) = engines.l(trsp_fuel, engine_type, car_or_truck,reg, t)+eps;
report_invest(reg, en_in, en_out, type, t)$effic(en_in, en_out, type, reg,t) = cap_invest.l(en_in, en_out, type,reg, t)+eps;
end_use_price(sector,reg,t)=-deliv_q.m(sector,reg,t)*(1+r)**((ord(t)-1)*t_step)/t_step +eps  ;
report_transport_energy(reg, trsp_fuel,trsp_mode,engine_type, t) = trsp_energy.L(trsp_fuel, engine_type, trsp_mode,reg, t)+eps;
transp_energy(reg, trsp_fuel,t) = sum((engine_type,trsp_mode), trsp_energy.L(trsp_fuel, engine_type, trsp_mode, reg,t))+eps;
transp_km(reg, trsp_fuel,trsp_mode, t) =sum(engine_type, trsp_energy.L(trsp_fuel, engine_type, trsp_mode, reg,t)*trsp_conv(trsp_fuel, engine_type, trsp_mode))+eps   ;
report_en_conv(reg, en_in, en_out, type, t)$effic(en_in, en_out, type, reg,t) =  en_conv.L(en_in, en_out, type, reg,t)+eps;
nuclear(reg, nuclear_fuel, en_out,type,t)$ effic(nuclear_fuel, en_out, type, reg,t)  =   en_conv.L(nuclear_fuel, en_out, type, reg,t)*effic(nuclear_fuel, en_out, type, reg,t);
oils(reg, oil_fuel, en_out,type,t)$effic(oil_fuel, en_out, type, reg,t)  =   en_conv.L(oil_fuel, en_out, type, reg,t)*effic(oil_fuel, en_out, type, reg,t);
feed_stock(reg, en_in,type,t)$effic(en_in, "feed-stock", type, reg,t)= en_conv.l(en_in, "feed-stock", type,reg, t) * effic(en_in, "feed-stock", type, reg,t) + eps;
non_solid_heat(reg, en_in,type, t)$effic(en_in, "non_solid_heat", type,reg, t)= en_conv.l(en_in, "non_solid_heat", type,reg, t) * effic(en_in, "non_solid_heat", type,reg, t)+ eps;
solid_heat(reg, en_in, type,t)$effic(en_in, "solid_heat", type,reg, t)= en_conv.l(en_in, "solid_heat", type,reg,t) * effic(en_in, "solid_heat", type,reg, t)+ eps ;
rural_heat(reg, en_in,type,t)$effic(en_in, "dist_heat", type, reg,t)= en_conv.l(en_in, "dist_heat", type, reg,t) * effic(en_in, "dist_heat", type, reg,t)+ eps;
urban_heat(reg, en_in,type,t)$effic(en_in, "central_heat", type, reg,t)= en_conv.l(en_in, "central_heat", type, reg,t) * effic(en_in, "central_heat", type, reg,t) + eps;
urban_heat(reg, en_in,"waste_heat",t)=  sum( cg_type, en_conv.l(en_in, "elec", cg_type,reg, t)*heat_effic(en_in, cg_type, "elec","central_heat")   )+ eps;
elec(reg, calibration_set ,type, t)$effic(calibration_set, "elec", type,reg, t)= en_conv.l(calibration_set, "elec", type, reg,t) * effic(calibration_set, "elec", type,reg, t)+ eps;
h2(reg, en_in,type, t)$effic(en_in, "h2", type, reg,t)=en_conv.l(en_in, "h2", type, reg,t) * effic(en_in, "h2", type, reg,t)+ eps;
MeOH(reg, en_in,type, t)$ effic(en_in, "MeOH", type,reg, t)= en_conv.l(en_in, "MeOH", type, reg,t) * effic(en_in, "MeOH", type,reg, t)+ eps;
biomass(reg, en_out,t)= sum(type, en_conv.l("bio", en_out, type,reg, t) )   +eps;
h2_use(reg, en_out,t)= sum(type, en_conv.l("h2", en_out, type, reg,t) ) + eps;
prices(primary,reg,t)=supply_1_Q.m(primary, reg,t)*((1+R)**((ord(t)-1)*t_step))/t_step+eps;
report_elec_gen(en_in,type,reg,slice,t)$effic(en_in,"elec",type,reg,t)= elec_gen.l(en_in,type,reg,slice,t)+eps;
report_elec_gen_summedslices(en_in,type,reg,t)$effic(en_in,"elec",type,reg,t) = sum(slice, elec_gen.l(en_in,type,reg,slice,t))+eps;
report_elec_gen_slice(en_in,type,reg,t,slice)$effic(en_in, "elec", type, reg,t)= elec_gen.l(en_in,type,reg,slice,t)+eps;
total_elec_gen(reg,slice,t) = sum((en_in,type), elec_gen.l(en_in,type,reg,slice,t));
report_elec_use(reg,elecsector,slice,t) = elec_use.l(elecsector,reg,slice,t);
ccs(reg, en_out,t)$ capt_effic("coal","dec",en_out) = sum((C_capt,ccs_fuel), en_conv.l(ccs_fuel, en_out, C_capt,reg, t)*emis_fact(ccs_fuel)*capt_effic(ccs_fuel,c_capt,en_out)  )+ sum( (C_capt),
           en_conv.l("bio", en_out, C_capt,reg, t)*110 *capt_effic("bio",c_capt,en_out))*t_step  + eps;
report_storage_transfers_2100(storage_tech,reg,slice,slice2) = storage_slice_transfer.l(storage_tech,reg,slice,slice2,"2100")+eps;
report_from_storage(t,reg,slice2) = sum((storage_tech,slice), storage_slice_transfer.l(storage_tech,reg,slice,slice2,t) * effic(storage_tech,"elec","0",reg,t))+eps;
report_to_storage(t,reg,slice) = sum((storage_tech,slice2), storage_slice_transfer.l(storage_tech,reg,slice,slice2,t))+eps;

* calculate curtailment
potential_generation(en_in,type,reg,slice,t) = slice_lng(reg,slice) * Msec_per_year *
                        capital.l(en_in,"elec",type,reg,t) * lfs(en_in,type,reg,slice,"elec");
potential_generation(class_tech,"0",reg,slice,t) = slice_lng(reg,slice) * Msec_per_year *
                        sum(class, capital_class.l(class_tech,class,reg,t) * lfsl(class_tech,class,reg,slice));
curtailment(en_in,type,reg,t,slice) $ effic(en_in,"elec",type,reg,t) =
                        max(eps, potential_generation(en_in,type,reg,slice,t) - elec_gen.l(en_in,type,reg,slice,t));

demand_out(reg, energy,t) = dem(energy,reg,t);
report_lfs(en_in, type,reg,slice)$effic(en_in, "elec", type, reg,"2070") = lfs(en_in , type,reg,slice, "elec");
report_slice_lng(reg,slice) = slice_lng(reg,slice);
report_capital_region(en_in, type, reg, t)$effic(en_in, "elec", type, reg,t) = capital.l(en_in, "elec", type,reg, t)+eps;
report_capital_class(class_tech,class,reg,t) = capital_class.l(class_tech,class,reg,t)+eps;
report_elec_solarwind(class_tech,reg,slice,t) = elec_gen.l(class_tech,"0",reg,slice,t)+eps;
report_elec_class_slice(class_tech,class,reg,slice,t) = elec_gen_class.l(class_tech,class,reg,slice,t)+eps;
marginal_el_price(reg,slice,t) = Elec_Deliv_Dem_Q.m(reg,slice,t)*((1+R)**((ord(t)-1)*t_step))/t_step+eps;

execute_unload "results.gdx" oils report_supply1 report_c report_capital report_engines report_invest report_elec_gen total_elec_gen elec_dem report_elec_use
        report_en_conv urban_heat elec h2 MeOH report_transport_energy  nuclear feed_stock non_solid_heat solid_heat rural_heat end_use_price  report_elec_gen_slice
        demand_out biomass h2_use prices ccs transp_energy emission transp_km report_export report_import report_tot_cost report_lfs report_slice_lng
        report_capital_region report_storage_transfers_2100 report_from_storage report_to_storage report_capital_class report_elec_solarwind report_elec_class_slice
        curtailment report_elec_gen_summedslices marginal_el_price

execute 'gdxxrw.exe results.gdx @output_parameters.txt'
$ontext


emission(reg, en_out,t)= sum((C_capt,ccs_fuel), en_conv.l(ccs_fuel, en_out, C_capt, reg,t)*emis_fact(ccs_fuel)*(1-capt_effic(ccs_fuel,c_capt,en_out) ) )-
                     sum(C_capt, en_conv.l("bio", en_out, C_capt, reg,t)*110*(1- capt_effic("bio",c_capt,en_out) ))
         +sum((non_ccs,en_in), en_conv.l(en_in, en_out, non_CCS, reg,t)*emis_count(en_in)  )+eps ;

$offtext
