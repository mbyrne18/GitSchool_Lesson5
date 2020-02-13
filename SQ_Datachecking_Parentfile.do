/****PMA Data Quality Checks****

**First do file in series
This do file is designed to clean and check data.  Information from Briefcase will need to be downloaded and exported as csv.
 The do file will then (by country):

Step 1
a. Append all different versions of the SDP Questionnaire into one version and destrings variables as appropriate, codes, and labels each questionnaire
*All duplicates are tagged and dropped if they are complete duplicates

Step 2
Run checks on the dataset, checking for data quality issues by RE/EA
**********************************************************************************/
clear mata
clear matrix
clear
set more off
set maxvar 30000

*******************************************************************************
* SET MACROS: UPDATE THIS SECTION FOR EACH COUNTRY/PHASE
*******************************************************************************
*BEFORE USE THE FOLLOWING NEED TO BE UPDATED:
*Country/Round/Abbreviations
global Country KE	 
global Phase Phase1
global phase 1
global CCPX KEP1

*Year of the Survey
local SurveyYear 2019 
local SYShort 19 

******CSV FILE NAMES ****
*SDP CSV File name 
global SQcsv "KEP1_SDP_Questionnaire_v6"


***If the REs used a second version of the form, update these 
*If they did not use a second version, DONT UPDATE 
global SQcsv2 

* DEFINE THE LISTING FORM HERE
local listcsv "" 


**** GEOGRAPHIC IDENTIFIERS ****
global GeoID "level1 level2 level3 level4 EA"

*Rename level1 variable to the geographic highest level, level2 second level
*done in the final data cleaning before dropping other geographic identifiers
global level1name county
global level2name district
global level3name zone
global level4name location

**** DIRECTORIES****

**Global directory for the dropbox where the csv files are originally stored
global csvdir "/Users/varshasrivatsan/Documents/Kenya Test Forms/EXPORTED FORMS"

**Create a global data directory - NEVER DROPBOX
global datadir "/Users/varshasrivatsan/Documents/Kenya Test Do-Files/Datasets"

**Create a global do file directory
**Should be your GitKraken working directory for the SDP_CQ_Cleaning-Monitoring Repository
global dofiledir "/Users/varshasrivatsan/Documents/Github_Core Data Management/SDP_CQ_Cleaning-Monitoring"


*******************************************************************************************
 			******* Stop Updating Macros Here *******
******************************************************************************************* 			
*Locals (Dont need to Update)
local Country "$Country"
local Phase "$Phase"
local CCPX "$CCPX"

/*Define locals for dates.  The current date will automatically update to the day you are running the do
file and save a version with that day's date*/
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

*******************************************************************************************
 			******* Stop Updating Macros Here *******
******************************************************************************************* 			
cd "$datadir"

**The following commands should be run after the first time you run the data. These commands
*archive all the old versions of the datasets so that data is not deleted and if it somehow is,
*we will have backups of all old datasets.  The shell command accesses the terminal in the background 
*(outside of Stata) but only works for Mac.  It is not necessary to use shell when using Windows but the commands are different
*The command zipfile should work for both Mac and Windows, however shell command only works for Mac.  
*The following commands will zip old datasets and then remove them so that only the newest version is available
*Make sure you are in the directory where you will save the data


/* 
capture zipfile `CCPX'*, saving (Archived_Data/Archived_SDP_Data_$date.zip, replace)

*Delete old versions: old version still saved in ArchivedData.zip
capture shell rm `CCPX'*
*/

capture log close
log using `CCPX'_SDP_DataCleaningQuality_$date.log, replace

*******************************************************************************
* IMPORT LISTING DATA TO CHECK FOR PRIVATE LISTING
*******************************************************************************
/*
*Read in .csv file
cap insheet using "$csvdir/`listcsv'.csv", names
*drop any duplicates

* Generate date variable
gen date="$date"
label variable date "Date"


* Create variable for total number of private SDPs listed
preserve
gen private_sdp_listed=1 if managing_authority!=1
egen total_private_sdp_listed=total(private_sdp_listed)
label variable total_private_sdp_listed "Total number of private SDPs listed"

* Drop duplicate entries 
duplicates drop total_private_sdp_listed, force

* Export number of submissions data to .xls file

export excel date total_private_sdp_listed using "$datadir\`CCPX'_SDP_Checks_$date.xls", firstrow(varl) sh(Listing) sheetreplace 

restore 
*/

*********************************************************************************************************
			*******************Step 1: Clean Data********************
*********************************************************************************************************

*******************************************************************************
* SDP CLEANING/CODING
*******************************************************************************

* Read in cleaning .do file here
run "$dofiledir/SQ_Datachecking.do"

*********************************************************************************************************
******************************COUNTRY SPECIFIC CLEANING SECTION********************************************
*********************************************************************************************************

