* CONTENTS - MANUSCRIPT AND APPENDIX RESULTS
* A1  Table 3, Panel A: early signatories, unadjusted sample (JS1).
* A2  Table 3, Panel B: early signatories, adjusted sample (JSadj).
* B1  Table 4, Panel A: night returns (JSnight).
* B2  Table 4, Panel B: day returns (JSday).
* C   Appendix Table D1: Carhart four-factor model (FF).
* D1  Table 5: firms sourcing from Rana Plaza (RP).
* D2  Table 6: firm-level daily ARs and formatting thresholds.
* E1  Table 7: Bangladesh-sourcing firms (BGL).
* E2  Additional non-Bangladesh-sourcing event study (noBGL).
* F   Table 8: pooled analysis of previous factory disasters (H4).
* G   Appendix F preparation: outcomes for all 121 firms (ALL).
* H   Appendix E discussion: separate analyses of the four earlier events.
*
* Results are assembled manually from the output files; this script does
* not export formatted manuscript tables. Tables 1 and 2 are descriptive
* tables compiled separately. Appendix Tables F1/F2 are compiled based on estimations described in the separate Appendix_F1_F2_reproduction.do file in 3.Appendix_F1_F2.

*
* OUTPUT GUIDE FOR EACH eventstudy2 PREFIX LISTED ABOVE
* *_aabn_ret_file.dta: daily mean AR, N, test statistics and p-values.
* *_cum_average_abn_ret_file.dta: mean CAR, N, statistics and p-values.
* *_abn_ret_file.dta: firm-level daily ARs for medians and % negative.
* *_cross_sec_file.dta: firm-level CARs for medians and % negative.
* B-M-P = Boehmer; Kol-Py = Kolari; GenSign = GenSign; Cor-Zi = Zivney
* (Zivney_Cowan for CARs). P-prefixed fields contain the p-values.


** ---------------- ** 
/// General notes //

/* 1. We use the eventstudy2 user-written programme to run all event studies, apart from the 'direct replication' of Jacobs and Singhal (2017), reported in Appendix C (Table C1) of the Supplementary material. The respective file is in a different do-file. We strongly advice the user to become familiar with the programme and understand the structure of the eventstudy2 command that is used routinely here*/

/* 2. By default, each run of eventstudy2 produces several output files. For each analysis, i.e., each hypothesis test, the information that needs to be reported (e.g., ARs, CARs, test statistics, p-values) is spread across those files. In addition, the median and % negatives that are reported in every table in the manuscript need to be calculated manually post-hoc, using one or more of those output files. These files are saved on the working directory, and we assume that the user can access those files manually and extract the necessary information. */

/* 3. Our preferred approach was to copy all analysis results, in turn, to an Excel file, format the tables as desired, and paste them to our manuscript. The extraction of the information and tabulation of information is something that can be automated potentially, but we do not puruse this here */


** ---------------- **
/// Important Caveats regarding Public holidays / non-trading days, and implications for CAR construction ///

 *1. Because we are focussing on calendar days - as discussed in the paper - security returns on a non-trading day (i.e., when Volume is missing) have been set to zero in the security_returns2 dataset, to retain the security-date observation. The user must do the same in their security_returns dataset, after downloading the price data (see readme.doc file). Market returns on those days remain missing, so no abnormal returns are calculated on those days (e.g., on Day 5 - May 1st 2013 - for European firms, since it was a stock-market public holiday).
 
 *2 Eventstudy2 produces correct average ARs and test statistics, and for each calendar day in the event window it considers only those firms whose securities were traded. So, on Day 5 of the main analysis for example (A.1), there are only 29 ARs, because European firms are excluded due to May 1st 2013 (Day 5) being a public holiday.
 
 *3 When it comes to the [0,10] CARs, the missing ARs are 'skipped' in the CAR calculation, effectively considered zeros. eventstudy2 deals with these efficiently when it comes to the derivation of the test statistics, employing an algorithm to deal with missingness using trade-to-trade returns based on Maynes and Rumsey (1992) (see eventstudy2 documentation and the respective Stata Journal paper).
 
 ** Note 1: Although we do not report [0,5] and [0,6] in the paper, or any other CAR that ends on intermediate dates (since they do not provide useful insight) this script produces several of these CARs. We note that eventstudy2 is unable to calculate CARs for firms that have a missing AR on the boundary of the window. For example, in the Baseline analysis (A.1) you will notice that for the [0,5] CAR, because most European markets were closed on Day 5, these firms do not have a CAR. They thus do not contribute to the cross-sectional analysis and not considered for the derivation of test statistics. This appears to be a deliberate design feature of the programme (see the eventstudy.ado file), and we believe that it is a consequence of our decision to produce ARs/CARs for calendar (as opposed to trading days), and the return-generation process assumptions of the algorithm employed in eventstudy2 based on Maynes and Rumsey (1992).
 
