/*******************************************************************************
* Create tables of surrogate index estimates                                   * 
********************************************************************************

This .do file creates the surrogate index estimates used throughout section 7. 
The file consists of four sections:

	A.  Prepare data 
			- Generates cumulative means and saves count of observations.
		
	B.  Treatment effects over 36 quarters: experimental vs. surrogate vs. naive estimation 
			- Estimates treatment effects on mean employment and earnings over 36 quarters, 
			  producing an experimental estimate, a naive estimate, a surrogate index estimate 
			  and a single surrogate estimate. 
			- In the surrogate, single surrogate and naive case, we vary the quarters 
			  of data used to construct the estimate. 
			- In the surrogate index case, we compute the weight placed on each quarter. 
			- In the surrogate index case, we compute bounds for the degree of bias 
			  that could arise due to the violation of the surrogacy assumption. 
			- Output is used to create Appendix Tables 1 and 2, Figure 3, Figure 5, 
			  Appendix Figure 2 and Appendix Figure 4.
			 
	C. 	Treatment effects over x quarters: experimental vs. six-quarters surrogate index 
			- Estimates treatment effects on mean employment and earnings over x quarters, 
			  where x varies between 6 and 36, producing an experimental estimate and a 
			  surrogate estimate based on a six-quarter surrogate index. 
			- Output is used to create Figure 4 and Appendix Figure 3. 

	D. 	Treatment effects on yearly outcomes: experimental vs. six-quarter surrogate index 
			- Estimates treatment effects on yearly employment and earnings. 
			- Output is used to create Appendix Figure 5. 
	
	E.	Evaluate use of Riverside surrogates index to predict effects in other GAIN sites (Los Angeles, San Diego and Alameda)
			- Estimates six-quarter surrogate index (using Riverside data) and uses 
			  six-quarter surrogate index estimates to produce estimated treatment effects
			  in other sites. 
			- Compares surrogate index estimates to experimental estimates in other sites. 
			- Output is used to create Figure 6.
	*/

/* ----------------------- 
     A. Prepare data
-------------------------*/
* Clear 
clear all

* Import data 
use "${data_raw}/${data_type} Riverside GAIN data.dta", clear

* Confirm structure of data  
isid id
misstable sum 
assert `r(max)' == . 

* Specify outcomes used in analysis 
	// The simulated data include employment outcomes only 
if "$data_type" == "real" local outcomes emp earn 
if "$data_type" == "simulated" local outcomes emp 

* Generate cumulative means of employment and quarterly wage earnings, from Q6 forward
forvalues q = 1/36 {
	foreach outcome in `outcomes' {
		egen `outcome'_cm`q' = rowtotal(`outcome'1-`outcome'`q')
		qui replace `outcome'_cm`q' = `outcome'_cm`q'/`q'
	}
}

* Count observations in dataset (for use calculating SEs)
qui count 
local number_observations = `r(N)'

* Generate variables in which to store estimated treatment effects   
foreach estimate in experimental surrogate_index naive single_surrogate {
	foreach outcome in `outcomes' {
		qui gen `estimate'_`outcome' = .
		qui gen `estimate'_se_`outcome' = .
	}
}

* Save data for later use 
tempfile base 
save `base'

/* -------------------------------------------------------------------------
B. Treatment effects over 36 quarters: experimental vs. surrogate vs. naive estimation
--------------------------------------------------------------------------*/

**************
* Compute estimates
**************
* Generate variables in which to store the weight placed on each quarter and 
	// the constant in the regression of primary outcome on surrogate outcomes 
foreach outcome in `outcomes' {
	forvalues q = 1(1)36 {
		qui gen `outcome'_weight_`q'_b = . 
		qui gen `outcome'_weight_`q'_se = . 
	}
	qui gen `outcome'_constant = . 
	qui gen `outcome'_constant_se = .
}

* Generate variables in which to store bounds for bias, and calculate relevant locals 
foreach outcome in `outcomes' {

	* Create bias variable 
	qui gen bias_01_`outcome' = .
	qui gen bias_05_`outcome' = .
	
	* Store variance of the outcome variable 
	qui sum `outcome'_cm36
	local var_`outcome' = `r(Var)'
}

