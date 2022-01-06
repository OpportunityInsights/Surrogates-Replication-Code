/*******************************************************************************
* Format Appendix Table 1                                                      *
********************************************************************************

This file rearranges the weights on each quarter so that they are outputted 
as Appendix Table 1. 

The weights themselves are calculated in "Estimate treatment effects.do." 
*/ 

* Import results 
import delimited using "${data_derived}/Unformatted Appendix Tables Output.csv", clear 

* Set locals for outcomes
// The simulated data include employment outcomes only 
if "$data_type" == "real" local outcomes emp earn 
if "$data_type" == "simulated" local outcomes emp 

* Generate quarter labels 
gen label = "Quarter " + string(quarter)

* Store treatment effects and constants for quarter 6 and quarter 12 surrogate indices 
foreach outcome in `outcomes' {
	sum surrogate_index_`outcome' if label == "Quarter 6"
	local surrogate_`outcome'_6_quarter = `r(mean)'
	sum surrogate_index_se_`outcome' if label == "Quarter 6"
	local surrogate_`outcome'_6_quarter_se = `r(mean)'	
	sum `outcome'_constant if label == "Quarter 6"
	local `outcome'_constant_6_quarter = `r(mean)'
	sum `outcome'_constant_se if label == "Quarter 6"
	local `outcome'_constant_6_quarter_se = `r(mean)'
	sum surrogate_index_`outcome' if label == "Quarter 12"
	local surrogate_`outcome'_12_quarter = `r(mean)'
	sum surrogate_index_se_`outcome' if label == "Quarter 12"
	local surrogate_`outcome'_12_quarter_se = `r(mean)'		
	sum `outcome'_constant if label == "Quarter 12"
	local `outcome'_constant_12_quarter = `r(mean)'
	sum `outcome'_constant_se if label == "Quarter 12"
	local `outcome'_constant_12_quarter_se = `r(mean)'
}

* Keep only relevant data 
keep *_weight_6* *_weight_12* label quarter
drop if _n > 15 

* Rearrange from wide to long 
reshape long emp_weight_6_ emp_weight_12_ earn_weight_6_ earn_weight_12_, i(label) j(estimate_type) string

* Check that data are sorted with SEs below point estimates  
sort quarter estimate_type 
assert estimate_type[_n + 1] == "se" if estimate_type == "b"
assert estimate_type[_n + 1] == "b" if estimate_type == "se" & quarter != 15
assert quarter[_n + 1] == quarter[_n] if estimate_type == "b"

* Remove labels for SEs 
replace label = "" if estimate_type == "se" | _n > 24

* Add constant term and SE for constant term 
replace label = "Constant" if _n == 26 
forvalues q = 6(6)12 {
	foreach outcome in `outcomes' {
		replace `outcome'_weight_`q' = ``outcome'_constant_`q'_quarter' if _n == 26
		replace  `outcome'_weight_`q' = ``outcome'_constant_`q'_quarter_se' if _n == 27
	}
}

* Add estimated treatment effect and SE for treatment effect 
replace label = "Estimated Treatment Effect" if _n == 29 
forvalues q = 6(6)12 {
	foreach outcome in `outcomes' {
		replace `outcome'_weight_`q' = `surrogate_`outcome'_`q'_quarter' if _n == 29
		replace `outcome'_weight_`q' = `surrogate_`outcome'_`q'_quarter_se' if _n == 30
	}
}

* Round, put SEs into brackets, make missings into blank cells
forvalues q = 6(6)12 {
	foreach outcome in emp earn {
		replace `outcome'_weight_`q'_ = round(`outcome'_weight_`q'_, 0.001)
		tostring `outcome'_weight_`q'_, replace force format(%4.3f)
		replace  `outcome'_weight_`q'_ = "(" + `outcome'_weight_`q'_ + ")" if mi(label)
		replace `outcome'_weight_`q' = "" if `outcome'_weight_`q' == "." | `outcome'_weight_`q' == "(.)"
	}
}

* Rearrange for table 
drop estimate_type 
sort quarter 
drop quarter 
order label emp_weight_6 earn_weight_6 emp_weight_12 earn_weight_12 
rename *_ *

* Export table 
export excel using "${output}/Formatted Appendix Tables.xlsx", sheet("Appendix Table 1 (RAW)") sheetreplace firstrow(variables)