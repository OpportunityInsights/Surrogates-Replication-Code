/*******************************************************************************
* Format Appendix Table 2                                                      *
********************************************************************************

This file rearranges the surrogate index estimates of treatment effects so that 
they are outputted the way that they appear in Appendix Table 2. 

The weights themselves are calculated in "Estimate treatment effects.do." */ 

* Import results 
import delimited using "${data_derived}/Unformatted Appendix Tables Output.csv", clear 

* Set locals for outcomes
	// The simulated data include employment outcomes only 
if "$data_type" == "real" local outcomes emp earn 
if "$data_type" == "simulated" local outcomes emp 

* Keep relevant variables 
keep quarter *surrogate_index*
if "$data_type" == "real" rename (surrogate_index_emp surrogate_index_earn surrogate_index_se_emp surrogate_index_se_earn) (empb earnb empse earnse)
if "$data_type" == "simulated" rename (surrogate_index_emp surrogate_index_se_emp) (empb empse)

* Reshape data from long to wide 
reshape long emp earn, i(quarter) j(estimate_type) string

* Check that data are sorted with SEs below treatment effects
assert estimate_type[_n + 1] == "se" if estimate_type == "b"
assert estimate_type[_n + 1] == "b" if estimate_type == "se" & quarter != 36
assert quarter[_n + 1] == quarter[_n] if estimate_type == "b"

* Remove labels from standard errors 
tostring quarter, replace	
replace quarter = "" if estimate_type == "se"
drop estimate_type 

* Round and put SEs in brackets 
tostring emp, replace force format(%4.3f)
replace  emp = "(" + emp + ")" if quarter == ""
tostring earn, replace force format(%4.3f)
replace  earn = "(" + earn + ")" if quarter == ""	

export excel using "${output}/Formatted Appendix Tables.xlsx", sheet("Appendix Table 2 (RAW)") sheetreplace firstrow(variables)