** Note 2: It is not imperimissible to use the 'arfillevnt' option, which fills missing ARs with zeros. However, the author of the programme cautions against this, since it efficitvely assumes that, for example, there was trading on Day 5 for European firms and all their returns were zero, even though there was no trading in reality. Even though all CARs for all firms and across all windows will be the same (due to adding a zero), the test statistics will be slightly different. The substantive results will not change, but we believe that this approach is less preferable for inference with regard to CARs (and definitely misleading when it comes to individual day mean and median ARs).

** Note 3: If one wants to implement the above, in each of the commands below, one can add the 'arfillevnt' after the 'replace' option. Only CARs should be considered in that case - the test statistics for individual day ARs will be misleading for the days with 'true' missings ARs (like Day 5)

** ------------------ **


** Make sure you set your working directory to be the one you have all the datasets:
cd "C:..."

// The Repl_eventdates_RP.dta file contains the firms, event dates and all variables of interest. All 'eventstudy2' commands need to be run when this file is open:

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta.dta"


* ==========================================================================
* A1. TABLE 3, PANEL A - UNADJUSTED EARLY-SIGNATORY SAMPLE
* Daily rows: days 0-10. CAR rows: CAR1=[0,1], CAR4=[0,10].
* Output prefix: JS1. CAR2 and CAR3 are additional, unreported windows.
* ==========================================================================
/////////////////////////////////////////////////////////////////////////////
/// A1. Table 3, Panel A: market model, close-to-close returns
/////////////////////////////////////////////////////////////////////////////

 * Note: Variable JSyes is an indicator of being in the Jacobs & Singhal 
 * sample size: N=39
 
