/****PMA Data Quality Checks****

**First do file in series
This do file is designed to clean and check data.  Information from Briefcase will need to be downloaded and exported as csv.
 The do file will then (by country):

Step 1
a. Append all different versions of the CQ Questionnaire into one version and destrings variables as appropriate, codes, and labels each questionnaire
*All duplicates are tagged and dropped if they are complete duplicates

Step 2
Run checks on the dataset, checking for data quality issues by RE/EA

Step 3
Merge SDP AND CEI data and address issues with facility numbers of duplicated facility names

**********************************************************************************/

clear matrix
clear
set more off
clear mata
set maxvar 30000

*******************************************************************************
* SET MACROS: UPtoday THIS SECTION FOR EACH COUNTRY/PHASE
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
*CQ CSV File name 
global CQcsv "KEP1_CEI_Questionnaire_v7"


***If the REs used a second version of the form, uptoday these 
*If they did not use a second version, DONT UPtoday 
global CQcsv2 

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
*Locals (Dont need to Uptoday)
local Country "$Country"
local Phase "$Phase"
local CCPX "$CCPX"

/*Define locals for todays.  The current today will automatically uptoday to the day you are running the do
file and save a version with that day's today*/
local today=c(current_date)
local c_today= "`today'"
global today=subinstr("`c_today'", " ", "",.)

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
capture zipfile `CCPX'*, saving (Archived_Data/Archived_CQ_Data_$date.zip, replace)

*Delete old versions: old version still saved in ArchivedData.zip
capture shell rm `CCPX'*
*/

capture log close
log using `CCPX'_CQ_DataCleaningQuality_$date.log, replace

*********************************************************************************************************
			*******************Step 1: Clean Data********************
*********************************************************************************************************

*******************************************************************************
* CQ CLEANING/CODING
*******************************************************************************

* Read in cleaning .do file here
run "$dofiledir/CQ_Datachecking.do"

*********************************************************************************************************
******************************COUNTRY SPECIFIC CLEANING SECTION********************************************
*********************************************************************************************************

* Read country specific .do file here.
run "$dofiledir/CountrySpecific_CQ.do"

*********************************************************************************************************
******************************CQ FORM CLEANING SECTION********************************************
*********************************************************************************************************
******After you clean the data, you will need to correct duplicate submissions.
*  You will correct those errors here and in the section below so that the next time you run the files, the dataset will
* be cleaned and only errors that remain unresolved are generated.  
**Write your corrections into the do file named "/Whatever/your/path/name/is/CCP#_CleaningByRE_CQ.do

run "$dofiledir/CleaningByRE_CQ.do"

*********************************************************************************************************
			*******************Step 2: Check Data********************
*********************************************************************************************************
* Total number of submissions
preserve
egen number=seq()
egen total_submissions=max(number)
label var total_submissions "Total number of CQ surveys submitted"

* Total number of completed CQ surveys
gen completed=1 if cei_result==1
replace completed=0 if cei_result!=1
egen total_completed=total(completed)
label var total_completed "Total number of CQ surveys: completed"

* Total number of refusal CQ surveys
gen refused=1 if cei_result==2
replace refused=0 if cei_result!=2
egen total_refused=total(refused)
label var total_refused "Total number of CQ surveys: refused"

* Total number of partly completed CQ surveys
gen partly_completed=1 if cei_result==3
replace partly_completed=0 if cei_result!=3
egen total_partlycompleted=total(partly_completed)
label var total_partlycompleted "Total number of CQ surveys: partly completed"

* Total number of ineligible CQ surveys
*always cross check with eligibility==0, RE may put cei_result=4 despite client is eligible
gen ineligible=1 if cei_result==4
replace ineligible=0 if cei_result!=4
egen total_ineligible=total(ineligible)
label var total_ineligible " Total number of CQ surveys: ineligible"

* Total number of other_result CQ surveys
gen other_results=1 if cei_result==5
replace other_results=0 if cei_result!=5
egen total_other=total(other_results)
label var total_other "Total number of CQ surveys:other"


* Order data before export
order today total_submissions total_completed total_refused total_partlycompleted total_ineligible total_other


* Drop duplicate entries based on today
duplicates drop total_submissions, force
export excel today total_submissions total_completed total_refused total_partlycompleted total_ineligible total_other using "`CCPX'_CQ_Checks_$date.xlsx", sh(summary) sheetreplace firstrow(var)

restore
*******************************************************************************
* CQ DATA CHECKS: SUPERVISOR CHECKS, BY RE
*******************************************************************************
preserve
*gen total submissions per RE
bysort RE: egen number=seq()
bysort RE: egen submissions=max(number)

