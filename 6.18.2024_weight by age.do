use "C:\Users\Nemoo\Desktop\wt\palyed data\analyses.dta", clear

* Generate a new variable for BMI

* Keep records where age is 80 or older
keep if age >= 80

drop if weight > 499
drop if height > 2

gen BMI = weight / (height^2)

drop if BMI > 5000
drop if BMI < 15
drop if BMI > 60

* Categorize BMI into the specified categories
gen BMI_category = .
replace BMI_category = 1 if BMI < 18.5
replace BMI_category = 2 if BMI >= 18.5 & BMI < 24.0
replace BMI_category = 3 if BMI >= 24.0 & BMI < 28.0
replace BMI_category = 4 if BMI >= 28.0

label define BMI_label 1 "Underweight" 2 "Normal weight" 3 "Overweight" 4 "Obese"
label values BMI_category BMI_label


* Drop records where deathstatus is 1
drop if deathstatus == 1

bysort id (wave): gen baseline_BMI_category = BMI_category[1]
xx
* Calculate mean weight by age, deathsample, and BMI
foreach k in weight {
    bysort age deathsample baseline_BMI_category: egen mean_`k' = mean(weight)
    replace mean_`k' = round(mean_`k', 0.01)
}

* Keep relevant variables
keep mean age deathsample baseline_BMI_category mean_*

* Remove duplicate records
duplicates drop

* Generate the graph
graph twoway ///
    (line mean_weight age if deathsample == 0 & baseline_BMI_category == 1, lcolor(blue) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight age if deathsample == 0 & baseline_BMI_category == 2, lcolor(green) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight age if deathsample == 0 & baseline_BMI_category == 3, lcolor(red) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight age if deathsample == 0 & baseline_BMI_category == 4, lcolor(orange) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight age if deathsample == 1 & baseline_BMI_category == 1, lcolor(blue) lpattern(dash) lwidth(vsmall)) ///
    (line mean_weight age if deathsample == 1 & baseline_BMI_category == 2, lcolor(green) lpattern(dash) lwidth(vsmall)) ///
    (line mean_weight age if deathsample == 1 & baseline_BMI_category == 3, lcolor(red) lpattern(dash) lwidth(vsmall)) ///
    (line mean_weight age if deathsample == 1 & baseline_BMI_category == 4, lcolor(orange) lpattern(dash) lwidth(vsmall)), ///
    title("Mean Weight by Age, Deathsample, and BMI") ///
    xlabel(, grid) ylabel(, grid) ///
    legend(order(1 "alive, Underweight" ///
                 2 "alive, Normal weight" ///
                 3 "alive, Overweight" ///
                 4 "alive, Obese" ///
                 5 "dead, Underweight" ///
                 6 "dead, Normal weight" ///
                 7 "dead, Overweight" ///
                 8 "dead, Obese") ///
           rows(4) size(small))