* Read country specific .do file here.
run "$dofiledir/CountrySpecific_SQ.do"

*********************************************************************************************************
******************************SDP FORM CLEANING SECTION********************************************
*********************************************************************************************************
******After you clean the data, you will need to correct duplicate submissions.
*  You will correct those errors here and in the section below so that the next time you run the files, the dataset will
* be cleaned and only errors that remain unresolved are generated.  
**Write your corrections into the do file named "/Whatever/your/path/name/is/CCP#_CleaningByRE_SQ.do

run "$dofiledir/CleaningByRE_SQ.do"

*********************************************************************************************************
			*******************Step 2: Check Data********************
*********************************************************************************************************

* Rename ea variable
capture rename ea EA
label variable EA "EA"

* Generate date variable
gen date="$date"
label variable date "Date"

* Generate variable that represents difference in minutes between survey start and end time	
gen survey_time_millsec=endSIF-startSIF
label variable survey_time_millsec "Time to complete SDP survey in milliseconds"
gen survey_time_min=survey_time_millsec/60000
label variable survey_time_min "Time to complete SDP survey in minutes"

* Create a time flag for any survey times less than 20 minutes
gen timeflag=0
replace timeflag=1 if survey_time_min<=20 
label variable timeflag "Time to complete SDP survey <20 minutes, or negative"

* Generate visit flag variable 
gen visitflag=0
replace visitflag=1 if times_visited<3 & SDP_result!=1
label variable visitflag "SDP visited less than 3 times and submitted but not complete"

* Generate GPS flag variable equal to 1 if data missing or > 6 meters
gen gpsflag=0
replace gpsflag=1 if (locationaccuracy>6 | locationaccuracy==. | locationlatitude==. | locationlongitude==.)
label variable gpsflag "GPS missing or greater than 6 meters accuracy"

* Generate duplicate SDP name flag
egen duplicatename = tag(facility_name)
label variable duplicatename "Duplicate SDP name"

*******************************************************************************
* SDP DATA CHECKS: SUMMARY 
*******************************************************************************

* Total number of submissions
preserve
egen number=seq()
egen total_submissions=max(number)
label variable total_submissions "Total number of SDP surveys submitted"

* Tota number of completed SDP surveys
gen completed=1 if SDP_result==1
replace completed=0 if SDP_result!=1
egen total_completed=total(completed)
label variable total_completed "Total number of SDP surveys completed"

* Order data before export
order date total_submissions total_completed

* Generate dichotomous public/private variable
gen public=1 if managing_authority==1
egen total_public=total(public)
label variable total_public "Total number of submitted SDP surveys public"
gen private=1 if managing_authority!=1 & managing_authority!=.
egen total_private=total(private)
label variable total_private "Total number of submitted SDP surveys private"

* Drop duplicate entries based on date
duplicates drop total_submissions, force

* Export number of submissions data to .xls file
export excel date total_submissions total_completed total_public total_private using `CCPX'_SDP_Checks_$date.xls, firstrow(varl) sh(Summary) sheetreplace 

restore

*******************************************************************************
* SDP DATA CHECKS: CONSENT FLAG, BY RE
*******************************************************************************

* Total number of submissions without consent, by RE
preserve
bysort RE: egen number=seq()
bysort RE: egen submissions=max(number)
bysort RE: gen totalconsent=sum(consent_obtained)

gen noconsentflag=submissions-totalconsent

bysort RE: egen noconsentflag2=min(noconsentflag)
drop noconsentflag 
rename noconsentflag2 noconsentflag

*******************************************************************************
* SDP DATA CHECKS: SURVEY TIME FLAG, BY RE
*******************************************************************************

* Total number of submissions that took 20 minutes or less (including negative times), by RE 
bysort RE: egen totaltimeflag=total(timeflag)
drop timeflag
bysort RE: egen timeflag=max(totaltimeflag)

*******************************************************************************
* SDP DATA CHECKS: NUMBER OF VISITS FLAG, BY RE
*******************************************************************************

* Total number of submissions where number of visits less than 3 but not marked as "completed",  by RE
bysort RE: egen totalvisitflag=total(visitflag)
drop visitflag
bysort RE: egen visitflag=max(totalvisitflag)

*******************************************************************************
* SDP DATA CHECKS: GPS FLAG, BY RE
*******************************************************************************

* Total number of submissions with GPS accuracy > 6 meters or missing, by RE
bysort RE: egen totalgpsflag=total(gpsflag)
drop gpsflag
bysort RE: egen gpsflag=max(totalgpsflag)

*******************************************************************************
* SDP DATA CHECKS: YEAR OPENED FLAG, BY RE
*******************************************************************************

* Total number of submissions with unkown year facility opened, by RE
bysort RE: egen totalyearopenflag=total(yearopenflag)
drop yearopenflag
bysort RE: egen yearopenflag=max(totalyearopenflag)

*******************************************************************************
* SDP DATA CHECKS: UNKNOWN CATCHMENT POPULATION FLAG, BY RE
*******************************************************************************

* Total number of submissions with unknown or no catchment area, by RE
bysort RE: egen totalcatchmentflag=total(catchmentflag)
drop catchmentflag
bysort RE: egen catchmentflag=max(totalcatchmentflag)

*******************************************************************************
* SDP DATA CHECKS: EXPORT SUMMARY FLAG DATA, BY RE
*******************************************************************************

* Create summary by RE
duplicates drop RE, force
order RE EA submissions noconsentflag timeflag visitflag gpsflag yearopenflag catchmentflag

* Export summary flag data to .xls file
export excel RE EA submissions noconsentflag timeflag visitflag gpsflag yearopenflag catchmentflag using `CCPX'_SDP_Checks_$date.xls, firstrow(varl) sh(Flag_Summary) sheetreplace 