qui sum treatment 
local var_treatment = `r(Var)'

* Estimate treatment effect, varying the number of quarters of data used to make the estimate
foreach outcome in `outcomes' {
	forvalues q = 1(1)36 {
	
	* Create surrogate index estimates 
		// Regress outcome on surrogates 
		qui reg `outcome'_cm36 `outcome'1-`outcome'`q' if treatment == 1
		
		// Store weight placed on each quarter and constant 
		forvalues i = 1(1)`q' {
			qui replace `outcome'_weight_`q'_b = _b[`outcome'`i'] in `i'
			qui replace `outcome'_weight_`q'_se = _se[`outcome'`i'] in `i'
		}
		qui replace `outcome'_constant = _b[_cons] in `q'
		qui replace `outcome'_constant_se = _se[_cons] in `q'
		
		// Create surrogate index 
		qui predict `outcome'_cm_pred`q', xb  

		// Estimate treatment effect on surrogate index 
		qui reg `outcome'_cm_pred`q' treatment
		qui replace surrogate_index_`outcome' = _b[treatment] in `q'
		qui replace surrogate_index_se_`outcome' = _se[treatment] in `q'
		
		// Calculate bounds for degree of bias arising from violations of surrogacy 
		qui reg treatment `outcome'1-`outcome'`q' 
		local R2_treatment_surrogates = `e(r2)'
		qui reg `outcome'_cm36 `outcome'1-`outcome'`q' 
		local R2_outcome_surrogates = `e(r2)'
		qui replace bias_01_`outcome' = (`var_`outcome'' * 0.01 * (1 - `R2_treatment_surrogates') * (1 - `R2_outcome_surrogates') / `var_treatment')^(1/2) in `q'
		qui replace bias_05_`outcome' = (`var_`outcome'' * 0.05 * (1 - `R2_treatment_surrogates') * (1 - `R2_outcome_surrogates') / `var_treatment')^(1/2) in `q'

	* Create surrogate index estimates, using outcome in a single quarter as surrogate
		// Regress outcome on surrogates 
		qui reg `outcome'_cm36 `outcome'`q' if treatment == 1
		
		// Create surrogate index 
		predict `outcome'_cm_1_pred`q', xb
		
		// Estimate treatment effect on surrogate index 
		qui reg `outcome'_cm_1_pred`q' treatment 
		qui replace single_surrogate_`outcome' = _b[treatment] in `q'
		qui replace single_surrogate_se_`outcome' = _se[treatment] in `q'
		
	* Create naive estimate of treatment effect on mean  
		qui reg `outcome'_cm`q' treatment 
		qui replace naive_`outcome' = _b[treatment] in `q'
		qui replace naive_se_`outcome' = _se[treatment] in `q'

	* Create "ground truth": experimental estimate of treatment effect on mean 
		qui reg `outcome'_cm36 treatment 
		qui replace experimental_`outcome' = _b[treatment] in `q'
		qui replace experimental_se_`outcome' = _se[treatment] in `q'	
		
	* Dots to show progress 
	noi _dots `q' 0
	}
}

**************
* Output results 
**************
* Create a temporary file for results 
gen quarter = _n 
if "$data_type" == "real" keep *_emp *_earn *_weight_* quarter *constant*
if "$data_type" == "simulated" keep *_emp *_weight_* quarter *constant*
drop if _n > 36 

tempfile part_b_results
save `part_b_results'

* Output results for use in Figure 3 and Appendix Figure 2  
foreach outcome in `outcomes' {
	use `part_b_results', clear 
	keep *_`outcome' quarter 
	rename *_`outcome' *
	foreach estimate in experimental surrogate_index naive {
		qui gen upper_`estimate' = `estimate' + invttail(`number_observations' - 2, 0.025) * `estimate'_se
		qui gen lower_`estimate' = `estimate' - invttail(`number_observations' - 2, 0.025) * `estimate'_se
	}
	drop if quarter > 36 
	order quarter 
	if "`outcome'" == "emp" export delimited using "${data_derived}/Estimated Treatment Effect on Cumulative Employment (36 Quarters).csv", replace
	if "`outcome'" == "earn" export delimited using "${data_derived}/Estimated Treatment Effect on Cumulative Earnings (36 Quarters).csv", replace
}

* Output results for use in Figure 5 and Appendix Figure 4 
foreach outcome in `outcomes' {
	use `part_b_results', clear	
	keep *_`outcome' quarter 
	rename *_`outcome' *	
	keep experimental surrogate_index quarter bias* quarter 
	qui gen upper_bias_01 = surrogate_index + bias_01
	qui gen lower_bias_01 = surrogate_index - bias_01
	qui gen upper_bias_05 = surrogate_index + bias_05
	qui gen lower_bias_05 = surrogate_index - bias_05
	drop if quarter > 36 
	order quarter 
	if "`outcome'" == "emp" export delimited using "${data_derived}/Estimated Bounds on Treatment Effect on Cumulative Employment (36 Quarters).csv", replace
	if "`outcome'" == "earn" export delimited using "${data_derived}/Estimated Bounds on Treatment Effect on Cumulative Earnings (36 Quarters).csv", replace
}

