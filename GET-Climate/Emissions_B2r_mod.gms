set IIASAdata	/ CO2, CO2luc, CH4, N2O, N2O_energy /;

set t_10
	/q2000, q2010, q2020, q2030, q2040, q2050, q2060, q2070, q2080, q2090, q2100, q2110, q2120, q2130, q2140, q2150, q2160, q2170, q2180, q2190, q2200, q2210, q2220, q2230, q2240, q2250, q2260, q2270, q2280, q2290, q2300/;

parameter t10year(t_10);
	t10year(t_10) = 2000 + 10*(ord(t_10)-1);

# taken from the IIASA B2r scenario: CO2 [MtC] CH4 [MtCH4] N2O [MtN2O]
table baseline_10(t_10, *)
	    	CO2     	CO2luc		CH4     	N2O     	N2O_energy
	q2000	7113.86		1080		291.51608	11.03896	1.26876
	q2010	9072.232	979.038		352.33682	12.65501	1.56699
	q2020	11187.323	884.288		415.31545	14.77124	1.83824
	q2030	11939.692	755.708		462.44662	16.12893	2.15922
	q2040	12214.886	603.421		513.86049	17.34184	2.4964
	q2050	11897.771	430.724		545.44192	18.29206	2.86381
	q2060	11997.928	240.534		551.12909	18.77927	3.10381
	q2070	12170.859	35.017		560.23048	19.15142	3.32531
	q2080	12370.516	0     		565.09254	19.19474	3.48672
	q2090	12855.931	0     		577.82704	19.27516	3.63961
	q2100	13021.1		0     		581.6642	19.41896	3.80887
;

baseline_10(t_10,IIASAdata) $ (t10year(t_10) > 2100) =
	baseline_10('q2100',IIASAdata) +  (baseline_10('q2100',IIASAdata) - baseline_10('q2090',IIASAdata)) * (t10year(t_10) - 2100)/10;

baseline_10(t_10,'N2O_energy') $ (t10year(t_10) > 2100) = baseline_10('q2100','N2O_energy');
baseline_10(t_10,'N2O_energy') $ (t10year(t_10) > 2100) = baseline_10('q2100','N2O_energy');

baseline_10(t_10,'CO2') = baseline_10(t_10,'CO2') / 1000;
baseline_10(t_10,'CO2luc') = baseline_10(t_10,'CO2luc') / 1000;

# interpolate baseline emissions from 10-year data to arbitrary year
parameter t_round(t);
	t_round(t) = 10*floor(year(t)/10);
parameter totalbaseline(gas,t);
parameter deforest_CO2(t_a);
parameter baselineN2Oenergy(t);
	totalbaseline(gas,t) =
		(1 - (year(t)-t_round(t))/10) * sum(t_10 $ (t10year(t_10) = t_round(t)), baseline_10(t_10,gas))
			+ (year(t)-t_round(t))/10 * sum(t_10 $ (t10year(t_10) = t_round(t)+10), baseline_10(t_10,gas));
	deforest_CO2(t) =
		(1 - (year(t)-t_round(t))/10) * sum(t_10 $ (t10year(t_10) = t_round(t)), baseline_10(t_10,'CO2luc'))
			+ (year(t)-t_round(t))/10 * sum(t_10 $ (t10year(t_10) = t_round(t)+10), baseline_10(t_10,'CO2luc'));
	baselineN2Oenergy(t) =
		(1 - (year(t)-t_round(t))/10) * sum(t_10 $ (t10year(t_10) = t_round(t)), baseline_10(t_10,'N2O_energy'))
			+ (year(t)-t_round(t))/10 * sum(t_10 $ (t10year(t_10) = t_round(t)+10), baseline_10(t_10,'N2O_energy'));