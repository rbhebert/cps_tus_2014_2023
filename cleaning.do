/*
Begin by importing data from harmonized file through 2019 from:
https://cancercontrol.cancer.gov/brp/tcrb/tus-cps/results

Download 2014-2023 wave datasets for TUS

Run:
	tus_1415_import.do
	tus_1819_import.do
	tus_2223_import.do 
	
*/

global dir "/YourDirectoryHere"
cd "$dir"

use "$dir/data/cleaned/sep22pub.dta", clear
append using "$dir/data/cleaned/jan23pub.dta"
append using "$dir/data/cleaned/may23pub.dta"

/*
Variable list for matching with -2019 harmonized data
*/

foreach var of varlist _all {
    local upper = upper("`var'")
    rename `var' `upper'
}

label define yesNoLabel -9 "-9: No Response" -8 "-8: Not available" -3 "-3: Refused" -2 "-2: Don't know" -1 "-1: Not in universe" 1 " 1: Yes" 2 " 2: No"

gen SurWave = 11 //harmonized formatting includes a label for these values
gen SurYear = HRYEAR4
gen SurMonth = HRMONTH
egen RecordID = concat(HRHHID HRHHID2 QSTNUM OCCURNUM HRMONTH)
gen SRWEIGHT = PWSRWGT
label variable SRWEIGHT "Self Respondent Weight"
gen SelfResp = (PRS64 == 1)
label variable SelfResp "Self Respondent Indicator"

label define  SURWAVEF     ///
              1         "1992-1993"    ///
              2         "1995-1996"    ///
              3         "1998-1999"    ///
              4         "2000"    ///
              5         "2001-2002"    ///
              6         "2003"    ///
              7         "2006-2007"    ///
              8         "2010-2011"    ///
              9         "2014-2015"    ///
              10        "2018-2019" ///
              11        "2022-2023"

* Sex
gen Sex = PESEX

label define  SEXF         ///
			  -1		"-1: Not in universe" ///
              1         "1: Male"    ///
              2         "2: Female"

label values Sex SEXF

* Age
gen age = PRTAGE //85 topcoded to be any age >=85

* Race/Ethnicity
gen HISPAN = PEHSPNON
gen Race22 = PTDTRACE //harmonized data has RACE03 values, see https://www2.census.gov/programs-surveys/cps/techdocs/cpssep22.pdf

gen race4level = -1
replace race4level = 1 if PTDTRACE == 1
replace race4level = 2 if PTDTRACE == 2
replace race4level = 3 if HISPAN == 1
replace race4level = 4 if HISPAN != 1 & PTDTRACE > 2

label define raceLabel -1 "-1: Not in universe" 1 "1: White non-Hispanic" 2 "2: Black non-Hispanic" 3 "3: Hispanic" 4 "4: Other non-Hispanic"

label values race4level raceLabel
label variable race4level "Race (4 category)"

* Education
gen Edu = PEEDUCA //identical to harmonized values 

label define  EDUF         ///
			  -1		"-1: Not in universe" ///
              31        "31: Less Than 1st Grade"    ///
              32        "32: 1st, 2nd, 3rd Or 4th Grade"    ///
              33        "33: 5th Or 6th Grade"    ///
              34        "34: 7th Or 8th Grade"    ///
              35        "35: 9th Grade"    ///
              36        "36: 10th Grade"    ///
              37        "37: 11th Grade"    ///
              38        "38: 12th Grade No Diploma"    ///
              39        "39: High School Grad-Diploma Or Equiv (Ged)"    ///
              40        "40: Some College But No Degree"    ///
              41        "41: Associate Degree-Occupational/Vocational"    ///
              42        "42: Associate Degree-Academic Program"    ///
              43        "43: Bachelor's Degree (Ex: BA, AB, BS)"    ///
              44        "44: Master's Degree (Ex: MA, MS, MEng, MEd, MSW)"    ///
              45        "45: Professional School Deg (Ex: MD, DDS, DVM)"    ///
              46        "46: Doctorate Degree (Ex: PhD, EdD)"
			  
label values Edu EDUF

* Marital Status
* gen MARITAL = PEMARITL
gen MARITAL = PRMARSTA //MARITAL STATUS BASED ON ARMED FORCES PARTICIPATION

label define  MARITALF     ///
			  -1		"-1: Not in universe" ///
              1         "1: Married, civilian spouse present"    ///
              2         "2: Married, armed forces spouse present"    ///
              3         "3: Married, spouse absent (exc. separated)"    ///
              4         "4: Widowed"    ///
              5         "5: Divorced"    ///
              6         "6: Separated"    ///
              7         "7: Never married"    ///
              11        "11: Unknown"
			  
label values MARITAL MARITALF

* Geographic codes
gen state_fips = GESTFIPS
gen StCounty = GTCO //County FIPS
gen CBSA = GTCBSA //CBSA-MSA code with 0=Missing, approx 26%
gen MetStat = GTMETSTA
label define  METSTATF     ///
              1         "1: Metropolitan"    ///
              2         "2: Non-Metropolitan"    ///
              3         "3: Not Identified"