* Tota number of completed CQ surveys
gen completed=1 if cei_result==1
replace completed=0 if cei_result!=1
bys RE: egen Retotal_completed=total(completed)
label var Retotal_completed "CQ surveys completed"

* Tota number of refusal CQ surveys
gen refused=1 if cei_result==2
replace refused=0 if cei_result!=2
bys RE: egen Retotal_refused=total(refused)
label var Retotal_refused "CQ surveys: refused"

* Tota number of partly completed CQ surveys
gen partly_completed=1 if cei_result==3
replace partly_completed=0 if cei_result!=3
bys RE: egen Retotal_partlycompleted=total(partly_completed)
label var Retotal_partlycompleted "CQ surveys partly completed"

* Total number of ineligible CQ surveys
gen ineligible=1 if cei_result==4
replace ineligible=0 if cei_result!=4
bys RE: egen Retotal_ineligible=total(ineligible)
label var Retotal_ineligible " ineligible CQ surveys"

* Tota number of other_result CQ surveys
gen other_results=1 if cei_result==5
replace other_results=0 if cei_result!=5
bys RE: egen Retotal_other=total(other_results)
label var Retotal_other "CQ surveys:other results"

order  RE $GeoID Retotal_completed Retotal_refused Retotal_partlycompleted Retotal_ineligible Retotal_other

*drop duplicates by RE
duplicates drop RE, force

*Export data to excel
export excel RE $GeoID submissions Retotal_completed Retotal_refused Retotal_partlycompleted Retotal_ineligible Retotal_other  using "`CCPX'_CQ_Checks_$date.xlsx", sh(Supervisor_checks) sheetreplace firstrow(varl)

restore


*******************************************************************************
* CQ DATA CHECKS: No of CQs  , BY Facility Number/Name
*******************************************************************************

preserve

*gen total submissions per CQ
bysort facility_number: egen number=seq()
bysort facility_number: egen submissions=max(number)

* Total number of completed CQ surveys
gen completed=1 if cei_result==1
replace completed=0 if cei_result!=1
bys facility_number: egen CQ_completed=total(completed)
label var CQ_completed "Total number of CQ surveys completed in an SDP"

order $GeoID facility_number facility_name facility_name_other submissions CQ_completed

*drop duplicates by facility number
duplicates drop facility_number, force

*Export to progress report file
export excel  $GeoID facility_number facility_name facility_name_other submissions CQ_completed using "`CCPX'_CQ_Checks_$date.xlsx" , firstrow(varl) sh("No_CQs_done per SDP") sheetreplace 

restore


*******************************************************************************
* CQ DATA CHECKS: Eligibility by age , BY RE
*******************************************************************************
* Eligible female respondent 18-49 years
* Eligible male respondent 18-59 years

gen age_group=1 if  age >17 & age <50 
replace age_group= 2 if  age >17 & age <60 
lab var age_group "age group female"

lab def  agelab 1 "18-49 years" 2 "18-59 years"
lab values age_group agelab

gen age_notEligible =0
* minimum eligible age is 18 not 16
replace age_notEligible =1 if  age <18
replace age_notEligible =1 if  age >49  

bys RE : egen totalage_noteligible =total(age_notEligible)
lab var totalage_noteligible "total respondents outside the required age limit"

preserve
*duplicates drop RE, force
duplicates drop RE, force

*Export to progress report file
export excel  RE $GeoID totalage_noteligible using "`CCPX'_CQ_Checks_$date.xlsx" , firstrow(varl) sh("flag_age eligibility") sheetreplace 
restore

preserve

*export data : for respondents not eligible

count if totalage_noteligible==1
di r(N) 
if r(N)  !=0{
			export excel   using "`CCPX'_CQ_Checks_$date.xlsx"  if age_notEligible==1, firstrow(varl) sh("data_age eligibility") sheetreplace 
            }
			
restore


*******************************************************************************
* CQ DATA CHECKS: CONSENT FLAG, TIME FLAG,  BY RE
*******************************************************************************

* Generate variable that represents difference in minutes between survey start and end time	
gen survey_time_millsec=endSIF-startSIF
label var survey_time_millsec "Time to complete CQ survey in milliseconds"
gen survey_time_min=survey_time_millsec/60000
label var survey_time_min "Time to complete CQ survey in minutes"

* Create a time flag for any survey times less than 20 minutes
gen timeflag=0
replace timeflag=1 if survey_time_min<=20 


preserve

*gen total submissions per RE
bysort RE: egen number=seq()
bysort RE: egen submissions=max(number)
cap drop number


