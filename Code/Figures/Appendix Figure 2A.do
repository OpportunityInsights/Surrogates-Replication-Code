********************************************************************************
* Appendix Figure 2A (Estimates of Treatment Effect on Quarterly Earnings Over Nine Years, 
* Varying Quarters of Data Used to Construct Surrogate Index)
********************************************************************************

* Import data
import delimited "${data_derived}/Estimated Treatment Effect on Cumulative Earnings (36 Quarters).csv", encoding(ISO-8859-2) clear

* Make graph 
twoway	(line upper_experimental quarter, lpattern(dash) lwidth(*.5) color("31 143 141")) ///
		(line lower_experimental quarter, lpattern(dash) lwidth(*.5) color("31 143 141")) ///
		(line experimental quarter, color("31 143 141")) ///
		(scatter surrogate_index quarter, color("0 115 162")) ///
		(scatter naive quarter, symbol(T) color("137 199 103")) ///
		, ///
		xtitle(Quarters Since Random Assignment) ///
		ytitle("Estimated Treatment Effect on Mean" "Quarterly Earnings Over 9 Years ($)") ///
		ylabel(0(100)400, nogrid) ///
		xlabel(1(5)36) ///
		legend(order(4 "Surrogate Index Estimate" 5 "Naive Short-Run Estimate" 3 "Actual Mean Treatment Effect Over 36 Quarters") ring(0) position(4) cols(1)) ///
		title(" ", size(${title_size}))

* Export graph 
graph export "${output}/Appendix Figure 2A.${extension}", replace