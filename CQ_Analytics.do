*PMA CQ Analytics
**This file generates the Analytics report for the CQ Questionnaire

clear matrix
clear
set more off
set maxvar 30000

*******************************************************************************/
*******************************UPDATE BY COUNTRY********************************

clear

*Country-Phase macros
local country KE
local phase 1
local CCPX KEP1

local Geo_ID level1 level2 level3

local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

*Where the ODK files are saved for this survey
global odkdir "/Users/varshasrivatsan/Desktop/odk2stata"

*ODK file name
global CQodk "KEP1-CEI-Questionnaire-v9-kad"

*Where the Analytics .csv files are saved
global analyticsdir "/Users/varshasrivatsan/Documents/Kenya Test Forms/Analytics"

*Change analytic csv file names here
global CQanalytics1 "KEP1_CQ_Questionnaire_v9_Analytics.csv"

*Where the outputs from this .do file should be saved
global datadir "/Users/varshasrivatsan/Documents/Kenya Test Do-Files/Datasets"

*Datadate of the CEI dataset
global datadate 1Nov2019

*If there is 2nd version of analytics, use the older version below and add csv names
*global CQanalytics2 RJR3_CEI_Questionaire_v2_Analytics.csv

**For the following macros the section name can be whatever you want it to be
**The firstvar is the note that begins the section in the ODK
**The lastvar is the note that begins the following section in the ODK
**NOTE: THE VARIABLE SECT_FP_SERVICE_INTEGRATION_NOTE SHOULD BE SHORTENED TO SECT_FP_SERVICE_INTEGRATION

*Section 1 macros
local sec1_name info
local sec1_firstvar services_note
local sec1_lastvar fp_services_note

*Section 2 macros
local sec2_name fp_services
local sec2_firstvar fp_services_note
local sec2_lastvar client_satisfaction_note

*Section 3 macros
local sec3_name client_satisfaction
local sec3_firstvar client_satisfaction_note
local sec3_lastvar sect_flw

*Section 4 macros
local sec4_name followup
local sec4_firstvar sect_flw
local sec4_lastvar sect_end


*Number of sections in the survey
local n_sections 4

*Should there be more sections, copy the format of the other section macros and add them, and update the n_sections macro

********************************************************************************
*  First Step is to Generate a List of Separate Screens in ODK by var name
********************************************************************************
cd "$odkdir"
import excel "$CQodk", sheet("survey") firstrow
cd "$datadir"


*drop completely missing vars
 foreach var of varlist _all {
     capture assert mi(`var')
     if !_rc {
        drop `var'
     }
 }

*extract all questions
gen type_clean="select_one" if strpos(type, "select_one")>0
replace type_clean="select_multiple" if strpos(type, "select_multiple")>0
replace type_clean=type if (type=="date"|type=="dateTime"|type=="decimal"|type=="geopoint"| ///
type=="image"|type=="integer"|type=="text")


/* this section should be comment out if needed, tabulation of question types
drop if type=="select_one blank_list" 
gen type_rough="select_one" if type_clean=="select_one"
replace type_rough="select_multiple" if type_clean=="select_multiple"
replace type_rough="date" if type_clean=="date" | type_clean=="dateTime"
replace type_rough="number" if type_clean=="decimal" | type_clean=="integer"
replace type_rough="other" if type_clean=="geopoint" | type_clean=="image" | type_clean=="text"
disp "`country'"
tab type_rough
*/

***************These codes deal with screens, not questions
*For ODK groups where multiple questions are displayed on the same screen at the same time, keep only one variable per screen
gen screen="select_one" if strpos(type, "select_one")>0
replace screen="select_multiple" if strpos(type, "select_multiple")>0
replace screen=type if (type=="date"|type=="dateTime"|type=="decimal"|type=="geopoint"| ///
type=="image"|type=="integer"|type=="text"|type=="note")

*generage tag for those within the group
gen tempvar=1 if type=="begin group" & appearance=="field-list"
replace tempvar=2 if type=="end group"
carryforward tempvar, gen(fieldlist_tag)
drop tempvar
order fieldlist_tag, after(type)
order appearance, after(type)