* Output results for use in Appendix Tables 1 and 2
use `part_b_results', clear 
export delimited using "${data_derived}/Unformatted Appendix Tables Output.csv", replace

/* -------------------------------------------------------------------------
C. 	Treatment effects over x quarters: experimental vs. six-quarters surrogate index 
--------------------------------------------------------------------------*/

**************
* Compute estimates
**************
use `base', clear 

* Compute treatment effect over x quarters estimated with an experimental estimate vs. 
	// six-quarter surrogate index estimate, varying x from 1 to 36 
foreach outcome in `outcomes' {

	forvalues q = 6(1)36 {
	
	* Compute surrogate index estimates 
		// Regress outcome on surrogates 
		qui reg `outcome'_cm`q' `outcome'1-`outcome'6 if treatment == 1
		
		// Create surrogate index 
		qui predict `outcome'_cm_pred`q', xb 
		
		// Estimate treatment effect on surrogate index 
		qui reg `outcome'_cm_pred`q' treatment
		qui replace surrogate_index_`outcome' = _b[treatment] in `q'
		qui replace surrogate_index_se_`outcome' = _se[treatment] in `q'
		
	* Compute "ground truth" estimates 
		qui reg `outcome'_cm`q' treatment 
		qui replace experimental_`outcome' = _b[treatment] in `q'
		qui replace experimental_se_`outcome' = _se[treatment] in `q'
		
	* Dots to show progress 
	noi _dots `q' 0

	}
}

**************
* Output results 
**************
* Rearrange for output to table 
keep *experimental* *surrogate_index*
qui gen quarter = _n 
drop if quarter > 36 | quarter < 6
order quarter 

* Create temporary file 
tempfile part_c_results 
save `part_c_results'

* Output results 
foreach outcome in `outcomes' {
	use `part_c_results', clear  
	keep quarter *_`outcome' 
	rename *_`outcome' *
	qui gen upper_experimental = experimental + invttail(`number_observations' - 2, 0.025) * experimental_se
	qui gen lower_experimental = experimental - invttail(`number_observations' - 2, 0.025) * experimental_se
	if "`outcome'" == "emp" export delimited using "${data_derived}/Estimated Treatment Effect on Cumulative Employment, Varying Outcome Horizon.csv", replace
	if "`outcome'" == "earn" export delimited using "${data_derived}/Estimated Treatment Effect on Cumulative Earnings, Varying Outcome Horizon.csv", replace
}

/* -------------------------------------------------------------------------
D. 	Treatment effects on yearly outcomes: experimental vs. six-quarter surrogate index 
------------------------------------------------------------------------- */

