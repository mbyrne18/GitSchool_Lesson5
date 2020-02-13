*PMA SQ Analytics
**This file generates the Analytics report for the SDP Questionnaire

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

*Geo ID variables
local Geo_ID level1 level2 level3


*Where the ODK files are saved for this survey
global odkdir "/Users/varshasrivatsan/Desktop/odk2stata"

*ODK file name
global SQodk KEP1-SDP-Questionnaire-v6-kad

*Where the Analytics .csv files are saved
global analyticsdir "/Users/varshasrivatsan/Documents/Kenya Test Forms/Analytics"

*Change analytic csv file names here
global SQanalytics1 KEP1_SDP_Questionnaire_v6_Analytics.csv

*Where the outputs from this .do file should be saved
global datadir "/Users/varshasrivatsan/Documents/Kenya Test Do-Files/Datasets"

*Datadate of the SDP dataset
global datadate 31Oct2019


*If there is 2nd version of analytics, use the older version below and add csv names
*global SQanalytics2 RJR3_SDP_Questionaire_v2_Analytics.csv

**For the following macros the section name can be whatever you want it to be
**The firstvar is the note that begins the section in the ODK
**The lastvar is the note that begins the following section in the ODK
**NOTE: THE VARIABLE SECT_FP_SERVICE_INTEGRATION_NOTE SHOULD BE SHORTENED TO SECT_FP_SERVICE_INTEGRATION

*Section 1 macros
local sec1_name info
local sec1_firstvar sect_services_info
local sec1_lastvar sect_fps_info

*Section 2 macros
local sec2_name fp_services
local sec2_firstvar sect_fps_info
local sec2_lastvar sect_fp_methods_note

*Section 3 macros
local sec3_name charged_fees_visits
local sec3_firstvar sect_fp_methods_note
local sec3_lastvar regb_note

*Section 4 macros
local sec4_name sold_stock
local sec4_firstvar regb_note
local sec4_lastvar fp_service_integration

*Section 5 macros
local sec5_name integration
local sec5_firstvar fp_service_integration
local sec5_lastvar thankyou

*Number of sections in the survey
local n_sections 5

*Should there be more sections, copy the format of the other section macros and add them, and update the n_sections macro


*****************************************************************************************
 			******* Stop Updating Macros Here *******
*****************************************************************************************
cd "$datadir"

local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)


********************************************************************************
********************************************************************************
* First Step is to Generate a List of Separate Screens in ODK by var name
********************************************************************************
import excel "$odkdir/$SQodk", sheet("survey") firstrow


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
capture replace name="sdp_result" if name=="SDP_result"
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
local all_sdpvar 
foreach var of varlist _all {
	local all_sdpvar "`all_sdpvar' `var'"
}


*********************************************************************************
*SDP Analytics
*********************************************************************************
*open SDP dataset and keep necessary information to be added to analytics
use "$datadir/`CCPX'_SDP_Clean_Data_with_checks_$datadate.dta", clear
keep metainstanceID RE facility_type managing_authority fp_offered
tempfile combined2
save `combined2', replace

clear
capture noisily insheet using "$analyticsdir/$SQanalytics1", clear
save `CCPX'_SQanalytics_$date.dta, replace	
	
capture noisily insheet using "$analyticsdir/$SQanalytics2", comma case
if _rc==0 {
	*rename old version to be consistent with new version
	capture rename *, lower

    tempfile SQana
    save `SQana', replace	
	
	use `CCPX'_SQanalytics_$date.dta
	append using `SQana', force
	save `CCPX'_SQanalytics_$date.dta, replace	
}
	
*housekeeping of analytics files
rename dir_uuid metainstanceID
replace metainstanceID=subinstr(metainstanceID,"uuid","uuid:",.)
gen RE=your_name
tostring RE,replace
tostring name_typed, replace
replace RE=name_typed if missing(your_name)

save "`CCPX'_SDP_Questionnaire_Analytics_$date.dta", replace

