********************************************************************************
* Figure 2 (Control and Treatment Mean Employment Over Nine Years)
********************************************************************************

/*---------------------------------
          Prepare data
----------------------------------*/
* Import data
use "${data_raw}/${data_type} Riverside GAIN data.dta", clear

* Confirm structure of data  
isid id
misstable sum 
assert `r(max)' == . 

* Set outcomes 
local outcomes emp earn 

* Set treatment groups 
local treatment_groups control treatment 

* Generate variables in which to store mean employment in each quarter, by treatment group 
foreach group in `treatment_groups' {
		gen `group'_mean_emp = . 
}

/*---------------------------------
        Compute means
----------------------------------*/
* Compute employment rate in each quarter, by treatment group
forvalues q = 1(1)36 {
	
	* Compute control means 
	gen emp`q'_control = emp`q' if treatment == 0
	egen control_mean_emp_`q' = mean(emp`q'_control)
	replace control_mean_emp = control_mean_emp_`q' in `q'
	
	* Compute treatment means 
	gen emp`q'_treatment = emp`q' if treatment == 1
	egen treatment_mean_emp_`q' = mean(emp`q'_treatment)
	replace treatment_mean_emp = treatment_mean_emp_`q' in `q'	
}

keep *_mean_emp
gen quarter = _n 
drop if quarter > 36

* Rescale employment to be as a percentage (not a fraction)
foreach group in `treatment_groups' {	
	replace `group'_mean_emp = 100*`group'_mean_emp
}

* Compute mean of employment on average over full sample period, by treatment group 
	// Note that the number of treatment and control group observations does not 
	// vary by quarter, so we can take a mean over the 36 quarters, rather 
	// than needing to take the means at the individual level 
foreach group in `treatment_groups' {
	egen `group'_full_mean_emp = mean(`group'_mean_emp)
}

/*---------------------------------
        Create figure
----------------------------------*/
* Make graph 
twoway ///
	(connected treatment_mean_emp quarter, color("0 115 162")) ///
	(connected treatment_full_mean_emp quarter, symbol(i) color("0 115 162")) ///
	(connected control_mean_emp quarter, symbol(T) color("137 199 103")) ///
	(connected control_full_mean_emp quarter, symbol(i) color("137 199 103")) ///
	, ///
	xtitle("Quarters Since Random Assignment") ///
	ytitle("Employment Rate (%)") ///
	ylabel(10 (10) 40, nogrid) ///
	xlabel(1(5)36) ///
	legend(order(1 "Treatment" 2 "Treatment Mean Over 9 Years" 3 "Control" 4 "Control Mean Over 9 Years") ring(0) position(5) cols(1)) ///
	title(" ", size(vhuge))

* Export graph
graph export "${output}/Figure 2.${extension}", replace