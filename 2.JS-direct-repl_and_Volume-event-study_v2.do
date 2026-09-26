* CONTENTS - APPENDIX RESULTS
* A1  Table C1: data preparation, event windows and market-model estimation.
* A2  Table C1: daily mean/median ARs and % negative (days 0-10).
* A3  Table C1: daily sign-test and Wilcoxon statistics.
* A4  Table C1: CAR summaries, sign-test and Wilcoxon statistics.
* A5  Table C1: Brown-Warner CDA statistics for ARs and CARs.
* B1  Table G1: abnormal-volume preparation and rank statistic.
* B2  Table G1: display Rank Z by event day (days 0-10).
*
* Table C1 contains CAR windows [0,1], [0,5], [6,10] and [0,10].
* References to Jacobs and Singhal's Table 4 refer to their paper, not
* Table 4 of the present manuscript. These results belong to Appendix C.
* Section B supplies Appendix G, Table G1, and builds on stockdata_JS.dta
* created in section A, merging the prepared volumes_only.dta dataset.
* Results are copied manually; this script does not export formatted tables.
* The original paths, commands, samples and estimation settings are retained.


* ==========================================================================
* A1. APPENDIX TABLE C1 - DIRECT REPLICATION OF JACOBS AND SINGHAL
* Prepare data and estimate firm-level market models for the 39 firms.
* Event time follows each market's trading days in this direct replication.
* ==========================================================================
///////////////////////////////////////////////////////////////////////////
/// A. Appendix Table C1: direct replication of Jacobs and Singhal (2017)
////// Results reported in Appendix C, Table C1.
///////////////////////////////////////////////////////////////////////////

** This script replicates Jacobs and Singhal (2017) directly, and as faithfully as possible. It creates a set of results that will be directly compared to their Table 4, Panel A (unadjusted sa) **

** The script is heavily based on Princeton's online event study manual: "Event Study with Stata: A Step-by-Step Guide" available at: https://libguides.princeton.edu/c.php?g=1283406&p=9420882#s-lg-box-wrapper-35186858. We strongly advice the user to familiarise themeselves with it **

** This script assumes the existence of the two retrusn datafiles, described in the 1st do-file and in the readme document.

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta"

drop if JS!=1 // To keep only JS sample
save "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\eventdates_JS.dta", replace
rename date event_date // we will need this later
save "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\eventdates_JS.dta", replace

sort Security_ID
by Security_ID: gen eventcount=_N
tab eventcount // to verify that it's one event per company

* The script requires a separate file with an event count by company (in our case it is 1)
by Security_ID: keep if _n==1
sort Security_ID
keep Security_ID eventcount
save eventcount, replace

* Unlike eventstudy2, this script needs only one returns dataset where the market return is a separate column. To create this we can merge our two datasets. To simplify, we only keep the MKT return, the Country_ID and date
use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\market_returns.dta"
keep MKT Country_ID date
save "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\MKT_JS.dta", replace

* merge:
use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\security_returns2.dta"
merge m:1 Country_ID date using "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\MKT_JS.dta"
 drop if _merge==2  // these are values of market returns for dates outside our timeframe
drop _merge
save "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\stockdata_JS.dta", replace

* Then merge the eventcount dataset and keep only the observations that relate to the 39 firms of JS
sort Security_ID
merge m:1 Security_ID using eventcount
tab _merge
keep if _merge==3
drop _merge

drop eventcount
sort Security_ID date
save "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\stockdata_JS.dta", replace

* now we merge the eventdates_JS info
merge m:1 Security_ID using eventdates_JS
tab _merge  // all matched
drop _merge

* now mark the days. but to align trading days across countries and be in line with JS we should delete the observations where MKT is missing, i.e., the holidays.
drop if MKT==.
sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td
* in effect now dif marks the trading day before/after 24th April, aligning trading days across countries

* now mark estimation and event windows and minimum observations
by Security_ID: gen event_window=1 if dif>=0 & dif<=10
egen count_event_obs=count(event_window), by(Security_ID)
by Security_ID: gen estimation_window=1 if dif>-210 & dif<=-11
egen count_est_obs=count(estimation_window), by(Security_ID)
replace event_window=0 if event_window==.
replace estimation_window=0 if estimation_window==.