label values MetStat METSTATF
label variable MetStat "Metropolitan Status"
gen Region = GEREG
label define  REGIONF      ///
              1         "1: Northeast"    ///
              2         "2: Midwest"    ///
              3         "3: South"    ///
              4         "4: West"
label values Region REGIONF
label variable Region "Census Region"			  

* (Current / Daily / Exclusive) Cigarette / Cigar / ENDS use
gen Cig100 = PEA1 
label values Cig100 yesNoLabel
label variable Cig100 "Smoke 100 cigarettes in lifetime"
gen CIGNOW = PEA3 //1=every day, 2=some days
label define  CIGNOWF      ///
              -9        "-9: No response"    ///
              -3        "-3: Refused"    ///
              -2        "-2: Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Every day"    ///
              2         " 2: Some days"    ///
              3         " 3: Not at all"
label values CIGNOW CIGNOWF		
label variable CIGNOW "How often do you smoke cigarettes"	  
gen CIGTYPE = PEB2
label define  CIGTYPEF     ///
              -9        "-9: No response"    ///
              -3        "-3: Refused"    ///
              -2        "-2: Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Menthol"    ///
              2         " 2: Non-menthol"    ///
              3         " 3: No usual type"
label values CIGTYPE CIGTYPEF	
label variable CIGTYPE "Usually smoke menthol or non-menthol cigarettes"	

//Cigars PEJ2A1
// PEJB1, 2, 3 
gen CIGRLG = PEJB1
gen CIGRILLO = PEJB2
gen CIGRLITTLE = PEJB3
label values CIGRLG yesNoLabel
label values CIGRILLO yesNoLabel
label values CIGRLITTLE yesNoLabel
label variable CIGRLG "Past 30 days Use regular/large cigars"
label variable CIGRILLO "Past 30 days Use cigarillos"
label variable CIGRLITTLE "Past 30 days Use little cigars"


label define  OTPSTATF     ///
              -9        "-9: Indeterminate"    ///
              -8        "-8: Not available"    ///
              -3        "-3: Refused"    ///
              -2        "-2 :Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Never"    ///
              2         " 2: Every day"    ///
              3         " 3: Some days"    ///
              4         " 4: Former"

*gen CIGRSTAT = PEJ2A1
recode PEJ2A1 (3 = 4) (1 = 2) (2 = 3), gen(CIGRSTAT)
replace CIGRSTAT = 1 if PEJ1A1 == 2 

* PEJ1A1 (Have/Has) (you/name) EVER used any of the following 1283-1284 EVEN ONE TIME? ... A regular cigar or cigarillo OR a little filtered cigar?

* PEJ2A1 (Do you/Does name) NOW smoke regular cigars or cigarillos or little 1295-1296 filtered cigars every day, some days or not at all?



label values CIGRSTAT OTPSTATF
label variable CIGRSTAT "Current Cigar Use Status"

//flavored regular or large cigars, cigarillos, little cigars 
//PEJFLA1A1 PEJFLA1A2 PTJFLA1A3 PEJFLA1A4 PEJFLA1A5 PEJFLA1A6 PEJFLA1A8 PTJFLA1A9 PEJFLA1B1 PTJFLA1B2 PTJFLA1B3 PEJFLA1B4 PEJFLA1B5 PEJFLA1B6 PEJFLA1B8 PTJFLA1B9 PEJFLA1C1 PTJFLA1C2 PEJFLA1C3 PEJFLA1C4 PTJFLA1C5 PEJFLA1C6 PEJFLA1C8 PTJFLA1C9 PEJFLA1D1 PEJFLA1D2 PEJFLA1D3 PEJFLA1D4 PEJFLA1D5 PEJFLA1D6 PEJFLA1D8 PEJFLA1D9
//In order: menthol, mint, clove/spice/herb, fruit, alcohol, candy/dessert/sweets, tobacco, unflavored, other flavor 

/*
Recoding of Items about Flavors

Some variables for past 30-day use of flavored non-cigarette tobacco products have been recoded/masked due to a low number of responses. To promote consistency within a single type of non-cigarette tobacco product and across the three survey months of the 2022-2023 wave (September 2022, January 2023, and May 2023), if a flavor had too few responses during any survey month, the flavor was recoded/masked across the wave. Thus, different flavor categories are available for different types of non-cigarette tobacco products, and the "other flavor" categories may represent different combinations of flavors. See the Record Layout (Attachment 7) for specific flavor categories available for each product.

Recoding/masking a flavor with too few positive responses involved changing all "yes" responses for that flavor to "no" responses and changing the variable name's prefix to indicate that topcoding has taken place (e.g., a variable name beginning with PEJFLA would be changed to PTJFLA). For that same product, the response to the "other" flavor variable would be changed from "no" to "yes," if it was not "yes" already. The "other" flavor variable's name would also be changed to indicate that topcoding has taken place.

See: September 2022 Technical Documentation
https://cancercontrol.cancer.gov/sites/default/files/2024-06/22-23_TUS-CPSTechDoc_CPS22-508.pdf
*/

