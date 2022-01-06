********************************************************************************
* Appendix Figure 2B (Estimates of Treatment Effect on Mean Quarterly Earnings Over Nine Years, 
* Using Employment Rate in Single Quarter as a Surrogate)
********************************************************************************

* Import data
import delimited "${data_derived}/Estimated Treatment Effect on Cumulative Earnings (36 Quarters).csv", encoding(ISO-8859-2) clear 

* Make graph 
twoway	///
		(line experimental quarter, color("31 143 141")) ///
		(line upper_experimental quarter, lpattern(dash) lwidth(*.5) color("31 143 141")) ///
		(line lower_experimental quarter, lpattern(dash) lwidth(*.5) color("31 143 141")) ///
		(scatter single_surrogate quarter, color("0 115 162")) ///
		, ///
		xtitle("Quarters Since Random Assignment") ///
		ytitle("Estimated Treatment Effect on Mean" "Quarterly Earnings Over 9 Years ($)") ///
		ylabel(0(100)350, nogrid) ///
		yscale(range(-50 350)) ///
		xlabel(1(5)36) ///
		legend(order(1  "Actual Mean Treatment Effect Over 36 Quarters" 4 "Surrogate Estimate Using Earnings in Quarter {it:x} Only") position(7) ring(0) cols(1)) ///
		title(" ", size(${title_size}))
		
* Export graph 
graph export "${output}/Appendix Figure 2B.${extension}", replace