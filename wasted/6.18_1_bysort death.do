*drop extreme values
drop if weight > 400

drop if deathstatus == 1 
keep if age >=80

foreach k in weight {
	bysort age deathsample  : egen mean_`k' = mean(weight)
	replace mean_`k'= round(mean_`k',0.01)
	
}

keep mean age deathsample mean_*
duplicates drop

graph twoway (line mean_weight age if deathsample == 1) ///
	(line mean_weight age if deathsample == 0)