/* 
2014: Some tobacco products come in flavors such as menthol or mint, clove, spice, fruit, chocolate, alcohol, or other flavors.
When you smoke a cigar is it usually flavored? 

2018: same base question with 3 follow ups: 
	Is it usually menthol or mint flavored?
	Is it usually flavored like clove, spice, herb, fruit, alcohol, candy, sweets, or chocolate?
	Is it usually some other type of flavor?
	additional follow up for e-cigs - tobacco flavored 
*/

* past 30 days flavor variables: Unflavored, Menthol, Other Flavors
* note PTJFLA1a3 topcoded PEJFLA1B2 as well; breaks ability to choose menthol/mint as a single category 
gen CIGRLG_unflv = 0
gen CIGRLG_menthol = 0
gen CIGRLG_otherFlv = 0
replace CIGRLG_unflv = 1 if (PEJFLA1A8 == 1)
replace CIGRLG_menthol = (PEJFLA1A1 == 1)
replace CIGRLG_otherFlv = (PEJFLA1A2 == 1 | PEJFLA1A4 == 1 | PEJFLA1A5 == 1 | PEJFLA1A6 == 1)

gen CIGRILLO_unflv = 0
gen CIGRILLO_menthol = 0
gen CIGRILLO_otherFlv = 0
replace CIGRILLO_unflv = 1 if (PEJFLA1B8 == 1)
replace CIGRILLO_menthol = (PEJFLA1B1 == 1)
replace CIGRILLO_otherFlv = (PEJFLA1B4 == 1 | PEJFLA1B5 == 1 | PEJFLA1B6 == 1)

gen CIGRLITTLE_unflv = 0
gen CIGRLITTLE_menthol = 0
gen CIGRLITTLE_otherFlv = 0
replace CIGRLITTLE_unflv = 1 if (PEJFLA1C8 == 1)
replace CIGRLITTLE_menthol = (PEJFLA1C1 == 1)
replace CIGRLITTLE_otherFlv = (PEJFLA1C3 == 1 | PEJFLA1C4 == 1 | PEJFLA1C6 == 1)

gen CIGR_unflv = 0
gen CIGR_menthol = 0
gen CIGR_otherFlv = 0
replace CIGR_unflv = 1 if (PEJFLA1D8 == 1)
replace CIGR_menthol = (PEJFLA1D1 == 1)
replace CIGR_otherFlv = (PEJFLA1D2 == 1 | PEJFLA1D3 == 1 | PEJFLA1D4 == 1 | PEJFLA1D5 == 1 | PEJFLA1D6 == 1 | PEJFLA1D9 == 1)
				
//ENDS PEJ2A3_5
*gen ECIGSTAT = PEJ2A3_5
* PEJ1A3_5 (Have/Has)(you/name) EVER used E-cigarettes EVEN ONE TIME?
* PEJ2A3_5 (Do you/Does name) NOW use an E-cigarette every day, 1307-1308 some days or not at all?
recode PEJ2A3_5 (3 = 4) (1 = 2) (2 = 3), gen(ECIGSTAT)
replace ECIGSTAT = 1 if PEJ1A3_5 == 2 
label values ECIGSTAT OTPSTATF
label variable ECIGSTAT "Current e-Cigarette Use Status"

* past 30 days e-cigarette flavor 
gen ECIGFLV_unflv = 0
gen ECIGFLV_menthol = 0
gen ECIGFLV_tobacco = 0
gen ECIGFLV_otherFlv = 0
replace ECIGFLV_unflv = (PEJFLA358 == 1)
replace ECIGFLV_menthol = (PEJFLA351 == 1)
replace ECIGFLV_tobacco = (PEJFLA357 == 1)
replace ECIGFLV_otherFlv = (PEJFLA352 == 1 | PEJFLA353 == 1 | PEJFLA354 == 1 | PEJFLA355 == 1 | PEJFLA356 == 1 | PEJFLA359 == 1)

//Smokeless PEJ2A4
gen SMKLSTAT = PEJ2A4
label values SMKLSTAT OTPSTATF
label variable SMKLSTAT "Current Smokeless tobacco Use Status"
//Nicotine Pouch PEJ2A5r
gen POUCHSTAT = PEJ2A5R
label values POUCHSTAT OTPSTATF
label variable POUCHSTAT "Current Nicotine Pouch Use Status"
//Heated tobacco
gen HEATSTAT = PEJ2A6
label values HEATSTAT OTPSTATF
label variable HEATSTAT "Current Heated Tobacco Use Status"
//Switching PEH6FA2D1 


sort SurYear SurMonth RecordID 

 
recode CIGNOW (3 = 4) (1 = 2) (2 = 3), gen(CIGSTAT)
replace CIGSTAT = 1 if Cig100 == 2
label values CIGSTAT OTPSTATF
save "$dir/data/temp/2223wave.dta", replace 


********************************************************************************


use "$dir/data/cleaned/jul18pub.dta", clear
append using "$dir/data/cleaned/jan19pub.dta"
append using "$dir/data/cleaned/may19pub.dta"


foreach var of varlist _all {
    local upper = upper("`var'")
    rename `var' `upper'
}