* Total number of submissions that took 20 minutes or less (including negative times), by RE 
bysort RE: egen totaltimeflag=total(timeflag)
label var totaltimeflag "Total number of CQ surveys completed with <20 minutes, or negative"


* Total number of submissions without consent, by RE
gen consenting=0
replace consenting=1 if consent_obtained==1
bysort RE: egen totalconsent=sum(consenting)

gen noconsentflag=submissions-totalconsent

bysort RE: egen noconsentflag2=min(noconsentflag)
drop noconsentflag 
rename noconsentflag2 noconsentflag
lab var noconsentflag "Total number of nonconsent CQ surveys"

order RE $GeoID submissions totaltimeflag noconsentflag 

*drop duplicates by RE
duplicates drop RE, force

*Export data to excel
export excel RE $GeoID submissions totaltimeflag noconsentflag  using "`CCPX'_CQ_Checks_$date.xlsx", sh(Flag_timeflag) sheetreplace firstrow(varl)

restore

export excel RE $GeoID facility_type facility_name cei_result if survey_time_min<20 using "`CCPX'_CQ_Checks_$date.xlsx", sh(Flag_timeflag_detail) sheetreplace firstrow(varl)


*******************************************************************************
* CQ DATA CHECKS: Total number of "dont know" and "no response", BY RE
*******************************************************************************
preserve

*gen total submissions per RE
bysort RE: egen number=seq()
bysort RE: egen submissions=max(number)
qui ds  
tostring `r(varlist)', force replace
 
qui ds  

foreach var in `r(varlist)' {
								gen `var'_dnk=0 if `var' != "-88"
								qui replace `var'_dnk=1 if `var' == "-88"
								order `var'_dnk, after (`var')

								gen `var'_nr=0 if `var' != "-99"
								qui replace `var'_nr=1 if `var' == "-99"
								order `var'_nr, after (`var')
										}
		
*create a variable that holds the row total(per interview)
egen dontknow =rowtotal(*_dnk) 
egen noresponse =rowtotal(*_nr) 

*collapse (sum) dontknow, by(RE)
bys RE: egen total_dontknowbyRE =total(dontknow)
bys RE: egen total_noresponsebyRE =total(noresponse)
	
lab var total_dontknowbyRE "Total number of  'dont know'"
lab var total_noresponsebyRE "Total number of 'no response'"

destring submissions total_noresponsebyRE total_dontknowbyRE , replace

*drop duplicates by RE
duplicates drop RE, force

* Export summary flag data to .xls file
export excel RE $GeoID submissions  total_dontknowbyRE total_noresponsebyRE   using "`CCPX'_CQ_Checks_$date.xlsx", firstrow(varl) sh("Flag_dont know") sheetreplace 

restore

*******************************************************************************
* CQ DATA CHECKS: Respondents who refused to be contacted , BY RE
*******************************************************************************
gen primary_phone_no = flw_number_confirm
gen sec_phone_no = flw_number2_confirm
gen missing_phonenumber =0 if flw_willing==1 & (strlen(primary_phone_no)>8 | strlen(sec_phone_no)>8)
order missing_phonenumber, after(flw_willing)
replace missing_phonenumber=1 if  flw_willing==0 

bys RE : egen miss_phonenumber = total(missing_phonenumber)
lab var miss_phonenumber "missing either primary/secondary phone number"
order miss_phonenumber, after(missing_phonenumber)

gen  flag_nocontact=1 if flw_willing==0 
order flag_nocontact, after(miss_phonenumber)
replace flag_nocontact=0 if flw_willing ==1 & (strlen(primary_phone_no)>8 | strlen(sec_phone_no)>8)

bys RE: egen total_nocontact  = total(flag_nocontact)
order total_nocontact , after(flag_nocontact)

lab var total_nocontact "number of respondents who refused to be contacted"
preserve
* drop males and 

*drop duplicates by RE
duplicates drop RE, force

order  RE $GeoID total_nocontact miss_phonenumber

*Export to progress report file

export excel  RE $GeoID total_nocontact  miss_phonenumber using "`CCPX'_CQ_Checks_$date.xlsx", firstrow(varl) sh("flag_refused call") sheetreplace 
restore

*******************************************************************************
* CQ DATA CHECKS: Export data for respondents who refused to be contacted , BY RE
*******************************************************************************

count if flag_nocontact==1
di r(N) 
if r(N)  !=0{

			export excel RE $GeoID SubmissionDate flw_willing primary_phone_no sec_phone_no flw_number_yn age facility_type managing_authority using "`CCPX'_CQ_Checks_$date.xlsx"  if  flag_nocontact ==1, firstrow(varl) sh("data_refused_call") sheetreplace 
            }
