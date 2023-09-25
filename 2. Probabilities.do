********************************************************************************
* Calculate transition probabilities 
********************************************************************************
global dir ""
cd "$dir"

use "Data\Clean data\insurance_ipums_v1.dta", clear

gen vet = 1 // Veteran dummy
replace vet = 0 if vetlast == 0

keep if labforce==2 // Keep only individuals in the labor force

drop if cpsidp==0 // Drop id 0

drop if asecflag!=1 & month==3 // Drop observations for march that are not ASEC (duplicates)

gen time = ym(year, month) //Time variable
tsset cpsidp time, monthly

* Unemployed
gen unemp = 0
replace unemp = 1 if empstat == 21 | empstat == 22 // Unemployed: new and experienced

* Insurance = 1 if the worker reports to receive unemployment benefits
gen insurance = 0
replace insurance = 1 if incunemp > 0 & incunemp < 999999 
replace insurance = . if incunemp == .
label define insurance 0 "No insurance" 1 "Insurance"
label values insurance insurance

* Aggregate industries
gen industry = 0
replace industry = 11 if ind >= 170  & ind <= 290      // Agriculture, forestry, fishing and hunting
replace industry = 21 if ind >= 370  & ind <= 490      // Mining
replace industry = 22 if ind >= 570  & ind <= 690      // Utilities
replace industry = 23 if ind == 770                    // Construction
replace industry = 31 if ind >= 1070 & ind <= 3990     // Manufacturing
replace industry = 42 if ind >= 4070 & ind <= 4590     // Wholesale trade
replace industry = 44 if ind >= 4670 & ind <= 5790     // Retail trade
replace industry = 48 if ind >= 6070 & ind <= 6390     // Transportation and warehousing
replace industry = 51 if ind >= 6470 & ind <= 6780     // Information 
replace industry = 52 if ind >= 6870 & ind <= 6990     // Finance and insurance
replace industry = 53 if ind >= 7070 & ind <= 7190     // Real estate and rental and leasing
replace industry = 54 if ind >= 7270 & ind <= 7490     // Professional, scientific, and technical services
replace industry = 55 if ind == 7570                   // Management of companies and enterprises
replace industry = 56 if ind >= 7580 & ind <= 7790     // Administrative and support and waste management services
replace industry = 61 if ind >= 7860 & ind <= 7890     // Educational services
replace industry = 62 if ind >= 7970 & ind <= 8470     // Health care and social assistance
replace industry = 71 if ind >= 8560 & ind <= 8590     // Arts, entertainment, and recreation
replace industry = 72 if ind >= 8660 & ind <= 8690     // Accommodation and food services
replace industry = 81 if ind >= 8770 & ind <= 9290     // Other services, except public administration 
replace industry = 92 if ind >= 9370 & ind <= 9590     // Public administration 
replace industry = 928110 if ind >= 9670 & ind <= 9870 // Other services, except public administration 

* Age groups
drop if age<18
gen agegroups=.
replace agegroups=1 if age>=18 & age<30
replace agegroups=2 if age>=30 & age<40
replace agegroups=3 if age>=40 & age<50
replace agegroups=4 if age>=50

* Inflation adjustment
replace incwage = incwage*0.774 if year==2009
replace incwage = incwage*0.777 if year==2010
replace incwage = incwage*0.764 if year==2011
replace incwage = incwage*0.741 if year==2012
replace incwage = incwage*0.726 if year==2013
replace incwage = incwage*0.715 if year==2014
replace incwage = incwage*0.704 if year==2015
replace incwage = incwage*0.703 if year==2016
replace incwage = incwage*0.694 if year==2017
replace incwage = incwage*0.679 if year==2018
replace incwage = incwage*0.663 if year==2019
replace incwage = incwage*0.652 if year==2020
replace incwage = incwage*0.644 if year==2021
replace incwage = incwage*0.615 if year==2022

sort cpsidp time
* Unemployment in t+1
gen unemp1m = F1.unemp 
gen unemp3m = F3.unemp
gen unemp1y = F12.unemp

save "Data\Clean data\temp_v1.dta", replace

******************************************************************************
* Calculate probabilities of unemployment conditional on having insurance for
* one month, three months and a year later
*******************************************************************************

global time "1m 3m 1y"

