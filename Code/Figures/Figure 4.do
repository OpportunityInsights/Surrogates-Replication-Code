********************************************************************************
* Figure 4 (Validation of Six-Quarter Surrogate Index: Estimates of Treatment Effects 
* on Mean Employment Rates, Varying Outcome Horizon)
********************************************************************************

* Import data 
import delimited "${data_derived}/Estimated Treatment Effect on Cumulative Employment, Varying Outcome Horizon.csv", clear 

* Rescale employment to be a percentage variable 
foreach var in experimental upper_experimental lower_experimental surrogate_index {
	replace `var' = 100*`var'
}

* Produce graph
twoway	/// 
		(scatter experimental quarter, symbol(T) color("137 199 103")) ///
		(rcap upper_experimental lower_experimental quarter, lwidth(*.5) color("137 199 103") msize(0)) ///
		(scatter surrogate_index quarter, color("0 115 162")) ///
		, ///
		xtitle(Quarters Since Random Assignment) ///
		ytitle("Estimated Treatment Effect on Mean" "Employment Rate to Quarter {it:x} (%)") ///
		ylabel(, nogrid) ///
		xlabel(6(5)36) ///
		legend(order(3 "Six-Quarter Surrogate Index Estimate" 1 "Actual Experimental Estimate") position(7) ring(0) cols(1)) ///
		title(" ", size(${title_size}))
		
* Export graph 
graph export "${output}/Figure 4.${extension}", replace