********************************************************************************
* Figure 4 (Validation of Six-Quarter Surrogate Index: Estimates of Treatment Effects 
* on Mean Quarterly Earnings, Varying Outcome Horizon)
********************************************************************************

* Import data 
import delimited "${data_derived}/Estimated Treatment Effect on Cumulative Earnings, Varying Outcome Horizon.csv", clear 

* Produce graph 
twoway	(rcap upper_experimental lower_experimental quarter, lwidth(*.5) color("137 199 103") msize(0)) ///
		(scatter experimental quarter, symbol(T) color("137 199 103")) ///
		(scatter surrogate_index quarter, color("0 115 162")) ///
		, ///
		xtitle(Quarters Since Random Assignment) ///
		ytitle("Estimated Treatment Effect on Mean" "Quarterly Earnings to Quarter {it:x} ($)") ///
		ylabel(150(50)415, nogrid) ///
		yscale(range(145 420)) ///
		xlabel(6(5)36) ///
		legend(order(3 "Six-Quarter Surrogate Index Estimate" 2 "Actual Experimental Estimate")  position(7) ring(0) cols(1)) ///
		title(" ", size(${title_size}))
		
* Export graph 
graph export "${output}/Appendix Figure 3.${extension}", replace