tab Security_ID if count_event_obs<11
tab Security_ID if count_est_obs<40 // making sure that all companies have an 11 day event window and all have at least 40 observations in the estimation window
drop count_event_obs count_est_obs

* and now estimating 'normal' performance using the market model
gen predicted_return=.
egen id=group(Security_ID)
/* for multiple event dates, use: egen id = group(group_id) */
forvalues i=1(1)39{
     l id Security_ID if id==`i' & dif==0
       reg ret MKT if id==`i' & estimation_window==1
       predict p if id==`i'
       replace predicted_return = p if id==`i' & event_window==1
       drop p
   } 

* Table C1: construct ARs and the four reported CAR windows.
 * calculate ARs and CARs
 sort id date
gen abnormal_return=ret-predicted_return if event_window==1

* gen the CARs of JS
by id: egen CAR_0_10 = sum(abnormal_return) 
by id: egen CAR_0_1 = sum(abnormal_return) if dif==0 | dif==1
by id: egen CAR_0_5 = sum(abnormal_return) if dif>=0 & dif<=5
by id: egen CAR_6_10 = sum(abnormal_return) if dif>=6 & dif<=10
* for easier display later on we can replace all missing obs for the 3 latter CARs   

bys Security_ID: egen tmp = max( CAR_0_1 )
replace CAR_0_1  = tmp if missing(CAR_0_1 ) & tmp < .
drop tmp
bys Security_ID: egen tmp = max( CAR_0_5 )
replace CAR_0_5  = tmp if missing(CAR_0_5 ) & tmp < .
drop tmp
bys Security_ID: egen tmp = max( CAR_6_10 )
replace CAR_6_10  = tmp if missing(CAR_6_10) & tmp < .
drop tmp


* ==========================================================================
* A2. TABLE C1 - DAILY MEANS, MEDIANS AND % NEGATIVE
* Rows for event days 0-10; returns are stored as fractions.
* ==========================================================================
* get AARs, medians and % for each day
tabstat abnormal_return if dif>-1 & dif<11, by(dif) stats(p50 mean) columns(statistics)
gen negAR = abnormal_return<0 if !missing(abnormal_return)
tabstat negAR if dif>-1 & dif<11, by(dif) stats(mean)


* ==========================================================================
* A3. TABLE C1 - DAILY SIGN AND WILCOXON TESTS
* The first loop displays sign-test z statistics and two-sided p-values.
* The second loop displays Wilcoxon z statistics and p-values.
* ==========================================================================
* signtest: one can easily establish that JS have reported a z-statistic based on the normal approximation to the binomial sign test. We can do this for all event window days and display:

forvalues d = 0/10 {

    quietly count if abnormal_return>0 & dif==`d'
    local pos = r(N)

    quietly count if abnormal_return<0 & dif==`d'
    local neg = r(N)

    local N = `pos' + `neg'

    if `N' > 0 {

        local z = (`pos' - `N'/2) / sqrt(`N'/4)
        local p = 2*normal(-abs(`z'))

        display %3.0f `d' "     " ///
                %3.0f `N' "     " ///
                %9.4f `z' "     " ///
                %8.4f `p'
    }
}

* For wilcoxon test it is easier
forvalues d = 0/10 {

    quietly signrank abnormal_return = 0 if dif==`d'

    if r(N) > 0 {
        display %3.0f `d' "     " ///
                %3.0f r(N) "     " ///
                %9.4f r(z) "     " ///
                %8.4f r(p)
    }
}



* ==========================================================================
* A4. TABLE C1 - CAR SUMMARIES AND NONPARAMETRIC TESTS
* Windows: [0,1], [0,5], [6,10] and [0,10].
* Displayed order: window, N, fraction negative, median, mean,
* sign-test z, sign-test p-value, Wilcoxon z.
* ==========================================================================
* now we need signtests and Wilcoxon tests for the CARs

local myvars CAR_0_1 CAR_0_5 CAR_6_10 CAR_0_10

