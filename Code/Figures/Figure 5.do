********************************************************************************
* Figure 5 (Bounds on Mean Treatment Effect on Employment Rates Over Nine Years, 
* Varying Number of Quarters Used to Construct Surrogate Index)
********************************************************************************

* Import data
import delimited "${data_derived}/Estimated Bounds on Treatment Effect on Cumulative Employment (36 Quarters).csv", clear

* Rescale employment to be a percentage variable 
foreach var in experimental upper_bias_01 lower_bias_01 upper_bias_05 lower_bias_05 surrogate_index {
	replace `var' = 100*`var'
}

* Make graph 
tw ///
	(rarea upper_bias_01 lower_bias_01 quarter, sort color(%10 gs2) lcolor(%0 black) fcolor(gray)) ///
	(rarea upper_bias_05 upper_bias_01 quarter, sort color(%10 gs2) lcolor(%0 black) fcolor(dimgray)) ///
	(rarea lower_bias_05 lower_bias_01 quarter, sort color(%10 gs2) lcolor(%0 black) fcolor(dimgray)) ///
	(line experimental quarter, color("31 143 141")) ///
	(scatter surrogate_index quarter, color("0 115 162")) ///
	, ///
	xtitle("Quarters Since Random Assignment") ///
	ytitle("Estimated Treatment Effect on Mean" "Employment Rate Over 9 Years (%)") ///
	ylabel(-20(10)20, nogrid) ///
	xlabel(1(5)36) ///
	yline(0, lcolor(black%60)) ///
	legend(order(4 "Actual Mean Treat. Eff. Over 36 Quart." 5 "Surrogate Index Estimate" 1 "Bounds on Bias:                " 2 "Bounds on Bias:") position(5) ring(0) region(col(none)) cols(1)) ///
	title(" ", size(vhuge))

* Export graph
graph export "${output}/Figure 5 (Raw).${extension}", replace