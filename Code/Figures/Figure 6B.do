********************************************************************************
* Figure 6B (Surrogate Index Estimates vs. Actual Experimental Estimates, by Site
* Quarterly Earnings
********************************************************************************

* Import data
import delimited "${data_derived}/Estimated Six-Quarter Surrogate Index vs Actual Treatment Effects for Other Sites (Earnings).csv", clear 

* Make labels for dots
gen la = "Los Angeles"
gen sd = "San Diego"
gen rs = "Riverside"
gen al = "Alameda"

* Make Graph
tw ///
	(scatter surrogate_index_rs_q6 experimental_rs_q6, color(navy) mlabel(rs) mlabpos(10) mlabcolor(navy)) ///
	(scatter surrogate_index_la_q6 experimental_la_q6, color(navy) mlabel(la) mlabpos(5) mlabcolor(navy)) ///
	(scatter surrogate_index_sd_q6 experimental_sd_q6, color(navy) mlabel(sd) mlabpos(7) mlabcolor(navy)) ///
	(scatter surrogate_index_al_q6 experimental_al_q6, color(navy) mlabel(al) mlabpos(3) mlabcolor(navy)) ///
	(function y = x, range(-100 380)  lpattern(dash) lcolor(gray)) ///	
	(rbar upper_experimental_rs_q6 lower_experimental_rs_q6 experimental_rs_q6, barwidth(0.0001) color(navy)) ///
	(rbar upper_experimental_la_q6 lower_experimental_la_q6 experimental_la_q6, barwidth(0.0001) color(navy)) ///
	(rbar upper_experimental_sd_q6 lower_experimental_sd_q6 experimental_sd_q6, barwidth(0.0001) color(navy)) ///
	(rbar upper_experimental_al_q6 lower_experimental_al_q6 experimental_al_q6, barwidth(0.0001) color(navy)) ///
	, ///
	ytitle("Six-Quarter Surrogate Index Estimate of" "Treatment Effect on Mean Quarterly Earnings($)") ///
    xtitle("Actual Treatment Effect on" "Mean Quarterly Earnings ($) Over 36 Quarters") ///
    legend(order() off ring(0) position(5) cols(1)) ///
	text(-99 -50 "45° Line", color(gray)) ///
	xlabel(-100 (100) 350) ///
	ylabel(-100 (100) 350, nogrid) ///
	yscale( range(-50 350)) ///
	xscale( range(-50 350))
	
* Export graph 
graph export "${output}/Figure 6B.${extension}", replace