foreach v of local myvars {

    quietly count if `v'>0 & dif==0
    local pos = r(N)

    quietly count if `v'<0 & dif==0
    local neg = r(N)

    local N = `pos' + `neg'
	local L = `neg' / `N'

	quietly summarize `v' if dif==0, detail
    local med = r(p50)
	local mn = r(mean)
	
	quietly signrank `v'=0 if dif==0
	local G =r(z)
	
    if `N' > 0 {

        local z = (`pos' - `N'/2) / sqrt(`N'/4)
        local p = 2*normal(-abs(`z'))

        display "`v'   " ///
                %3.0f `N' "     " ///
                %9.4f `L' "     " ///
				%9.4f `med' "    " ///
				%9.4f `mn' "    " ///
				%9.4f `z' "     " ///
                %8.4f `p' "     " ///
				%9.4f `G'
    }
}


* ==========================================================================
* A5. TABLE C1 - BROWN-WARNER CDA TEST
* Compute daily CDA statistics using the estimation-window variability.
* The original hard-coded CAR calculations below are retained as examples.
* ==========================================================================
* Finally we have to calculate the Brown and Warner 1985 CDA stats.
* For these we need to calculate ARs over the estimation window too. 
* We thus need to first estimate the predicted return and then calculate the AR
* we just need to adjust slightly the script from earlier

forvalues i=1(1)39{
     l id Security_ID if id==`i' & dif==0
       reg ret MKT if id==`i' & estimation_window==1
       predict p if id==`i'
       replace predicted_return = p if id==`i' & estimation_window==1
       drop p
   } 

replace abnormal_return=ret-predicted_return if estimation_window==1

* for the denominator we need the std over the estimation window
 
bysort dif: egen AAR = mean(abnormal_return)
bys dif: gen tag = _n==1

summarize AAR if estimation_window==1 & tag
local sdAAR = r(sd)
gen bw_t = AAR/`sdAAR' if event_window==1 // this is the CDA t-stat for every event day

list dif AAR bw_t if event_window==1 & tag, sep(0) // and copy the stats to excel

* Table C1 CAR CDA: original examples for [0,10] and [0,1];
* the [0,5] and [6,10] calculations are not automated here.
* For the cumulative ones, it is easy to get them manually, dividing each CAAR with the std tiems the sqrt of the number of days, e.g.:
di .0130225 / (.0040509 *sqrt(11)) // CAR_0_10
di .0034451  / (.0040509 *sqrt(2)) // CAR_0_1 

save "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\stockdata_JS.dta", replace


* ==========================================================================
* B1. APPENDIX TABLE G1 - ABNORMAL-VOLUME EVENT STUDY
* Uses stockdata_JS.dta from section A and volumes_only.dta.
* The rank-based Z statistic supplies the Rank Z column of Table G1.
* ==========================================================================
////////////////////////////////////////////////////////////////////////////
/////// B. Appendix Table G1: abnormal-volume event study
////////////////////////////////////////////////////////////////////////////

* The log-transformed relative volumes for each security have been calculated elsehwere, following Campbell and Wasley (1996), and are in a Stata data file that we call "volumes_only"
  
use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\stockdata_JS.dta"
merge 1:1 Security_ID date using "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\volumes_only.dta"
drop if _merge==2
drop _merge

* for convenience we only keep estimation window and event window observations
keep if estimation_window==1 | event_window==1

* generate ranks and number of total non-missing observations 
bys Security_ID (date): egen rank = rank(log_rel_vol)
bys Security_ID: egen T = count(rank)

* compute expected rank and rank deviations
gen exp_rank = (T + 1)/2
gen rd = rank - exp_rank

* calculate the cross-sectional average by day
bys dif: egen A_t = mean(rd)

* mark one obs per day
drop tag
bys dif: gen tag = _n==1 

* estimate the time-series standard deviation of the day-average over the estimation window
quietly summarize A_t if estimation_window==1 & tag
gen sdA = r(sd)

* so then the corrado Z-stat is simply the following. it is unit normal as the number of securities increases
gen corrado_z = A_t / sdA


* ==========================================================================
* B2. TABLE G1 - DISPLAY RESULTS FOR DAYS 0-10
* The list command displays event day and Rank Z.
* Table G1 also reports N=39; this list does not print an N column.
* ==========================================================================
* to then tabulated by event date:
list dif corrado_z if event_window==1 & tag, sep(0)

/* Can save this file if desired for further processing, but it only has the estimation and event window observations */

* Campbell, CJ. and Wasley, CE. 'Measuring abnormal daily trading volume for samples of NYSE/ASE and NASDAQ securities using parametric and nonparametric test statistics'. Review of Quantitative Finance and Accounting, 6.3 (1996): 309-326 