restore

*******************************************************************************
* SDP DATA CHECKS: EXPORT FLAGGED OBSERVATIONS TO .XLS SHEET BY FLAG TYPE
*******************************************************************************
sort RE EA

* Export flagged survey time (less than 20 minutes) to .xls sheet
order RE EA facility_name managing_authority facility_type fp_offered startSIF endSIF survey_time_min SDP_result 
capture export excel RE EA facility_name managing_authority facility_type fp_offered startSIF endSIF survey_time_min SDP_result using `CCPX'_SDP_Checks_$date.xls if timeflag==1, firstrow(varl) sh(FlaggedTime_Data) sheetreplace 

* Export flagged GPS accuracy data to .xls sheet 
order RE EA facility_name managing_authority facility_type locationaccuracy SDP_result 
capture export excel RE EA facility_name managing_authority facility_type locationaccuracy SDP_result using `CCPX'_SDP_Checks_$date.xls if gpsflag==1, firstrow(varl) sh(FlaggedGPS_Data) sheetreplace 


*******************************************************************************
* SDP DATA CHECKS: EXPORT OBSERVATIONS WITH POTENTIAL NUMERIC TYPOS TO .XLS SHEET
*******************************************************************************
*Identify if there are any SDP integer variables with a value of 77, 88, or 99 indicating a potential mistype on the part of the RE or in the Cleaning file
preserve
sort RE EA

**Checking if numeric variables have the values
gen mistype=0
gen mistype_var=""
foreach var of varlist _all{
	capture confirm numeric var `var'
	if _rc==0 {
		replace mistype=mistype+1 if (`var'==77 | `var'==88 | `var'==99) 
		replace mistype_var=mistype_var+" "+"`var'" if `var'==77 | `var'==88 | `var'==99
	}
}

*Exclude entries for facility number
recode mistype 0=.
replace mistype_var=strtrim(mistype_var)
replace mistype=. if mistype_var=="facility_number"
replace mistype_var="" if mistype_var=="facility_number"

*Keep all variables that have been mistyped
levelsof mistype_var, local(typo) clean
keep if mistype!=. 
keep metainstanceID RE EA `typo'
capture drop facility_number
order metainstanceID RE EA, first

capture noisily export excel using `CCPX'_SDP_Checks_$date.xls, firstrow(variables) sh(Potential_Typos) sheetreplace
	if _rc!=198 {
		restore
	}
	else {
		clear 
		set obs 1
		gen x="NO NUMERIC VARIABLES WITH A VALUE OF 77, 88, OR 99"
		export excel using `CCPX'_SDP_Checks_$date.xls, firstrow(variables) sh(Potential_Typos) sheetreplace
		restore
		}

*******************************************************************************
* SDP DATA CHECKS: EXPORT PUBLIC FACILITIES SUBMITTED BY COUNTY/RE/EA TO .XLS SHEET
*******************************************************************************

* Sort public facilities to match public listing Excel file
sort RE EA facility_type facility_name 

* Export
capture export excel RE EA facility_type facility_name if managing_authority==1 using `CCPX'_SDP_Checks_$date.xls, firstrow(varl) sh(PublicFacilities_Submitted) sheetreplace 

*******************************************************************************
* SDP DATA CHECKS: EXPORT PRIVATE FACILITIES SUBMITTED BY RE/EA TO .XLS SHEET
*******************************************************************************

* Export 
export excel RE EA facility_name if managing_authority!=1 using `CCPX'_SDP_Checks_$date.xls, firstrow(varl) sh(PrivateFacilities_Submitted) sheetreplace 

*******************************************************************************
* SAVE, CLOSE LOG AND EXIT
*******************************************************************************

save "$datadir/`CCPX'_SDP_Clean_Data_with_checks_$date.dta", replace

************************************************************************************

translate `CCPX'_SDP_DataCleaningQuality_$date.log `CCPX'_SDP_DataCleaningQuality_$date.pdf, replace


