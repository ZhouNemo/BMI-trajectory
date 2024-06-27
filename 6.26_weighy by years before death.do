use "C:\Users\Nemoo\Desktop\wt\palyed data\analyses.dta", clear

sort id wave  // Sort to facilitate observation

* Keep records where age is 80 or older
keep if age >= 80

drop if weight > 499 & deathstatus != 1
drop if height > 2 & deathstatus != 1

* Generate a new variable for BMI
gen BMI = weight / (height^2)

drop if BMI > 5000 & deathstatus != 1  // Prevent excluding death observations
drop if BMI < 15
drop if BMI > 60 & deathstatus != 1

* Categorize BMI into the specified categories
gen BMI_category = .
replace BMI_category = 1 if BMI < 18.5
replace BMI_category = 2 if BMI >= 18.5 & BMI < 24.0
replace BMI_category = 3 if BMI >= 24.0 & BMI < 28.0
replace BMI_category = 4 if BMI >= 28.0

label define BMI_label 1 "Underweight" 2 "Normal weight" 3 "Overweight" 4 "Obese"
label values BMI_category BMI_label

* Ensure each person has a fixed baseline BMI category
bysort id (wave): gen baseline_BMI_category = BMI_category[1]

* Keep only the records where deathsample is 1
keep if deathsample == 1

* Sort by id and wave in descending order
gsort id -wave

* Replace wave with dthyear for death status observations
replace wave = dthyear if deathstatus == 1

bysort id (wave): gen gap = wave - wave[_n+1]

drop if deathstatus == 1  // Exclude death observation

* Create a variable for years before death
bysort id (wave): egen years_before_death = sum(gap)

* Calculate mean weight by years before death and baseline BMI category
foreach k in weight {
    bysort years_before_death baseline_BMI_category: egen mean_`k' = mean(weight)
    replace mean_`k' = round(mean_`k', 0.01)
}

* Keep relevant variables
keep mean years_before_death baseline_BMI_category mean_*

* Remove duplicate records
duplicates drop

* Generate the graph
graph twoway ///
    (line mean_weight years_before_death if baseline_BMI_category == 1, lcolor(blue) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight years_before_death if baseline_BMI_category == 2, lcolor(green) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight years_before_death if baseline_BMI_category == 3, lcolor(red) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight years_before_death if baseline_BMI_category == 4, lcolor(orange) lpattern(solid) lwidth(vsmall)), ///
    title("Mean Weight by Years Before Death and Baseline BMI Category") ///
    xlabel(, grid) ylabel(, grid) ///
    legend(order(1 "Underweight" ///
                 2 "Normal weight" ///
                 3 "Overweight" ///
                 4 "Obese") ///
           rows(1) size(small))
