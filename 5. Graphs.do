********************************************************************************
* Estimations - Graphs
********************************************************************************

global dir ""
cd "$dir"

use "Data\Clean data\insurance_clean.dta", clear


********************************************************************************
* Graph 1
********************************************************************************

matrix A = J(2,3,.)

* Keep only observations that are on the two periods
keep if unemp1y!=. & income1y!=.


eststo clear
eststo mpl1, title(Unemployed): reg unemp1y insurance if unemp==1, r

matrix A[1,1] = r(table)[1,1]
matrix A[1,2] = r(table)[5,1]
matrix A[1,3] = r(table)[6,1]


eststo mpl2, title(Unemployed): reg unemp1y insurance i.agegroups i.sex education if unemp==1, r
matrix A[2,1] = r(table)[1,1]
matrix A[2,2] = r(table)[5,1]
matrix A[2,3] = r(table)[6,1]

svmat A 
keep A1 A2 A3
drop if A1 == .

gen x = _n
tostring x, gen(Employed)

twoway (bar A1 x, color(dknavy)) (rcap A2 A3 x, color(black)), xlabel(1 "No controls" 2 "Controls") xtitle("") legend(order(2 "95% CI")) graphregion(color(white)) ylabel(, nogrid) 

graph export "Outputs\Figures\LPM1.png", replace



********************************************************************************
* Graph 2
********************************************************************************

use "Data\Clean data\insurance_clean.dta", clear
keep if unemp1y!=. & income1y!=.

matrix B = J(4,3,.)

eststo mpl1, title(Unionized): reg union1y insurance if unemp==1 & unemp1y==0, r 
matrix B[1,1] = r(table)[1,1]
matrix B[1,2] = r(table)[5,1]
matrix B[1,3] = r(table)[6,1]


eststo mpl3, title(Health): reg health1y insurance if unemp==1 & unemp1y==0, r
matrix B[2,1] = r(table)[1,1]
matrix B[2,2] = r(table)[5,1]
matrix B[2,3] = r(table)[6,1]


eststo mpl2, title(Unionized): reg union1y insurance i.agegroups i.sex i.education if unemp==1 & unemp1y==0, r
matrix B[3,1] = r(table)[1,1]
matrix B[3,2] = r(table)[5,1]
matrix B[3,3] = r(table)[6,1]

eststo mpl4, title(Health): reg health1y insurance i.agegroups i.sex i.education if unemp==1 & unemp1y==0, r
matrix B[4,1] = r(table)[1,1]
matrix B[4,2] = r(table)[5,1]
matrix B[4,3] = r(table)[6,1]

svmat B
keep B1 B2 B3
drop if B1 == .
gen x = _n



twoway (bar B1 x if x==1, bcolor(maroon) barw(1.1)) /// 
(bar B1 x if x==3, bcolor(maroon) barw(0.95) ) ///
(bar B1 x if x==2, bcolor(dknavy) barw(0.95)) ///
(bar B1 x if x==4, bcolor(dknavy) barw(1.1)) ///
(rcap B2 B3 x, color(black)) , xlabel(1 `""Unionized" "No controls""' 2 `""Health Insurance" "No controls""' 3 `""Unionized" "Controls""' 4 `""Health insurance"  "Controls""') xtitle("") legend(order(5 "95% CI")) graphregion(color(white)) ylabel(, nogrid) 


graph export "Outputs\Figures\LPM2.png", replace

