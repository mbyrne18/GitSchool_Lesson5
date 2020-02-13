****PMA Data Quality Checks****
***This file cleans country specific variables, applies country specific weights if used, recodes current method, and drops unnecessary and identifying variables

set more off

local CCPX $CCPX

********************************************************************************************************************
******************************All country specific variables need to be encoded here********************

*Facility Type
**Update corrected date of interview if phone had incorrect settings. Update to year/month of data collection
**Geographic Variables
**Survey language
* Methods List

*************************************************************
*************************  SDP ************************
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
* Staffing variables may need to be updated by country
rename sdstaffing_doctor_tot staffing_doctor_tot
rename sdstaffing_doctor_here staffing_doctor_here
rename scostaffing_clinic_officer_tot staffing_clinic_officer_tot
rename scostaffing_clinic_officer_here staffing_clinic_officer_here
rename snstaffing_nurse_tot staffing_nurse_tot
rename snstaffing_nurse_here staffing_nurse_here
rename smastaffing_ma_tot staffing_MA_tot
rename smastaffing_ma_here staffing_MA_here
rename sppharmacist_tot pharmacist_tot
rename sppharmacist_here pharmacist_here
rename sptstaffing_pharm_tech_tot staffing_pharm_tech_tot
rename sptstaffing_pharm_tech_here staffing_pharm_tech_here
rename sostaffing_other_tot staffing_other_tot
rename sostaffing_other_here staffing_other_here
rename lmglinda_mama_adult linda_mama_adult
rename lmglinda_mama_child linda_mama_child

/* ---------------------------------------------------------
         SECTION 3: Destring country specific variables
   --------------------------------------------------------- */
destring staffing_doctor_tot, replace
destring staffing_doctor_here, replace
destring staffing_clinic_officer_tot, replace
destring staffing_clinic_officer_here, replace
destring staffing_nurse_tot, replace
destring staffing_nurse_here, replace
destring staffing_MA_tot, replace
destring staffing_MA_here, replace
destring pharmacist_tot, replace
destring pharmacist_here, replace
destring staffing_pharm_tech_tot, replace
destring staffing_pharm_tech_here, replace
destring staffing_other_tot, replace
destring staffing_other_here, replace
destring linda_mama_adult, replace
destring linda_mama_child, replace

/* ---------------------------------------------------------
         SECTION 4: Encode select ones
   --------------------------------------------------------- */
label define facility_type_list , replace
   
encode facility_type, gen(facility_typeV2) lab(facility_type_list)
order facility_typeV2, after(facility_type)
drop facility_type
rename facility_typeV2 facility_type

label define language_list , replace

encode survey_language, gen(survey_languageV2) lab(language_list)
order survey_languageV2, after(survey_language)
drop survey_language
rename survey_languageV2 survey_language


/* ---------------------------------------------------------
         SECTION 5: Split select multiples
   --------------------------------------------------------- */

/* ---------------------------------------------------------
         SECTION 6: Label variables that are country specific
   --------------------------------------------------------- */

label var staffing_doctor_tot "Total number: doctors"
label var staffing_doctor_here "Present today : doctors"
label var staffing_clinic_officer_tot "Total number: clinical officers"
label var staffing_clinic_officer_here "Present today : clinical officers"
label var staffing_nurse_tot "Total number: nurses"
label var staffing_nurse_here "Present today : nurses"
label var staffing_MA_tot "Total number: medical assistants / Nurse Aids"
label var staffing_MA_here "Present today: medical assistants / Nurse Aids"
label var pharmacist_tot "Total number: pharmacists"
label var pharmacist_here "Present today: pharmacists"


save, replace

