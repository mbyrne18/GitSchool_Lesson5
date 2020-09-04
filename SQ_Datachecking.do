*PMA Core SDP Questionnaire Data Checking file 
**This .do file imports the SDP Questionnaire (without roster) into Stata and cleans it 
 
clear matrix 
clear 
set more off 
label drop _all 
 
cd "$datadir"  
 
*Macros 
local CCPX $CCPX 
local SQcsv $SQcsv 
local SQcsv2 $SQcsv2 
 
local today=c(current_date) 
local date=subinstr("`today'", " ", "", .) 
 
*Import the SQ csv file and save a dta as is 
import delimited "$csvdir/`SQcsv'.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear 
save `CCPX'_SQ.dta, replace 
 
*If a second version of the form was used, append it to the dataset with the first version 
clear 
capture import delimited "$csvdir/`SQcsv2'.csv", charset("utf-8") delimiters(",") stringcols(_all) bindquote(strict) clear 
if _rc==0 { 
	tempfile tempSQ 
	save `tempSQ', replace 
 
	use `CCPX'_SQ.dta, clear 
	append using `tempSQ', force 
	save, replace 
	} 
 
use `CCPX'_SQ.dta, clear 

/* ---------------------------------------------------------
         SECTION 1: Drop columns
   --------------------------------------------------------- */

drop consent_start
drop consent_warning
drop sect_services_info
drop staffing_prompt
drop sect_fps_info
drop sect_fp_methods_note
drop fpcfpc_note
drop fpffpf_note
drop rgsregb_note
drop stockout_note
drop sect_fp_service_integration_note
drop thankyou
drop sect_end
drop low_volume_note
drop high_volume_note
/* ---------------------------------------------------------
         SECTION 2: Rename
   --------------------------------------------------------- */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         SUBSECTION: Rename to original ODK names
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

rename dsystem_date system_date
rename dsystem_date_check system_date_check
rename ea EA
rename pssign sign
rename pscheckbox checkbox
rename fpcfpc_label fpc_label
rename fpcfster_charged fster_charged
rename fpcmster_charged mster_charged
cap rename fpcimpl_charged impl_charged
rename fpciud_charged iud_charged
cap rename fpcinjdp_charged injdp_charged
cap rename fpcinjsp_charged injsp_charged
rename fpcpill_charged pill_charged
rename fpcec_charged ec_charged
rename fpcmc_charged mc_charged
rename fpcfc_charged fc_charged
rename fpcdia_charged dia_charged
rename fpcfoam_charged foam_charged
rename fpcbeads_charged beads_charged
rename fpccharged_joined charged_joined
rename fpcfpc_other fpc_other
rename fpffster_fees fster_fees
rename fpfmster_fees mster_fees
rename fpfimpl_fees impl_fees
rename fpfiud_fees iud_fees
rename fpfinjdp_fees injdp_fees
rename fpfinjsp_fees injsp_fees
rename fpfpill_fees pill_fees
rename fpfec_fees ec_fees
rename fpfmc_fees mc_fees
rename fpffc_fees fc_fees
rename fpfdia_fees dia_fees
rename fpffoam_fees foam_fees
rename fpfbeads_fees beads_fees
rename iud_insert IUD_insert
rename iud_remove IUD_remove
rename iud_supplies IUD_supplies
rename rfsfster_tot fster_tot
rename rmsmster_tot mster_tot
cap rename rimimpl_tot impl_tot
cap rename rimimpl_new impl_new
rename riuiud_tot iud_tot
rename riuiud_new iud_new
cap rename rdpinjdp_tot injdp_tot
cap rename rdpinjdp_new injdp_new
cap rename rspinjsp_tot injsp_tot
cap rename rspinjsp_new injsp_new
rename rppill_tot pill_tot
rename rppill_new pill_new
rename recec_tot ec_tot
rename recec_new ec_new
rename rmcmc_tot mc_tot
rename rmcmc_new mc_new
rename rfcfc_tot fc_tot
rename rfcfc_new fc_new
rename rdidia_tot dia_tot
rename rdidia_new dia_new
rename rfofoam_tot foam_tot
rename rfofoam_new foam_new
rename rbdbeads_tot beads_tot
rename rbdbeads_new beads_new
cap rename rgsimpl_units impl_units
rename rgsiud_units iud_units
cap rename rgsinjdp_units injdp_units
cap rename rgsinjsp_units injsp_units
rename rgspill_units pill_units
rename rgsec_units ec_units
rename rgsmc_units mc_units
rename rgsfc_units fc_units
rename rgsdia_units dia_units
rename rgsfoam_units foam_units
rename rgsbeads_units beads_units
rename stock_iud stock_IUD
rename stockout_days_iud stockout_days_IUD
rename stockout_3mo_iud stockout_3mo_IUD
rename stockout_why_iud stockout_why_IUD
rename ship_iud_units ship_IUD_units
rename ship_iud_lab ship_IUD_lab
rename ship_iud_value ship_IUD_value
rename hiv_services HIV_services
rename hiv_condom HIV_condom
rename hiv_other_fp HIV_other_fp
rename sdp_photo SDP_photo
rename sdp_result SDP_result



/* ---------------------------------------------------------
         SECTION 3: Destring
   --------------------------------------------------------- */

destring facility_number, replace
destring handwashing_stations, replace
destring fp_days, replace
destring num_fp_volunteers, replace
cap destring mobile_outreach_12mo, replace
cap destring mobile_outreach_6mo, replace
destring fster_fees, replace
destring mster_fees, replace
cap destring impl_fees, replace
destring iud_fees, replace
cap destring injdp_fees, replace
cap destring injsp_fees, replace
destring pill_fees, replace
destring ec_fees, replace
destring mc_fees, replace
destring fc_fees, replace
destring dia_fees, replace
destring foam_fees, replace
destring beads_fees, replace
destring fster_tot, replace
destring mster_tot, replace
cap destring impl_tot, replace
cap destring impl_new, replace
destring iud_tot, replace
destring iud_new, replace
cap destring injdp_tot, replace
cap destring injdp_new, replace
cap destring injsp_tot, replace
cap destring injsp_new, replace
destring pill_tot, replace
destring pill_new, replace
destring ec_tot, replace
destring ec_new, replace
destring mc_tot, replace
destring mc_new, replace
destring fc_tot, replace
destring fc_new, replace
destring dia_tot, replace
destring dia_new, replace
destring foam_tot, replace
destring foam_new, replace
destring beads_tot, replace
destring beads_new, replace
cap destring impl_units, replace
destring iud_units, replace
cap destring injdp_units, replace
cap destring injsp_units, replace
destring pill_units, replace
destring ec_units, replace
destring mc_units, replace
destring fc_units, replace
destring dia_units, replace
destring foam_units, replace
destring beads_units, replace
cap destring stockout_days_implants, replace
cap destring ship_implants_value, replace
destring stockout_days_IUD, replace
destring ship_IUD_value, replace
cap destring stockout_days_sp, replace
cap destring ship_sp_value, replace
cap destring stockout_days_dp, replace
cap destring ship_dp_value, replace
destring stockout_days_injectables, replace
destring ship_injectables_value, replace
destring stockout_days_pills, replace
destring ship_pills_value, replace
destring stockout_days_ec, replace
destring ship_ec_value, replace
destring stockout_days_male_condoms, replace
destring ship_male_condoms_value, replace
destring stockout_days_female_condoms, replace
destring ship_female_condoms_value, replace
destring stockout_days_diaphragm, replace
destring ship_diaphragm_value, replace
destring stockout_days_foam, replace
destring ship_foam_value, replace
destring stockout_days_beads, replace
destring ship_beads_value, replace

/* ---------------------------------------------------------
         SECTION 4: Encode select ones
   --------------------------------------------------------- */

label define SDP_result_list 1 "completed" 2 "not_at_facility" 3 "postponed" 4 "refused" 5 "partly_completed" 96 "other"
label define blank_list 1 "1"
label define managing_list 1 "government" 2 "NGO" 3 "faith_based" 4 "private" 96 "other"
label define out_of_stock_reason_list 1 "no_order" 2 "ordered_no_shipment" 3 "ordered_wrong_quantity" 4 "received_wrong_quantity" 5 "increase_consumption" 96 "other" -88 "-88" -99 "-99"
label define positions_list 1 "1" 2 "2" 3 "3" -99 "-99"
label define sel_nr_list 1 "selected" -99 "-99"
label define stock_list 1 "instock_obs" 2 "instock_unobs" 3 "outstock" -99 "-99"
label define visits_list 1 "1" 2 "2" 3 "3"
label define weeks_months_list 1 "weeks" 2 "months" -88 "-88" -99 "-99"
label define yes_no_dnk_nr_list 1 "yes" 0 "no" -88 "-88" -99 "-99"
label define yes_no_list 1 "yes" 0 "no"
label define yes_no_nr_list 1 "yes" 0 "no" -99 "-99"


encode managing_authority, gen(managing_authorityV2) lab(managing_list)
order managing_authorityV2, after(managing_authority)
drop managing_authority
rename managing_authorityV2 managing_authority

encode position, gen(positionV2) lab(positions_list)
order positionV2, after(position)
drop position
rename positionV2 position

encode fpc_other, gen(fpc_otherV2) lab(sel_nr_list)
order fpc_otherV2, after(fpc_other)
drop fpc_other
rename fpc_otherV2 fpc_other

encode times_visited, gen(times_visitedV2) lab(visits_list)
order times_visitedV2, after(times_visited)
drop times_visited
rename times_visitedV2 times_visited


encode SDP_result, gen(SDP_resultV2) lab(SDP_result_list)
order SDP_resultV2, after(SDP_result)
drop SDP_result
rename SDP_resultV2 SDP_result

cap foreach var in system_date_check available begin_interview fpc_label ///
               fster_charged mster_charged impl_charged iud_charged injdp_charged injsp_charged ///
               pill_charged ec_charged mc_charged fc_charged dia_charged foam_charged beads_charged ///
               photo_permission  {
encode `var', gen(`var'V2) lab(yes_no_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

foreach var in checkbox witness_auto  {
encode `var', gen(`var'V2) lab(blank_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

cap foreach var in elec_cur water_cur fp_offered fp_community_health_volunteers fees_rw implant_insert ///
               implant_remove IUD_insert IUD_remove inserted_impl_today removed_impl_today ///
               removed_deep_impl_today refer_impl_today rega_note postpartum_fp postnatal_fp ///
               fp_during_postabortion HIV_services  {
encode `var', gen(`var'V2) lab(yes_no_nr_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

cap foreach var in elec_rec water_rec stockout_3mo_implants stockout_3mo_IUD stockout_3mo_sp stockout_3mo_dp ///
               stockout_3mo_injectables stockout_3mo_pills stockout_3mo_ec stockout_3mo_male_condoms ///
               stockout_3mo_female_condoms stockout_3mo_diaphragm stockout_3mo_foam stockout_3mo_beads ///
               miso_available miso_mife_available HIV_condom HIV_other_fp  {
encode `var', gen(`var'V2) lab(yes_no_dnk_nr_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

cap foreach var in stock_implants stock_IUD stock_sp stock_dp stock_injectables stock_pills stock_ec ///
               stock_male_condoms stock_female_condoms stock_diaphragm stock_foam stock_beads miso_seen ///
               miso_mife_seen  {
encode `var', gen(`var'V2) lab(stock_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

cap foreach var in stockout_why_implants stockout_why_IUD stockout_why_sp stockout_why_dp ///
               stockout_why_injectables stockout_why_pills stockout_why_ec stockout_why_male_condoms ///
               stockout_why_female_condoms stockout_why_diaphragm stockout_why_foam stockout_why_beads  {
encode `var', gen(`var'V2) lab(out_of_stock_reason_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

cap foreach var in ship_implants_units ship_IUD_units ship_sp_units ship_dp_units ship_injectables_units ///
               ship_pills_units ship_ec_units ship_male_condoms_units ship_female_condoms_units ///
               ship_diaphragm_units ship_foam_units ship_beads_units  {
encode `var', gen(`var'V2) lab(weeks_months_list)
order `var'V2, after(`var')
drop `var'
rename `var'V2 `var'
}

label define SDP_result_list 1 "Completed" 2 "Not at facility" 3 "Postponed" 4 "Refused" 5 "Partly completed" 96 "Other", replace
label define blank_list 1 "", replace
label define managing_list 1 "Government" 2 "NGO" 3 "Faith-based organization" 4 "Private" 96 "Other", replace
label define out_of_stock_reason_list 1 "Did not place order for shipment" 2 "Ordered but did not receive shipment" 3 "Did not order right quantities" 4 "Ordered but did not receive right quantities" 5 "Unexpected increase in consumption" 96 "Other" -88 "Don’t know" -99 "No response", replace
label define positions_list 1 "Owner" 2 "In-charge / manager" 3 "Staff" -99 "No response", replace
label define sel_nr_list 1 "Respondent answered" -99 "No response", replace
label define stock_list 1 "In-stock and observed" 2 "In-stock but not observed" 3 "Out of stock" -99 "No response", replace
label define visits_list 1 "1st time" 2 "2nd time" 3 "3rd time", replace
label define weeks_months_list 1 "X weeks" 2 "X months" -88 "Don’t know" -99 "No response", replace
label define yes_no_dnk_nr_list 1 "Yes" 0 "No" -88 "Do not know" -99 "No response", replace
label define yes_no_list 1 "Yes" 0 "No", replace
label define yes_no_nr_list 1 "Yes" 0 "No" -99 "No response", replace

/* ---------------------------------------------------------
         SECTION 5: Split select multiples
   --------------------------------------------------------- */

label define o2s_binary_label 0 No 1 Yes


***** Begin split of "handwashing_observations_staff"
* Create padded variable
gen handwashing_observations_staffV2 = " " + handwashing_observations_staff + " "

* Build binary variables for each choice
gen handwashing_obser_soap = 0 if handwashing_observations_staff != ""
replace handwashing_obser_soap = 1 if strpos(handwashing_observations_staffV2, " soap ")
label var handwashing_obser_soap "May I see a nearby handwashing facility that is used by staff? : Soap is present"

gen handwashing_obser_storedwater = 0 if handwashing_observations_staff != ""
replace handwashing_obser_storedwater = 1 if strpos(handwashing_observations_staffV2, " stored_water ")
label var handwashing_obser_storedwater "May I see a nearby handwashing facility that is used b : Stored water is present"

gen handwashing_obser_tapwater = 0 if handwashing_observations_staff != ""
replace handwashing_obser_tapwater = 1 if strpos(handwashing_observations_staffV2, " tap_water ")
label var handwashing_obser_tapwater "May I see a nearby handwashing facility that is used  : Running water is present"

gen handwashing_obser_nearsanitation = 0 if handwashing_observations_staff != ""
replace handwashing_obser_nearsanitation = 1 if strpos(handwashing_observations_staffV2, " near_sanitation ")
label var handwashing_obser_nearsanitation "May I see a nearby handwashing  : Handwashing area is near a sanitation facility"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order handwashing_obser_soap-handwashing_obser_nearsanitation, after(handwashing_observations_staff)
label values handwashing_obser_soap-handwashing_obser_nearsanitation o2s_binary_label
drop handwashing_observations_staffV2

***** Begin split of "methods_offered"
* Create padded variable
gen methods_offeredV2 = " " + methods_offered + " "

* Build binary variables for each choice
gen methods_offered_malecondoms = 0 if methods_offered != ""
replace methods_offered_malecondoms = 1 if strpos(methods_offeredV2, " male_condoms ")
label var methods_offered_malecondoms "Do the community health volunteers provide any of the following contra : Condoms"

gen methods_offered_pill = 0 if methods_offered != ""
replace methods_offered_pill = 1 if strpos(methods_offeredV2, " pill ")
label var methods_offered_pill "Do the community health volunteers provide any of the following contrace : Pills"

gen methods_offered_injectables = 0 if methods_offered != ""
replace methods_offered_injectables = 1 if strpos(methods_offeredV2, " injectables ")
label var methods_offered_injectables "Do the community health volunteers provide any of the following co : Injectables"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order methods_offered_malecondoms-methods_offered_injectables, after(methods_offered)
label values methods_offered_malecondoms-methods_offered_injectables o2s_binary_label
drop methods_offeredV2

***** Begin split of "adolescents"
* Create padded variable
gen adolescentsV2 = " " + adolescents + " "

* Build binary variables for each choice
gen adolescents_counseled = 0 if adolescents != ""
replace adolescents_counseled = 1 if strpos(adolescentsV2, " counseled ")
label var adolescents_counseled "What FP services do you offer to unmarried a : Counsel for contraceptive methods"

gen adolescents_provided = 0 if adolescents != ""
replace adolescents_provided = 1 if strpos(adolescentsV2, " provided ")
label var adolescents_provided "What FP services do you offer to unmarried adole : Provide contraceptive methods"

gen adolescents_prescribed = 0 if adolescents != ""
replace adolescents_prescribed = 1 if strpos(adolescentsV2, " prescribed ")
label var adolescents_prescribed "What FP services do you offer to u : Prescribe / refer for contraceptive methods"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order adolescents_counseled-adolescents_prescribed, after(adolescents)
label values adolescents_counseled-adolescents_prescribed o2s_binary_label
drop adolescentsV2

***** Begin split of "fp_provided"
* Create padded variable
gen fp_providedV2 = " " + fp_provided + " "

* Build binary variables for each choice
gen fp_provided_fster = 0 if fp_provided != ""
replace fp_provided_fster = 1 if strpos(fp_providedV2, " fster ")
label var fp_provided_fster "Which of the following methods are provided to clients at : Female sterilization"

gen fp_provided_mster = 0 if fp_provided != ""
replace fp_provided_mster = 1 if strpos(fp_providedV2, " mster ")
label var fp_provided_mster "Which of the following methods are provided to clients at t : Male sterilization"

gen fp_provided_impl = 0 if fp_provided != ""
replace fp_provided_impl = 1 if strpos(fp_providedV2, " impl ")
label var fp_provided_impl "Which of the following methods are provided to clients at this facilit : Implant"

gen fp_provided_iud = 0 if fp_provided != ""
replace fp_provided_iud = 1 if strpos(fp_providedV2, " iud ")
label var fp_provided_iud "Which of the following methods are provided to clients at this facility? : IUD"

gen fp_provided_iudpp = 0 if fp_provided != ""
replace fp_provided_iudpp = 1 if strpos(fp_providedV2, " iudpp ")
label var fp_provided_iudpp "401b. Which of the following methods are provided to clients at : Postpartum IUD"

gen fp_provided_injdp = 0 if fp_provided != ""
replace fp_provided_injdp = 1 if strpos(fp_providedV2, " injdp ")
label var fp_provided_injdp "Which of the following methods are provided to clie : Injectables - Depo Provera"

gen fp_provided_injsp = 0 if fp_provided != ""
replace fp_provided_injsp = 1 if strpos(fp_providedV2, " injsp ")
label var fp_provided_injsp "Which of the following methods are provided to clie : Injectables - Sayana Press"

gen fp_provided_pill = 0 if fp_provided != ""
replace fp_provided_pill = 1 if strpos(fp_providedV2, " pill ")
label var fp_provided_pill "Which of the following methods are provided to clients at this facility? : Pill"

gen fp_provided_ec = 0 if fp_provided != ""
replace fp_provided_ec = 1 if strpos(fp_providedV2, " ec ")
label var fp_provided_ec "Which of the following methods are provided to clients : Emergency contraception"

gen fp_provided_mc = 0 if fp_provided != ""
replace fp_provided_mc = 1 if strpos(fp_providedV2, " mc ")
label var fp_provided_mc "Which of the following methods are provided to clients at this fac : Male condom"

gen fp_provided_fc = 0 if fp_provided != ""
replace fp_provided_fc = 1 if strpos(fp_providedV2, " fc ")
label var fp_provided_fc "Which of the following methods are provided to clients at this f : Female condom"

gen fp_provided_dia = 0 if fp_provided != ""
replace fp_provided_dia = 1 if strpos(fp_providedV2, " dia ")
label var fp_provided_dia "Which of the following methods are provided to clients at this facil : Diaphragm"

gen fp_provided_foam = 0 if fp_provided != ""
replace fp_provided_foam = 1 if strpos(fp_providedV2, " foam ")
label var fp_provided_foam "Which of the following methods are provided to clients at this fa : Foam / jelly"

gen fp_provided_beads = 0 if fp_provided != ""
replace fp_provided_beads = 1 if strpos(fp_providedV2, " beads ")
label var fp_provided_beads "Which of the following methods are provided to cli : Standard days / cycle beads"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order fp_provided_fster-fp_provided_beads, after(fp_provided)
label values fp_provided_fster-fp_provided_beads o2s_binary_label
drop fp_providedV2

***** Begin split of "implant_supplies"
* Create padded variable
gen implant_suppliesV2 = " " + implant_supplies + " "

* Build binary variables for each choice
gen impl_cleangloves = 0 if implant_supplies != ""
replace impl_cleangloves = 1 if strpos(implant_suppliesV2, " clean_gloves ")
label var impl_cleangloves "Does this facility have these supplies needed to insert and/or re : Clean Gloves"

gen impl_antiseptic = 0 if implant_supplies != ""
replace impl_antiseptic = 1 if strpos(implant_suppliesV2, " antiseptic ")
label var impl_antiseptic "Does this facility have these supplies needed to insert and/or remo : Antiseptic"

gen impl_sterilegauzepadorcottonwool = 0 if implant_supplies != ""
replace impl_sterilegauzepadorcottonwool = 1 if strpos(implant_suppliesV2, " sterile_gauze_pad_or_cotton_wool ")
label var impl_sterilegauzepadorcottonwool "Does this facility have these supplies needed : Sterile Gauze Pad or Cotton Wool"

gen impl_localanesthetic = 0 if implant_supplies != ""
replace impl_localanesthetic = 1 if strpos(implant_suppliesV2, " local_anesthetic ")
label var impl_localanesthetic "Does this facility have these supplies needed to insert and/o : Local Anesthetic"

gen impl_sealedimplantpack = 0 if implant_supplies != ""
replace impl_sealedimplantpack = 1 if strpos(implant_suppliesV2, " sealed_implant_pack ")
label var impl_sealedimplantpack "Does this facility have these supplies needed to insert an : Sealed Implant Pack"

gen impl_blade = 0 if implant_supplies != ""
replace impl_blade = 1 if strpos(implant_suppliesV2, " blade ")
label var impl_blade "Does this facility have these supplies needed to insert and/or  : Surgical Blade"


* Clean up: reorder binary variables, label binary variables, drop padded variable
order impl_cleangloves-impl_blade, after(implant_supplies)
label values impl_cleangloves-impl_blade o2s_binary_label
drop implant_suppliesV2

***** Begin split of "IUD_supplies"
* Create padded variable
gen IUD_suppliesV2 = " " + IUD_supplies + " "

* Build binary variables for each choice
gen IUD_supplie_examgloves = 0 if IUD_supplies != ""
replace IUD_supplie_examgloves = 1 if strpos(IUD_suppliesV2, " exam_gloves ")
label var IUD_supplie_examgloves "Does this facility have these supplies needed to insert and/or rem : Exam gloves"

gen IUD_supplie_antiseptic = 0 if IUD_supplies != ""
replace IUD_supplie_antiseptic = 1 if strpos(IUD_suppliesV2, " antiseptic ")
label var IUD_supplie_antiseptic "Does this facility have these supplies needed to  : Antiseptic (povidone iodine)"

gen IUD_supplie_drapes = 0 if IUD_supplies != ""
replace IUD_supplie_drapes = 1 if strpos(IUD_suppliesV2, " drapes ")
label var IUD_supplie_drapes "Does this facility have these supplies needed to insert and/or remove I : Drapes"

gen IUD_supplie_scissors = 0 if IUD_supplies != ""
replace IUD_supplie_scissors = 1 if strpos(IUD_suppliesV2, " scissors ")
label var IUD_supplie_scissors "Does this facility have these supplies needed to insert and/or remove : Scissors"

gen IUD_supplie_spongeholdingforceps = 0 if IUD_supplies != ""
replace IUD_supplie_spongeholdingforceps = 1 if strpos(IUD_suppliesV2, " sponge_holding_forceps ")
label var IUD_supplie_spongeholdingforceps "Does this facility have these supplies needed to insert : Sponge-holding forceps"

gen IUD_supplie_speculums = 0 if IUD_supplies != ""
replace IUD_supplie_speculums = 1 if strpos(IUD_suppliesV2, " speculums ")
label var IUD_supplie_speculums "Does this facility have these supplies needed to  : Speculums (large and medium)"

gen IUD_supplie_tenaculum = 0 if IUD_supplies != ""
replace IUD_supplie_tenaculum = 1 if strpos(IUD_suppliesV2, " tenaculum ")
label var IUD_supplie_tenaculum "Does this facility have these supplies needed to insert and/or remov : Tenaculum"

gen IUD_supplie_uterinesound = 0 if IUD_supplies != ""
replace IUD_supplie_uterinesound = 1 if strpos(IUD_suppliesV2, " uterine_sound ")
label var IUD_supplie_uterinesound "Does this facility have these supplies needed to insert and/or r : Uterine Sound"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order IUD_supplie_examgloves-IUD_supplie_uterinesound, after(IUD_supplies)
label values IUD_supplie_examgloves-IUD_supplie_uterinesound o2s_binary_label
drop IUD_suppliesV2

***** Begin split of "antenatal"
* Create padded variable
gen antenatalV2 = " " + antenatal + " "

* Build binary variables for each choice
gen antenatal_antenatal = 0 if antenatal != ""
replace antenatal_antenatal = 1 if strpos(antenatalV2, " antenatal ")
label var antenatal_antenatal "Which of the following maternal health services are provided at this : Antenatal"

gen antenatal_delivery = 0 if antenatal != ""
replace antenatal_delivery = 1 if strpos(antenatalV2, " delivery ")
label var antenatal_delivery "Which of the following maternal health services are provided at this  : Delivery"

gen antenatal_postnatal = 0 if antenatal != ""
replace antenatal_postnatal = 1 if strpos(antenatalV2, " postnatal ")
label var antenatal_postnatal "Which of the following maternal health services are provided at this : Postnatal"

gen antenatal_postabortion = 0 if antenatal != ""
replace antenatal_postabortion = 1 if strpos(antenatalV2, " postabortion ")
label var antenatal_postabortion "Which of the following maternal health services are provided at  : Post-abortion"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order antenatal_antenatal-antenatal_postabortion, after(antenatal)
label values antenatal_antenatal-antenatal_postabortion o2s_binary_label
drop antenatalV2

***** Begin split of "antenatal_methods"
* Create padded variable
gen antenatal_methodsV2 = " " + antenatal_methods + " "

* Build binary variables for each choice
gen antenatal_methods_fertility = 0 if antenatal_methods != ""
replace antenatal_methods_fertility = 1 if strpos(antenatal_methodsV2, " fertility ")
label var antenatal_methods_fertility "Which of the following is discussed with the mother during : Return to fertility"

gen antenatal_methods_space = 0 if antenatal_methods != ""
replace antenatal_methods_space = 1 if strpos(antenatal_methodsV2, " space ")
label var antenatal_methods_space "Which of the following is discussed  : Healthy timing and spacing of pregnancies"

gen antenatal_methods_breastfeed = 0 if antenatal_methods != ""
replace antenatal_methods_breastfeed = 1 if strpos(antenatal_methodsV2, " breastfeed ")
label var antenatal_methods_breastfeed "Which of the following is discussed with : Immediate and exclusive breastfeeding"

gen antenatal_methods_fpbf = 0 if antenatal_methods != ""
replace antenatal_methods_fpbf = 1 if strpos(antenatal_methodsV2, " fp_bf ")
label var antenatal_methods_fpbf "Which of the foll : Family planning methods available to use while breastfeeding"

gen antenatal_methods_LAM = 0 if antenatal_methods != ""
replace antenatal_methods_LAM = 1 if strpos(antenatal_methodsV2, " LAM ")
label var antenatal_methods_LAM "Which of the fol : Lactational Amenorrhea Method and transition to other methods"

gen antenatal_methods_iudpp = 0 if antenatal_methods != ""
replace antenatal_methods_iudpp = 1 if strpos(antenatal_methodsV2, " iudpp ")
label var antenatal_methods_iudpp "502. Which of the following is discussed with the mother during : Postpartum IUD"

gen antenatal_methods_longacting = 0 if antenatal_methods != ""
replace antenatal_methods_longacting = 1 if strpos(antenatal_methodsV2, " long_acting ")
label var antenatal_methods_longacting "Which of the following is discussed with the mother : Long-acting method options"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order antenatal_methods_fertility-antenatal_methods_longacting, after(antenatal_methods)
label values antenatal_methods_fertility-antenatal_methods_longacting o2s_binary_label
drop antenatal_methodsV2

***** Begin split of "postpartum_methods"
* Create padded variable
gen postpartum_methodsV2 = " " + postpartum_methods + " "

* Build binary variables for each choice
gen postpartum_methods_fertility = 0 if postpartum_methods != ""
replace postpartum_methods_fertility = 1 if strpos(postpartum_methodsV2, " fertility ")
label var postpartum_methods_fertility "Discussed these items with mother before she leaves the fa : Return to fertility"

gen postpartum_methods_space = 0 if postpartum_methods != ""
replace postpartum_methods_space = 1 if strpos(postpartum_methodsV2, " space ")
label var postpartum_methods_space "Discussed these items with mother be : Healthy timing and spacing of pregnancies"

gen postpartum_methods_breastfeed = 0 if postpartum_methods != ""
replace postpartum_methods_breastfeed = 1 if strpos(postpartum_methodsV2, " breastfeed ")
label var postpartum_methods_breastfeed "Discussed these items with mother before : Immediate and exclusive breastfeeding"

gen postpartum_methods_fpbf = 0 if postpartum_methods != ""
replace postpartum_methods_fpbf = 1 if strpos(postpartum_methodsV2, " fp_bf ")
label var postpartum_methods_fpbf "Discussed these i : Family planning methods available to use while breastfeeding"

gen postpartum_methods_LAM = 0 if postpartum_methods != ""
replace postpartum_methods_LAM = 1 if strpos(postpartum_methodsV2, " LAM ")
label var postpartum_methods_LAM "Discussed these  : Lactational Amenorrhea Method and transition to other methods"

gen postpartum_methods_iudpp = 0 if postpartum_methods != ""
replace postpartum_methods_iudpp = 1 if strpos(postpartum_methodsV2, " iudpp ")
label var postpartum_methods_iudpp "503. Which of the following is discussed with the mother after  : Postpartum IUD"

gen postpartum_methods_longacting = 0 if postpartum_methods != ""
replace postpartum_methods_longacting = 1 if strpos(postpartum_methodsV2, " long_acting ")
label var postpartum_methods_longacting "Discussed these items with mother before she leaves : Long-acting method options"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order postpartum_methods_fertility-postpartum_methods_longacting, after(postpartum_methods)
label values postpartum_methods_fertility-postpartum_methods_longacting o2s_binary_label
drop postpartum_methodsV2

***** Begin split of "postnatal_methods"
* Create padded variable
gen postnatal_methodsV2 = " " + postnatal_methods + " "

* Build binary variables for each choice
gen postnatal_methods_fertility = 0 if postnatal_methods != ""
replace postnatal_methods_fertility = 1 if strpos(postnatal_methodsV2, " fertility ")
label var postnatal_methods_fertility "Which of the following is discussed with the mother during : Return to fertility"

gen postnatal_methods_space = 0 if postnatal_methods != ""
replace postnatal_methods_space = 1 if strpos(postnatal_methodsV2, " space ")
label var postnatal_methods_space "Which of the following is discussed  : Healthy timing and spacing of pregnancies"

gen postnatal_methods_breastfeed = 0 if postnatal_methods != ""
replace postnatal_methods_breastfeed = 1 if strpos(postnatal_methodsV2, " breastfeed ")
label var postnatal_methods_breastfeed "Which of the following is discussed with : Immediate and exclusive breastfeeding"

gen postnatal_methods_fpbf = 0 if postnatal_methods != ""
replace postnatal_methods_fpbf = 1 if strpos(postnatal_methodsV2, " fp_bf ")
label var postnatal_methods_fpbf "Which of the foll : Family planning methods available to use while breastfeeding"

gen postnatal_methods_LAM = 0 if postnatal_methods != ""
replace postnatal_methods_LAM = 1 if strpos(postnatal_methodsV2, " LAM ")
label var postnatal_methods_LAM "Which of the fol : Lactational Amenorrhea Method and transition to other methods"

gen postnatal_methods_iudpp = 0 if postnatal_methods != ""
replace postnatal_methods_iudpp = 1 if strpos(postnatal_methodsV2, " iudpp ")
label var postnatal_methods_iudpp "505. Which of the following is discussed with the mother during : Postpartum IUD"

gen postnatal_methods_longacting = 0 if postnatal_methods != ""
replace postnatal_methods_longacting = 1 if strpos(postnatal_methodsV2, " long_acting ")
label var postnatal_methods_longacting "Which of the following is discussed with the mother : Long-acting method options"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order postnatal_methods_fertility-postnatal_methods_longacting, after(postnatal_methods)
label values postnatal_methods_fertility-postnatal_methods_longacting o2s_binary_label
drop postnatal_methodsV2

***** Begin split of "postabortion_discussion_cc"
* Create padded variable
gen postabortion_discussion_ccV2 = " " + postabortion_discussion_cc + " "

* Build binary variables for each choice
gen postabortion_disc_mental = 0 if postabortion_discussion_cc != ""
replace postabortion_disc_mental = 1 if strpos(postabortion_discussion_ccV2, " mental ")
label var postabortion_disc_mental "Which of the following is discussed with the mothe : Post-abortion mental health"

gen postabortion_disc_fertility = 0 if postabortion_discussion_cc != ""
replace postabortion_disc_fertility = 1 if strpos(postabortion_discussion_ccV2, " fertility ")
label var postabortion_disc_fertility "Which of the following is discussed with the mother during : Return to fertility"

gen postabortion_disc_healthyspacing = 0 if postabortion_discussion_cc != ""
replace postabortion_disc_healthyspacing = 1 if strpos(postabortion_discussion_ccV2, " healthy_spacing ")
label var postabortion_disc_healthyspacing "Which of the following is discussed  : Healthy timing and spacing of pregnancies"

gen postabortion_disc_longacting = 0 if postabortion_discussion_cc != ""
replace postabortion_disc_longacting = 1 if strpos(postabortion_discussion_ccV2, " long_acting ")
label var postabortion_disc_longacting "Which of the following is discussed with the mother : Long-acting method options"

gen postabortion_disc_fpmethods = 0 if postabortion_discussion_cc != ""
replace postabortion_disc_fpmethods = 1 if strpos(postabortion_discussion_ccV2, " fp_methods ")
label var postabortion_disc_fpmethods "Which of the following is discussed with the mother du : Family planning methods"

* Clean up: reorder binary variables, label binary variables, drop padded variable
order postabortion_disc_mental-postabortion_disc_fpmethods, after(postabortion_discussion_cc)
label values postabortion_disc_mental-postabortion_disc_fpmethods o2s_binary_label
drop postabortion_discussion_ccV2

/* ---------------------------------------------------------
         SECTION 6: Label variable
   --------------------------------------------------------- */

* LABEL SKIPPED: variable "your_name" has no label.
label var system_date "Current date and time."
label var system_date_check "Is this date and time correct?"
label var manual_date "Record the correct date and time."
label var level1 "LOCATION INFORMATION 1"
label var EA "Enumeration Area"
label var facility_number "Facility number"
label var advanced_facility "Facility is advanced facility"
label var managing_authority "Managing authority"
label var available "Is a competent respondent present and available to be interviewed today?"
capture label var begin_interview "May I begin the interview now?"
label var sign "Respondent's signature"
label var checkbox "Checkbox"
label var witness_auto "Interviewer's ID: ${your_name}"
label var witness_manual "Interviewer's ID. Please record your ID as a witness to the consent process."
label var facility_name "Name of the facility"
label var facility_name_other "Name of the facility"
label var position "What is your position in this facility?"
label var elec_cur "Does the facility have electricity at this time?"
label var elec_rec "At any point today, has the electricty been out for two or more hours?"
label var water_cur "Does this facility have running water at this time?"
label var water_rec "At any point today, has running water been unavailable for two or more hours?"
label var handwashing_stations "How many handwashing facilities are available on site for staff to use?"
label var handwashing_observations_staff "May I see a nearby handwashing facility that is used by staff?"
label var fp_offered "Do you usually offer family planning services / products?"
label var fp_days "How many days in a week are FP services / products offered / sold here?"
label var fp_community_health_volunteers "Does this facility provide FP supervision, support, or supplies to CHVs?"
label var num_fp_volunteers "How many CHVs are supported by this facility to provide FP services?"
label var methods_offered "Do the community health volunteers provide any of the following contraceptives:"
cap label var mobile_outreach_12mo "How often in the last 12mo has a mobile outreach team visited to deliver FP?"
cap label var mobile_outreach_6mo "How often in the last 6mo has a mobile outreach team visited to deliver FP?"
label var adolescents "What FP services do you offer to unmarried adolescents aged 10-19?"
label var fp_provided "Which of the following methods are provided to clients at this facility?"
* LABEL SKIPPED: variable "fpc_label" has no label.
label var fster_charged "Charge female sterilization"
label var mster_charged "Charge male sterilization"
cap label var impl_charged "Charge implants"
label var iud_charged "Charge IUD"
cap label var fpciudpp_charged  "Postpartum IUD"
cap label var injdp_charged "Charge injectables Sayana Press"
cap label var injsp_charged "Charge injectables depo"
label var pill_charged "Charge pill"
label var ec_charged "Charge emergency contraceptive"
label var mc_charged "Charge male condoms"
label var fc_charged "Charge female condoms"
label var dia_charged "Charge diaphragm"
label var foam_charged "Charge foam/jelly"
label var beads_charged "Charge beads"
* LABEL SKIPPED: variable "charged_joined" has no label.
label var fpc_other "Did the respondent answer the questions or give no response?"
label var fster_fees "How much do you charge for: Female sterilization"
label var mster_fees "How much do you charge for: Male sterilization"
cap label var impl_fees "How much do you charge for one unit of: Implants (including insertion)"
label var iud_fees "How much do you charge for one unit of: IUD (including nsertion)"
cap label var fpfiudpp_fees "Postpartum IUD (full cost of the PPIUD and insertion)"
cap label var injdp_fees "How much do you charge for one unit of: Injectables"
cap label var injsp_fees "How much do you charge for one unit of: Injectables Sayana Press"
label var pill_fees "How much do you charge for one unit of: Injectables injectables depo"
label var ec_fees "How much do you charge for one unit of: Pill"
label var mc_fees "How much do you charge for one unit of: Emergency contraception"
label var fc_fees "How much do you charge for one unit of: Male condom"
label var dia_fees "How much do you charge for one unit of: Female condom"
label var foam_fees "How much do you charge for one unit of: Diaphragm"
label var beads_fees "How much do you charge for one unit of: Foam/jelly"
label var fees_rw "Do FP clients pay fees to be seen by a provider even if they do not obtain an FP method?"
cap label var implant_insert "On days when you offer FP services, are there trained to insert implants?"
cap label var implant_remove "On days when you offer FP services, are there trained to remove implants?"
label var IUD_insert "On days when you offer FP services, are there trained to insert IUDs?"
label var IUD_remove "On days when you offer FP services, are there trained to remove IUDs?"
cap label var implant_supplies "Does this facility have these supplies needed to insert and/or remove implants:"
cap label var inserted_impl_today "Could implant insertion be provided to a woman onsite today?"
cap label var removed_impl_today "Could implant removal be provided to a woman onsite today?"
cap label var removed_deep_impl_today "Could implant removal (when deeply inserted) be provided to a woman onsite today"
cap label var refer_impl_today "Would someone at this facility know where to send her to have implant removed?"
label var IUD_supplies "Does this facility have these supplies needed to insert and/or remove IUDs:"
label var rega_note "May I see your FP register from the last completed month?"
label var fster_tot "Total number of visits in last month: Female Sterilization"
label var mster_tot "Total number of visits in last month: Male Sterilization"
cap label var impl_tot "Total number of visits in last month: Implant insertions"
cap label var impl_new "Number of new clients in last month: Implant insertions"
label var iud_tot "Total number of visits in last month: IUD insertion"
label var iud_new "Number of new clients in last month: IUD insertion"
cap label var iudpp_tot "Total number of visits: Postpartum IUD"
cap label var iudpp_new "Number of new clients: Postpartum IUD"
cap label var injdp_tot "Total number of visits in last month: Injectables Sayana Press"
cap label var injdp_new "Number of new clients in last month: Injectables Sayana Press"
cap label var injsp_tot "Total number of visits in last month: Injectables Depo"
cap label var injsp_new "Number of new clients in last month: Injectables Depo"
label var pill_tot "Total number of visits in last month: Pill"
label var pill_new "Number of new clients in last month: Pill"
label var ec_tot "Total number of visits in last month: Emergency contraception"
label var ec_new "Number of new clients in last month: Emergency contraception"
label var mc_tot "Total number of visits in last month: Male condom"
label var mc_new "Number of new clients in last month: Male condom"
label var fc_tot "Total number of visits in last month: Female condom"
label var fc_new "Number of new clients in last month: Female condom"
label var dia_tot "Total number of visits in last month: Diaphragm"
label var dia_new "Number of new clients in last month: Diaphragm"
label var foam_tot "Total number of visits in last month: Foam/jelly"
label var foam_new "Number of new clients in last month: Foam/jelly"
label var beads_tot "Total number of visits in last month: Standard days/cycle beads"
label var beads_new "Number of new clients in last month: Standard days/cycle beads"
cap label var impl_units "Implant units sold in last month"
label var iud_units "IUD units sold in last month"
cap label var iudpp_units "Postpartum IUD sold in the last month"
cap label var injdp_units "Injectables Depo sold in last month"
cap label var injsp_units "Injectables Sayana Press sold in last month"
label var pill_units "Pill units sold in last month"
label var ec_units "Emergency Contraception units sold in last month"
label var mc_units "Male Condom units sold in last month"
label var fc_units "Female Condom units sold in last month"
label var dia_units "Diaphragm units sold in last month"
label var foam_units "Foam/jelly units sold in last month"
label var beads_units "Standard days/cycle beads units sold in last month"
* LABEL SKIPPED: variable "methods_selected" has no label.
* LABEL SKIPPED: variable "methods_selected" has no label.
cap label var stock_implants "You mentioned you provide Implants at this facility, can you show them to me?"
cap label var stockout_days_implants "How many days have Implants been out of stock?"
cap label var stockout_3mo_implants "Have Implants been out of stock at any time in the last 3 months?"
cap label var stockout_why_implants "What is the main reason facility out of stock for IUD?"
cap label var ship_implants_units "When do you expect to receive your next shipment of Implants?"
cap label var ship_implants_value "Enter a value for weeks/months you expect to receive implants"
label var stock_IUD "You mentioned you provide IUDs at this facility, can you show them to me?"
label var stockout_days_IUD "How many days have IUDs been out of stock?"
label var stockout_3mo_IUD "Have IUDs been out of stock at any time in the last 3 months?"
label var stockout_why_IUD "What is the main reason facility out of stock for IUD?"
label var ship_IUD_units "When do you expect to receive your next shipment of IUDs?"
label var ship_IUD_value "Enter a value for weeks/months you expect to receive IUDs"
cap label var stock_sp "You mentioned you provide Inj SP at this facility, can you show them to me?"
cap label var stockout_days_sp "How many days has Injectable Sayana Press been out of stock?"
cap label var stockout_3mo_sp "Has Injectable Sayana Press been out of stock at any time in the last 3 months?"
cap label var stockout_why_sp "What is the main reason facility out of stock for Injectable Sayana Press?"
cap label var ship_sp_units "When do you expect to receive your next shipment of Injectable Sayana Press?"
cap label var ship_sp_value "Enter a value for weeks/months you expect to receive Injectable SP"
cap label var stock_dp "You mentioned you provide Inj Depo at this facility, can you show them to me?"
cap label var stockout_days_dp "How many days has Injectable Depo been out of stock?"
cap label var stockout_3mo_dp "Has Injectable Depo been out of stock at any time in the last 3 months?"
cap label var stockout_why_dp "What is the main reason facility out of stock for Injectable Depo?"
cap label var ship_dp_units "When do you expect to receive your next shipment of Injectable Depo?"
cap label var ship_dp_value "Enter a value for weeks/months you expect to receive Injectable Depo"
cap label var stock_injectables "You mentioned you provide Injectables at this facility, can you show them to me?"
cap label var stockout_days_injectables "How many days have Injectables been out of stock?"
cap label var stockout_3mo_injectables "Have Injectables been out of stock at any time in the last 3 months?"
cap label var stockout_why_injectables "What is the main reason the facility out of stock for Injectables?"
cap label var ship_injectables_units "When do you expect to receive your next shipment of Injectables?"
cap label var ship_injectables_value "Enter a value for weeks/months you expect to receive Injectables"
label var stock_pills "You mentioned you provide Pills at this facility, can you show them to me?"
label var stockout_days_pills "How many days have Pills been out of stock?"
label var stockout_3mo_pills "Have Pills been out of stock at any time in the last 3 months?"
label var stockout_why_pills "What is the main reason why the facility is out of stock for Pills?"
label var ship_pills_units "When do you expect to receive your next shipment of Pills?"
label var ship_pills_value "Enter a value for weeks/months you expect to receive Pills"
label var stock_ec "You mentioned you provide ECs at this facility, can you show them to me?"
label var stockout_days_ec "How many days have ECs been out of stock?"
label var stockout_3mo_ec "Have ECs been out of stock at any time in the last 3 months?"
label var stockout_why_ec "What is the main reason why the facility is out of stock for ECs?"
label var ship_ec_units "When do you expect to receive your next shipment of ECs?"
label var ship_ec_value "Enter a value for weeks/months you expect to receive Ecs"
label var stock_male_condoms "You mentioned you provide Male Condom at this facility,can you show them to me?"
label var stockout_days_male_condoms "How many days have Male Condoms been out of stock?"
label var stockout_3mo_male_condoms "Have Male Condoms been out of stock at any time in the last 3 months?"
label var stockout_why_male_condoms "What is the main reason why the facility is out of stock for MaleCondoms?"
label var ship_male_condoms_units "When do you expect to receive your next shipment of Male Condoms?"
label var ship_male_condoms_value "Enter a value for weeks/months you expect to receive Male Condoms"
label var stock_female_condoms "You mentioned provide FemaleCondom at this facility,can you show them to me?"
label var stockout_days_female_condoms "How many days have Female Condoms been out of stock?"
label var stockout_3mo_female_condoms "Have Female Condoms been out of stock at any time in the last 3 months?"
label var stockout_why_female_condoms "Why is this facility out of stock for Female Condoms?"
label var ship_female_condoms_units "When do you expect to receive your next shipment of Female Condoms?"
label var ship_female_condoms_value "Enter a value for weeks/months you expect to receive Female Condoms"
label var stock_diaphragm "You mentioned you provide Diaphragms at this facility,can you show them to me?"
label var stockout_days_diaphragm "How many days have Diaphragms been out of stock?"
label var stockout_3mo_diaphragm "Have Diaphragms been out of stock at any time in the last 3 months?"
label var stockout_why_diaphragm "Why is this facility out of stock for Diaphragms?"
label var ship_diaphragm_units "When do you expect to receive your next shipment of Diaphragms?"
label var ship_diaphragm_value "Enter a value for weeks/months you expect to receive diaphragms"
label var stock_foam "You mentioned you provide Foam/Jelly at this facility,can you show them to me?"
label var stockout_days_foam "How many days have Foam/Jelly been out of stock?"
label var stockout_3mo_foam "Have Foam/Jelly been out of stock at any time in the last 3 months?"
label var stockout_why_foam "Why is this facility out of stock for Foam/Jelly?"
label var ship_foam_units "When do you expect to receive your next shipment of Foam/jelly?"
label var ship_foam_value "Enter a value for weeks/months you expect to receive Foam/Jelly"
label var stock_beads "You mentioned you provide Beads at this facility,can you show them to me?"
label var stockout_days_beads "How many days have Beads been out of stock?"
label var stockout_3mo_beads "Have Beads been out of stock at any time in the last 3 months?"
label var stockout_why_beads "Why is this facility out of stock for Beads?"
label var ship_beads_units "When do you expect to receive your next shipment of Beads?"
label var ship_beads_value "Enter a value for weeks/months you expect to receive Beads"
label var miso_available "Is Miso-Kare (misoprostol) available in the facility?"
label var miso_seen "Can you show Miso-Kare to me?  If no, probe: Is it out of stock today?"
label var miso_mife_available "Is Ma-Kare (misoprostol & mifepristone) available in the facility?"
label var miso_mife_seen "Can you show Ma-Kare to me?  If no, probe: Is it out of stock today?"
label var antenatal "Which of the following maternal health services are provided at this facility?"
label var antenatal_methods "Which of the following is discussed with the mother during antenatal care visit?"
label var postpartum_methods "Discussed these items with mother before she leaves the facility after delivery"
label var postpartum_fp "Is the woman offered a method of FP before discharge from the facility?"
label var postnatal_methods "Which of the following is discussed with the mother during postnatal care visit?"
label var postnatal_fp "Is the woman offered a method of FP during a postnatal care visit?"
label var postabortion_discussion_cc "Which of the following is discussed with the mother during a postabortion visit?"
label var fp_during_postabortion "Is the woman offered a method of FP during a post-abortion visit?"
label var HIV_services "Does this facility offer any services for HIV?"
label var HIV_condom "Are clients coming for HIV serves offered condoms by the service provider?"
label var HIV_other_fp "Does the HIV service provider offer any other FP method besides condoms?"
label var photo_permission "Ask permission to take a photo of the entrance of the facility."
label var SDP_photo "Ensure that no people are in the photo."
label var locationlatitude "Take a GPS point outside near the entrance to the facility."
label var locationlongitude "Take a GPS point outside near the entrance to the facility."
label var locationaltitude "Take a GPS point outside near the entrance to the facility."
label var locationaccuracy "Take a GPS point outside near the entrance to the facility."
label var times_visited "How many times have you visited this service delivery point for this interview?"
label var SDP_result "Questionnaire Result"

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


/* --------------------------------------------------------- 
         SECTION 8: Additional Cleaning 
   --------------------------------------------------------- */ 
* Standardising varaible names and labels to PMA2020 where possible
rename handwashing_obser_soap soap_present
rename handwashing_obser_storedwater stored_water_present
rename handwashing_obser_tapwater tapwater_present
rename handwashing_obser_nearsanitation near_sanitation
rename methods_offered_malecondoms chv_condoms 
rename  methods_offered_pill chv_pills
rename methods_offered_injectables chv_injectables
rename fp_provided_* provided_*
rename provided_impl provided_implants 
rename provided_dia provided_diaphragm
rename provided_mc  provided_male_condoms
rename provided_fc provided_female_condoms
rename provided_fster provided_female_ster
rename provided_mster provided_male_ster
cap rename provided_iudpp provided_iud_pp
cap rename provided_injsp provided_injectable_sp
cap rename provided_injdp provided_injectable_dp
rename provided_pill provided_pills
cap rename impl_localanesthetic implant_anesthetic
cap rename impl_antiseptic implant_antiseptic 
cap rename impl_blade  implant_blade
cap rename impl_cleangloves implant_gloves
cap rename impl_sealedimplantpack implant_sealed_pack 
cap rename impl_sterilegauzepadorcottonwool implant_sterile_gauze 
rename IUD_supplie_spongeholdingforceps iud_forceps
rename IUD_supplie_speculums iud_speculums
rename IUD_supplie_tenaculum iud_tenaculum
rename IUD_supplie_examgloves iud_gloves
rename IUD_supplie_antiseptic iud_antiseptic
rename IUD_supplie_drapes iud_drapes
rename IUD_supplie_scissors   iud_scissors
rename IUD_supplie_uterinesound iud_uterinesound
rename antenatal maternalservices
rename antenatal_antenatal antenatal
rename antenatal_delivery delivery
rename antenatal_postnatal postnatal
rename antenatal_postabortion postabortion
rename antenatal_methods_fertility  antenatal_fertility
rename antenatal_methods_space antenatal_healthy_spacing
rename antenatal_methods_breastfeed antenatal_breastfeed
rename antenatal_methods_fpbf  antenatal_fp_bf
rename antenatal_methods_LAM  antenatal_lam
cap rename antenatal_methods_iudpp antenatal_iud_pp
rename antenatal_methods_longacting antenatal_long_acting_fp
rename postnatal_methods_fertility  postnatal_fertility
rename postnatal_methods_space postnatal_healthy_spacing
rename postnatal_methods_breastfeed postnatal_breastfeed
rename postnatal_methods_fpbf  postnatal_fp_bf
rename postnatal_methods_LAM  postnatal_lam
cap rename postnatal_methods_iudpp postnatal_iud_pp
rename postnatal_methods_longacting postnatal_long_acting_fp
rename postpartum_methods_fertility  postpartum_fertility
rename postpartum_methods_space postpartum_healthy_spacing
rename postpartum_methods_breastfeed postpartum_breastfeed
rename postpartum_methods_fpbf  postpartum_fp_bf
rename postpartum_methods_LAM  postpartum_lam
cap rename postpartum_methods_iudpp postpartum_iud_pp
rename postabortion_disc_longacting postabortion_long_acting_fp
rename postpartum_methods_longacting postpartum_long_acting_fp
rename postabortion_disc_mental  postabortion_mental
rename postabortion_disc_fertility  postabortion_fertility
rename postabortion_disc_healthyspacing postabortion_healthy_spacing
rename postabortion_disc_fpmethods postabortion_fp_methods
rename *_charged charged_*
rename *_fees fees_*
cap rename fees_*iudpp fees_iudpp		
cap rename charged_*iudpp charged_iudpp
rename *_units sold_*
rename sold_ship_* ship_*_units
rename fster_tot visits_fster_total
rename mster_tot visits_mster_total
cap rename impl_tot visits_implant_total
rename iud_tot visits_iud_total
cap rename iudpp_tot visits_iud_pp_total
cap rename injdp_tot visits_injectable_dp_total
cap rename injsp_tot visits_injectable_sp_total
cap rename inj_tot visits_injectable_total
rename pill_tot visits_pills_total
rename ec_tot visits_ec_total
rename mc_tot visits_male_condoms_total
rename fc_tot  visits_female_condoms_total
rename dia_tot visits_diaphragm_total
rename foam_tot visits_foam_total
rename beads_tot visits_beads_total
cap rename impl_new visits_implant_new
rename iud_new visits_iud_new
cap rename iudpp_new visits_iud_pp_new
cap rename injdp_new visits_injectable_dp_new
cap rename injsp_new visits_injectable_sp_new
cap rename inj_new visits_injectable_new
rename pill_new visits_pills_new
rename ec_new visits_ec_new
rename mc_new visits_male_condoms_new
rename fc_new  visits_female_condoms_new
rename dia_new visits_diaphragm_new
rename foam_new visits_foam_new
rename beads_new visits_beads_new
cap rename charged_*iudpp charged_iudpp
cap rename fees_*iudpp fees_iudpp
cap rename sold_*iudpp sold_iudpp


foreach var in charged fees sold  {
cap rename `var'_impl `var'_implant
cap rename `var'_injdp `var'_injectable_dp
cap rename `var'_injsp `var'_injectable_sp
cap rename `var'_inj `var'_injectable
cap rename `var'_iudpp `var'_iud_pp
cap rename `var'_iud `var'_iud
rename `var'_pill `var'_pills
rename `var'_mc `var'_male_condoms
rename `var'_fc `var'_female_condoms
rename `var'_dia `var'_diaphragm
}

foreach var in charged fees   {
rename `var'_fster `var'_female_ster 
rename `var'_mster `var'_male_ster 
}

* Stock section
foreach var in stockout_3mo stock stockout_why  {
rename `var'_IUD `var'_iud
cap rename `var'_sp `var'_injectable_sp
cap rename `var'_dp `var'_injectable_dp
}

foreach var in lab units value  {
rename ship_IUD_`var' ship_iud_`var' 
cap rename ship_sp_`var' ship_injectable_sp_`var'
cap rename ship_dp_`var' ship_injectable_dp_`var'
}

* Other variables
rename facility_number facility_ID
rename IUD_insert iud_insert
rename IUD_remove iud_remove
rename IUD_supplies iud_supplies
cap rename inserted_impl_today implant_insert_today
cap rename removed_impl_today implant_remove_today
cap rename removed_deep_impl_today implant_deep_remove_today
cap rename refer_impl_today refer_implant_remove
rename submissiondate* SubmissionDate* 
 
     
label var stored_water_present "Stored water present at handwashing station"
label var tapwater_present "Tap water present at handwashing station"
label var soap_present "Soap present at handwashing station"
label var near_sanitation "Handwashing area is near a sanitation facility"
label var adolescents_counseled "Offer family planning counseling to unmarried adolescents"
label var adolescents_prescribed "Offer family planning method referrals to unmarried adolescents"
label var adolescents_provided  "Offer family planning methods to unmarried adolescents"   
label var chv_condoms "Community Health Volunteers offer male condoms"
label var chv_pills	"Community Health Volunteers offer pills"	
label var chv_injectables "Community Health Volunteers offer injectables"	
label var provided_diaphragm "Provide diaphragm"
label var provided_ec "Provide emergency contraceptive"	
label var provided_female_condoms "Provide female condoms"
label var provided_female_ster "Provide female sterilization"
label var provided_foam "Provide foam/jelly"
cap label var provided_implants "Provide implants"
cap label var provided_injectable_dp "Provide injectable - DepoProvera"
cap label var provided_injectable_sp "Provide injectable - Sayana Press"
cap label var provided_iud_pp "Provide IUD-Postpartum"
label var provided_iud	"Provide IUD"
label var provided_male_condoms "Provide male condoms"
label var provided_male_ster "Provide male sterilization"
label var provided_pills "Provide pills"	
cap label var implant_anesthetic  "Implant supplies: anesthetic"
cap label var implant_antiseptic  "Implant supplies: antiseptic"
cap label var implant_blade "Implant supplies: blade"
cap label var implant_gloves  "Implant supplies: clean gloves"
cap label var implant_sealed_pack "Implant supplies: sealed implant pack"
cap label var implant_sterile_gauze "Implant supplies: sterile gauze, pad or cottonwool"
cap label var implant_forceps "Implant supplies: mosquito forceps"
label var iud_forceps "Have sponge-holding forceps for IUD insertion/removal"
label var iud_speculums "Have  speculums (large and medium)for IUD insertion/removal"	
label var iud_tenaculum "Have tenaculum for IUD insertion/removal"
label var iud_gloves "Have exam-gloves for IUD insertion/removal"
label var iud_antiseptic "Have antiseptic for IUD insertion/removal"
label var iud_drapes "Have drapes for IUD insertion/removal"
label var iud_scissors "Have scissors for IUD insertion/removal"
label var iud_uterinesound	"Have uterine sound for IUD insertion/removal"
label var antenatal "Provide antenatal services"
label var delivery "Provide delivery services"	
label var postabortion "Provide postabortion services"
label var postnatal	"Provide postnatal services" 
label var antenatal_fertility "Discuss return to fertility during antenatal visit"
label var antenatal_healthy_spacing  "Discuss healthy timing and spacing of pregnancies during antenatal visit"
label var antenatal_breastfeed "Discuss immediate and exclusive breastfeeding during antenatal visit"
label var antenatal_fp_bf "Discuss FP methods available to use while breastfeeding during antenatal visit"
label var antenatal_lam "Discuss LAM and trasition to other methods during antenatal visit"
cap label var antenatal_iud_pp "Discuss Post partum IUD during antenatal visit"
label var antenatal_long_acting_fp "Discuss long-acting FP options during antenatal visit"
label var postnatal_fertility "Discuss return to fertility during postnatal visit"
label var postnatal_healthy_spacing  "Discuss healthy timing and spacing of pregnancies during postnatal visit"
label var postnatal_breastfeed "Discuss immediate and exclusive breastfeeding during postnatal visit"
label var postnatal_fp_bf "Discuss FP methods available to use while breastfeeding during postnatal visit"
label var postnatal_lam "Discuss LAM and trasition to other methods during postnatal visit"
cap label var postnatal_iud_pp "Discuss Post partum IUD during postnatal visit"
label var postnatal_long_acting_fp "Discuss long-acting FP options during postnatal visit"
label var postpartum_fertility "Discuss return to fertility during postpartum visit"
label var postpartum_healthy_spacing  "Discuss healthy timing and spacing of pregnancies during postpartum visit"
label var postpartum_breastfeed "Discuss immediate and exclusive breastfeeding during postpartum visit"
label var postpartum_fp_bf "Discuss FP methods available to use while breastfeeding during postpartum visit"
label var postpartum_lam "Discuss LAM and trasition to other methods during postpartum visit"
cap label var postpartum_iud_pp "Discuss Post partum IUD during postpartum visit"
label var postpartum_long_acting_fp "Discuss long-acting FP options during postpartum visit"
label var postpartum_fertility "Discuss return to fertility during postpartum visit"
label var postpartum_healthy_spacing  "Discuss healthy timing and spacing of pregnancies during postpartum visit"
label var postpartum_long_acting_fp "Discuss long-acting FP options during postpartum visit"
label var postabortion_fertility "Discuss return to fertility during postabortion visit"
label var postabortion_healthy_spacing  "Discuss healthy timing and spacing of pregnancies during postabortion visit"
label var postabortion_long_acting_fp "Discuss long-acting FP options during postabortion visit"
label var postabortion_mental "Discuss mental health during post abortion visit"
label var postabortion_fp_methods  "Discuss FP methods during post abortion visit"
label var facility_ID "Facility ID"
label var register_advanced_total "ODK Cal:Total visits from all FP methods in advanced facilities"
label var register_basic_total "ODK Cal:Total units of all FP methods sold from lower level facilities"
label var register_clients_total "ODK Cal:Total Visits+Sold of all FP methods from all facilities"
label var days_open_per_month "ODK Cal:How many days per month are FP services/products offered/sold here?"
label var clients_per_day "ODK Cal:Number of clients per day (Days Open/Total Client Visits)"
label var start "SDP interview start time"
label var startSIF "SDP interview start time (SIF)"
label var end "SDP interview end time"
label var endSIF "SDP interview end time (SIF)"
label var today "Date of interview (string)"
label var this_country "PMA Country"
label var consent_obtained "Is consent obtained?"

*RE
replace your_name=name_typed if missing(your_name)
rename your_name RE
 
* DROP UNNECESSARY VARIABLES:
drop *_lab
 

**Check any complete duplicates, duplicates of metainstanceid, and duplicates of SDP
duplicates report                                                                                                                                                                                            							                                                                                                                                                                                                                          
rename metainstanceid metainstanceID 
duplicates report metainstanceID 
duplicates tag metainstanceID, gen (dupmeta) 
 
save `CCPX'_SQ_`date'.dta, replace 