*merge analytics dataset and partial core dataset
merge 1:1 metainstanceID using `combined2', nogen force


*label SQ result in case it's string
capture drop SDP_result
rename sdp_result SDP_result
label define SDP_result_list 1 completed 2 not_at_facility 3 postponed 4 refused 5 partly_completed 6 other
encode SDP_result, gen(SDP_resultv2) lab(SDP_result_list)
order SDP_resultv2, after(SDP_result)
drop SDP_result
rename SDP_resultv2 SDP_result

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
	capture drop SQ`sec`x'_name'_time
	egen SQ`sec`x'_name'_time=rowtotal(`sec`x'_firstvar'_t-`sec`x'_lastvar'_t)
	replace SQ`sec`x'_name'_time=SQ`sec`x'_name'_time-`sec`x'_lastvar'_t
	local section_time "`section_time' SQ`sec`x'_name'_time"
	}	
	
foreach var in `section_time' {
	replace `var'=`var'/60/1000
    }

*flag if interview <10min
gen SQinterview=resumed+short_break
gen SQinterview_min=(resumed+short_break)/60000
gen SQtime_flag=1 if SQinterview_min<10
format SQinterview_min %12.2f

****Generate interview speed in v8
foreach var in `all_sdpvar' {
  capture gen `var'_u=.
  capture replace `var'_u=1 if `var'_v!=.
}

order *_u, after(sdp_result_t)

egen unique_visit_total=rowtotal(your_name_check_u - sdp_result_u)
drop your_name_check_u-sdp_result_u

*generate macro names for _t _v _c _d
local all_sdpvar_t
foreach var in `all_sdpvar' {
local all_sdpvar_t "`all_sdpvar_t' `var'_t"
}

local all_sdpvar_v
foreach var in `all_sdpvar' {
local all_sdpvar_v "`all_sdpvar_v' `var'_v"
}

local all_sdpvar_c
foreach var in `all_sdpvar' {
local all_sdpvar_c "`all_sdpvar_c' `var'_c"
}

local all_sdpvar_d
foreach var in `all_sdpvar' {
local all_sdpvar_d "`all_sdpvar_d' `var'_d"
}

**generate a variable speed=sum(each question time)/unique screen. unit is screen per second
egen SQ_t_total=rowtotal(`all_sdpvar_t')
gen SQspeed_second=(SQ_t_total/unique_visit_total)/1000

*******************************************************************************
* Error Report
*******************************************************************************
*export histogram to show interview time distribution
*generate statistics for overall time distribution
preserve
capture graph drop third
drop if SQinterview_min>10000
drop if SQinterview_min==0
quietly sum SQinterview_min, detail
return list
histogram SQinterview_min if SDP_result==1, width(10)  start(0) percent addlabels title("`CCPX' SQ Completed Interview Time Distribution $date") ///
   xtitle("Interview Time in Minute") ytitle("Percent Among All Completed Forms") xtick(0(10)120) bcolor(green) ///
   text(25 100 "N=`r(N)'", placement(se)) ///
   text(23 100 "Minimum=`r(min)'", placement(se)) ///
   text(21 100 "Median=`r(p50)'", placement(se)) ///
   text(19 100 "Max=`r(max)'", placement(se)) ///
   text(17 100 "SD=`r(sd)'", placement(se)) name(third)
capture graph export "SQ_interview_time_distribution_$date.png", replace
restore

***Summary of SQ interview
	preserve
	keep if SQinterview_min<10
	drop if SQinterview_min==0
	keep if SDP_result==1

*Interview time export
capture noisily export excel RE metainstanceID GeoID facility_type managing_authority fp_offered SQinterview_min SQspeed_second ///
	`section_time' using `CCPX'_SDP_Analytics_Error_Report_$date.xls, firstrow(variables) sh(SQoverview<10min) replace
	*Stata 12 or above use export excel
	if _rc!=198{
		restore
		}
	else{
		clear 
		set obs 1
		gen x="NO COMPLETED SDP INTERVIEWS LESS OR EQUAL TO 10 MINUTES"
		export excel using `CCPX'_SDP_Analytics_Error_Report_$date.xls, firstrow(variables) sh(SQoverview<10min) replace
		restore
	}


***Breakdown by each RE, include time summary, CC, screen visit, rs
preserve
keep if SDP_result==1

collapse (count) SDP_completed=SDP_result (min) SQinterview_minimum=SQinterview_min ///
	(p50) SQinterview_median=SQinterview_min (max) SQinterview_maximum=SQinterview_min ///
	(mean) mean_SQinterview_speed=SQspeed_second ///
	(count) num_interview_less_10min=SQtime_flag, by(RE)
export excel using `CCPX'_SDP_Analytics_Error_Report_$date.xls, firstrow(variables) sh(SQbyRE) sheetmodify
restore


