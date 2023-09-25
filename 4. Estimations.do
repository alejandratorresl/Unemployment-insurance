********************************************************************************
* Estimations
********************************************************************************

global dir ""
cd "$dir"

use "Data\Clean data\insurance_clean.dta", clear


* Keep only observations that are on the two periods
keep if unemp1y!=. & income1y!=.

********************************************************************************
* Linear probability model
********************************************************************************

********************************************************************************
* Unemployed in t only
********************************************************************************


* Unemployed
eststo clear
eststo mpl1, title(Unemployed): reg unemp1y insurance if unemp==1, r
matrix A = J(2,2,.)
matrix A[1,1] = r(table)[1,1]

matlist A

local b_unemp r(table)[1,1]
local se_unemp r(table)[2,1]
dis `b_unemp'

graph bar `b_unemp'

eststo mpl2, title(Unemployed): reg unemp1y insurance i.agegroups i.sex education if unemp==1, r
local b_unemp_c r(table)[1,1]
local se_unemp_c r(table)[2,1]


twoway (bar `b_unemp') (rcap `se_unemp')
estadd local Controls "No"

quietly eststo mpl2, title(Unemployed): reg unemp1y insurance i.agegroups i.sex education if unemp==1, r
estadd local Controls "Yes"


local mean= e(b)[1,1]
di "`mean'"
mat list r(table)


* Union
quietly eststo mpl3, title(Unionized): reg union1y insurance if unemp==1, r
estadd local Controls "No"

quietly eststo mpl4, title(Unionized): reg union1y insurance i.agegroups i.sex i.education if unemp==1, r
estadd local Controls "Yes"

* Health insurance
 eststo mpl5, title(Health): reg health1y insurance if unemp==1, r
estadd local Controls "No"

 eststo mpl6, title(Health): reg health1y insurance i.agegroups i.sex i.education if unemp==1, r
estadd local Controls "Yes"

esttab using "$dir\Outputs\Tables\regs.tex", replace se keep(insurance) mlabel(, titles) s(Controls N) label title(Linear Probability Model - Unemployed in t only) 


********************************************************************************
* Unemployed in t and employed in t+1
********************************************************************************
eststo clear
* Union
 eststo mpl1, title(Unionized): reg union1y insurance if unemp==1 & unemp1y==0, r
estadd local Controls "No"

 eststo mpl2, title(Unionized): reg union1y insurance i.agegroups i.sex i.education if unemp==1 & unemp1y==0, r
estadd local Controls "Yes"

* Health insurance
 eststo mpl3, title(Health): reg health1y insurance if unemp==1 & unemp1y==0, r
estadd local Controls "No"

 eststo mpl4, title(Health): reg health1y insurance i.agegroups i.sex i.education if unemp==1 & unemp1y==0, r
estadd local Controls "Yes"


esttab using "$dir\Outputs\Tables\regs.tex", append se keep(insurance) mlabel(, titles) s(Controls N) label title(Linear Probability Model - Unemployed in t and employed in t+1) 


********************************************************************************
* Logit
********************************************************************************

********************************************************************************
* Unemployed in t only
********************************************************************************

* Unemployed
eststo clear
quietly eststo logit1, title(Unemployed): logit unemp1y insurance if unemp==1
estadd local Controls "No"

quietly eststo logit2, title(Unemployed): logit unemp1y insurance i.agegroups i.sex i.education if unemp==1
estadd local Controls "Yes"

* Union
quietly eststo logit3, title(Unionized): logit union1y insurance if unemp==1,
estadd local Controls "No"

quietly eststo logit4, title(Unionized): logit union1y insurance i.agegroups i.sex i.education if unemp==1
estadd local Controls "Yes"

* Health insurance
quietly eststo logit5, title(Health): logit health1y insurance if unemp==1
estadd local Controls "No"

quietly eststo logit6, title(Health): logit health1y insurance i.agegroups i.sex i.education if unemp==1
estadd local Controls "Yes"

esttab using "$dir\Outputs\Tables\regs.tex", append se keep(insurance) mlabel(, titles) s(Controls N) label title(Logit - Unemployed in t only) 


********************************************************************************
* Unemployed in t and employed in t+1
********************************************************************************
eststo clear

* Union
quietly eststo logit1, title(Unionized): logit union1y insurance if unemp==1 & unemp1y==0,
estadd local Controls "No"

quietly eststo logit2, title(Unionized): logit union1y insurance i.agegroups i.sex i.education if unemp==1 & unemp1y==0
estadd local Controls "Yes"

* Health insurance
quietly eststo logit3, title(Health): logit health1y insurance if unemp==1 & unemp1y==0
estadd local Controls "No"

quietly eststo logit4, title(Health): logit health1y insurance i.agegroups i.sex i.education if unemp==1 & unemp1y==0
estadd local Controls "Yes"

esttab using "$dir\Outputs\Tables\regs.tex", append se keep(insurance) mlabel(, titles) s(Controls N) label title(Logit - Unemployed in t and employed in t+1) 

********************************************************************************
* Multinomial logit
********************************************************************************


* Multinomial logit - Unemployment and union

gen mult2 = 0
replace mult2 = 1 if unemp==1 & unemp1y==0 & union1y==1
replace mult2 = 2 if unemp==1 & unemp1y==0 & union1y==0
replace mult2 = 3 if unemp==1 & unemp1y==1 & union1y==0


label define mult2 1 "ut = 1, ut1 = 0, union = 1" 2 "ut = 1, ut1 = 0, union = 0" 3 "ut = 1, ut1 = 1, union = 0"
label values mult2 mult2

preserve
keep if unemp==1
eststo clear

eststo mlogit1, title(No controls): mlogit mult2 insurance, b(3)
estadd local Controls "No"
estadd local Change "Base outcome"
*margins, dydx(*)
*predict p2, replace
quietly eststo mlogit2, title(Controls): mlogit mult2 insurance i.agegroups i.sex i.education, b(3)
estadd local Controls "Yes"
estadd local Change "Base outcome"
esttab using "$dir\Outputs\Tables\regs.tex", append se keep(insurance) mlabel(, titles) s(Controls N) label title(Multinomial logit - Unemployment and unions) 


restore