label define yesNoLabel -9 "-9: No Response" -8 "-8: Not available" -3 "-3: Refused" -2 "-2: Don't know" -1 "-1: Not in universe" 1 " 1: Yes" 2 " 2: No"

gen SurWave = 10 //harmonized formatting includes a label for these values
gen SurYear = HRYEAR4
gen SurMonth = HRMONTH
egen RecordID = concat(HRHHID HRHHID2 QSTNUM OCCURNUM HRMONTH)
gen SRWEIGHT = PWSRWGT
label variable SRWEIGHT "Self Respondent Weight"
gen SelfResp = (PRS64 == 1)
label variable SelfResp "Self Respondent Indicator"

label define  SURWAVEF     ///
              1         "1992-1993"    ///
              2         "1995-1996"    ///
              3         "1998-1999"    ///
              4         "2000"    ///
              5         "2001-2002"    ///
              6         "2003"    ///
              7         "2006-2007"    ///
              8         "2010-2011"    ///
              9         "2014-2015"    ///
              10        "2018-2019" ///
              11        "2022-2023"


* Sex
gen Sex = PESEX

label define  SEXF         ///
			  -1		"-1: Not in universe" ///
              1         "1: Male"    ///
              2         "2: Female"

label values Sex SEXF

* Age
gen age = PRTAGE //85 topcoded to be any age >=85

* Race/Ethnicity
gen HISPAN = PEHSPNON
gen Race03 = PTDTRACE //harmonized data has RACE03 values, see https://www2.census.gov/programs-surveys/cps/techdocs/cpssep22.pdf

gen race4level = -1
replace race4level = 1 if PTDTRACE == 1
replace race4level = 2 if PTDTRACE == 2
replace race4level = 3 if HISPAN == 1
replace race4level = 4 if HISPAN != 1 & PTDTRACE > 2

label define raceLabel -1 "-1: Not in universe" 1 "1: White non-Hispanic" 2 "2: Black non-Hispanic" 3 "3: Hispanic" 4 "4: Other non-Hispanic"

label values race4level raceLabel
label variable race4level "Race (4 category)"

* Education
gen Edu = PEEDUCA //identical to harmonized values 

label define  EDUF         ///
			  -1		"-1: Not in universe" ///
              31        "31: Less Than 1st Grade"    ///
              32        "32: 1st, 2nd, 3rd Or 4th Grade"    ///
              33        "33: 5th Or 6th Grade"    ///
              34        "34: 7th Or 8th Grade"    ///
              35        "35: 9th Grade"    ///
              36        "36: 10th Grade"    ///
              37        "37: 11th Grade"    ///
              38        "38: 12th Grade No Diploma"    ///
              39        "39: High School Grad-Diploma Or Equiv (Ged)"    ///
              40        "40: Some College But No Degree"    ///
              41        "41: Associate Degree-Occupational/Vocational"    ///
              42        "42: Associate Degree-Academic Program"    ///
              43        "43: Bachelor's Degree (Ex: BA, AB, BS)"    ///
              44        "44: Master's Degree (Ex: MA, MS, MEng, MEd, MSW)"    ///
              45        "45: Professional School Deg (Ex: MD, DDS, DVM)"    ///
              46        "46: Doctorate Degree (Ex: PhD, EdD)"
			  
label values Edu EDUF

* Marital Status
* gen MARITAL = PEMARITL
gen MARITAL = PRMARSTA //MARITAL STATUS BASED ON ARMED FORCES PARTICIPATION

label define  MARITALF     ///
			  -1		"-1: Not in universe" ///
              1         "1: Married, civilian spouse present"    ///
              2         "2: Married, armed forces spouse present"    ///
              3         "3: Married, spouse absent (exc. separated)"    ///
              4         "4: Widowed"    ///
              5         "5: Divorced"    ///
              6         "6: Separated"    ///
              7         "7: Never married"    ///
              11        "11: Unknown"
			  
label values MARITAL MARITALF

* Geographic codes
gen state_fips = GESTFIPS
gen StCounty = GTCO //County FIPS
gen CBSA = GTCBSA //CBSA-MSA code with 0=Missing, approx 26%
gen MetStat = GTMETSTA
label define  METSTATF     ///
              1         "1: Metropolitan"    ///
              2         "2: Non-Metropolitan"    ///
              3         "3: Not Identified"
label values MetStat METSTATF
label variable MetStat "Metropolitan Status"
gen Region = GEREG
label define  REGIONF      ///
              1         "1: Northeast"    ///
              2         "2: Midwest"    ///
              3         "3: South"    ///
              4         "4: West"
label values Region REGIONF
label variable Region "Census Region"			  


* (Current / Daily / Exclusive) Cigarette / Cigar / ENDS use
gen Cig100 = PEA1 
label values Cig100 yesNoLabel
label variable Cig100 "Smoke 100 cigarettes in lifetime"
gen CIGNOW = PEA3 //1=every day, 2=some days
label define  CIGNOWF      ///
              -9        "-9: No response"    ///
              -3        "-3: Refused"    ///
              -2        "-2: Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Every day"    ///
              2         " 2: Some days"    ///
              3         " 3: Not at all"
