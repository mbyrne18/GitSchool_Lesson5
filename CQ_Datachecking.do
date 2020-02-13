*PMA Core Client Exit Interview Questionnaire Data Checking file 
**This .do file imports the Client Exit Interview Questionnaire (without roster) into Stata and cleans it 
 
clear matrix 
clear 
set more off 
label drop _all 
 
cd "$datadir"  
 
*Macros 
local CCPX $CCPX 
local CQcsv $CQcsv 
local CQcsv2 $CQcsv2 
 
local today=c(current_date) 
local date=subinstr("`today'", " ", "", .) 
 
*Import the CQ csv file and save a dta as is 
import delimited "$csvdir/`CQcsv'", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear 
save `CCPX'_CQ.dta, replace 
 
*If a second version of the form was used, append it to the dataset with the first version 
clear 
capture import delimited "$csvdir/`CQcsv2'.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear 
if _rc==0 { 
	tempfile tempCQ 
	save `tempCQ', replace 
 
	use `CCPX'_CQ.dta, clear 
	append using `tempCQ', force 
	save, replace 
	} 
 
use `CCPX'_CQ.dta, clear 

/* ---------------------------------------------------------
         SECTION 1: Drop columns
   --------------------------------------------------------- */

drop consent_start
drop services_note
drop age_check
drop ttgtravel_time_note
drop fp_services_note
drop vppvpp_note
drop vpovpo_note
drop client_satisfaction_note
drop twftime_wait_note
drop sect_flw
drop thankyou
drop thankyou_non_avail
drop sect_end
/* ---------------------------------------------------------
         SECTION 2: Rename
   --------------------------------------------------------- */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         SUBSECTION: Rename to original ODK names
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

rename dsystem_date system_date
rename dsystem_date_check system_date_check
rename ea EA
capture rename pssign sign
capture rename pscheckbox checkbox
capture rename v26 consent_obtained
rename ttgtravel_time_m travel_time_m
rename ttgtravel_time_h travel_time_h
rename vppexplain_label explain_label
rename vppexplain_method explain_method
rename vppexplain_side_effects explain_side_effects
rename vppexplain_problems explain_problems
rename vppexplain_follow_up explain_follow_up
rename vpodiscuss_label discuss_label
rename vpodiscuss_other_fp discuss_other_fp
rename vpodiscuss_hiv discuss_hiv
rename vpodiscuss_fp_prefs discuss_fp_prefs
rename vpodiscuss_switch discuss_switch
rename twftime_wait_m time_wait_m
rename twftime_wait_h time_wait_h



/* ---------------------------------------------------------
         SECTION 3: Destring
   --------------------------------------------------------- */

destring facility_number, replace
destring age, replace
destring birth_events, replace
destring travel_time_m, replace
destring travel_time_h, replace
destring method_duration_value, replace
destring time_wait_m, replace
destring time_wait_h, replace

/* ---------------------------------------------------------
         SECTION 4: Encode select ones
   --------------------------------------------------------- */

label define blank_list 1 "1"
label define cei_result_list 1 "completed" 2 "not_at_facility" 3 "postponed" 4 "refused" 5 "partly_completed" 96 "other"
label define decision_list 1 "you_alone" 2 "provider" 3 "partner" 4 "you_and_provider" 5 "you_and_partner" 96 "other" -88 "-88" -99 "-99"
label define how_clear_list 1 "very_clear" 2 "clear" 3 "somewhat_clear" 4 "not_clear" 5 "not_at_all_clear" -88 "-88" -99 "-99"
label define howtreat_list 1 "very_politely" 2 "politely" 3 "neither_politely" 4 "impolitely" 5 "very_impolitely" -99 "-99"
label define injectable_probe_list 1 "syringe" 2 "small_needle" -99 "-99"
label define ladder_list 1 "first_step" 2 "second" 3 "third" 4 "fourth" 5 "fifth" 6 "sixth" 7 "seventh" 8 "eigth" 9 "ninth" 10 "tenth" -99 "-99"
label define managing_list 1 "government" 2 "ngo" 3 "faith_based" 4 "private" 96 "other"
label define marital_status_list 1 "currently_married" 2 "currently_living_with_someone" 3 "divorced" 4 "widow" 5 "never_married" -99 "-99"
label define method_satisfaction 1 "very_satisfied" 2 "satisfied" 3 "neither_nor_satisfied" 4 "dissatisfied" 5 "very_dissatisfied" -99 "-99"
label define reason_visit_list 1 "sti" 2 "hiv_aids" 3 "maternal_health" 4 "child_health" 5 "general_health" 96 "other" -99 "-99"
label define switch_method_list 1 "same" 2 "another" 0 "no" -99 "-99"
label define travel_means_list 1 "motor_vehicle" 2 "bicycle" 3 "animal_cart" 4 "walking" -99 "-99"
label define visit_nearest_hf_list 1 "no_fp" 2 "inconv_hrs" 3 "bad_reputation" 4 "not_like_personnel" 5 "no_medicine" 6 "remain_anonymous" 7 "more_expensive" 8 "referred" 9 "less_convenient_loc" 10 "absent_provider" 96 "other" -88 "-88" -99 "-99"
label define whatgiven_today 1 "contraceptive_method" 2 "prescription_method" 3 "neither" -99 "-99"
label define whynomethod_list 1 "out_of_stock" 2 "unavailable" 3 "untrained" 4 "different" 5 "ineligible" 6 "decided_not_to_adopt" 7 "cost" 96 "other" -88 "-88" -99 "-99"
label define yes_no_dnk_nr_list 1 "yes" 0 "no" -88 "-88" -99 "-99"
label define yes_no_list 1 "yes" 0 "no"
label define yes_no_nr_list 1 "yes" 0 "no" -99 "-99"
label define fp_obtain_desired_list 1 "yes" 2 "no" 3 "follow_up" 4 "-99"


encode managing_authority, gen(managing_authorityV2) lab(managing_list)
order managing_authorityV2, after(managing_authority)
drop managing_authority
rename managing_authorityV2 managing_authority

encode marital_status, gen(marital_statusV2) lab(marital_status_list)
order marital_statusV2, after(marital_status)
drop marital_status
rename marital_statusV2 marital_status

encode hh_location_ladder, gen(hh_location_ladderV2) lab(ladder_list)
order hh_location_ladderV2, after(hh_location_ladder)
drop hh_location_ladder
rename hh_location_ladderV2 hh_location_ladder

encode reason_notvisit_hf, gen(reason_notvisit_hfV2) lab(visit_nearest_hf_list)
order reason_notvisit_hfV2, after(reason_notvisit_hf)
drop reason_notvisit_hf
rename reason_notvisit_hfV2 reason_notvisit_hf

encode travel_means, gen(travel_meansV2) lab(travel_means_list)
order travel_meansV2, after(travel_means)
drop travel_means
rename travel_meansV2 travel_means

encode reason_visit, gen(reason_visitV2) lab(reason_visit_list)
order reason_visitV2, after(reason_visit)
drop reason_visit
rename reason_visitV2 reason_visit

encode whatgiven_today, gen(whatgiven_todayV2) lab(whatgiven_today)
order whatgiven_todayV2, after(whatgiven_today)
drop whatgiven_today
rename whatgiven_todayV2 whatgiven_today

capture encode injectable_probe, gen(injectable_probeV2) lab(injectable_probe_list)
capture order injectable_probeV2, after(injectable_probe)
capture drop injectable_probe
capture rename injectable_probeV2 injectable_probe

encode switch_method, gen(switch_methodV2) lab(switch_method_list)
order switch_methodV2, after(switch_method)
drop switch_method
rename switch_methodV2 switch_method

encode method_duration_units, gen(method_duration_unitsV2) lab(dwmy_list)
order method_duration_unitsV2, after(method_duration_units)
drop method_duration_units
rename method_duration_unitsV2 method_duration_units

encode fp_obtain_desired, gen(fp_obtain_desiredV2) lab(fp_obtain_desired_list)
order fp_obtain_desiredV2, after(fp_obtain_desired)
drop fp_obtain_desired
rename fp_obtain_desiredV2 fp_obtain_desired


encode fp_obtain_desired_whynot, gen(fp_obtain_desired_whynotV2) lab(whynomethod_list)
order fp_obtain_desired_whynotV2, after(fp_obtain_desired_whynot)
drop fp_obtain_desired_whynot
rename fp_obtain_desired_whynotV2 fp_obtain_desired_whynot

encode fp_final_decision, gen(fp_final_decisionV2) lab(decision_list)
order fp_final_decisionV2, after(fp_final_decision)
drop fp_final_decision
rename fp_final_decisionV2 fp_final_decision

encode howclear_fp_info, gen(howclear_fp_infoV2) lab(how_clear_list)
order howclear_fp_infoV2, after(howclear_fp_info)
drop howclear_fp_info
rename howclear_fp_infoV2 howclear_fp_info

encode how_staff_treat, gen(how_staff_treatV2) lab(howtreat_list)
order how_staff_treatV2, after(how_staff_treat)
drop how_staff_treat
rename how_staff_treatV2 how_staff_treat

encode satisfied_services_today, gen(satisfied_services_todayV2) lab(method_satisfaction)
order satisfied_services_todayV2, after(satisfied_services_today)
drop satisfied_services_today
rename satisfied_services_todayV2 satisfied_services_today


encode cei_result, gen(cei_resultV2) lab(cei_result_list)
order cei_resultV2, after(cei_result)
drop cei_result
rename cei_resultV2 cei_result

foreach var in system_date_check available begin_interview consent_obtained {
encode `var', gen(`var'V2) lab(yes_no_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

cap foreach var in checkbox witness_auto  {
encode `var', gen(`var'V2) lab(blank_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}


foreach var in fp_info_yn fp_reason_yn provider_discuss_fp_today method_used_before_yn ///
               method_used_before_12m fp_paid pill_counsel inj_counsel explain_label ///
               explain_method explain_side_effects explain_problems explain_follow_up discuss_label ///
               discuss_other_fp discuss_hiv discuss_fp_prefs discuss_switch allow_question ///
               understand_answer discuss_pro_con_delay flw_willing flw_number_yn  {
encode `var', gen(`var'V2) lab(yes_no_nr_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

foreach var in closest_hf_home refer_hf return_to_facility  {
encode `var', gen(`var'V2) lab(yes_no_dnk_nr_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}


label define blank_list 1 "", replace
label define cei_result_list 1 "Completed" 2 "Not at facility" 3 "Postponed" 4 "Refused" 5 "Partly completed" 96 "Other", replace
label define decision_list 1 "Respondent alone" 2 "Provider" 3 "Partner" 4 "Respondent and provider" 5 "Respondent and partner" 96 "Other" -88 "Do not know" -99 "No response", replace
label define how_clear_list 1 "Very clear" 2 "Clear" 3 "Somewhat clear" 4 "Not clear" 5 "Not at all clear" -88 "Do not know" -99 "No response", replace
label define howtreat_list 1 "Very politely" 2 "Politely" 3 "Neither politely nor impolitely" 4 "Impolitely" 5 "Very impolitely" -99 "No response", replace
label define injectable_probe_list 1 "Syringe" 2 "Small needle (Sayana Press)" -99 "No Response", replace
label define ladder_list 1 "One (poorest)" 2 "Two" 3 "Three" 4 "Four" 5 "Five" 6 "Six" 7 "Seven" 8 "Eight" 9 "Nine" 10 "Ten (richest)" -99 "No response", replace
label define managing_list 1 "Government" 2 "NGO" 3 "Faith-based organization" 4 "Private" 96 "Other", replace
label define marital_status_list 1 "Yes, currently married" 2 "Yes, living with a man" 3 "Not currently in union: Divorced / separated" 4 "Not currently in union: Widow" 5 "No, never in union" -99 "No response", replace
label define method_satisfaction 1 "Very satisfied" 2 "Satisfied" 3 "Neither satisfied nor dissatisfied" 4 "Dissatisfied" 5 "Very dissatisfied" -99 "No response", replace
label define reason_visit_list 1 "STI" 2 "HIV/AIDS" 3 "Maternal health" 4 "Child health" 5 "General health" 96 "Other" -99 "No response", replace
label define switch_method_list 1 "Same method" 2 "Another method" 0 "No method" -99 "No response", replace
label define travel_means_list 1 "Motor vehicle (car, motorcycle, bus)" 2 "Bicycle / pedicab" 3 "Animal drawn cart" 4 "Walking" -99 "No response", replace
label define visit_nearest_hf_list 1 "No family planning services" 2 "Inconvenient operating hours" 3 "Bad reputation / Bad prior experience" 4 "Do not like personnel" 5 "No medicine" 6 "Prefers to remain anonymous" 7 "It is more expensive than other options" 8 "Was referred" 9 "Less convenient location" 10 "Absence of provider" 96 "Other" -88 "Do not know" -99 "No response", replace
label define whatgiven_today 1 "A contraceptive method" 2 "A prescription for a method" 3 "Neither" -99 "No response", replace
label define whynomethod_list 1 "Method out of stock" 2 "Method not available at all" 3 "Provider not trained to provide the method" 4 "Provider recommended a different method" 5 "Not eligible for method" 6 "Decided not to adopt a method" 7 "Too costly" 96 "Other" -88 "Do not know" -99 "No response", replace
label define yes_no_dnk_nr_list 1 "Yes" 0 "No" -88 "Do not know" -99 "No response", replace
label define yes_no_list 1 "Yes" 0 "No", replace
label define yes_no_nr_list 1 "Yes" 0 "No" -99 "No response", replace
label define fp_obtain_desired_list 1 "Yes" 2 "No" 3 "Neither, follow-up visit only" 4 "No response", replace


/* ---------------------------------------------------------
         SECTION 5: Split select multiples
   --------------------------------------------------------- */

label define o2s_binary_label 0 No 1 Yes


***** Begin split of "method_pro"
* Create padded variable
gen method_proV2 = " " + method_pro + " "

* Build binary variables for each choice
gen method_pro_efficacy = 0 if method_pro != ""
replace method_pro_efficacy = 1 if strpos(method_proV2, " efficacy ")
label var method_pro_efficacy "Advantages provider told you about your FP method:Efficacy"

gen method_pro_lessbleeding = 0 if method_pro != ""
replace method_pro_lessbleeding = 1 if strpos(method_proV2, " less_bleeding ")
label var method_pro_lessbleeding "Advantages provider told you about your FP method:Less bleeding"

gen method_pro_morebleeding = 0 if method_pro != ""
replace method_pro_morebleeding = 1 if strpos(method_proV2, " more_bleeding ")
label var method_pro_morebleeding "Advantages provider told you about your FP method:More regular bleeding"

gen method_pro_protectlong = 0 if method_pro != ""
replace method_pro_protectlong = 1 if strpos(method_proV2, " protect_long ")
label var method_pro_protectlong "Advantages provider told you about your FP method:Long term protection"

gen method_pro_nohormones = 0 if method_pro != ""
replace method_pro_nohormones = 1 if strpos(method_proV2, " no_hormones ")
label var method_pro_nohormones "Advantages provider told you about your FP method:No hormones"

gen method_pro_ease = 0 if method_pro != ""
replace method_pro_ease = 1 if strpos(method_proV2, " ease ")
label var method_pro_ease "Advantages provider told you about your FP method:Ease of use"

gen method_pro_fertility = 0 if method_pro != ""
replace method_pro_fertility = 1 if strpos(method_proV2, " fertility ")
label var method_pro_fertility "Advantages provider told you about your FP method:Return to fertility"

gen method_pro_discrete = 0 if method_pro != ""
replace method_pro_discrete = 1 if strpos(method_proV2, " discrete ")
label var method_pro_discrete "Advantages provider told you about your FP method:Discrete"

gen method_pro_fewsideeffects = 0 if method_pro != ""
replace method_pro_fewsideeffects = 1 if strpos(method_proV2, " few_side_effects ")
label var method_pro_fewsideeffects "Advantages provider told you about your FP method:Few side effects"

gen method_pro_other = 0 if method_pro != ""
replace method_pro_other = 1 if strpos(method_proV2, " other ")
label var method_pro_other "Advantages provider told you about your FP method:Other"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order method_pro_efficacy-method_pro_other, after(method_pro)
label values method_pro_efficacy-method_pro_other o2s_binary_label
drop method_proV2

***** Begin split of "method_con"
* Create padded variable
gen method_conV2 = " " + method_con + " "

* Build binary variables for each choice
gen method_con_irregularbleeding = 0 if method_con != ""
replace method_con_irregularbleeding = 1 if strpos(method_conV2, " irregular_bleeding ")
label var method_con_irregularbleeding "Disadvantages provider told you about your FP method:Irregular bleeding"

gen method_con_morebleeding = 0 if method_con != ""
replace method_con_morebleeding = 1 if strpos(method_conV2, " more_bleeding ")
label var method_con_morebleeding "Disadvantages provider told you about your FP method:More bleeding"

gen method_con_lessperiods = 0 if method_con != ""
replace method_con_lessperiods = 1 if strpos(method_conV2, " less_periods ")
label var method_con_lessperiods "Disadvantages provider told you about your FP method:Few/no periods"

gen method_con_weightgain = 0 if method_con != ""
replace method_con_weightgain = 1 if strpos(method_conV2, " weight_gain ")
label var method_con_weightgain "Disadvantages provider told you about your FP method:Weight gain"

gen method_con_nausea = 0 if method_con != ""
replace method_con_nausea = 1 if strpos(method_conV2, " nausea ")
label var method_con_nausea "Disadvantages provider told you about your FP method:Nausea"

gen method_con_cramping = 0 if method_con != ""
replace method_con_cramping = 1 if strpos(method_conV2, " cramping ")
label var method_con_cramping "Disadvantages provider told you about your FP method:Cramping"

gen method_con_noteasy = 0 if method_con != ""
replace method_con_noteasy = 1 if strpos(method_conV2, " not_easy ")
label var method_con_noteasy "Disadvantages provider told you about your FP method:Not easy to use"

gen method_con_noteffective = 0 if method_con != ""
replace method_con_noteffective = 1 if strpos(method_conV2, " not_effective ")
label var method_con_noteffective "Disadvantages provider told you about your FP method:Not very effective"

gen method_con_headache = 0 if method_con != ""
replace method_con_headache = 1 if strpos(method_conV2, " headache ")
label var method_con_headache "Disadvantages provider told you about your FP method:Headache"

gen method_con_other = 0 if method_con != ""
replace method_con_other = 1 if strpos(method_conV2, " other ")
label var method_con_other "Disadvantages provider told you about your FP method:Other"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order method_con_irregularbleeding-method_con_other, after(method_con)
label values method_con_irregularbleeding-method_con_other o2s_binary_label
drop method_conV2


/* ---------------------------------------------------------
         SECTION 6: Label variable
   --------------------------------------------------------- */

label var system_date "Current date and time."
label var system_date_check "Is this date and time correct?"
label var manual_date "Record the correct date and time."
label var EA "Enumeration Area"
label var facility_number "Facility number"
label var facility_type "Type of facility"
label var advanced_facility "Facility is advanced facility"
label var managing_authority "Managing authority"
label var available "Is a competent respondent present and available to be interviewed today?"
capture label var sign "Respondent's signature"
capture label var checkbox "Checkbox"
capture label var begin_interview "May I begin the interview now?"
capture label var firstname_raw "Respondent’s name"
capture label var witness_auto "Interviewer's ID:"
capture label var witness_manual "Interviewer's ID. Please record your ID as a witness to the consent process."
label var facility_name_other "Name of the facility (Manual)"
label var fp_info_yn "Did you receive any FP information or a method during your visit today?"
label var age "How old were you at your last birthday?"
label var marital_status "Are you currently married or living together with a man as if married?"
label var birth_events "How many times have you given birth?"
label var hh_location_ladder "On a 10-step ladder, where is your household located today?"
label var closest_hf_home "Is this the closest health facility to your current residence?"
label var reason_notvisit_hf "What was the main reason you did not go to the facility nearest to your home?"
label var travel_time_m "How much time did it take you to travel here today in minutes"
label var travel_time_h "How much time did it take you to travel here today in hours"
label var travel_means "What means of transportation did you use to travel here?"
label var fp_reason_yn "Was family planning the main reason you came here today?"
label var reason_visit "What was the main reason for your visit today?"
label var whatgiven_today "What were you given at your family planning visit today?"
label var provider_discuss_fp_today "Did your provider discuss family planning with you today?"
capture label var injectable_probe "PROBE: Was the injection administered via syringe or small needle?"
label var switch_method "Were you using the same method, using no method or switch from another method?"
label var method_duration_units "How long have you been using this method without stopping?"
label var method_duration_value "Enter a value for ${method_duration_lab}:"
label var method_used_before_yn "Have you ever used this method before?"
label var method_used_before_12m "Have you used it in the past 12 months?"
label var fp_obtain_desired "During today's visit, did you obtain the method of family planning you wanted?"
label var fp_obtain_desired_whynot "Why didn't you obtain the method you wanted?"
label var fp_final_decision "Who made the final decision about what method you got today?"
label var fp_paid "Did you pay for any of the FP services you received or were provided today?"
label var pill_counsel "Counselled on higher chances of pregnancy if you do not take the pill every day?"
label var inj_counsel "Counselled on higher chances of pregnancy if you are >1 month late for shot?"
label var explain_method "During today's visit the provider:Explain how to use the method?"
label var explain_side_effects "During today's visit the provider:Talk about possible side effects?"
label var explain_problems "During today's visit the provider:Tell you what to do if you have problems?"
label var explain_follow_up "During today's visit the provider:Tell you when to return for follow-up?"
label var discuss_other_fp "During today's visit the provider:Tell you about other FP methods"
label var discuss_hiv "During today's visit the provider:talk about FP methods that protect against STI"
label var discuss_fp_prefs "During today's visit the provider:As your FP method of preference"
label var discuss_switch "During today's visit the provider:Tell you could switch FP method in the future?"
label var howclear_fp_info "How clear was the family planning information you received today?"
label var allow_question "Did the provider allow you to ask questions?"
label var understand_answer "Did the provider answer all your questions in a way you understood?"
label var discuss_pro_con_delay "During today's visit the provider:Tell you advan/disadvan with FP method"
label var method_pro "What advantages did the provider tell you about your FP method"
label var method_con "What disadvantages did the provider tell you about your FP method"
label var time_wait_m "How long did you wait at the facility to see a provider today in minutes?"
label var time_wait_h "How long did you wait at the facility to see a provider today in hours?"
label var how_staff_treat "During this visit how politely did the provider and other staff treat you?"
label var satisfied_services_today "Overall, how satisfied are you with the FP services you received today?"
label var refer_hf "Would you refer your relative or friend to this facility?"
label var return_to_facility "Would you return to this facility?"
label var flw_willing "Could we contact you via phone to update this information in the next 4 months?"
label var flw_number_yn "Do you own a phone?"
label var flw_number_typed "Can I have your primary phone number to follow up with you in the future?"
label var flw_number_confirm "Can you repeat the number again?"
label var cei_result "Record the result of the Client Exit Interview Questionnaire."
label var advanced_facility "Facility is an advanced facility"
label var start "SDP interview start time"
label var end "SDP interview end time"
label var today "Date of interview (string)"
label var this_country "PMA Country"
cap label var consent_obtained "Is consent obtained?"

/* --------------------------------------------------------- 
         SECTION 7: Format Dates 
   --------------------------------------------------------- */ 
**Change date variable of upload from scalar to stata time (SIF) 
*Drop the day of the week of the interview and the UST 
foreach var in submissiondate system_date manual_date start end { 
	gen double `var'SIF=clock(`var', "MDYhms") 
	format `var'SIF %tc 
	local `var'_lab : variable label `var' 
	label var `var'SIF "``var'_lab' SIF" 
	order `var'SIF, after(`var') 
	}  
 
gen double todaySIF=date(today, "YMD") 
format todaySIF %td 
label var todaySIF "Today's date SIF" 
order todaySIF, after(today) 

label var startSIF "SDP interview start time (SIF)"
label var endSIF "SDP interview end time (SIF)"

/* --------------------------------------------------------- 
         SECTION 8: Additional Cleaning 
   --------------------------------------------------------- */ 
rename submissiondate* SubmissionDate* 

**RE
replace your_name=name_typed if missing(your_name)
rename your_name RE

  
**Check any complete duplicates, duplicates of metainstanceid, and duplicates of SDP
duplicates report                                                                                                                                                                                                                                                                                                                                                                                                                            
rename metainstanceid metainstanceID 
duplicates report metainstanceID 
duplicates tag metainstanceID, gen (dupmeta) 
duplicates tag facility_number, gen(dup_fac_num) 
save `CCPX'_CQ_`date'.dta, replace 
 
