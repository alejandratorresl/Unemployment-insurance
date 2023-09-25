********************************************************************************
* Clean data and create new variables
********************************************************************************

global dir ""
cd "$dir"

use "Data\Clean data\insurance_ipums_v1.dta", clear

* Clean data 

keep if asecflag == 1 // Keep only individuals from ASEC

keep if labforce == 2 // Keep only individuals in the labor force

drop if cpsidp == 0 // Drop id 0

drop if age<18

* Inflation adjustment for wages
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


* Generate useful variables

* Time variable
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

* Age groups
gen agegroups=.
replace agegroups=1 if age>=18 & age<30
replace agegroups=2 if age>=30 & age<40
replace agegroups=3 if age>=40 & age<50
replace agegroups=4 if age>=50

* Education
gen education = .
replace education = 1 if educ > 2 & educ <=32 // Until middle school
replace education = 2 if educ >= 40 & educ <=72 // High school
replace education = 3 if educ ==73 //  High school diploma 
replace education = 4 if educ >= 80 & educ <= 122 //  college no degree
replace education = 5 if educ == 111 // College degree
replace education = 6 if educ == 123 | educ == 124 | educ ==  125 // Grad school
replace education = 7 if educ == 2 // None

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

* Part of union in the next year
replace union = 0 if union <=1
replace union = 1 if union== 2 | union == 3
label define union 1 "Unionized", replace 
label values union union

* Health insurance
gen health_dummy = 1 if  paidgh == 22 // Employer fully covers health insurance
replace health_dummy = 0 if paidgh == 10 

* Pension
gen pension_dummy = 1 if pension == 3 
replace pension_dummy = 0 if pension == 1 | pension == 2


** Dynamic variables

* Unemployment in t+1
gen unemp1y = F12.unemp

* Income in the next year
gen income1y = F12.incwage

* Unionized next year
gen union1y = F12.union

* Health insurance next year
gen health1y = F12.health_dummy

* Pension next year
gen pension1y = F12.pension_dummy

save  "Data\Clean data\insurance_clean.dta", replace
