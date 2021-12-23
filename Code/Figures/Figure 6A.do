********************************************************************************
* Figure 6A (Surrogate Index Estimates vs. Actual Experimental Estimates, by Site
* Employment Rates
********************************************************************************

* Import data
import delimited "${data_derived}/Estimated Six-Quarter Surrogate Index vs Actual Treatment Effects for Other Sites (Employment).csv", clear 

* Rescale employment to be a percentage variable 
ds *6*
foreach var in `r(varlist)' {
	replace `var' = 100*`var'
}

* Make labels
gen la = "Los Angeles"
gen sd = "San Diego"
gen rs = "Riverside"
gen al = "Alameda"

* Make Graph
tw ///
	(scatter surrogate_index_rs_q6 experimental_rs_q6, color(navy) mlabel(rs) mlabpos(9) mlabcolor(navy)) ///
	(scatter surrogate_index_la_q6 experimental_la_q6, color(navy) mlabel(la) mlabpos(5) mlabcolor(navy)) ///
	(scatter surrogate_index_sd_q6 experimental_sd_q6, color(navy) mlabel(sd) mlabpos(3) mlabcolor(navy)) ///
	(scatter surrogate_index_al_q6 experimental_al_q6, color(navy) mlabel(al) mlabpos(9) mlabcolor(navy)) ///
	(function y = x, range(-3 8)  lpattern(dash) lcolor(gray)) ///	
	(rbar upper_experimental_rs_q6 lower_experimental_rs_q6 experimental_rs_q6, barwidth(0.0001) color(navy)) ///
	(rbar upper_experimental_la_q6 lower_experimental_la_q6 experimental_la_q6, barwidth(0.0001) color(navy)) ///
	(rbar upper_experimental_sd_q6 lower_experimental_sd_q6 experimental_sd_q6, barwidth(0.0001) color(navy)) ///
	(rbar upper_experimental_al_q6 lower_experimental_al_q6 experimental_al_q6, barwidth(0.0001) color(navy)) ///
	, ///
	ytitle("Six-Quarter Surrogate Index Estimate of" "Treatment Effect on Mean Employment Rate (%)") ///
    xtitle("Actual Treatment Effect on" "Mean Employment Rate (%) Over 36 Quarters") ///
    legend(order() off ring(0) position(5) cols(1)) ///
	text(-2.7 -1.7 "45° Line", color(gray)) ///
	xlabel(-2 (2) 8) ///
    ylabel(-2 (2) 8, nogrid) ///
	yscale( range(-3 7.5)) ///
	xscale( range(-3 7.5))
	
* Export graph 
graph export "${output}/Figure 6A.${extension}", replace