*for the series of questions in the group, drop begin, end, note and check
drop if ((type=="begin group"|strpos(type,"note")>0|type=="calculate") & fieldlist_tag==1)
drop if ((type=="select_one blank_list") & fieldlist_tag==1)

*only keep one for the entire group
recode fieldlist_tag 2=.
gen fieldlist_duptag=1 if fieldlist_tag==1 & fieldlist_tag[_n-1]==.
keep if ((fieldlist_duptag==1 & fieldlist_tag==1)|(fieldlist_duptag==.&fieldlist_tag==.))

drop fieldlist_duptag screen
drop if type=="calculate"
drop if type=="start"|type=="end"|type=="deviceid"|type=="simserial"|type=="phonenumber" ///
|type=="hidden string"|type=="hidden geopoint"|type=="hidden"|type=="hidden int"

drop if fieldlist_tag==. & (type=="end group" | type=="begin_group")
drop fieldlist_tag
***************

*rename variables to be shorter and match analytics data
capture replace name="CEI_result" if name=="cei_result"
capture replace name="sect_fp_service_integration" if name=="sect_fp_service_integration_note"

*make into lower cases
replace name=lower(name)

*only keep variable names and make it into a country-specific macro
keep name
sxpose, clear firstnames

*drop the space in the original ODK, otherwise it'll generate a random variable
capture drop _var*

*for modules drop the repeat prompt since it's not in analytics
capture drop *_rpt

*generate a macro that holds all ODK screen variables
local all_CEIvar 
foreach var of varlist _all {
	local all_CEIvar "`all_CEIvar' `var'"
}


*********************************************************************************
*CEI Analytics
*********************************************************************************
*open CEI dataset and keep necessary information to be added to analytics
use "$datadir/`CCPX'_CQ_Clean_Data_with_checks_$datadate.dta", clear
keep metainstanceID RE facility_type managing_authority cei_result
tempfile combined2
save `combined2', replace

clear
capture noisily insheet using "$analyticsdir/$CQanalytics1", clear
save `CCPX'_CQanalytics_$date.dta, replace	
	
capture noisily insheet using "$analyticsdir/$CQanalytics2", comma case
if _rc==0 {
	*rename old version to be consistent with new version
	capture rename *, lower

    tempfile CQana
    save `CQana', replace	
	
	use `CCPX'_CQanalytics_$date.dta
	append using `CQana', force
	save `CCPX'_CQanalytics_$date.dta, replace	
}
	
*housekeeping of analytics files
rename dir_uuid metainstanceID
replace metainstanceID=subinstr(metainstanceID,"uuid","uuid:",.)
gen RE=your_name
tostring RE,replace
tostring name_typed, replace
replace RE=name_typed if missing(your_name)

save "`CCPX'_CEI_Questionnaire_Analytics_$date.dta", replace

*merge analytics dataset and partial core dataset
merge 1:1 metainstanceID using `combined2', nogen force

*label CQ result in case it's string
rename cei_result CEI_result


*Get variable number for variable names that are too long
capture confirm var sect_fp_service_integration_note
if _rc==0 {
	preserve
	keep metainstanceID-sect_fp_service_integration_note
	global sect_fp_service_integration_t = c(k)+1
	global sect_fp_service_integration_v = c(k)+2
	global sect_fp_service_integration_d = c(k)+3
	global sect_fp_service_integration_b = c(k)+4
	restore

	*Rename variable names that are too long
	rename sect_fp_service_integration_note sect_fp_service_integration_c 
	rename v$sect_fp_service_integration_t sect_fp_service_integration_t
	rename v$sect_fp_service_integration_v sect_fp_service_integration_v
	rename v$sect_fp_service_integration_d sect_fp_service_integration_d
	rename v$sect_fp_service_integration_b sect_fp_service_integration_b
}



*name cleaning of csv
order RE, after(your_name)
capture drop your_name name_typed
capture rename ea EA
sort RE

if "`country'"=="RJ" | "`country'"=="Rajasthan" {
	replace RE="re"+RE if substr(RE,1,2)=="10"
	}