**************
* Compute estimates
**************
use `base', clear

* Generate yearly means of employment and wages starting from the third year
foreach outcome in `outcomes' {
	forvalues y = 3/9 {
		local year_start = 4 * `y' - 3
		local year_end = 4 * `y'
		qui egen `outcome'_annual_`y' = rowtotal(`outcome'`year_start'-`outcome'`year_end')
		qui replace `outcome'_annual_`y' = `outcome'_annual_`y'/4
	}
}

* Compute treatment effects on employment and wages from third year forward, 
	// comparing experimental estimate to six-quarter surrogate index 
foreach outcome in `outcomes' {

	forvalues y = 3(1)9 {
	
	* Create surrogate index estimates 
		// Regress outcome on surrogates 
		qui reg `outcome'_annual_`y' `outcome'1-`outcome'6 if treatment == 1
		
		// Create surrogate index 
		qui predict `outcome'_annual_pred`y', xb
		
		// Estimate treatment effect on surrogate index 
		qui reg `outcome'_annual_pred`y' treatment
		qui replace surrogate_index_`outcome' = _b[treatment] in `y'
		
	* Create "ground truth" estimates 
		qui reg `outcome'_annual_`y' treatment 
		qui replace experimental_`outcome' = _b[treatment] in `y'
		qui replace experimental_se_`outcome' = _se[treatment] in `y'
		
	* Create dots to show progress 
	noi _dots `y' 0
	}
}

**************
* Output results 
**************
* Rearrange for output to table 
keep *experimental* *surrogate_index*
gen year = _n 
drop if year > 9 | year < 3
order year 

tempfile part_d_results 
save `part_d_results'

* Output results
foreach outcome in `outcomes' {
	use `part_d_results', clear  
	keep year *_`outcome' 
	rename *_`outcome' *
	drop surrogate_index_se 
	gen upper_experimental = experimental + invttail(`number_observations' - 2, 0.025) * experimental_se
	gen lower_experimental = experimental - invttail(`number_observations' - 2, 0.025) * experimental_se
	if "`outcome'" == "emp" export delimited using "${data_derived}/Estimated Treatment Effect on Yearly Employment.csv", replace
	if "`outcome'" == "earn" export delimited using "${data_derived}/Estimated Treatment Effect on Yearly Earnings.csv", replace
}

/* -------------------------------------------------------------------------
E. Evaluate use of Riverside surrogates index to predict effects in other GAIN sites (Los Angeles, San Diego and Alameda)
------------------------------------------------------------------------- */

**************
* Prepare data
**************
* Clear
clear all

* Import data
use "${data_raw}/${data_type} All Locations GAIN data.dta", clear

* Specify outcomes used in analysis
	// The simulated data includes employment outcomes only 
if "$data_type" == "real" local outcomes emp earn 
if "$data_type" == "simulated" local outcomes emp 

* Specify sites used in analysis
replace site = "LA" if site == "Los Angeles"
replace site = "SD" if site == "San Diego"
replace site = "RS" if site == "Riverside"
replace site = "AL" if site == "Alameda"

local sites RS LA SD AL

* Generate cumulative means of employment and quarterly wage earnings, from Q6 forward
foreach outcome in `outcomes' {
	egen `outcome'_cm36 = rowtotal(`outcome'1-`outcome'36)
	qui replace `outcome'_cm36 = `outcome'_cm36/36
}

* Count observations in dataset (for use calculating SEs)
qui count if site == "RS"
local number_observations = `r(N)'

* Generate variables in which to store estimated treatment effects
foreach estimate in experimental surrogate_index {
	foreach outcome in `outcomes' {
		foreach site in `sites' {
			qui gen `estimate'_`outcome'_`site'_Q6 = .
			qui gen `estimate'_`outcome'_`site'_Q6_se = .
		}
	}
}

**************
* Compute Estimates 
**************
* Estimate six-quarter surrogate index using Riverside data 
foreach outcome in `outcomes' {

	* Create surrogate index estimates
		// Regress outcome on surrogates
			qui reg `outcome'_cm36 `outcome'1-`outcome'6 if treatment == 1 & site == "RS"

		// Create surrogate index
			qui predict `outcome'_cm_predQ6, xb

		// Estimate treatment effect on surrogate index
		foreach site in `sites' {
			qui reg `outcome'_cm_predQ6 treatment if site == "`site'"
			qui replace surrogate_index_`outcome'_`site'_Q6 = _b[treatment]
		}

	* Create experimental estimate
		foreach site in `sites' {
			qui reg `outcome'_cm36 treatment if site == "`site'"
			qui replace experimental_`outcome'_`site'_Q6 = _b[treatment]
			qui replace experimental_`outcome'_`site'_Q6_se = _se[treatment]
		}
}

**************
* Output results 
**************
* Rearrange for output to table 
keep experimental*RS* experimental*LA* experimental*SD* experimental*AL* surrogate_index*RS* surrogate_index*LA* surrogate_index*SD* surrogate_index*AL* site

tempfile part_e_results 
save `part_e_results'

* Output results
foreach outcome in `outcomes' {
	use `part_e_results', clear  
	keep *_`outcome'* site
	rename *_`outcome'* **
	foreach site in `sites' {
		qui count if site == "`site'"
		gen upper_experimental_`site'_Q6 = surrogate_index_`site'_Q6 + invttail(`r(N)' - 2, 0.025) * experimental_`site'_Q6_se
		gen lower_experimental_`site'_Q6 = surrogate_index_`site'_Q6 - invttail(`r(N)' - 2, 0.025) * experimental_`site'_Q6_se
	}
	keep if _n == 1
	if "`outcome'" == "emp" export delimited using "${data_derived}/Estimated Six-Quarter Surrogate Index vs Actual Treatment Effects for Other Sites (Employment).csv", replace
	if "`outcome'" == "earn" export delimited using "${data_derived}/Estimated Six-Quarter Surrogate Index vs Actual Treatment Effects for Other Sites (Earnings).csv", replace
}