use "C:\Users\Nemoo\Desktop\wt\palyed data\analyses.dta", clear

* Keep records where age is 80 or older
keep if age >= 80

drop if weight > 499
drop if height > 2


* Generate a new variable for BMI
gen BMI = weight / (height^2)

* Drop unrealistic BMI values
drop if BMI > 5000
drop if BMI < 15
drop if BMI > 60

* Categorize BMI into the specified categories
gen BMI_category = .
replace BMI_category = 1 if BMI < 18.5
replace BMI_category = 2 if BMI >= 18.5 & BMI < 24.0
replace BMI_category = 3 if BMI >= 24.0

label define BMI_label 1 "Underweight" 2 "Normal weight" 3 "Overweight or Obese"
label values BMI_category BMI_label

* Keep only the records where deathsample is 1
keep if deathsample == 1

* Drop records where deathstatus is 1
drop if deathstatus == 1

* Sort by id and wave in descending order										//这个实现不了我的目的，去掉，我下面换一下
//gsort id -wave

* Create a gap variable to identify the time until death
bysort id (wave): gen gap_weight = weight[_n-1] - weight						// 这里留错了，我换掉
	
* Generate order variable to keep only the first observation for each id		//我们其实是想保留临终前最后一次观测，我这里换成这样
bysort id: gen order = _n
bysort id: gen total = _N
keep if order == total & total != 1

* Sum gap_weight by BMI_category
bysort BMI_category: sum gap_weight, detail

* Generate histograms for each BMI category
* Generate histogram and export for BMI category 1
histogram gap_weight if BMI_category == 1, ///
    title("Histogram of gap_weight for BMI Category Underweight") ///
    xlabel(, grid) ylabel(, grid)
graph export "histogram_gap_weight_BMI_category_Underweight.png", replace

* Generate histogram and export for BMI category 2
histogram gap_weight if BMI_category == 2, ///
    title("Histogram of gap_weight for BMI Category Normal weight") ///
    xlabel(, grid) ylabel(, grid)
graph export "histogram_gap_weight_BMI_category_Normal_weight.png", replace

* Generate histogram and export for BMI category 3
histogram gap_weight if BMI_category == 3, ///
    title("Histogram of gap_weight for BMI Category Overweight or Obese") ///
    xlabel(, grid) ylabel(, grid)
graph export "histogram_gap_weight_BMI_category_Overweight.png", replace