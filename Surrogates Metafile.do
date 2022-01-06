/*******************************************************************************
         The Surrogate Index: Combining Short-Term Proxies to Estimate
            Long-Term Treatment Effects More Rapidly and Precisely
********************************************************************************
This code reproduces the figures and tables that refer to the GAIN program, 
using a simulated dataset.

The code can be run directly from this metafile by setting the global
${surrogates} to point to this repository.
*******************************************************************************/

/*---------------------------------
            Set-up
----------------------------------*/
clear all
set more off

* Set global directing to this repository
global surrogates "[PLEASE INSERT THE FILE DIRECTORY]" // For example: global surrogates "C:\Users\OpportunityInsights\Documents\GitHub\surrogate-index"

* Choose between real and simulated data 
global data_type simulated // change to "real" if using real dataset 

* Create relevant directories
cap mkdir "${surrogates}/Data-derived"
cap mkdir "${surrogates}/Output"

* Set globals
global code "${surrogates}/Code"
global data_raw "${surrogates}/Data-raw"
global data_derived "${surrogates}/Data-derived"
global output "${surrogates}/Output"

/*---------------------------------
      Compute estimates
----------------------------------*/
* Produce experimental, surrogate index, single surrogate and naive estimates of treatment effects 
do "${code}/Compute Estimates/Estimate treatment effects.do"

* Compute confidence intervals 
	// This .do file produces the confidence intervals referred to in footnote 16. 
	// As the confidence intervals are produced by bootstrapping, the .do file takes 
	// rather a long time to run. For this reason, it is commented out of the code. 
* do "${code}/compute estimates/Create confidence intervals for bounds for degree of bias.do"

/*---------------------------------
   Make figures for employment 
----------------------------------*/
foreach ext in wmf pdf {

	* Settings for figures
	global extension "`ext'"
	global title_size = cond("`ext'"=="pdf","zero","vhuge")

	***********************
	*      Figure 2       *
	***********************
	do "${code}/Figures/Figure 2.do"

	***********************
	*      Figure 3       *
	***********************
	do "${code}/Figures/Figure 3A.do"
	do "${code}/Figures/Figure 3B.do"

	***********************
	*      Figure 4       *
	***********************
	do "${code}/Figures/Figure 4.do"

	***********************
	*      Figure 5       *
	***********************
	do "${code}/Figures/Figure 5.do"	
	
	***********************
	*      Figure 6       *
	***********************
	do "${code}/Figures/Figure 6A.do"
	
	***********************
	*  Appendix Figure 5  *
	***********************
	do "${code}/Figures/Appendix Figure 5A.do"
}

/*---------------------------------
    Make figures for earnings
----------------------------------*/
// Note that the simulated data include employment outcomes only 
if "$data_type" == "real" {
	foreach ext in wmf pdf {

		* Settings for figures
		global extension "`ext'"
		global title_size = cond("`ext'"=="pdf","zero","vhuge")
		
		***********************
		*      Figure 6       *
		***********************
		do "${code}/Figures/Figure 6B.do"

		***********************
		*  Appendix Figure 1  *
		***********************
		do "${code}/Figures/Appendix Figure 1.do"

		***********************
		*  Appendix Figure 2  *
		***********************
		do "${code}/Figures/Appendix Figure 2A.do"
		do "${code}/Figures/Appendix Figure 2B.do"

		***********************
		*  Appendix Figure 3  *
		***********************
		do "${code}/Figures/Appendix Figure 3.do"

		***********************
		*  Appendix Figure 4  *
		***********************
		do "${code}/Figures/Appendix Figure 4.do"

		***********************
		*  Appendix Figure 5  *
		***********************
		do "${code}/Figures/Appendix Figure 5B.do"
	}
}

/*---------------------------------
         Make tables
----------------------------------*/
* Appendix Table 1
do "${code}/Tables/Format Appendix Table 1.do"

* Appendix Table 2
do "${code}/Tables/Format Appendix Table 2.do"