eventstudy2 Security_ID date using security_returns2 if JSyes==1, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(0) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(JS1_aabn_ret_file) carfile(JS1_cum_average_abn_ret_file) arfile(JS1_abn_ret_file) crossfile(JS1_cross_sec_file) diagnosticsfile(JS1_diag_file) graphfile(JS1_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(5) car3lb(6) car3ub(10) car4lb(0) car4ub(10)

* Table 3A: daily medians and % negative from firm-level ARs.
 * to get medians % negatives of daily ARs we can use the file that saves timeseries of ARs for each company:
use JS1_abn_ret_file, clear

 * We create a variable 'dif' that is 0 on the day of the event (24/4/13). We can then use dif to get the summary stats for AR for Day 0 to Day 10
sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==original_event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td

* to get the medians
tabstat AR if dif>-1 & dif<11, by(dif) stats(p50 n) columns(statistics)

* to get % negatives
gen negAR = AR<0 if !missing(AR)
tabstat negAR if dif>-1 & dif<11, by(dif) stats(mean)

save "JS1_abn_ret_file.dta", replace

* Table 3A: daily N, mean, test statistics and p-values.
* another of output files includes all test statistics for all single days 0-10. We open it and manually copy and paste the required statistics to an excel file with all results
use JS1_aabn_ret_file, clear

* Table 3A: CAR N, mean, test statistics and p-values.
* similarly, from another output file we extract the test statistics relating to the four CARs
use JS1_cum_average_abn_ret_file, clear

* Table 3A: CAR medians and % negative; report CAR1 and CAR4.
 * the only thing missing is the medians and % negatives of CARs. We can extract them using the last output file:
 use JS1_cross_sec_file, clear
 
 foreach v of varlist CAR1-CAR4 {

    quietly count if `v' < 0
    local neg = r(N)

    quietly count if !missing(`v')
    local total = r(N)

    quietly summarize `v', detail
    local med = r(p50)

    display "`v'      " ///
        %9.2f (100*`neg'/`total') "      " ///
        %9.4f `med' "      " ///
		%9.2f `total'
}



* ==========================================================================
* A2. TABLE 3, PANEL B - ADJUSTED EARLY-SIGNATORY SAMPLE
* Daily rows: days 0-7. CAR rows: CAR1=[0,1], CAR4=[0,7].
* Output prefix: JSadj. CAR2 and CAR3 are additional windows.
* ==========================================================================
/////////////////////////////////////////////////////////////////////////////
/// A2. Table 3, Panel B: adjusted sample, days 0-7
/////////////////////////////////////////////////////////////////////////////

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta.dta"
 
* Note: FREYes is an indicator for whether there is a financially relevant event between 23rd of April and 1st of May
eventstudy2 Security_ID date using security_returns2 if JSyes==1 & FREYes==0, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(0) evwub(7) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(JSadj_aabn_ret_file) carfile(JSadj_cum_average_abn_ret_file) arfile(JSadj_abn_ret_file) crossfile(JSadj_cross_sec_file) diagnosticsfile(JSadj_diag_file) graphfile(JSadj_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(2) car3lb(0) car3ub(5) car4lb(0) car4ub(7)

* Table 3B: daily and CAR N, means, test statistics and p-values.
* we then extract the required test statistics and corresponding p-values from the two output files
use JSadj_aabn_ret_file, clear
use JSadj_cum_average_abn_ret_file, clear

* Table 3B: CAR medians and % negative; report CAR1 and CAR4.
* to extract the medians and % negatives of CARs:
use JSadj_cross_sec_file, clear

foreach v of varlist CAR1-CAR4 {

    quietly count if `v' < 0
    local neg = r(N)

    quietly count if !missing(`v')
    local total = r(N)

    quietly summarize `v', detail
    local med = r(p50)

    display "`v'      " ///
        %9.2f (100*`neg'/`total') "      " ///
        %9.4f `med' "      " ///
		%9.2f `total'
}

* Table 3B: daily medians and % negative.
* to extract the medians and % negatives for the daily ARs:
use JSadj_abn_ret_file, clear

sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==original_event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td

tabstat AR if dif>-1 & dif<8, by(dif) stats(p50 n) columns(statistics)

gen negAR = AR<0 if !missing(AR)
tabstat negAR if dif>-1 & dif<8, by(dif) stats(mean n)

save "JSadj_abn_ret_file.dta", replace


* ==========================================================================
* B1. TABLE 4, PANEL A - NIGHT RETURNS
* Daily rows: days 0-10. CAR rows: CAR1=[0,1], CAR4=[0,10].
* Output prefix: JSnight. Sample excludes Esprit and Kmart.
* ==========================================================================
/////////////////////////////////////////////////////////////////////////////
/// B1. Table 4, Panel A: night returns for early signatories
/////////////////////////////////////////////////////////////////////////////

* Day_ret, Night_ret are the day (open-to-close) and night (close-to-open) returns in the security_returns file, respectively.

* we distinguish between firms in markets that were open at the time of the disaster and those that were closed, with the indicator 'Market_open' in the eventdates file.
* There are only 2 firms in the J&S sample whose securities were traded in markets that were open. These must be excluded from this analysis.
* We investigate the day and night ARs for the firms whose securities are traded in markets that were closed at the moment of the disaster, i.e., the European and North American firms.
* As benchmark, we have used the close-to-close return of the market index. One could use the 'night' and 'day' market index returns (variable names being MKT_Night and MKT_Day respectively in the marketreturns file). The changes in the results are small and do not change the qualitative insight. Our choice is driven by convinience and due to the fact that the fraction pf missing values is lower for the standard close-to-close market return.

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta.dta", clear

eventstudy2 Security_ID date using security_returns2 if JSyes==1 & Market_open==0, returns(Night_ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(0) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(JSnight_aabn_ret_file) carfile(JSnight_cum_average_abn_ret_file) arfile(JSnight_abn_ret_file) crossfile(JSnight_cross_sec_file) diagnosticsfile(JSnight_diag_file) graphfile(JSnight_graph_file) replace  car1lb(0) car1ub(1) car2lb(0) car2ub(5) car3lb(6) car3ub(10) car4lb(0) car4ub(10)

* Table 4A: daily and CAR N, means, test statistics and p-values.
* get ARs and respective statistics from:
use JSnight_aabn_ret_file, clear
* and CARs and respective statistics from:
use JSnight_cum_average_abn_ret_file, clear

* Table 4A: daily medians and % negative.
* get medians and % negatives from
use JSnight_abn_ret_file, clear

sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==original_event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td

tabstat AR if dif>-1 & dif<11 & !missing(AR), by(dif) stats(mean p50 n) columns(statistics)

gen negAR = AR<0 if !missing(AR)
tabstat negAR if dif>-1 & dif<11, by(dif) stats(mean n)

* Table 4A: CAR medians and % negative; report CAR1 and CAR4.
* and CAR medians and % negatives
use JSnight_cross_sec_file, clear

foreach v of varlist CAR1-CAR4 {

    quietly count if `v' < 0
    local neg = r(N)

    quietly count if !missing(`v')
    local total = r(N)

    quietly summarize `v', detail
    local med = r(p50)

    display "`v'      " ///
        %9.2f (100*`neg'/`total') "      " ///
        %9.4f `med' "      " ///
		%9.2f `total'
}


* ==========================================================================
* B2. TABLE 4, PANEL B - DAY RETURNS
* Daily rows: days 0-10. CAR rows: CAR1=[0,1], CAR4=[0,10].
* Output prefix: JSday. Sample excludes Esprit and Kmart.
* ==========================================================================
*** For Day returns

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta.dta", clear

eventstudy2 Security_ID date using security_returns2 if JSyes==1 & Market_open==0, returns(Day_ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(0) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(JSday_aabn_ret_file) carfile(JSday_cum_average_abn_ret_file) arfile(JSday_abn_ret_file) crossfile(JSday_cross_sec_file) diagnosticsfile(JSday_diag_file) graphfile(JSday_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(5) car3lb(6) car3ub(10) car4lb(0) car4ub(10)

* Table 4B: daily and CAR N, means, test statistics and p-values.
* get ARs and respective statistics from:
use JSday_aabn_ret_file, clear
* and CARs and respective statistics from:
use JSday_cum_average_abn_ret_file, clear

* Table 4B: daily medians and % negative.
* get medians and % negatives from
use JSday_abn_ret_file, clear

sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==original_event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td

tabstat AR if dif>-1 & dif<11, by(dif) stats(p50 n) columns(statistics)

gen negAR = AR<0 if !missing(AR)
tabstat negAR if dif>-1 & dif<11, by(dif) stats(mean)

* Table 4B: CAR medians and % negative; report CAR1 and CAR4.
* and CAR medians and % negatives
use JSday_cross_sec_file, clear

foreach v of varlist CAR1-CAR4 {

    quietly count if `v' < 0
    local neg = r(N)

    quietly count if !missing(`v')
    local total = r(N)

    quietly summarize `v', detail
    local med = r(p50)

    display "`v'      " ///
        %9.2f (100*`neg'/`total') "      " ///
        %9.4f `med'
}



* ==========================================================================
* C. APPENDIX TABLE D1 - CARHART FOUR-FACTOR MODEL
* Daily rows: days 0-10. CAR rows: CAR1=[0,1], CAR4=[0,10].
* Output prefix: FF; intermediate windows are not reported in Table D1.
* ==========================================================================
///////////////////////////////////////////////////////////////////////////////
/// C. Appendix Table D1: Carhart four-factor expected returns
///////////////////////////////////////////////////////////////////////////////

* Note that this is a robustness check (i.e., alternative model for expected returns) and is reported in Appendix D.
* We run the event study using Carhart's (1997) four-factor model to estimate expected returns, which augments the market model with the size (small-minus-big, SMB), value (high-minus-low, HML), and momentum (MOM) factors. 

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta.dta", clear


eventstudy2 Security_ID date using security_returns2 if JSyes==1, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) factor1(SMB) factor2(HML) factor3(MOM) riskfreerate(rf) idmarket(Country_ID) evwlb(0) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(FF_aabn_ret_file) carfile(FF_cum_average_abn_ret_file) arfile(FF_abn_ret_file) crossfile(FF_cross_sec_file) diagnosticsfile(FF_diag_file) graphfile(FF_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(5) car3lb(6) car3ub(10) car4lb(0) car4ub(10)
 
* Table D1: daily and CAR N, means, test statistics and p-values.
 * to get AARs and CAARs and related statistics:
 use FF_aabn_ret_file, clear
 use FF_cum_average_abn_ret_file, clear

* Table D1: daily medians and % negative.
 * get medians and % negatives from
use FF_abn_ret_file, clear

sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==original_event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td

tabstat AR if dif>-1 & dif<11, by(dif) stats(p50 n) columns(statistics)

gen negAR = AR<0 if !missing(AR)
tabstat negAR if dif>-1 & dif<11, by(dif) stats(mean)

* Table D1: CAR medians and % negative; report CAR1 and CAR4.
* and CAR medians and % negatives
use FF_cross_sec_file, clear

foreach v of varlist CAR1-CAR4 {

    quietly count if `v' < 0
    local neg = r(N)

    quietly count if !missing(`v')
    local total = r(N)

    quietly summarize `v', detail
    local med = r(p50)

    display "`v'      " ///
        %9.2f (100*`neg'/`total') "      " ///
        %9.4f `med'
}

 

* ==========================================================================
* D1. TABLE 5 - FIRMS SOURCING FROM RANA PLAZA
* Daily rows: days 0-10. CAR rows: CAR1=[0,1], CAR4=[0,10].
* Output prefix: RP. The firm-level ARs also supply Table 6.
* ==========================================================================
/////////////////////////////////////////////////////////////////////////////
/// D1. Table 5: testing H2 for firms sourcing from Rana Plaza
/////////////////////////////////////////////////////////////////////////////

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta.dta", clear


* DefactoRP is an indicator for having been sourcing from Rana Plaza.
eventstudy2 Security_ID date using security_returns2 if DefactoRP==1, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(0) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(RP_aabn_ret_file) carfile(RP_cum_average_abn_ret_file) arfile(RP_abn_ret_file) crossfile(RP_cross_sec_file) diagnosticsfile(RP_diag_file) graphfile(RP_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(5) car3lb(6) car3ub(10) car4lb(0) car4ub(10)

* Table 5: daily and CAR N, means, test statistics and p-values.
* we extract ARs and respective test stats from:
use RP_aabn_ret_file, clear
* and CARs and respective test stats from:
use RP_cum_average_abn_ret_file, clear

* Table 5: CAR medians and % negative; report CAR1 and CAR4.
* CAR medians and % negatives from:

use RP_cross_sec_file, clear
 foreach v of varlist CAR1-CAR4 {

    quietly count if `v' < 0
    local neg = r(N)

    quietly count if !missing(`v')
    local total = r(N)

    quietly summarize `v', detail
    local med = r(p50)

    display "`v'      " ///
        %9.2f (100*`neg'/`total') "      " ///
        %9.4f `med' "      " ///
		%9.2f `total'

}


* Table 5: daily medians and % negative; save ARs for Table 6.
* finally the medians and % negatives of daily ARs
use RP_abn_ret_file, clear

sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==original_event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td

tabstat AR if dif>-1 & dif<11, by(dif) stats(p50 n) columns(statistics)

gen negAR = AR<0 if !missing(AR)
tabstat negAR if dif>-1 & dif<11, by(dif) stats(mean n)

save "RP_abn_ret_file.dta", replace


* ==========================================================================
* D2. TABLE 6 - DAILY ARs FOR INDIVIDUAL RANA PLAZA FIRMS
* Extract each firm's AR for days 0-10 from RP_abn_ret_file.dta.
* The following JS1 comparison supplies the bold/italic thresholds.
* ==========================================================================
* for the in-depth analysis we extract the AR for each firm day-by-day (0,10)
preserve
keep if dif>=0 & dif<=10
keep Firm_name dif AR
sort Firm_name dif
* copy paste manually the ARs
restore

* Table 6 formatting: bold above mean+SD; italic below mean-SD,
* using the early-signatory cross-section for the corresponding day.
* now we can compare these values with the daily cross-section from H1
* we load the file with the daily ARs testing H1, and calculate meaningful thresholds : mean + or - 1sd 

use JS1_abn_ret_file, clear

forvalues d = 0/10 {

    quietly summarize AR if dif==`d'

    if r(N)>0 {
        display %3.0f `d' "      " ///
                %10.4f (r(mean)-r(sd)) "      " ///
                %10.4f (r(mean)+r(sd))
    }
}

* The values we are comparing daily ARs of the 8 firms are the following:

*  Day        AAR - sd       AAR + sd
//  0         -0.0189          0.0147
//  1         -0.0114          0.0230
//  2         -0.0187          0.0237
//  3         -0.0177          0.0138
//  4         -0.0149          0.0185
//  5         -0.0168          0.0149
//  6         -0.0151          0.0160
//  7         -0.0084          0.0170
//  8         -0.0178          0.0053
//  9         -0.0101          0.0226
// 10         -0.0207          0.0225



* ==========================================================================
* E1. TABLE 7 - BANGLADESH-SOURCING FIRMS
* Daily rows: days -5 to 10. CAR rows: CAR1=[0,1], CAR5=[0,10].
* Output prefix: BGL. Note that [0,10] is CAR5 in this block.
* ==========================================================================
//////////////////////////////////////////////////////////////////////////////
/// E1. Table 7: testing H3 for Bangladesh-sourcing firms
//////////////////////////////////////////////////////////////////////////////

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\eventdates_RP_updated.dta"

* DefactoBGL is an indicator for whether the firm was sourcing from BGL

eventstudy2 Security_ID date using security_returns2 if DefactoBGL==1, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(-5) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(BGL_aabn_ret_file) carfile(BGL_cum_average_abn_ret_file) arfile(BGL_abn_ret_file) crossfile(BGL_cross_sec_file) diagnosticsfile(BGL_diag_file) graphfile(BGL_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(5) car3lb(6) car3ub(10) car4lb(0) car4ub(7) car5lb(0) car5ub(10) 

* Table 7: daily medians and % negative.
* to get medians and % negatives for ARs
use BGL_abn_ret_file, clear

sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==original_event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td

tabstat AR if dif>-6 & dif<11, by(dif) stats(p50 n) columns(statistics)

gen negAR = AR<0 if !missing(AR)
tabstat negAR if dif>-6 & dif<11, by(dif) stats(mean)

* Table 7: daily and CAR N, means, test statistics and p-values.
* extract ARs and stats from:
use BGL_aabn_ret_file, clear

* same for CARs
use BGL_cum_average_abn_ret_file, clear

* Table 7: CAR medians and % negative; report CAR1 and CAR5.
* CAR medians and % negatives from:

use BGL_cross_sec_file, clear


 foreach v of varlist CAR1-CAR5 {

    quietly count if `v' < 0
    local neg = r(N)

    quietly count if !missing(`v')
    local total = r(N)

    quietly summarize `v', detail
    local med = r(p50)

    display "`v'      " ///
        %9.2f (100*`neg'/`total') "      " ///
        %9.4f `med'
}



* ==========================================================================
* E2. ADDITIONAL NON-BANGLADESH-SOURCING EVENT STUDY
* Output prefix: noBGL. This block is not part of main Table 7.
* Appendix F reports a sourcing-status comparison; its dedicated analysis
* uses the ALL outcomes prepared in section G, not this block.
* ==========================================================================
* Additional event study for firms without identified Bangladesh sourcing.
eventstudy2 Security_ID date using security_returns2 if DefactoBGL==0, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(-5) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(noBGL_aabn_ret_file) carfile(noBGL_cum_average_abn_ret_file) arfile(noBGL_abn_ret_file) crossfile(noBGL_cross_sec_file) diagnosticsfile(noBGL_diag_file) graphfile(noBGL_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(5) car3lb(6) car3ub(10) car4lb(0) car4ub(10)
* This additional block is not a separate main-manuscript table.


* ==========================================================================
* F. TABLE 8 - PREVIOUS FACTORY DISASTERS POOLED
* Reported daily rows: days -1 to 5. CAR1=[0,1] and CAR3=[0,5].
* Output prefix: H4. The command also calculates longer/unreported windows.
* ==========================================================================
///////////////////////////////////////////////////////////////////////////////
// F. Table 8: testing H4 for previous factory disasters
///////////////////////////////////////////////////////////////////////////////

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta.dta"

eventstudy2 Security_ID date using security_returns2 if Event_RP_1!=1, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(-1) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(H4_aabn_ret_file) carfile(H4_cum_average_abn_ret_file) arfile(H4_abn_ret_file) crossfile(H4_cross_sec_file) diagnosticsfile(H4_diag_file) graphfile(H4_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(2) car3lb(0) car3ub(5) car4lb(0) car4ub(10) 

* Table 8: daily and CAR N, means, test statistics and p-values.
* extract AARs, CARs and related test stats from:
use H4_aabn_ret_file, clear
use H4_cum_average_abn_ret_file, clear

* Table 8: daily medians and % negative for days -1 to 5.
* medians and % negatives for ARs
use H4_abn_ret_file, clear

sort Security_ID date
by Security_ID: gen datenum=_n
by Security_ID: gen target=datenum if date==original_event_date
egen td=min(target), by(Security_ID)
drop target
gen dif=datenum-td

tabstat AR if dif>-2 & dif<6, by(dif) stats(p50 n) columns(statistics)

gen negAR = AR<0 if !missing(AR)
tabstat negAR if dif>-2 & dif<6, by(dif) stats(mean)

save "H4_abn_ret_file.dta", replace

* Table 8: CAR medians and % negative; report CAR1 and CAR3.
* CAR medians and % negatives from:
use H4_cross_sec_file, clear

 foreach v of varlist CAR1-CAR3 {

    quietly count if `v' < 0
    local neg = r(N)

    quietly count if !missing(`v')
    local total = r(N)

    quietly summarize `v', detail
    local med = r(p50)

    display "`v'      " ///
        %9.2f (100*`neg'/`total') "      " ///
        %9.4f `med'
}


* ==========================================================================
* G. APPENDIX F PREPARATION - OUTCOMES FOR ALL FIRMS
* Output prefix: ALL. CAR1 is day-0 AR; CAR10 is CAR[0,10].
* This creates return outcomes for Table F1. It does not estimate Tables
* F1/F2 or construct their financial covariates. See the separate
* 3.Appendix_F1_F2_reproduction.do and prepared dataset.
* ==========================================================================
/////////////////////////////////////////////////////////////////////////
/// G. Appendix F preparation: event-study outcomes for all firms
//////////////////////////////////////////////////////////////////////////

* For convenience  we can run one event study for all firms to generate ARs/CARs qnd construct the dataset used for the matching. 
* With the command below, using Event_RP_1==1 to denote all firms 'relevant' to the Rana Plaza, we geneate ARs/CARs for all 121 firms, 64 of whcih were sourcing from Bangladesh
use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\Repl_eventdates_RP.dta.dta"

eventstudy2 Security_ID date using security_returns2 if Event_RP_1==1, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(0) evwub(10) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(ALL_aabn_ret_file) carfile(ALL_cum_average_abn_ret_file) arfile(ALL_abn_ret_file) crossfile(ALL_cross_sec_file) diagnosticsfile(ALL_diag_file) graphfile(ALL_graph_file) replace car1lb(0) car1ub(0) car2lb(1) car2ub(1) car3lb(2) car3ub(2) car4lb(3) car4ub(3) car5lb(4) car5ub(4) car6lb(5) car6ub(5) car7lb(0) car7ub(1) car8lb(0) car8ub(5) car9lb(6) car9ub(10) car10lb(0) car10ub(10)

* the file has ARs for Days 0-5 and all CARs of interest that will be the outcome variables on the basis of which we will compare the matched pairs.
use ALL_cross_sec_file, clear


* ==========================================================================
* H. APPENDIX E DISCUSSION - SEPARATE PREVIOUS EVENTS
* These commands support the separate-event results discussed in Appendix E.
* Table E1 itself lists event details; it is not generated by these commands.
* ==========================================================================
//////////////////////////////////////////////////////////////////////////
/// H. Appendix E discussion: separate event studies
//////////////////////////////////////////////////////////////////////////

* Separate event study for each disaster. These results are not reported in detail. Only headline results are reported in Appendix E of the Online Supplement.
* Event_RP_1 is the categorical variable capturing the event. '1' is Rana Plaza, 2-5 are the other 4 - see manuscript.

use "C:\Users\Tony\Dropbox\Rana-Plaza Replication\Data\eventdates_RP_updated.dta"


* Appendix E: event code 2; output prefix Ev2.
eventstudy2 Security_ID date using security_returns2 if Event_RP_1==2, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(-1) evwub(5) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(Ev2_aabn_ret_file) carfile(Ev2_cum_average_abn_ret_file) arfile(Ev2_abn_ret_file) crossfile(Ev2_cross_sec_file) diagnosticsfile(Ev2_diag_file) graphfile(Ev2_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(2) car3lb(0) car3ub(5)

* Appendix E: event code 3; output prefix Ev3.
eventstudy2 Security_ID date using security_returns2 if Event_RP_1==3, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(-1) evwub(5) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(Ev3_aabn_ret_file) carfile(Ev3_cum_average_abn_ret_file) arfile(Ev3_abn_ret_file) crossfile(Ev3_cross_sec_file) diagnosticsfile(Ev3_diag_file) graphfile(Ev3_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(2) car3lb(0) car3ub(5)

* Appendix E: event code 4; output prefix Ev4.
eventstudy2 Security_ID date using security_returns2 if Event_RP_1==4, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(-1) evwub(5) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(Ev4_aabn_ret_file) carfile(Ev4_cum_average_abn_ret_file) arfile(Ev4_abn_ret_file) crossfile(Ev4_cross_sec_file) diagnosticsfile(Ev4_diag_file) graphfile(Ev4_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(2) car3lb(0) car3ub(5)

* Appendix E: event code 5; output prefix Ev5.
eventstudy2 Security_ID date using security_returns2 if Event_RP_1==5, returns(ret) model(FM) marketfile(market_returns) marketreturns(MKT) idmarket(Country_ID) evwlb(-1) evwub(5) eswlb(-210) eswub(-11) minevw(0) minesw(40) aarfile(Ev5_aabn_ret_file) carfile(Ev5_cum_average_abn_ret_file) arfile(Ev5_abn_ret_file) crossfile(Ev5_cross_sec_file) diagnosticsfile(Ev5_diag_file) graphfile(Ev5_graph_file) replace car1lb(0) car1ub(1) car2lb(0) car2ub(2) car3lb(0) car3ub(5)