label values CIGNOW CIGNOWF		
label variable CIGNOW "How often do you smoke cigarettes"	  
gen CIGTYPE = PEB2
label define  CIGTYPEF     ///
              -9        "-9: No response"    ///
              -3        "-3: Refused"    ///
              -2        "-2: Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Menthol"    ///
              2         " 2: Non-menthol"    ///
              3         " 3: No usual type"
label values CIGTYPE CIGTYPEF	
label variable CIGTYPE "Usually smoke menthol or non-menthol cigarettes"	

* Cigars PEJB
label define  CIGRTYPF     ///
              -9        "-9: No response"    ///
              -3        "-3: Refused"    ///
              -2        "-2: Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Regular"    ///
              2         " 2: Cigarillos"    ///
              3         " 3: Little filtered cigars"
gen CIGRTYPE = PEJB
label values CIGRTYPE CIGRTYPF

label define  OTPSTATF     ///
              -9        "-9: Indeterminate"    ///
              -8        "-8: Not available"    ///
              -3        "-3: Refused"    ///
              -2        "-2 :Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Never"    ///
              2         " 2: Every day"    ///
              3         " 3: Some days"    ///
              4         " 4: Former"

*gen CIGRSTAT = PEJ2A1
recode PEJ2A1 (3 = 4) (1 = 2) (2 = 3), gen(CIGRSTAT)
replace CIGRSTAT = 1 if PEJ1A1 == 2 

* PEJ1A1 (Have/Has) (you/name) EVER used any of the following 1283-1284 EVEN ONE TIME? ... A regular cigar or cigarillo OR a little filtered cigar?

* PEJ2A1 (Do you/Does name) NOW smoke regular cigars or cigarillos or little 1295-1296 filtered cigars every day, some days or not at all?



label values CIGRSTAT OTPSTATF
label variable CIGRSTAT "Current Cigar Use Status"

* Cigar flavor
* PEJNFLVR1: usually flavored 
* PEJNFLA1B PEJNFLA1C PEJNFLA1D
gen CIGRFLV_usual = PEJNFLVR1
label values CIGRFLV_usual yesNoLabel

gen CIGR_unflv = 0
gen CIGR_menthol = 0
gen CIGR_otherFlv = 0
replace CIGR_unflv = (PEJNFLVR1 == 2)
replace CIGR_menthol = (PEJNFLA1B == 1)
replace CIGR_otherFlv = (PEJNFLA1C == 1 | PEJNFLA1D == 1)

//ENDS PEJ2A3_5
*gen ECIGSTAT = PEJ2A3_5
* PEJ1A3_5 (Have/Has)(you/name) EVER used E-cigarettes EVEN ONE TIME?
* PEJ2A3_5 (Do you/Does name) NOW use an E-cigarette every day, 1307-1308 some days or not at all?
recode PEJ2A3_5 (3 = 4) (1 = 2) (2 = 3), gen(ECIGSTAT)
replace ECIGSTAT = 1 if PEJ1A3_5 == 2 
label values ECIGSTAT OTPSTATF
label variable ECIGSTAT "Current e-Cigarette Use Status"



* E-cigarette flavor 
* PEJNFLV35: usually flavored 
* PEJNFA35A PEJNFA35B PEJNFA35C PEJNFA35D PEJNFVB35
gen ECIGFLV_usual = PEJNFLV35
label values ECIGFLV_usual yesNoLabel

gen ECIGFLV_unflv = 0
gen ECIGFLV_menthol = 0
gen ECIGFLV_tobacco = 0
gen ECIGFLV_otherFlv = 0
replace ECIGFLV_unflv = (PEJNFLV35 == 2)
replace ECIGFLV_menthol = (PEJNFA35B == 1)
replace ECIGFLV_tobacco = (PEJNFA35A == 1)
replace ECIGFLV_otherFlv = (PEJNFA35C == 1 | PEJNFA35D == 1)

sort SurYear SurMonth RecordID 

recode CIGNOW (3 = 4) (1 = 2) (2 = 3), gen(CIGSTAT)
replace CIGSTAT = 1 if Cig100 == 2
label values CIGSTAT OTPSTATF
save "$dir/data/temp/1819wave.dta", replace 

********************************************************************************





use "$dir/data/cleaned/jul14pub.dta", clear
append using "$dir/data/cleaned/jan15pub.dta"
append using "$dir/data/cleaned/may15pub.dta"


foreach var of varlist _all {
    local upper = upper("`var'")
    rename `var' `upper'
}

label define yesNoLabel -9 "-9: No Response" -8 "-8: Not available" -3 "-3: Refused" -2 "-2: Don't know" -1 "-1: Not in universe" 1 " 1: Yes" 2 " 2: No"

gen SurWave = 9 //harmonized formatting includes a label for these values
gen SurYear = HRYEAR4
gen SurMonth = HRMONTH
egen RecordID = concat(HRHHID HRHHID2 QSTNUM OCCURNUM HRMONTH)
gen SRWEIGHT = PWSRWGT
label variable SRWEIGHT "Self Respondent Weight"
gen SelfResp = (PRS64 == 1)
label variable SelfResp "Self Respondent Indicator"