foreach a in $time{
use "Data\Clean data\temp_vet.dta", clear
	
	drop if unemp`a'==. | insurance==. // Drop observations that are not in the two periods
	keep if asecflag==1 

	preserve	
	
	* Denominator
	collapse (count) dem=cpsidp, by(unemp insurance year)
		tempfile temp_dem
		save `temp_dem'
	restore

	* Numerator
	collapse (count) num=cpsidp, by(unemp unemp`a' insurance year)

	* Merge numerator and denominator
	merge m:1 unemp insurance year using `temp_dem', nogen
	erase `temp_dem'
	
	gen prob = num/dem //Transition probability
sort year unemp insurance unemp`a'
drop if unemp==0

	export excel using "Outputs/probabilities_vet.xlsx", firstrow(variables) sheet(`a', replace)
	drop num dem
}
*/

********************************************************************************
*Income in the next period
********************************************************************************

use "Data\Clean data\temp_vet.dta", clear

* Keep only observations on asec
keep if asecflag==1

** Generate dynamic variables
* Income in the next year
gen income1y = F12.incwage

* Keep only observations that are on the two periods
keep if unemp1y!=. & income1y!=.

********************************************************************************
* Keep workers that are unemployed today and employed tomorrow

keep if unemp==1 & unemp1y==0

	preserve	
	* Denominator
	collapse incwage income1y (count) dem=cpsidp, by(unemp insurance year)
		tempfile temp_dem
		save `temp_dem'
	restore

	* Numerator
	collapse incwage income1y (count) num=cpsidp, by(unemp unemp1y insurance year)

	* Merge numerator and denominator
	merge m:1 unemp insurance year using `temp_dem', nogen
	erase `temp_dem'
	
	gen prob = num/dem //Transition probability
	sort year insurance unemp unemp1y  
	order year unemp unemp1y insurance 
	export excel using "Outputs/probabilities_vet.xlsx", firstrow(variables) sheet("wage_only_employed_t+1", replace)

	* Bar graph
	graph bar incwage income1y , by(insurance, graphregion(fcolor(white)))  ylabel(, nogrid) ytitle("Average wage income") legend(label(1 "Wage income in t") label(2 "Wage income in t+1"))
	graph export "Outputs\Figures\wage_only_employed_t+1.png", replace


************************************************

* Keep workers that are unemployed today and can be anything tomorrow
use "Data\Clean data\temp_vet.dta", clear


* Keep only observations on asec
keep if asecflag==1

** Generate dynamic variables

* Income in the next year
gen income1y = F12.incwage

* Keep only observations that are on the two periods
keep if unemp1y!=. & income1y!=.

	drop if unemp==0
	drop if unemp1y==.
	preserve	
	* Denominator
	collapse incwage income1y (count) dem=cpsidp, by(unemp insurance year)
		tempfile temp_dem
		save `temp_dem'
	restore

	* Numerator
	collapse incwage income1y (count) num=cpsidp, by(unemp unemp1y insurance year)

	* Merge numerator and denominator
	merge m:1 unemp insurance year using `temp_dem', nogen
	erase `temp_dem'
	
	gen prob = num/dem //Transition probability
	sort year insurance unemp unemp1y  
	order year unemp unemp1y insurance 

	export excel using "Outputs/probabilities_vet.xlsx", firstrow(variables) sheet("wage_all_t+1", replace)
	
label define unemp 0 "Employed" 1 "Unemployed"
label values unemp1y unemp
graph bar incwage income1y, over(unemp1y) by(insurance, graphregion(fcolor(white)))  ylabel(, nogrid) ytitle("Average wage income")legend(label(1 "Wage income in t") label(2 "Wage income in t+1"))
graph export "Outputs\Figures\wage_all_t+1.png", replace


********************************************************************************
* Unions
********************************************************************************	

* Keep workers that are unemployed today and can be anything tomorrow
use "Data\Clean data\temp_vet.dta", clear


* Keep only observations on asec
keep if asecflag==1

* Part of union in the next year
replace union = 0 if union <=1
replace union = 1 if union== 2 | union == 3
label define union 1 "Unionized", replace 
label values union union

** Generate dynamic variables

* Unionized next year
gen union1y = F12.union

* See if the worker changes industry in the next year
gen ind1y = F12.industry

* Income in the next year
gen income1y = F12.incwage

* Keep only observations that are on the two periods
keep if unemp1y!=. & income1y!=.


graph bar union1y if unemp==1 & unemp1y==0, by(insurance, graphregion(fcolor(white))) over(year, lab(labsize(medium) angle(90)))  ylabel(, nogrid) ytitle("Unionized in t+1") note("Unemployed in t and employed in t+1")
graph export "Outputs\Figures\union_year.png", replace

graph bar union1y if unemp==1 & unemp1y==0, by(insurance, graphregion(fcolor(white))) ylabel(, nogrid) ytitle("Unionized in t+1") note("Unemployed in t and employed in t+1")
graph export "Outputs\Figures\union.png", replace

	drop if unemp==0
	drop if unemp1y==.
	preserve	
	* Denominator
	collapse (count) dem=cpsidp, by(union insurance year)
		tempfile temp_dem
		save `temp_dem'
	restore

	* Numerator
	collapse  (count) num=cpsidp, by(union union1y insurance year)

	* Merge numerator and denominator
	merge m:1 union insurance year using `temp_dem', nogen
	erase `temp_dem'
	
	gen prob = num/dem //Transition probability
	sort year insurance union
	order year union union1y insurance
	export excel using "Outputs/probabilities_vet.xlsx", firstrow(variables) sheet("union", replace)
	

