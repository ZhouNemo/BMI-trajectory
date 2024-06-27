* Load your dataset
use "C:\Users\Nemoo\Desktop\wt\palyed data\analyses.dta", clear

distinct id

* Keep records where age is 80 or older
keep if age >= 80

* drop the obs with missing weight or height
drop if weight > 665
drop if height > 2

* create BMI variable
gen BMI = weight / (height^2)


* drop BMI extreme values
drop if BMI < 10
drop if BMI > 50
distinct id

* Create a tag for the first observation of each individual
bysort id: gen first_obs = _n == 1              // 这个忘记先sort id wave了，这个排在第一个不一定真的是第一个观测

* Summarize the distribution of BMI for unique individuals
histogram BMI if first_obs, frequency


