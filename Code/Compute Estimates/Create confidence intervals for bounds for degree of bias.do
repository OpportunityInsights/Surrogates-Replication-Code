/*******************************************************************************
* Create confidence intervals for bounds                                       *
********************************************************************************

This .do file calculates confidence intervals around bounds for the degree of 
bias arising from violations of the surrogacy assumption. The bounds are calculated 
through bootstrapping and applying the formula for confidence intervals for 
partially identified parameters in Imbens and Manski (Econometrica, 2004). 

Due to the bootstrapping, this file takes a while to run! 
You can see the output from the file by looking at 
"${data_derived}/Estimated Bounds on Degree of Bias.csv". */ 

/* ----------------------- 
    Preparing data
-------------------------*/
* Setting up
clear all 
set maxvar 25000

* Declare number of runs 
local reps 5000 

* Import data 
use "${data_raw}/Riverside GAIN Data.dta", clear 

* Set outcomes 
	// The simulated data include employment outcomes only 
if "$data_type" == "real" local outcomes emp earn 
if "$data_type" == "simulated" local outcomes emp 

* Generate cumulative mean
foreach outcome in `outcomes' {
	egen `outcome'_cm36 = rowtotal(`outcome'1-`outcome'36)
	replace `outcome'_cm36 = `outcome'_cm36/36 
} 

* Save data for later use 
tempfile base 
save `base'

/* ----------------------- 
    Defining program
-------------------------*/
capture program drop bootstrap_ci
program bootstrap_ci 

	* Create bootstrapped sample 
	bsample
	
	* Estimate surrogate index estimate by quarter 
	local outcomes emp earn
	foreach outcome in `outcomes' {
	
		forvalues q = 1(1)36 {
		
			// Regress outcome on surrogates 
			qui reg `outcome'_cm36 `outcome'1-`outcome'`q' if treatment == 1
			
			// Create surrogate index 
			qui predict `outcome'_cm_pred`q', xb  
			
			// Estimate treatment effect on surrogate index 
			qui reg `outcome'_cm_pred`q' treatment
			
			// Store estimated treatment effect in the matrix B 
			mat B_`outcome'[`q', `1'] = _b[treatment]

			// Calculate bounds for degree of bias arising from violations of surrogacy 
			qui sum `outcome'_cm36
			local var_outcome = `r(Var)'
			qui sum treatment 
			local var_treatment = `r(Var)'
			qui reg treatment `outcome'1-`outcome'`q' 
			local R2_treatment_surrogates = `e(r2)'
			qui reg `outcome'_cm36 `outcome'1-`outcome'`q' 
			local R2_outcome_surrogates = `e(r2)'
			
			// Store estimated treatment effect in the matrix V 
			mat V_`outcome'[`q', `1'] = (`var_outcome' * 0.01 * (1 - `R2_treatment_surrogates') * (1 - `R2_outcome_surrogates') / `var_treatment')^(1/2)
		
		}
	}
end

/* ----------------------- 
    Running program
-------------------------*/
* Create matrices in which to store results 
foreach outcome in `outcomes' {
	mat V_`outcome' = J(36, `reps', .)
	mat B_`outcome' = J(36, `reps', .)
}

* Run program 
forvalues i = 1(1)`reps' {
	use `base', clear 
	bootstrap_ci `i'
	noi _dots `i' 0
}

use `base', clear 

* Move results of program from matrix into variables 
foreach outcome in `outcomes' {
	forvalues i = 1(1)`reps' {
		qui gen lower_bias_`outcome'_`i' = . 
		qui gen upper_bias_`outcome'_`i' = .

		forvalues q = 1(1)36 {
			qui replace lower_bias_`outcome'_`i' = B_`outcome'[`q', `i'] - V_`outcome'[`q', `i'] in `q'
			qui replace upper_bias_`outcome'_`i' = B_`outcome'[`q', `i'] + V_`outcome'[`q', `i'] in `q'
		}
	} 
}

* Calculate standard error of bounds 
foreach outcome in `outcomes' {
	egen top_ci_`outcome'_se = rowsd(upper_bias_`outcome'_*)
	egen bottom_ci_`outcome'_se = rowsd(lower_bias_`outcome'_*)
}

/* ----------------------- 
 Computing point estimates
-------------------------*/
foreach outcome in `outcomes' {
	gen estimate_`outcome' = . 
	gen se_estimate_`outcome' = . 
	gen bias_01_`outcome' = .
	gen bias_05_`outcome' = .  
	gen experimental_est_`outcome' = . 

	forvalues q = 1(1)36 {
	
	* Create surrogate index estimates 
		// Regress outcome on surrogates 
		qui reg `outcome'_cm36 `outcome'1-`outcome'`q' if treatment == 1
				
		// Create surrogate index 
		predict `outcome'_cm_pred`q', xb  

		// Estimate treatment effect on surrogate index 
		qui reg `outcome'_cm_pred`q' treatment
		replace estimate_`outcome' = _b[treatment] in `q'
		
		// Calculate bounds for degree of bias arising from violations of surrogacy 
		qui sum `outcome'_cm36 
		local var_outcome = `r(Var)'
		qui sum treatment 
		local var_treatment = `r(Var)'
		qui reg treatment `outcome'1-`outcome'`q' 
		local R2_treatment_surrogates = `e(r2)'
		qui reg `outcome'_cm36 `outcome'1-`outcome'`q' 
		local R2_outcome_surrogates = `e(r2)'
		replace bias_01_`outcome' = (`var_outcome' * 0.01 * (1 - `R2_treatment_surrogates') * (1 - `R2_outcome_surrogates') / `var_treatment')^(1/2) in `q'
	
	}
}

/* ----------------------- 
     Generate bound
-------------------------*/
* Keep only relevant data 
gen quarter = _n 
keep if quarter < 37 

* Generate bound 
local outcomes emp earn 
foreach outcome in `outcomes' {
	gen top_ci_01_`outcome' = estimate_`outcome' + bias_01_`outcome' + 1.645 * top_ci_`outcome'_se
	gen bottom_ci_01_`outcome' = estimate_`outcome' - bias_01_`outcome' - 1.645 * bottom_ci_`outcome'_se
}

* Rearrange for export  
keep quarter top_ci_01_emp bottom_ci_01_emp top_ci_emp_se bottom_ci_emp_se top_ci_01_earn bottom_ci_01_earn top_ci_earn_se bottom_ci_earn_se
order quarter top_ci_01_emp bottom_ci_01_emp top_ci_emp_se bottom_ci_emp_se top_ci_01_earn bottom_ci_01_earn top_ci_earn_se bottom_ci_earn_se

* Export 
export delimited using "${data_derived}/CI on Bounds for Degree of Bias.csv", replace