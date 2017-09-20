clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
Split Student-Level Files 
Evan Kramer
9/19/2017
*/

* Define macros
global input "K:/ORP_accountability/data/2017_final_accountability_files"
global output "K:/ORP_accountability/data/2017_final_accountability_files/Accountability Application"
global date = subinstr(c(current_date), " ", "", 3)

local tcap = 0
local elpa = 0
local base = 0
local acts = 0
local chra = 0

local stu = 1

* Student level files
if `stu' == 1 {
	* Remove all previous files
	cd "$output/Student Level Files"
	!del *.csv
		
	* TNReady student level files
	use "K:/ORP_accountability/projects/2017_student_level_file/state_student_level_2017_JP_final_09142017.dta", clear
	gsort system id
	levelsof system, local(sys_list)
	
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/Student Level Files/`s'_StudentLevelFiles_$date.csv", replace
		restore
	}
	
	* ACT substitution student level files
	import delimited using "$input/student_level_act_substitution.csv", clear
	gsort system id
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/ACT Files/`s'_ACTSubstitutionStudentLevelFile_$date.csv", replace
		restore
	}
}

* District accountability files
if `dis' == 1 {
	* Base with multiple worksheets
	import delimited using "K:/ORP_accountability/data/2017_final_accountability_files/system_base_2017_aug24.csv", clear
	levelsof system, local(sys_list)
	
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/District Accountability Files/`s'_DistrictBaseFile_$date.xlsx", replace firstrow(varlabels) sheet("District Base File")
		restore
	}
	
	** Suppress state release
	import excel using "K:/ORP_accountability/projects/2017_district_release/system_results_2017.xlsx", firstrow clear
	foreach v in Below Approaching OnTrack Mastered {
		foreach l in Number Percent {
			replace `l'`v' = . if ValidTests < 10
			la var `l'`v' "`l' `v'"
		}
		replace Percent`v' = . if Percent`v' > 99 | Percent`v' < 1
		replace Number`v'  = . if Number`v' / ValidTests > .99 | Number`v' / ValidTests < .01
	}
	replace PercentOnTrackMastered = . if PercentOnTrackMastered > 99 | PercentOnTrackMastered < 1
	foreach v in OnTrack Below {
		replace ChangeinPercent`v' = . if ValidTests < 10
	}
	
	** Output files
	la var SystemName "System Name"
	la var ValidTests "Valid Tests"
	la var NumberOnTrack "Number On Track"
	la var PercentOnTrack "Percent On Track"
	la var PercentOnTrackMastered "Percent On Track Mastered"
	la var ChangeinPercentOnTrack "Change in Percent On Track"
	la var ChangeinPercentBelow "Change in Percent Below"
		
	levelsof System, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if System == `s'
		export excel using "$output/District Accountability Files/`s'_DistrictBaseFile_$date.xlsx", firstrow(varlabels) sheet("Public Release Data") 
		restore
	}
	
	* Numeric
	
}

* School level files
* School accountability files
* ELPA files
* ACT files
* AMO files
* Chronic absenteeism files








exit

* TCAP student level
if `tcap' == 1 {
	use "K:/ORP_accountability/projects/2017_student_level_file/state_student_level_2017_JP_final.dta", clear

	* List of distinct systems
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/Student Level Files/`s'_StudentLevelFiles_$date.csv", replace
		restore
	}
}

