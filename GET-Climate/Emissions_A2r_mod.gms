set IIASAdata	/ CO2, CO2luc, CH4, N2O, N2O_energy /;

set t_10
	/q2000, q2010, q2020, q2030, q2040, q2050, q2060, q2070, q2080, q2090, q2100, q2110, q2120, q2130, q2140, q2150, q2160, q2170, q2180, q2190, q2200, q2210, q2220, q2230, q2240, q2250, q2260, q2270, q2280, q2290, q2300/;

parameter t10year(t_10);
	t10year(t_10) = 2000 + 10*(ord(t_10)-1);

# taken from the IIASA A2r scenario: CO2 [MtC] CH4 [MtCH4] N2O [MtN2O]
table baseline_10(t_10, *)
	    	CO2     	CO2luc		CH4     	N2O     	N2O_energy
	q2000	7217.86 	1080		281.67783	11.11603	0.83516
	q2010	8114.38 	979.038		316.79791	12.65332	0.99225
	q2020	10697   	884.288		380.43669	14.77634	1.21654
	q2030	13436.67	755.708		450.24851	16.88593	1.38546
	q2040	16142.83	603.421		521.16822	18.9676		1.48538
	q2050	18794.23	430.724		593.32457	20.20541	1.42754
	q2060	22692.57	240.534		663.50403	21.23684	1.40336
	q2070	25187.09	35.017		707.06919	22.06634	1.32063
	q2080	26758.65	0   		751.04733	22.58669	1.23428
	q2090	27227.69	0   		787.08542	23.08722	1.1701
	q2100	27871.67	0   		815.82364	23.52305	1.10948
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
