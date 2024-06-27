use "C:\Users\Nemoo\Desktop\wt\palyed data\analyses.dta", clear

sort id wave 																	// 加一个sort 方便观察
* Keep records where age is 80 or older
keep if age >= 80

drop if weight > 499  & 	deathstatus != 1			
drop if height > 2  & 	deathstatus != 1			

* Generate a new variable for BMI
gen BMI = weight / (height^2)

drop if BMI > 5000	& 	deathstatus != 1				//不好意思这里得加一个条件，防止把死亡的那个观测真的直接扔掉了,要算临终前的时间
drop if BMI < 15
drop if BMI > 60    & 	deathstatus != 1				
																				//从这里再做一张这个状态下的sum weight height,detail (让人能看到上下界)

* Categorize BMI into the specified categories
gen BMI_category = .
replace BMI_category = 1 if BMI < 18.5
replace BMI_category = 2 if BMI >= 18.5 & BMI < 24.0
replace BMI_category = 3 if BMI >= 24.0

label define BMI_label 1 "Underweight" 2 "Normal weight" 3 "Overweight" 4 "Obese"
label values BMI_category BMI_label


* Check who has height < 0.3
*browse id age wave deathstatus weight height if height < 0.3

* Drop extreme values
*drop if weight > 400
*drop if height < 1

* Keep only the records where deathsample is 1
keep if deathsample == 1

* Sort by id and wave in descending order
gsort id -wave

* Create a gap variable to identify the time until death
replace wave = dthyear	if deathstatus == 1										// 有一个细节，对于下一个wave去世的人而言，下一个wave不是真正的death year，应该是正确的死亡，我这里替换了一下，这样这个图出来的gap时间才是正确的

bysort id (wave): gen gap = wave - wave[_n+1]

drop if deathstatus == 1 														// 然后在这里扔掉死亡观测，目前开起来好像不影响，但是有意识低扔掉不纳入观测，不然你后面bysort 把这些也考虑进去了

* Handle the edge case for the last observation of each id
//bysort id (wave): replace gap = wave[_n-1] - wave if missing(gap)				// 其实这个是不需要的，因为三个数值剪出两个gap,有缺失是正常的，得星掉

* Create a variable for years before death
bysort id (wave): egen years_before_death = sum(gap)							// 这个不是gen，是egen，sum是特殊的

* Calculate mean weight by years before death, deathsample, and BMI           
foreach k in weight {
    bysort years_before_death BMI_category: egen mean_`k' = mean(weight) 		//不需要deathsample ，这里只有deathsample=1
    replace mean_`k' = round(mean_`k', 0.01)
}

* Keep relevant variables
**# Bookmark #5
keep mean years_before_death BMI_category mean_*

* Remove duplicate records
duplicates drop

* Generate the graph
graph twoway ///
    (line mean_weight years_before_death if  BMI_category == 1, lcolor(blue) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight years_before_death if BMI_category == 2, lcolor(green) lpattern(solid) lwidth(vsmall)) ///
    (line mean_weight years_before_death if  BMI_category == 3, lcolor(red) lpattern(solid) lwidth(vsmall)), ///
    title("Mean Weight by Years Before Death and BMI") ///
    xlabel(, grid) ylabel(, grid) ///
    legend(order(1 "Underweight" ///
                 2 "Normal weight" ///
                 3 "Overweight or Obese") ///
           rows(1) size(small))