* ELPA student level
if `elpa' == 1 {
	import delimited using "K:/ORP_accountability/projects/Jessica/Data Returns/Data/WIDA/WIDA_student_level2017_formatted.csv", clear
	la var drcrecordid "DRC Record ID"
	la var reportedrecord "Reported Record" 
	la var statenameabbreviation "State Name Abbreviation"
	la var systemname "System Name"
	rename systemnumber system 
	la var system "System Number"
	la var schoolname "School Name"
	la var schoolnumber "School Number"
	la var studentlastname "Student Last Name"
	la var studentfirstname "Student First Name"
	la var studentmiddlename "Student Middle Name" 
	la var birthdate "Birth Date"
	la var gender "Gender" 
	la var statestudentid "State Student ID"
	la var districtstudentid "District Student ID"
	la var grade "Grade"
	la var clusterlistening "Cluster - Listening" 
	la var clusterreading "Cluster - Reading"
	la var clusterspeaking "Cluster - Speaking"
	la var clusterwriting "Cluster - Writing"
	la var tierlistening "Tier - Listening"
	la var tierreading "Tier - Reading"
	la var tierspeaking "Tier - Speaking"
	la var tierwriting "Tier - Writing"
	la var reportedtier "Reported Tier"
	la var ethnicityhispaniclatino "Ethnicity - Hispanic/Latino"
	la var raceamericanindianalaskanative "Race - American Indian/Alaska Native"
	la var raceasian "Race - Asian"
	la var raceblackafricanamerican "Race - Black/African American"
	la var racepacificislanderhawaiian "Race - Pacific Islander/Hawaiian"
	la var racewhite "Race - White"
	la var nativelanguage "Native Language"
	la var datefirstenrolledusschool "Date First Enrolled US School"
	la var lengthoftimeinlepellprogram "Length of Time in LEP/ELL Program"
	la var titleiiistatus "Title III Status"
	la var migrant "Migrant"
	la var iepstatus "IEP Status"
	la var plan "504 Plan"
	la var primarydisability "Primary Disability"
	la var secondarydisability "Secondary Disability"
	la var liepclassification "LIEP Classification"
	la var liepparentalrefusal "LIEP - Parental Refusal"
	la var liepoptionaldata "LIEP - Optional Data"
	la var mcaccommodation "MC - Accommodation"
	la var raaccommodation "RA - Accommodation"
	la var esaccommodation "ES - Accommodation"
	la var lpaccommodation "LP - Accommodation"
	la var braccommodation "BR - Accommodation"
	la var sdaccommodation "SD - Accommodation"
	la var hraccommodation "HR - Accommodation"
	la var rraccommodation "RR - Accommodation"
	la var hiaccommodation "HI - Accommodation"
	la var riaccommodation "RI - Accommodation"
	la var sraccommodation "SR - Accommodation"
	la var wdaccommodation "WD - Accommodation"
	la var rdaccommodation "RD - Accommodation"
	la var nsaccommodation "NS - Accommodation"
	la var etaccommodation "ET - Accommodation"
	la var emaccommodation "EM - Accommodation"
	la var statedefinedoptionaldata "State Defined Optional Data"
	la var districtdefinedoptionaldata "District Defined Optional Data"
	la var studenttype "Student Type"
	la var additionalfieldtobeusedbyastatei "Additional field to be used by a state if needed"
	la var formnumber "Form Number"
	la var listeningrawitemresponsesgradesk "Listening Raw Item Responses - Grades K-12"
	la var readingrawitemresponsesgradesk12 "Reading Raw Item Responses - Grades K-12"
	la var speakingrawitemresponsesgradesk1 "Speaking Raw Item Responses - Grades K-12"
	la var writingratingtask1grades112 "Writing Rating Task 1 - Grades 1-12"
	la var writingratingtask2grades112 "Writing Rating Task 2 - Grades 1-12"
	la var writingratingtask3grades112 "Writing Rating Task 3 - Grades 1-12"
	la var writingratingtask4grades1tiera "Writing Rating Task 4 - Grades 1 Tier A"
	la var writingrawresponseskindergarten "Writing Raw Responses - Kindergarten"
	la var domaintermintationlistening "Domain Termintation - Listening"
	la var domaintermintationreading "Domain Termintation - Reading"
	la var domaintermintationspeaking "Domain Termintation - Speaking"
	la var domaintermintationwriting "Domain Termintation - Writing"
	la var listeningcomplete "Listening - Complete"
	la var readingcomplete "Reading - Complete"
	la var speakingcomplete "Speaking - Complete"
	la var writingcomplete "Writing - Complete"
	la var listeningscoredresponsesgradesk1 "Listening Scored Responses - Grades K-12"
	la var readingscoredresponsesgradesk12 "Reading Scored Responses - Grades K-12"
	la var speakingscoredresponsesgradesk12 "Speaking Scored Responses - Grades K-12"
	la var writingscoredresponsestask1grade "Writing Scored Responses - Task 1 (Grades 1-12)"
	la var writingscoredresponsestask2grade "Writing Scored Responses - Task 2 (Grades 1-12)"
	la var writingscoredresponsestask3grade "Writing Scored Responses - Task 3 (Grades 1-12)"
	la var writingscoredresponsestask4grade "Writing Scored Responses - Task 4 (Grade 1 Tier A)"
	la var writingscoredresponseskindergart "Writing Scored Responses - Kindergarten"
	la var listeningscalescore "Listening Scale Score"
	la var readingscalescore "Reading Scale Score"
	la var speakingscalescore "Speaking Scale Score"
	la var writingscalescore "Writing Scale Score"
	la var comprehensionscalescore "Comprehension Scale Score"
	la var oralscalescore "Oral Scale Score"
	la var literacyscalescore "Literacy Scale Score"
	la var compositeoverallscalescore "Composite (Overall) Scale Score"
	la var listeningproficiencylevel "Listening Proficiency Level"
	la var readingproficiencylevel "Reading Proficiency Level"
	la var speakingproficiencylevel "Speaking Proficiency Level"
	la var writingproficiencylevel "Writing Proficiency Level"
	la var comprehensionproficiencylevel "Comprehension Proficiency Level"
	la var oralproficiencylevel "Oral Proficiency Level"
	la var literacyproficiencylevel "Literacy Proficiency Level"
	la var compositeoverallproficiencylevel "Composite (Overall) Proficiency Level"
	la var donotscorecodelistening "Do Not Score Code - Listening"
	la var donotscorecodereading "Do Not Score Code - Reading"
	la var donotscorecodespeaking "Do Not Score Code - Speaking"
	la var donotscorecodewriting "Do Not Score Code - Writing"
	la var listeningconfidencehighscore "Listening Confidence - High Score"
	la var listeningconfidencelowscore "Listening Confidence - Low Score"
	la var readingconfidencehighscore "Reading Confidence - High Score"
	la var readingconfidencelowscore "Reading Confidence - Low Score"
	la var speakingconfidencehighscore "Speaking Confidence - High Score"
	la var speakingconfidencelowscore "Speaking Confidence - Low Score"
	la var writingconfidencehighscore "Writing Confidence - High Score"
	la var writingconfidencelowscore "Writing Confidence - Low Score"
	la var comprehensionconfidencehighscore "Comprehension Confidence - High Score"
	la var comprehensionconfidencelowscore "Comprehension Confidence - Low Score"
	la var oralconfidencehighscore "Oral Confidence - High Score"
	la var oralconfidencelowscore "Oral Confidence - Low Score"
	la var literacyconfidencehighscore "Literacy Confidence - High Score"
	la var literacyconfidencelowscore "Literacy Confidence - Low Score"
	la var compositeoverallconfidencehighsc "Composite (Overall) Confidence - High Score"
	la var compositeoverallconfidencelowsco "Composite (Overall) Confidence - Low Score"
	la var testcompletiondate "Test Completion Date"
	la var securitybarcodelistening "Security Barcode - Listening"
	la var securitybarcodereading "Security Barcode - Reading"
	la var securitybarcodespeaking "Security Barcode - Speaking"
	la var securitybarcodewriting "Security Barcode - Writing"
	la var lithocodelistening "Lithocode - Listening"
	la var lithocodereading "Lithocode - Reading"
	la var lithocodespeaking "Lithocode - Speaking"
	la var lithocodewriting "Lithocode - Writing"
	la var listeningtesteventid "Listening Test Event ID"
	la var readingtesteventid "Reading Test Event ID"
	la var speakingtesteventid "Speaking Test Event ID"
	la var writingtesteventid "Writing Test Event ID"
	la var documentlabelcodelistening "Document Label Code - Listening"
	la var documentlabelcodereading "Document Label Code - Reading"
	la var documentlabelcodespeaking "Document Label Code - Speaking"
	la var documentlabelcodewriting "Document Label Code - Writing"
	la var reportedmode "Reported Mode"
	la var modeofadministrationlistening "Mode of Administration - Listening"
	la var modeofadministrationreading "Mode of Administration - Reading"
	la var modeofadministrationspeaking "Mode of Administration - Speaking"
	la var modeofadministrationwriting "Mode of Administration - Writing"
	la var modeofresponsewriting "Mode of Response - Writing"
	la var onlinelisteningitemids "Online Listening Item IDs"
	la var onlinereadingitemids "Online Reading Item IDs"
	la var semlistening "SEM - Listening"
	la var semreading "SEM - Reading"
	la var semspeaking "SEM - Speaking"
	la var semwriting "SEM - Writing"
	la var semoral "SEM - Oral"
	la var semliteracy "SEM - Literacy"
	la var semcomprehension "SEM - Comprehension"
	la var semoverall "SEM - Overall"
	la var futureuse1 "Future Use 1"
	la var futureuse2 "Future Use 2"
	la var futureuse3 "Future Use 3"
	la var futureuse4 "Future Use 4"
	la var datetimestamp "Date/Time Stamp"
	la var fileuse "File Use"
	la var priorcompositeperformancelevelne "Prior Composite Performance Level New Standard"
	la var priorliteracyperformancelevelnew "Prior Literacy Performance Level New Standard"
	la var priorcompositescalescorenewstand "Prior Composite Scale Score New Standard"
					
	* List of distinct systems
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/ELPA Files/`s'_ACCESSStudentLevelFile_$date.xlsx", replace firstrow(varlabels)
		restore
	}
}

* Base with second worksheet for state release
if `base' == 1 {
	
}

* ACT substitution student level
if `acts' == 1 {
	
}

* Chronic absenteeism student level
if `chra' == 1 {
	import delimited using "K:/ORP_accountability/data/2017_chronic_absenteeism/student_chronic_absenteeism.csv", clear
	
	* List of distinct systems
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/Chronic Absenteeism/`s'_ChronicAbsenteeismStudentFile_$date.csv", replace
		restore
	}
}
