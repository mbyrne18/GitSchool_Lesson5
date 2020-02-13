****PMA Data Quality Checks****
***This file cleans country specific variables, applies country specific weights if used, and drops unnecessary and identifying variables

set more off
********************************************************************************************************************
* Define local macros for all country specific variables 
local CCPX $CCPX
local all_methods_list 

********************************************************************************************************************
******************************All country specific variables need to be encoded here********************
*Facility Type
**Update corrected date of interview if phone had incorrect settings. Update to year/month of data collection
**Geographic Variables
**Survey language
* Methods List
****PMA Data Quality Checks****

*************************************************************
*************************  CQ ************************
*SDP Geographic Variables
local level1 $level1name
local level2 $level2name
local level3 $level3name
local level4 $level4name

forval y = 1/4 {
	capture confirm var level`y'
	if _rc==0 {
		rename level`y' `level`y''
		label var `level`y'' "`level`y''"
		}
	}

*Facility DOI
capture drop doi*

gen doi=system_date
replace doi=manual_date if manual_date!="." & manual_date!=""

split doi, gen(doisplit_)
capture drop wrongdate
*If survey spans across 2 years add | doisplit_3!=year2
gen wrongdate=1 if doisplit_3!="2019"
replace wrongdate=1 if doisplit_1!="Sep" & doisplit_1!="Oct" & doisplit_1!="Nov" & doisplit_1!="Dec" & doisplit_1!=""

gen doi_corrected=doi
replace doi_corrected=SubmissionDate if wrongdate==1 & SubmissionDate!=""
drop doisplit*

/* ---------------------------------------------------------
         SECTION 2: Renaming country specific variables
   --------------------------------------------------------- */

/* ---------------------------------------------------------
         SECTION 3: Encode select ones
   --------------------------------------------------------- */
 
   foreach var in method_prescribed fp_first_desired  {
encode `var', gen(`var'V2) lab(all_methods_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

encode facility_type, gen(facility_typeV2) lab(facility_type_list)
order facility_typeV2, after(facility_type)
drop facility_type
rename facility_typeV2 facility_type

encode school, gen(schoolV2) lab(school_list)
order schoolV2, after(school)
drop school
rename schoolV2 school

encode survey_language, gen(survey_languageV2) lab(language_list)
order survey_languageV2, after(survey_language)
drop survey_language
rename survey_languageV2 survey_language

label define school_list , replace
label define facility_type_list , replace
label define all_methods_list  , replace
label define language_list, replace

/* ---------------------------------------------------------
         SECTION 4: Split select multiple
   --------------------------------------------------------- */


/* ---------------------------------------------------------
         SECTION 5: Rename multiple select
   --------------------------------------------------------- */

/* ---------------------------------------------------------
         SECTION 6: Label variables that are country specific
--------------------------------------------------------- */
label var fp_first_desired "Which method did you initially want to use?"
label var method_prescribed "Which method(s) were you prescribed or given?"
label var facility_type "Type of facility"
label var school "What is the highest level of school you attended?"
label var survey_language "In what language was this interview conducted?"
/* ----------------------------------------------------------
		SECTION 7: DROP UNNECESSARY VARIABLES
 ---------------------------------------------------------- */
 
 
drop consent_warning


save, replace