label define  SURWAVEF     ///
              1         "1992-1993"    ///
              2         "1995-1996"    ///
              3         "1998-1999"    ///
              4         "2000"    ///
              5         "2001-2002"    ///
              6         "2003"    ///
              7         "2006-2007"    ///
              8         "2010-2011"    ///
              9         "2014-2015"    ///
              10        "2018-2019" ///
              11        "2022-2023"


* Sex
gen Sex = PESEX

label define  SEXF         ///
			  -1		"-1: Not in universe" ///
              1         "1: Male"    ///
              2         "2: Female"

label values Sex SEXF

* Age
gen age = PRTAGE //85 topcoded to be any age >=85

* Race/Ethnicity
gen HISPAN = PEHSPNON
gen Race03 = PTDTRACE //harmonized data has RACE03 values, see https://www2.census.gov/programs-surveys/cps/techdocs/cpssep22.pdf

gen race4level = -1
replace race4level = 1 if PTDTRACE == 1
replace race4level = 2 if PTDTRACE == 2
replace race4level = 3 if HISPAN == 1
replace race4level = 4 if HISPAN != 1 & PTDTRACE > 2

label define raceLabel -1 "-1: Not in universe" 1 "1: White non-Hispanic" 2 "2: Black non-Hispanic" 3 "3: Hispanic" 4 "4: Other non-Hispanic"

label values race4level raceLabel
label variable race4level "Race (4 category)"

* Education
gen Edu = PEEDUCA //identical to harmonized values 

label define  EDUF         ///
			  -1		"-1: Not in universe" ///
              31        "31: Less Than 1st Grade"    ///
              32        "32: 1st, 2nd, 3rd Or 4th Grade"    ///
              33        "33: 5th Or 6th Grade"    ///
              34        "34: 7th Or 8th Grade"    ///
              35        "35: 9th Grade"    ///
              36        "36: 10th Grade"    ///
              37        "37: 11th Grade"    ///
              38        "38: 12th Grade No Diploma"    ///
              39        "39: High School Grad-Diploma Or Equiv (Ged)"    ///
              40        "40: Some College But No Degree"    ///
              41        "41: Associate Degree-Occupational/Vocational"    ///
              42        "42: Associate Degree-Academic Program"    ///
              43        "43: Bachelor's Degree (Ex: BA, AB, BS)"    ///
              44        "44: Master's Degree (Ex: MA, MS, MEng, MEd, MSW)"    ///
              45        "45: Professional School Deg (Ex: MD, DDS, DVM)"    ///
              46        "46: Doctorate Degree (Ex: PhD, EdD)"
			  
label values Edu EDUF

* Marital Status
* gen MARITAL = PEMARITL
gen MARITAL = PRMARSTA //MARITAL STATUS BASED ON ARMED FORCES PARTICIPATION

label define  MARITALF     ///
			  -1		"-1: Not in universe" ///
              1         "1: Married, civilian spouse present"    ///
              2         "2: Married, armed forces spouse present"    ///
              3         "3: Married, spouse absent (exc. separated)"    ///
              4         "4: Widowed"    ///
              5         "5: Divorced"    ///
              6         "6: Separated"    ///
              7         "7: Never married"    ///
              11        "11: Unknown"
			  
label values MARITAL MARITALF

* Geographic codes
gen state_fips = GESTFIPS
gen StCounty = GTCO //County FIPS
gen CBSA = GTCBSA //CBSA-MSA code with 0=Missing, approx 26%
gen MetStat = GTMETSTA
label define  METSTATF     ///
              1         "1: Metropolitan"    ///
              2         "2: Non-Metropolitan"    ///
              3         "3: Not Identified"
label values MetStat METSTATF
label variable MetStat "Metropolitan Status"
gen Region = GEREG
label define  REGIONF      ///
              1         "1: Northeast"    ///
              2         "2: Midwest"    ///
              3         "3: South"    ///
              4         "4: West"
label values Region REGIONF
label variable Region "Census Region"			  


* (Current / Daily / Exclusive) Cigarette / Cigar / ENDS use
gen Cig100 = PEA1 
label values Cig100 yesNoLabel
label variable Cig100 "Smoke 100 cigarettes in lifetime"
gen CIGNOW = PEA3 //1=every day, 2=some days
label define  CIGNOWF      ///
              -9        "-9: No response"    ///
              -3        "-3: Refused"    ///
              -2        "-2: Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Every day"    ///
              2         " 2: Some days"    ///
              3         " 3: Not at all"
label values CIGNOW CIGNOWF		
label variable CIGNOW "How often do you smoke cigarettes"	  
gen CIGTYPE = PEB2
label define  CIGTYPEF     ///
              -9        "-9: No response"    ///
              -3        "-3: Refused"    ///
              -2        "-2: Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Menthol"    ///
              2         " 2: Non-menthol"    ///
              3         " 3: No usual type"
label values CIGTYPE CIGTYPEF	
label variable CIGTYPE "Usually smoke menthol or non-menthol cigarettes"	

* Cigars PEJB
label define  CIGRTYPF     ///
              -9        "-9: No response"    ///
              -3        "-3: Refused"    ///
              -2        "-2: Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Regular"    ///
              2         " 2: Cigarillos"    ///
              3         " 3: Little filtered cigars"