*******************************************************************************
* CQ DATA CHECKS: FACILITIES THAT DO NOT HAVE A PREPOPULATED ODK NAME, BY RE
*******************************************************************************

gen facility_other =1 if facility_name=="other" & facility_name_other==""
replace facility_other=0 if facility_name !="other"

bys RE: egen facility_noname = total(facility_other)

preserve
*duplicates drop RE, force
collapse (sum) facility_other, by(RE)

*order RE facility_number facility_noname  
cap export excel using "`CCPX'_CQ_Checks_$date.xlsx", firstrow(varl) sh("Flag_facility without prepopulated ODK name") sheetreplace 
restore

*Export facility name data 
cap drop start end CQtodaySIF today
cap export excel  using "`CCPX'_CQ_Checks_$date.xlsx" if facility_other == 1 , firstrow(varl) sh("Flag_facility  without prepopulated ODK name") sheetreplace 


******x********************************************
*SAVE -DATASET
***************************************************
save "$datadir/`CCPX'_CQ_Clean_Data_with_checks_$date.dta", replace
******x********************************************
*CLEARING EMPTY MATRIX - SPREADSHEET
***************************************************
set matsize 10000
matrix clearer = J(1000,15,.)
local sheetnames FEMALE_AGE_NUMCHILDREN CLOSEST_HF_DISTANCE DUP_FACILITY_NUMBERS REPEAT_FACILITY CQ_WITHOUT_SQ SQ_WITHOUT_CQ

version 14.0
foreach i in `sheetnames'{
capture noisily putexcel A4=matrix(clearer) using "`CCPX'_CQ_Checks_$date.xlsx", sheet(`i') keepcellformat modify

}

*COMPARING AGE AND NUMBER OF CHILDREN
cls
cd "$datadir"
use "`CCPX'_CQ_Clean_Data_with_Checks_$date.dta", clear
preserve
keep metainstanceID RE age birth_events SubmissionDate facility_number facility_name $GeoID
keep if[age<=30 & birth_events>=5 &  !missing(birth_events)]
sort RE
egen No = seq()
order No RE metainstanceID $GeoID facility_number facility_name SubmissionDate age birth_events
capture noisily export excel using "`CCPX'_CQ_Checks_$date.xlsx", cell(A3) firstrow(varl)sheet(FEMALE_AGE_NUMCHILDREN) sheetmodify 
putexcel A1=("ASCERTAIN WHETHER OR NOT THE AGE OF FEMALE RESPONDENT COMPARED TO THE NUMBER OF CHILDREN WAS CAPTURED CORRECTLY") using "`CCPX'_CQ_Checks_$date.xlsx", sheet(FEMALE_AGE_NUMCHILDREN) keepcellformat modify
restore

*CLOSEST HEALTH FACILITY AND DISTANCE
cls
cd "$datadir"
use "`CCPX'_CQ_Clean_Data_with_Checks_$date.dta", clear
preserve
keep metainstanceID $GeoID RE facility_number facility_name SubmissionDate travel_time_m travel_time_h closest_hf_home 
keep if([closest_hf_home==1]&[travel_time_m>5 & !missing(travel_time_m)])
sort RE
egen No = seq()
order metainstanceID No $GeoID RE facility_number facility_name travel_time_m travel_time_h closest_hf_home 
capture noisily export excel using  "`CCPX'_CQ_Checks_$date.xlsx",  cell(A4) firstrow(varl)sheet(CLOSEST_HF_DISTANCE) sheetmodify 
putexcel A1=("COMPARE DISTANCE FROM THE WHERE THE RESPONDENT CAME FROM TO THEIR CLOSEST HEALTH FACILITY AND ASCERTAIN IF ITS FACTUAL") using "`CCPX'_CQ_Checks_$date.xlsx", sheet(CLOSEST_HF_DISTANCE) keepcellformat modify
restore

* ABSENCE OF UNIQUE FACILITY NUMBERS
preserve
drop if cei_result==2
keep metainstanceID RE facility_name facility_number SubmissionDate $GeoID
sort facility_number facility_name
duplicates drop facility_name, force
duplicates tag facility_number, gen(dup_facility_number)
drop if dup_facility_number==0
sort facility_number
egen No = seq()
order No $GeoID RE metainstanceID SubmissionDate facility_name facility_number
drop dup_facility_number
cd "$datadir"
capture noisily export excel using  "`CCPX'_CQ_Checks_$date.xlsx",  cell(A4) firstrow(varl)sheet(DUP_FACILITY_NUMBERS) sheetmodify 
version 14.0
putexcel A1=("SAME FACILITY NUMBER ASSIGNED TO DIFFERENT HEALTH FACILITIES") using "`CCPX'_CQ_Checks_$date.xlsx", sheet(DUP_FACILITY_NUMBERS) keepcellformat modify