egen GeoID=concat(`Geo_ID' EA), punct(-)

*Section time calculations
forval x = 1/`n_sections' {
	capture drop CQ`sec`x'_name'_time
	egen CQ`sec`x'_name'_time=rowtotal(`sec`x'_firstvar'_t-`sec`x'_lastvar'_t)
	replace CQ`sec`x'_name'_time=CQ`sec`x'_name'_time-`sec`x'_lastvar'_t
	local section_time "`section_time' CQ`sec`x'_name'_time"
	}	
	
foreach var in `section_time' {
	replace `var'=`var'/60/1000
    }

*flag if interview <10min
gen CQinterview=resumed+short_break
gen CQinterview_min=(resumed+short_break)/60000
gen CQtime_flag=1 if CQinterview_min<10
format CQinterview_min %12.2f

****Generate interview speed in v8
foreach var in `all_CEIvar' {
  capture gen `var'_u=.
  capture replace `var'_u=1 if `var'_v!=.
}

order *_u, after(cei_result_t)

egen unique_visit_total=rowtotal(your_name_check_u - cei_result_u)
drop your_name_check_u-cei_result_u

*generate macro names for _t _v _c _d
local all_CEIvar_t
foreach var in `all_CEIvar' {
local all_CEIvar_t "`all_CEIvar_t' `var'_t"
}

local all_CEIvar_v
foreach var in `all_CEIvar' {
local all_CEIvar_v "`all_CEIvar_v' `var'_v"
}

local all_CEIvar_c
foreach var in `all_CEIvar' {
local all_CEIvar_c "`all_CEIvar_c' `var'_c"
}

local all_CEIvar_d
foreach var in `all_CEIvar' {
local all_CEIvar_d "`all_CEIvar_d' `var'_d"
}

**generate a variable speed=sum(each question time)/unique screen. unit is screen per second
egen CQ_t_total=rowtotal(`all_CEIvar_t')
gen CQspeed_second=(CQ_t_total/unique_visit_total)/1000

*******************************************************************************
* Error Report
*******************************************************************************
*export histogram to show interview time distribution
*generate statistics for overall time distribution
preserve
capture graph drop third
drop if CQinterview_min>10000
drop if CQinterview_min==0
quietly sum CQinterview_min, detail
return list
histogram CQinterview_min if CEI_result==1, width(10)  start(0) percent addlabels title("`CCPX' CQ Completed Interview Time Distribution $date") ///
   xtitle("Interview Time in Minute") ytitle("Percent Among All Completed Forms") xtick(0(10)120) bcolor(green) ///
   text(25 100 "N=`r(N)'", placement(se)) ///
   text(23 100 "Minimum=`r(min)'", placement(se)) ///
   text(21 100 "Median=`r(p50)'", placement(se)) ///
   text(19 100 "Max=`r(max)'", placement(se)) ///
   text(17 100 "SD=`r(sd)'", placement(se)) name(third)
capture graph export "CQ_interview_time_distribution_$date.png", replace
restore

***Summary of CQ interview
	preserve
	keep if CQinterview_min<10
	drop if CQinterview_min==0
	keep if CEI_result==1

*Interview time export
capture noisily export excel RE metainstanceID GeoID facility_type managing_authority fp_offered CQinterview_min CQspeed_second ///
	`section_time' using `CCPX'_CEI_Analytics_Error_Report_$date.xls, firstrow(variables) sh(CQoverview<10min) replace
	*Stata 12 or above use export excel
	if _rc!=198{
		restore
		}
	else{
		clear 
		set obs 1
		gen x="NO COMPLETED CEI INTERVIEWS LESS OR EQUAL TO 10 MINUTES"
		export excel using `CCPX'_CEI_Analytics_Error_Report_$date.xls, firstrow(variables) sh(CQoverview<10min) replace
		restore
	}


***Breakdown by each RE, include time summary, CC, screen visit, rs
preserve
keep if CEI_result==1

collapse (count) CEI_completed=CEI_result (min) CQinterview_minimum=CQinterview_min ///
	(p50) CQinterview_median=CQinterview_min (max) CQinterview_maximum=CQinterview_min ///
	(mean) mean_CQinterview_speed=CQspeed_second ///
	(count) num_interview_less_10min=CQtime_flag, by(RE)
export excel using `CCPX'_CEI_Analytics_Error_Report_$date.xls, firstrow(variables) sh(CQbyRE) sheetmodify
restore