gen CIGRTYPE = PEJB
label values CIGRTYPE CIGRTYPF

label define  OTPSTATF     ///
              -9        "-9: Indeterminate"    ///
              -8        "-8: Not available"    ///
              -3        "-3: Refused"    ///
              -2        "-2 :Don't know"    ///
              -1        "-1: Not in universe"    ///
              1         " 1: Never"    ///
              2         " 2: Every day"    ///
              3         " 3: Some days"    ///
              4         " 4: Former"

*gen CIGRSTAT = PEJ2A1
recode PEJ2A1 (3 = 4) (1 = 2) (2 = 3), gen(CIGRSTAT)
replace CIGRSTAT = 1 if PEJ1A1 == 2 

* PEJ1A1 (Have/Has) (you/name) EVER used any of the following 1283-1284 EVEN ONE TIME? ... A regular cigar or cigarillo OR a little filtered cigar?

* PEJ2A1 (Do you/Does name) NOW smoke regular cigars or cigarillos or little 1295-1296 filtered cigars every day, some days or not at all?



label values CIGRSTAT OTPSTATF
label variable CIGRSTAT "Current Cigar Use Status"

* Cigar flavor
* PEJNFLVR1: usually flavored 
gen CIGRFLV_usual = PEJNFLVR1
label values CIGRFLV_usual yesNoLabel



//ENDS PEJ2A3_5
*gen ECIGSTAT = PEJ2A3_5
* PEJ1A3_5 (Have/Has)(you/name) EVER used E-cigarettes EVEN ONE TIME?
* PEJ2A3_5 (Do you/Does name) NOW use an E-cigarette every day,  some days or not at all?
recode PEJ2A3_5 (3 = 4) (1 = 2) (2 = 3), gen(ECIGSTAT)
replace ECIGSTAT = 1 if PEJ1A3_5 == 2 
label values ECIGSTAT OTPSTATF
label variable ECIGSTAT "Current e-Cigarette Use Status"



* E-cigarette flavor 
* PEJNFLV35: usually flavored 

gen ECIGFLV_usual = PEJNFLV35
label values ECIGFLV_usual yesNoLabel


sort SurYear SurMonth RecordID 

recode CIGNOW (3 = 4) (1 = 2) (2 = 3), gen(CIGSTAT)
replace CIGSTAT = 1 if Cig100 == 2
label values CIGSTAT OTPSTATF
save "$dir/data/temp/1415wave.dta", replace 

********************************************************************************

append using "$dir/data/temp/1819wave.dta"
append using "$dir/data/temp/2223wave.dta"


save "$dir/data/cleaned/tus1423.dta", replace 

statastates, fips(state_fips)
drop _merge

********************************************************************************
/*
Not every identified CBSA also lists county and vice-versa 
StCounty = 0 means unidentified county
CBSA = 0 means unidentified CBSA
MetStat = 3 means unidentified metropolitan status

CBSA in wave 9,10,11 use February 28, 2013 OMB definitions. Except in wave 9 where denoted with * in technical document List 1
https://cancercontrol.cancer.gov/sites/default/files/2020-06/cpsjul14.pdf


levelsof state_name  if MetStat == 3, clean sep(", ")
ARIZONA, COLORADO, LOUISIANA, MASSACHUSETTS, NEVADA, OKLAHOMA, UTAH

326 CBSA in wave 9, 261 in waves 10,11
27% unidentified CBSA, 60% unidentified county 

*/

gen MSA_State = (state_fips * 100000) + CBSA
unique MSA_State if SurWave == 9
unique MSA_State if SurWave == 10
unique MSA_State if SurWave == 11
drop MSA_State

