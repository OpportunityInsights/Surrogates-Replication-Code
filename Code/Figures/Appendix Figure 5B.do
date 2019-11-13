********************************************************************************
* Appendix Figure 5A (Treatment Effects on Employment and Earnings in Each Year, 
* Varying Outcome Horizon: Quarterly Earnings)
********************************************************************************

* Import data
import delimited "${data_derived}/Estimated Treatment Effect on Yearly Earnings.csv", clear 

* Make graph 
twoway	(rcap upper_experimental lower_experimental year, lwidth(*.5) color("137 199 103") msize(0)) ///
		(scatter experimental year, symbol(T) color("137 199 103")) ///
		(scatter surrogate_index year, color("0 115 162")) ///
		, ///
		xtitle(Years Since Random Assignment) ///
		ytitle("Estimated Treatment Effect on Mean" "Quarterly Earnings at Year {it:x} ($)") ///
		ylabel(0(100)450, nogrid) ///
		yscale(range(-100 450)) ///
		xlabel(3(1)9) ///
		xscale(range(2 9)) ///
		legend(order(3 "Six-Quarter Surrogate Index Estimate" 2 "Actual Experimental Estimate")  position(7) ring(0) cols(1)) ///
		title(" ", size(${title_size}))

* Export graph
graph export "${output}/Appendix Figure 5B.${extension}", replace