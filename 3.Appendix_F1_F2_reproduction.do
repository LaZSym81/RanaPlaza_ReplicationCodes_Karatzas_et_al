
* This do-file reproduces the results shown in Tables F1 and F2 of the Appendix.
*
* The dataset was created by merging annual financial and other firm data
*  with ALL_cross_sec_file.dta, which contains
* the firm-level ARs and CARs calculated in the previously completed
* event-study analysis, together with the Bangladesh-sourcing indicator.
* The files were merged by Security_ID, linking each firm's annual records
* to its event-study results. Day-0 ARs and CARs over days [0,10] are the
* outcome variables in the regression and matching analyses below.
*
* Financial and other firm characteristics for 2010-2012 were retained to
* construct the 2012 covariates and three-year averages. Where possible,
* a small number of missing covariate values were supplemented using
* information found online, mainly from publicly available company reports.
* 
* The prepared dataset contains the covariates and transformations used
* below for 121 firms: 64 sourcing from Bangladesh and 57 without identified
* sourcing links.

* please change the cd accordingly, to the directory path where the "Appendix_F1_F2.dta" is saved:

cd "..."
use "Appendix_F1_F2.dta", clear

* Install psmatch2; continue if it is already installed.
capture ssc install psmatch2


* Table F2: descriptive statistics.
* Note that firm-financial data come from datastream. The Datastream codes are in the Datastream_Data_tickers excel file (sheet named Firm_data). They can of course be downloaded from other sources. What's important is that take the natural logarith of certain variables (e.g., number of employees). The prefixes of these variables start with 'log_'. Please note that we also calculate 3-year averages (2010-2012) for all varaibles, and in some sepcifcations we use these for matching.

global desc2012 log_totalassets_m log_employees_m book_to_market_m roa_m ///
    debttoequity_m roe_m liquidity_m numanalysts_m sic_binary
global desc3y log_totalassets_3ymean_m log_employees_3ymean_m ///
    book_to_market_3ymean_m roa_3ymean_m debttoequity_3ymean_m ///
    roe_3ymean_m liquidity_3ymean_m numanalysts_3ymean_m sic_binary

* 2012 values.
dtable $desc2012, by(treated, tests nototals) column(by(label, nofvlabel)) ///
    continuous($desc2012, statistics(mean)) novarlabel

* 2010-2012 averages.
dtable $desc3y, by(treated, tests nototals) column(by(label, nofvlabel)) ///
    continuous($desc3y, statistics(mean)) novarlabel

	
* Table F1: AR is Panel A; CAR_0_10 is Panel B.
* Multiply returns by 100 to express them as percentages.

global ols2012 log_totalassets_m log_employees_m book_to_market_m ///
    i.sic_binary debttoequity_m liquidity_m c.roa_m##c.roa_m ///
    c.numanalysts_m roe_m
global ols3y c.log_totalassets_3ymean_m liquidity_3ymean_m ///
    c.log_employees_3ymean_m c.roa_3ymean_m##c.roa_3ymean_m ///
    c.debttoequity_3ymean_m numanalysts_3ymean_m i.sic_binary ///
    roe_m book_to_market_3ymean_m

global full log_employees_m log_totalassets_m book_to_market_m roa_m ///
    debttoequity_m_w roe_m_w liquidity_m numanalysts_m sic_binary
global restricted log_employees_m log_totalassets_m debttoequity_m_w ///
    roa_m liquidity_m
global full3y log_employees_3ymean_m log_totalassets_3ymean_m ///
    book_to_market_3ymean_m roa_3ymean_m debttoequity_3ymean_m_w ///
    roe_3ymean_m_w liquidity_3ymean_m numanalysts_3ymean_m sic_binary
global restricted3y log_employees_3ymean_m log_totalassets_3ymean_m ///
    liquidity_3ymean_m roa_3ymean_m numanalysts_3ymean_m

	
* Column 1: raw comparison.
regress AR treated, vce(robust)
margins if treated == 1, at(treated=(0 1))

regress CAR_0_10 treated, vce(robust)
margins if treated == 1, at(treated=(0 1))


* Column 2: OLS with 2012 covariates.
regress AR treated $ols2012, vce(robust)
margins if treated == 1, at(treated=(0 1))

regress CAR_0_10 treated $ols2012, vce(robust)
margins if treated == 1, at(treated=(0 1))


* Column 3: OLS with three-year covariates (2012 ROE, as in the original).
regress AR treated $ols3y, vce(robust)
margins if treated == 1, at(treated=(0 1))

regress CAR_0_10 treated $ols3y, vce(robust)
margins if treated == 1, at(treated=(0 1))


* Matching results are in the ATT row.
* Each count below gives the number of distinct matched controls.

* Column 4: PSM with all 2012 covariates.
psmatch2 treated $full, out(AR) ai(1)
count if _treated == 0 & _weight > 0 & _weight < .

psmatch2 treated $full, out(CAR_0_10) ai(1)
count if _treated == 0 & _weight > 0 & _weight < .


* Column 5: PSM with restricted 2012 covariates.
psmatch2 treated $restricted, out(AR) ai(1)
count if _treated == 0 & _weight > 0 & _weight < .

psmatch2 treated $restricted, out(CAR_0_10) ai(1)
count if _treated == 0 & _weight > 0 & _weight < .


* Column 6: PSM with all 2012 covariates and a 0.02 caliper.
psmatch2 treated $full, out(AR) ai(1) caliper(0.02)
count if _treated == 0 & _weight > 0 & _weight < .

psmatch2 treated $full, out(CAR_0_10) ai(1) caliper(0.02)
count if _treated == 0 & _weight > 0 & _weight < .


* Column 7: PSM with all three-year covariates.
psmatch2 treated $full3y, out(AR) ai(1)
count if _treated == 0 & _weight > 0 & _weight < .

psmatch2 treated $full3y, out(CAR_0_10) ai(1)
count if _treated == 0 & _weight > 0 & _weight < .


* Column 8: PSM with restricted three-year covariates.
psmatch2 treated $restricted3y, out(AR) ai(1)
count if _treated == 0 & _weight > 0 & _weight < .

psmatch2 treated $restricted3y, out(CAR_0_10) ai(1)
count if _treated == 0 & _weight > 0 & _weight < .


* Column 9: PSM with all three-year covariates and a 0.02 caliper.
psmatch2 treated $full3y, out(AR) ai(1) caliper(0.02)
count if _treated == 0 & _weight > 0 & _weight < .

psmatch2 treated $full3y, out(CAR_0_10) ai(1) caliper(0.02)
count if _treated == 0 & _weight > 0 & _weight < .