* ABSENCE OF UNIQUE FACILITIES - MAY INDICATE DUPLICATES OR WRONG FACILITY NAME HAS BEEN CHOSEN/ENTERED
cls
* Set local/global macros for current today
cd "$datadir"
use "`CCPX'_CQ_Clean_Data_with_Checks_$date.dta", clear
keep metainstanceID RE facility_name facility_number SubmissionDate $GeoID cei_result
sort facility_number facility_name
duplicates drop facility_number, force
duplicates tag facility_name, gen(dup_facility_name)
drop if [dup_facility_name==0|facility_name=="other"]
sort facility_name
egen No = seq()
order No $GeoID RE metainstanceID SubmissionDate facility_name facility_number
drop dup_facility_name
cd "$datadir"
capture noisily export excel using  "`CCPX'_CQ_Checks_$date.xlsx",  cell(A4) firstrow(varl)sheet(REPEAT_FACILITY) sheetmodify 
version 14.0
putexcel A1=("A SINGLE FACILITY ASSIGNED DIFFERENT FACILITY NUMBERS") using "`CCPX'_CQ_Checks_$date.xlsx", sheet(REPEAT_FACILITY) keepcellformat modify

*********************************************************************************************************
			*******************Step 3: MERGE DATA********************
*********************************************************************************************************
*************************************************************************************************************************
***** MERGE DATA ACROSS SQ AND CQ 
*************************************************************************************************************************
run "$dofiledir/SQ_Datachecking_Parentfile.do"
sleep 10000
keep $GeoID RE facility_number facility_name facility_name_other
tostring facility_number, replace
replace facility_number=subinstr(facility_number," ","",.)
sort facility_number
rename * *_SQ
rename facility_number_SQ facility_number
destring facility_number, replace
duplicates drop facility_number, force
cd "`datadir'"
save "`CCPX'_SQ_SubSetData_$date.dta", replace

use "`CCPX'_CQ_Clean_Data_with_checks_$date", clear
keep metainstanceID RE facility_name facility_name_other facility_number submissiondate $GeoID cei_result
sort facility_number
rename * *_CQ
rename facility_number_CQ facility_number
merge m:1 facility_number using "`CCPX'_SQ_SubSetData_$date.dta", force
sort metainstanceID
egen No = seq()  
save "`CCPX'_CQ_SQ_CombinedSubset_$date.dta", replace

* CQ WITHOUT SQ
cd "$datadir"
use "`CCPX'_CQ_SQ_CombinedSubset_$date.dta", clear
drop if[_merge!=1]
capture noisily export excel using  "`CCPX'_CQ_Checks_$date.xlsx",  cell(A4) firstrow(varl)sheet(CQ_WITHOUT_SQ) sheetmodify 
putexcel A1=("CQ Facility Numbers THAT CANNOT BE LINKED TO SQ Facility Numbers - EITHER WRONG/MISSPELLED Facility NUMBERS, WRONG TARGET FACILITY OR NO FOLLOW UP DONE JUST YET.") using "`CCPX'_CQ_Checks_$date.xlsx", sheet(CQ_WITHOUT_SQ) keepcellformat modify


*SQ WITHOUT CQ
cd "$datadir"
use "`CCPX'_CQ_SQ_CombinedSubset_$date.dta", clear
drop if[_merge !=2]
cd "$prelim_results"
capture noisily export excel using "`CCPX'_CQ_Checks_$date.xlsx",  cell(A4) firstrow(varl)sheet(SQ_WITHOUT_CQ) sheetmodify 
putexcel A1=("SQ Facility Numbers THAT CANNOT BE LINKED TO CQ Facility Numbers - EITHER WRONG/MISSPELLED Facility NUMBERS, WRONG TARGET FACILITY OR NO CQ DONE JUST YET.") using "`CCPX'_CQ_Checks_$date.xlsx",sheet(SQ_WITHOUT_CQ) keepcellformat modify


*******************************************************************************
* SAVE, CLOSE LOG AND EXIT
*******************************************************************************
translate `CCPX'_CQ_DataCleaningQuality_$date.log `CCPX'_CQ_DataCleaningQuality_$date.pdf, replace


