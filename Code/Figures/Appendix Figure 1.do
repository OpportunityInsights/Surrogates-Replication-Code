********************************************************************************
* Appendix Figure 1 (Control and Treatment Mean Earnings Over Nine Years)
********************************************************************************

/*---------------------------------
          Prepare data
----------------------------------*/
* Import data
use "${data_raw}/Riverside GAIN data.dta", clear

* Confirm structure of data  
isid id
misstable sum 
assert `r(max)' == . 

* Set outcomes 
local outcomes earn earn 

* Set treatment groups 
local treatment_groups control treatment 

* Generate variables in which to store mean earnings in each quarter, by treatment group 
foreach group in `treatment_groups' {
		gen `group'_mean_earn = . 
}

/*---------------------------------
        Compute means
----------------------------------*/
* Compute mean earnings in each quarter, by treatment group
forvalues q = 1(1)36 {
	
	* Compute control means 
	gen earn`q'_control = earn`q' if treatment == 0
	egen control_mean_earn_`q' = mean(earn`q'_control)
	replace control_mean_earn = control_mean_earn_`q' in `q'
	
	* Compute treatment means 
	gen earn`q'_treatment = earn`q' if treatment == 1
	egen treatment_mean_earn_`q' = mean(earn`q'_treatment)
	replace treatment_mean_earn = treatment_mean_earn_`q' in `q'	
}

keep *_mean_earn
gen quarter = _n 
drop if quarter > 36

* Compute means of earnings on average over full sample period, by treatment group 
	// Note that the number of treatment and control group observations does not 
	// vary by quarter, so we can take a mean over the 36 quarters, rather 
	// than needing to take the means at the individual level 
foreach group in `treatment_groups' {
	egen `group'_full_mean_earn = mean(`group'_mean_earn)
}

/*---------------------------------
        Create figure
----------------------------------*/
* Make graph 
twoway ///
	(connected treatment_mean_earn quarter, color("0 115 162")) ///
	(connected treatment_full_mean_earn quarter, symbol(i) color("0 115 162")) ///
	(connected control_mean_earn quarter, symbol(T) color("137 199 103")) ///
	(connected control_full_mean_earn quarter, symbol(i) color("137 199 103")) ///
	, ///
	xtitle("Quarters Since Random Assignment") ///
	ytitle("Mean Quarterly Earnings ($)") ///
		ylabel(0 (500) 1500, nogrid) ///
	xlabel(1(5)36) ///
	legend(order(1 "Treatment" 2 "Treatment Mean Over 9 Years" 3 "Control" 4 "Control Mean Over 9 Years") ring(0) position(5) cols(1)) ///
	title(" ", size(vhuge))

* Export graph
graph export "${output}/Appendix Figure 1.${extension}", replace