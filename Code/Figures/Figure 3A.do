********************************************************************************
* Figure 3A (Estimates of Treatment Effect on Mean Employment Rates Over Nine Years, 
* Varying Quarters of Data Used to Construct Surrogate Index)
********************************************************************************

* Import data
import delimited "${data_derived}/Estimated Treatment Effect on Cumulative Employment (36 Quarters).csv", encoding(ISO-8859-2) clear 

* Rescale employment to be a percentage variable 
foreach var in experimental upper_experimental lower_experimental surrogate_index naive {
	replace `var' = 100*`var'
}

* Make graph 
twoway	(line upper_experimental quarter, lpattern(dash) lwidth(*.5) color("31 143 141")) ///
		(line lower_experimental quarter, lpattern(dash) lwidth(*.5) color("31 143 141")) ///
		(line experimental quarter, color("31 143 141")) ///
		(scatter surrogate_index quarter, color("0 115 162")) ///
		(scatter naive quarter, symbol(T) color("137 199 103")) ///
		, ///
		xtitle(Quarters Since Random Assignment) ///
		ytitle("Estimated Treatment Effect on Mean" "Employment Rate Over 9 Years (%)") ///
		ylabel(0(2)12, nogrid) ///
		xlabel(1(5)36) ///
		legend(order(4 "Surrogate Index Estimate" 5 "Naive Short-Run Estimate" 3 "Actual Mean Treatment Effect Over 36 Quarters") ring(0) position(5) cols(1)) ///
		title(" ", size(${title_size}))

* Export graph 
graph export "${output}/Figure 3A.${extension}", replace