replace CBSA = 0 if CBSA == 70750 & SurWave == 9
replace CBSA = 0 if CBSA == 70900 & SurWave == 9
replace CBSA = 14460 if CBSA == 71650 & SurWave == 9
replace CBSA = 14860 if CBSA == 71950 & SurWave == 9
replace CBSA = 15540 if CBSA == 72400 & SurWave == 9
replace CBSA = 0 if CBSA == 72850 & SurWave == 9
replace CBSA = 25540 if CBSA == 73450 & SurWave == 9
replace CBSA = 0 if CBSA == 74500 & SurWave == 9
replace CBSA = 35300 if CBSA == 75700 & SurWave == 9
replace CBSA = 35980 if CBSA == 76450 & SurWave == 9
replace CBSA = 38860 if CBSA == 76750 & SurWave == 9
replace CBSA = 39300 if CBSA == 77200 & SurWave == 9
replace CBSA = 0 if CBSA == 77350 & SurWave == 9
replace CBSA = 44140 if CBSA == 78100 & SurWave == 9
replace CBSA = 0 if CBSA == 78700 & SurWave == 9
replace CBSA = 49340 if CBSA == 79600 & SurWave == 9
replace CBSA = 0 if CBSA == 11300 & SurWave == 9
replace CBSA = 0 if CBSA == 11340 & SurWave == 9
replace CBSA = 0 if CBSA == 13380 & SurWave == 9
replace CBSA = 14020 if CBSA == 14060 & SurWave == 9
replace CBSA = 0 if CBSA == 14740 & SurWave == 9
replace CBSA = 0 if CBSA == 23020 & SurWave == 9
replace CBSA = 0 if CBSA == 25060 & SurWave == 9
replace CBSA = 0 if CBSA == 25500 & SurWave == 9
replace CBSA = 0 if CBSA == 26100 & SurWave == 9
replace CBSA = 46520 if CBSA == 26180 & SurWave == 9
replace CBSA = 0 if CBSA == 27900 & SurWave == 9
replace CBSA = 0 if CBSA == 28100 & SurWave == 9
replace CBSA = 35620 if CBSA == 28740 & SurWave == 9
replace CBSA = 0 if CBSA == 29100 & SurWave == 9
replace CBSA = 0 if CBSA == 29940 & SurWave == 9
replace CBSA = 0 if CBSA == 30020 & SurWave == 9
replace CBSA = 31080 if CBSA == 31100 & SurWave == 9
replace CBSA = 0 if CBSA == 31340 & SurWave == 9
replace CBSA = 0 if CBSA == 31460 & SurWave == 9
replace CBSA = 0 if CBSA == 32900 & SurWave == 9
replace CBSA = 0 if CBSA == 33140 & SurWave == 9
replace CBSA = 0 if CBSA == 33260 & SurWave == 9
replace CBSA = 0 if CBSA == 34900 & SurWave == 9
replace CBSA = 0 if CBSA == 36140 & SurWave == 9
replace CBSA = 0 if CBSA == 36500 & SurWave == 9
replace CBSA = 0 if CBSA == 39100 & SurWave == 9
replace CBSA = 0 if CBSA == 39380 & SurWave == 9
replace CBSA = 35840 if CBSA == 39460 & SurWave == 9
replace CBSA = 0 if CBSA == 39900 & SurWave == 9
replace CBSA = 0 if CBSA == 41060 & SurWave == 9
replace CBSA = 0 if CBSA == 42060 & SurWave == 9
replace CBSA = 35840 if CBSA == 42260 & SurWave == 9
replace CBSA = 0 if CBSA == 44220 & SurWave == 9
replace CBSA = 0 if CBSA == 46220 & SurWave == 9
replace CBSA = 0 if CBSA == 46660 & SurWave == 9
replace CBSA = 0 if CBSA == 47020 & SurWave == 9
replace CBSA = 0 if CBSA == 49420 & SurWave == 9


gen MSA_State = (state_fips * 100000) + CBSA
unique MSA_State if SurWave == 9
unique MSA_State if SurWave == 10
unique MSA_State if SurWave == 11

* Missing in 10,11:
* 10500, 11020, 11500, 17860, 19460, 19500, 20260, 20740, 20940, 22460, 31740, 46940
replace CBSA = 0 if CBSA == 10500 & SurWave == 9
replace CBSA = 0 if CBSA == 11020 & SurWave == 9
replace CBSA = 0 if CBSA == 11500 & SurWave == 9
replace CBSA = 0 if CBSA == 17860 & SurWave == 9
replace CBSA = 0 if CBSA == 19460 & SurWave == 9
replace CBSA = 0 if CBSA == 19500 & SurWave == 9
replace CBSA = 0 if CBSA == 20260 & SurWave == 9
replace CBSA = 0 if CBSA == 20740 & SurWave == 9
replace CBSA = 0 if CBSA == 20940 & SurWave == 9
replace CBSA = 0 if CBSA == 22460 & SurWave == 9
replace CBSA = 0 if CBSA == 31740 & SurWave == 9
replace CBSA = 0 if CBSA == 46940 & SurWave == 9

drop MSA_State
gen MSA_State = (state_fips * 100000) + CBSA
unique MSA_State if SurWave == 9
unique MSA_State if SurWave == 10
unique MSA_State if SurWave == 11

* Missing in 10,11:
* 1000000, 1714020, 2425180, 3410900
replace CBSA = 37980 if MSA_State == 1000000 & SurWave == 9
replace CBSA = 0 if MSA_State == 1714020 & SurWave == 9
replace CBSA = 0 if MSA_State == 2425180 & SurWave == 9
replace CBSA = 0 if MSA_State == 3410900 & SurWave == 9

// Update CBSA code for Dayton, OH to Dayton–Springfield–Kettering, OH 
replace CBSA = 19430 if CBSA == 19380

// Update CBSA code for Prescott, AZ to Dayton–Springfield–Kettering, OH 
replace CBSA = 39150 if CBSA == 39140

drop MSA_State
gen MSA_State = (state_fips * 100000) + CBSA
unique MSA_State if SurWave == 9
unique MSA_State if SurWave == 10
unique MSA_State if SurWave == 11

********************************************************************************

recode SurMonth (1 2 3 = 1) (4 5 6 = 2) (7 8 9 = 3) (10 11 12 = 4), gen(Quarter)
gen Month = SurMonth
gen Year = SurYear
gen FIPS = (state_fips * 1000) + StCounty

save "$dir/data/cleaned/tus1423_clean.dta", replace
