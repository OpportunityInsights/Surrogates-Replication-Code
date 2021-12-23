********************************************************************************
* Appendix Figure 5A (Treatment Effects on Employment and Earnings in Each Year, 
* Varying Outcome Horizon: Employment Rates)
********************************************************************************

* Import data
import delimited "${data_derived}/Estimated Treatment Effect on Yearly Employment.csv", clear 

* Rescale employment to be a percentage variable 
foreach var in upper_experimental lower_experimental surrogate_index experimental {
	replace `var' = 100*`var'
}

* Make graph  
twoway	///
		(rcap upper_experimental lower_experimental year, lwidth(*.5) color("137 199 103") msize(0)) ///
		(scatter experimental year, symbol(T) color("137 199 103")) ///
		(scatter surrogate_index year, color("0 115 162")) ///
		, ///
		xtitle(Years Since Random Assignment) ///
		ytitle("Estimated Treatment Effect on Mean" "Employment Rate at Year {it:x} (%)") ///
		ylabel(, nogrid) ///
		xlabel(3(1)9) ///
		xscale(range(2 9)) ///
		legend(order(3 "Six-Quarter Surrogate Index Estimate" 2 "Actual Experimental Estimate") position(7) ring(0) cols(1)) ///
		title(" ", size(${title_size}))
graph export "${output}/Appendix Figure 5A.${extension}", replace 