clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
Split Files 
Evan Kramer
10/24/2017
*/

* Define macros
global input "K:/ORP_accountability/data/2017_final_accountability_files"
global output "K:/ORP_accountability/data/2017_final_accountability_files/Accountability Application"
global app = "J:\WEBPAGES\NCLBAppeals\Accountability Web Files"
global date = subinstr(c(current_date), " ", "", 3)

** Master files
global student_level = "state_student_level_2017_JP_final_10162017.dta"
global act_sub_student_level = "student_level_act_substitution.csv"
global district_base = "system_base_2017_oct17.csv"
global district_release = "system_release_2017_JW_10172017_formatted.xlsx"
global district_numeric = "system_numeric_2017_oct17.csv"
global heat_map = ""
global school_release = "school_release_2017_JW_10172017_formatted.xlsx"
global school_base = "school_base_2017_oct17.csv"
global school_numeric = "school_numeric_2017_oct17.csv"
global wida_student = "WIDA_student_level2017.csv"
global wida_district = ""
global wida_school = ""
global chronic_student = "student_chronic_absenteeism.csv"
global chronic_district = "system_chronic_absenteeism.csv"
global chronic_school = "school_chronic_absenteeism.csv"
global amo_input = "K:/ORP_accountability/projects/2018_amo"

** Flags
local stu = 0
local dis = 0
local sch = 0
local sca = 0
local elp = 0
local gr2 = 0
local act = 0
local amo = 0
local abs = 0
local sof = 0
local cor = 0
local che = 0
local err = 0
local van = 0
local hen = 0
local asd = 1

* ASD school split
if `asd' == 1 {
	cd "J:\WEBPAGES\NCLBAppeals\Accountability Web Files"
	* Data summary, Focus exit/improving, Priority exit/improving, School accountability file
	foreach f in DataSummary FocusExitImprove PriorityExitImprove SchoolAccountabilityFile {
		import delimited using "985_`f'_18Oct2017.csv", clear
		levelsof school, local(sch_list)
		foreach s in `sch_list' {
			preserve
			keep if school == `s'
			export delimited using "K:/ORP_accountability/projects/Evan/Data Releases/ASD School Split/985_`s'_`f'_$date.csv", replace
			restore
		}
	}
	
	* Reward file, school base file
	foreach f in RewardFile {
		import delimited using "985_`f'_19Oct2017.csv", clear
		levelsof school, local(sch_list)
		foreach s in `sch_list' {
			preserve
			keep if school == `s'
			export delimited using "K:/ORP_accountability/projects/Evan/Data Releases/ASD School Split/985_`s'_`f'_$date.csv", replace
			restore
		}
	}
	
	* School AMO
	foreach sh in "Accountability Targets" "Subject Targets | Planning Only" {
		import excel using "985_SchoolLevelAMO_15Nov2017.xlsx", firstrow clear sheet("`sh'")
		levelsof school, local(sch_list)
		foreach s in `sch_list' {
			preserve
			keep if school == `s'
			export excel using "K:/ORP_accountability/projects/Evan/Data Releases/ASD School Split/985_`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("`sh'", replace)
			restore
		}
	}
	
	* School base file
	foreach sh in "Sheet1" "Public Release Data" {		
		import excel using "985_SchoolBaseFile_19Oct2017.xlsx", firstrow clear sheet("`sh'")
		levelsof school, local(sch_list)
		foreach s in `sch_list' {
			preserve
			keep if school == `s'
			export excel using "K:/ORP_accountability/projects/Evan/Data Releases/ASD School Split/985_`s'_SchoolBaseFile_$date.xlsx", firstrow(var) sheet("`sh'", replace)
			restore
		}
	}
			
	* Student level file
	foreach f in StudentLevelFiles {
		import delimited using "985_`f'_12Oct2017.csv", clear
		levelsof school, local(sch_list)
		foreach s in `sch_list' {
			preserve
			keep if school == `s'
			export delimited using "K:/ORP_accountability/projects/Evan/Data Releases/ASD School Split/985_`s'_`f'_$date.csv", replace
			restore
		}
	}
	
	* School numeric file
	foreach f in SchoolNumericFile {
		import excel using "985_`f'_12Oct2017.xlsx", clear firstrow
		levelsof school, local(sch_list)
		foreach s in `sch_list' {
			preserve
			keep if school == `s'
			export delimited using "K:/ORP_accountability/projects/Evan/Data Releases/ASD School Split/985_`s'_`f'_$date.csv", replace
			restore
		}
	}
	
	* Grade 2 student, Grade 2 school, ELPA school
	foreach f in Grade2StudentFile Grade2SchoolFile ACCESSSchoolLevelFile {
		import delimited using "985_`f'_26Oct2017.csv", clear 
		levelsof school, local(sch_list)
		foreach s in `sch_list' {
			preserve
			keep if school == `s'
			export delimited using "K:/ORP_accountability/projects/Evan/Data Releases/ASD School Split/985_`s'_`f'_$date.csv", replace
			restore
		}
	}
	
	* ELPA student level
	foreach f in ACCESSStudentLevelFile {
		import excel using "985_`f'_3Aug2017.xlsx", clear firstrow
		levelsof SchoolNumber, local(sch_list)
		foreach s in `sch_list' {
			preserve
			keep if SchoolNumber == `s'
			export delimited using "K:/ORP_accountability/projects/Evan/Data Releases/ASD School Split/985_`s'_`f'_$date.csv", replace
			restore
		}
	}
}

* Henry County attendance errors
if `hen' == 1 {
	* Chronic absence files
	** Remove all previous files
	cd "$output/Chronic Absenteeism Files"
	!del 400*.csv
	cd "J:\WEBPAGES\NCLBAppeals\Accountability Web Files"
	!del 400_Chronic*.csv
	
	** District level
	import delimited using "K:/ORP_accountability/data/2017_chronic_absenteeism/$chronic_district", clear
	replace grade_band = "9th through 12th" if grade_band == "9-12"
	replace grade_band = "K through 8th" if grade_band == "K-8"
	preserve
	local s = 400
	keep if system == `s'
	export delimited using "$output/Chronic Absenteeism Files/`s'_ChronicAbsenteeismDistrictFile_$date.csv", replace
	export delimited using "J:\WEBPAGES\NCLBAppeals\Accountability Web Files/`s'_ChronicAbsenteeismDistrictFile_$date.csv", replace
	restore
	
	** School level
	import delimited using "K:/ORP_accountability/data/2017_chronic_absenteeism/$chronic_school", clear
	keep if grade_band == "All Grades"
	preserve
	local s = 400
	keep if system == `s' 
	export delimited using "$output/Chronic Absenteeism Files/`s'_ChronicAbsenteeismSchoolFile_$date.csv", replace
	export delimited using "J:\WEBPAGES\NCLBAppeals\Accountability Web Files/`s'_ChronicAbsenteeismSchoolFile_$date.csv", replace
	restore
		
	** Student level
	import delimited using "K:/ORP_accountability/data/2017_chronic_absenteeism/$chronic_student", clear
	rename (isp_days instructional_calendar_days) (student_enrolled_days school_instructional_days)
	destring absentee_rate, force replace
	preserve
	local s = 400
	keep if system == `s'
	export delimited using "$output/Chronic Absenteeism Files/`s'_ChronicAbsenteeismStudentFile_$date.csv", replace
	export delimited using "J:\WEBPAGES\NCLBAppeals\Accountability Web Files/`s'_ChronicAbsenteeismStudentFile_$date.csv", replace
	restore
}
* Van Buren 60% errors and Bartlett
if `van' == 1 {
	* Student level
	cd "$app"
	!del 880_StudentLevelFiles*
	cd "K:/ORP_accountability/data/2017_final_accountability_files/Accountability Application/Student Level Files"
	! del 880_StudentLevelFiles*
	use "K:/ORP_accountability/projects/2017_student_level_file/state_student_level_2017_JP_final_10192017", clear
	foreach s in 880 {
		preserve
		keep if system == `s'
		export excel using "$app/`s'_StudentLevelFiles_$date.xlsx", replace firstrow(var)
		export excel using "K:/ORP_accountability/data/2017_final_accountability_files/Accountability Application/Student Level Files/`s'_StudentLevelFiles_$date.xlsx", replace firstrow(var)
		restore
	}
		
	* School numeric
	cd "$app"
	!del 880_SchoolNumericFile*
	cd "K:/ORP_accountability/data/2017_final_accountability_files/Accountability Application/School Level Files"
	!del 880_SchoolNumericFile*
	
	import delimited using "K:/ORP_accountability/data/2017_final_accountability_files/school_numeric_2017_oct17.csv", clear
	foreach s in 880 {
		preserve
		keep if system == `s'
		export excel using "$app/`s'_SchoolNumericFile_$date.xlsx", replace firstrow(var)
		export excel using "K:/ORP_accountability/data/2017_final_accountability_files/Accountability Application/School Level Files/`s'_SchoolNumericFile_$date.xlsx", replace firstrow(var)
		restore
	}
	
	* District numeric
	cd "$app"
	!del 880_DistrictNumericFile*
	cd "K:/ORP_accountability/data/2017_final_accountability_files/Accountability Application/District Accountability Files"
	!del 880_DistrictNumericFile*
	
	import delimited using "K:/ORP_accountability/data/2017_final_accountability_files/system_numeric_2017_oct17.csv", clear
	foreach s in 880 {
		preserve
		keep if system == `s'
		export excel using "$app/`s'_DistrictNumericFile_$date.xlsx", replace firstrow(var)
		export excel using "K:/ORP_accountability/data/2017_final_accountability_files/Accountability Application/District Accountability Files/`s'_DistrictNumericFile_$date.xlsx", replace firstrow(var)
		restore
	}
	
	* District AMO
	cd "J:\WEBPAGES\NCLBAppeals\Accountability Web Files"
	!del 880*AMO*
	!del 794*AMO*
	cd "K:\ORP_accountability\data\2017_final_accountability_files\Accountability Application\AMO Files"
	!del 880*AMO*
	!del 794*AMO*
	
	** Accountability targets
	import delimited using "$amo_input/district_success_rate.csv", clear
	rename amo_target_4 double_amo_target
	tempfile amo_sr
	save `amo_sr', replace
	
	import delimited using "$amo_input/district_grad.csv", clear
	rename (grad_target grad_target_double) (amo_target double_amo_target)
	gen subject = "Graduation Rate", after(system_name)
	gen grade = "9th through 12th", after(subject)
	tempfile amo_grad
	save `amo_grad', replace
	
	import delimited using "$amo_input/district_elpa.csv", clear
	rename (amo_target_4 valid_tests) (double_amo_target valid_tests_prior)
	gen year = 2018, before(system)
	gen subject = "ELPA", after(system_name)
	gen grade = "All Grades", after(subject)
	tempfile amo_elpa
	
	save `amo_elpa', replace
	import delimited using "$amo_input/system_chronic_absenteeism.csv", clear
	gen subject = "Chronically Out of School", after(system_name)
	rename (grade_band amo_reduction_target_double) (grade double_amo_reduction_target) 
	order grade, after(subject)
	append using `amo_sr'
	append using `amo_grad'
	append using `amo_elpa'
	gsort system -subject grade subgroup
	order year system* subject grade subgroup amo_target double_amo_target amo_reduction_target ///
		double_amo_reduction_target valid_tests_prior pct_on_mastered_prior grad_cohort grad_rate ///
		n_met_growth pct_met_growth n_students n_chronically_absent pct_chronically_absent, first
		
	foreach s in 794 880 {
		preserve
		keep if system == `s'
		export excel using "$output/AMO Files/`s'_DistrictLevelAMO_$date.xlsx", firstrow(var) sheet("Accountability Targets") 
		export excel using "$app/`s'_DistrictLevelAMO_$date.xlsx", firstrow(var) sheet("Accountability Targets")
		restore
	}
	
	** Subject level targets
	import delimited using "$amo_input/district_grade_subject.csv", clear
	rename amo_target_4 double_amo_target
	order year system system_name subject grade subgroup amo_target double_amo_target subgroup valid_tests, first
	foreach s in 794 880 {
		preserve
		keep if system == `s'
		export excel using "$output/AMO Files/`s'_DistrictLevelAMO_$date.xlsx", firstrow(var) sheet("Subject Targets | Planning Only")
		export excel using "$app/`s'_DistrictLevelAMO_$date.xlsx", firstrow(var) sheet("Subject Targets | Planning Only")
		restore
	}
	
	* School AMO
	** Accountability targets
	import delimited using "$amo_input/school_success_rate.csv", clear
	rename amo_target_4 double_amo_target
	gen grade = "All Grades", after(subject)
	tempfile amo_sr
	save `amo_sr', replace
	
	import delimited using "$amo_input/school_ready_grad.csv", clear
	gen year = 2018, before(system)
	rename (grad_target grad_target_double) (amo_target double_amo_target)
	drop *act* 
	gen subject = "Graduation Rate", after(school)
	gen grade = "9th through 12th", after(subject)
	tempfile amo_grad
	save `amo_grad', replace
	
	import delimited using "$amo_input/school_ready_grad.csv", clear
	gen year = 2018, before(system)
	drop grad_target* grad_rate 
	rename (act_grad_target act_grad_target_double) (amo_target double_amo_target)
	gen subject = "Ready Graduate", after(school)
	gen grade = "9th through 12th", after(subject)
	tempfile amo_ready_grad
	save `amo_ready_grad', replace
	
	import delimited using "$amo_input/school_chronic_absenteeism.csv", clear
	gen subject = "Chronically Out of School", after(school_name)
	rename (grade_band amo_reduction_target_double) (grade double_amo_reduction_target) 
	order grade, after(subject)
	append using `amo_sr'
	append using `amo_grad'
	append using `amo_ready_grad'
	gsort system school -pool
	replace pool = pool[_n-1] if pool == "" & system == system[_n-1] & school == school[_n-1]
	gsort system school -system_name -school_name 
	foreach v in system_name school_name {
		replace `v' = `v'[_n-1] if `v' == "" & system == system[_n-1] & school == school[_n-1]
	}
	gsort system school -subject grade subgroup
	order year system* school* pool subject grade subgroup amo_target double_amo_target /// 
		amo_reduction_target double_amo_reduction_target valid_tests_prior pct_on_mastered_prior ///
		grad_cohort grad_rate valid_tests_act act_21_or_higher n_students ///
		n_chronically_absent pct_chronically_absent, first
	
	foreach s in 794 880 {
		preserve
		keep if system == `s'
		export excel using "$output/AMO Files/`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("Accountability Targets") 
		export excel using "$app/`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("Accountability Targets") 
		restore
	}
	
	collapse (firstnm) school_name, by(system school)
	tempfile temp
	save `temp', replace
	
	** Subject level targets
	import delimited using "$amo_input/school_subject.csv", clear
	rename amo_target_4 double_amo_target
	foreach v in pct_on_mastered_prior amo_target double_amo_target {
		replace `v' = "" if `v' == "NA"
		destring `v', replace
	}
	mmerge system school using `temp', type(n:1)
	drop if _merge == 2
	drop _merge 
	gsort system school subject subgroup
	order year system* school* pool subject subgroup amo_target double_amo_target /// 
		valid_tests_prior pct_on_mastered_prior, first
	
	foreach s in 794 880 {
		preserve
		keep if system == `s'
		export excel using "$output/AMO Files/`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("Subject Targets | Planning Only")
		export excel using "$app/`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("Subject Targets | Planning Only")
		restore
	}	
}

* Resolve errors
if `err' == 1 {
	* Student level
	cd "$app"
	!del 541_StudentLevelFiles*
	!del 880_StudentLevelFiles*
	use "K:/ORP_accountability/projects/2017_student_level_file/$student_level", clear
	foreach s in 541 880 {
		preserve
		keep if system == `s'
		export excel using "$app/`s'_StudentLevelFiles_$date.xlsx", replace firstrow(var)
		restore
	}
	
	* District base
	cd "$app" 
	!del 541_DistrictBase*
	!del 880_DistrictBase*
	
	** Base
	import delimited using "$input/$district_base", clear
	foreach s in 541 880 {
		preserve
		keep if system == `s'
		export excel using "$app/`s'_DistrictBaseFile_$date.xlsx", replace firstrow(varlabels) sheet("District Base File")
		restore
	}
	
	** Suppress state release
	import excel using "$input/$district_release", firstrow clear
	rename (Year System SystemName Subject Subgroup Grade ValidTests NBelow NApproaching NOnTrack NMastered PercentBelow PercentApproaching PercentOnTrack PercentMastered PercentOnTrackMastered BelowChange OMChange) ///
		(year system system_name subject subgroup grade valid_tests n_below n_approaching n_on_track n_mastered pct_below pct_approaching pct_on_track pct_mastered pct_on_mastered change_in_pct_below change_in_pct_on_mastered)
		
	foreach v in below approaching on_track mastered {
		foreach l in n_ pct_ {
			replace `l'`v' = . if valid_tests < 10
		}
		replace pct_`v' = . if pct_`v' > 99 | pct_`v' < 1
		replace n_`v' = . if n_`v' / valid_tests > .99 | n_`v' / valid_tests < .01
	}
	replace pct_on_mastered = . if pct_on_mastered > 99 | pct_on_mastered < 1
	foreach v in below on_mastered {
		replace change_in_pct_`v' = . if valid_tests < 10
	}
	
	la var year "Year" 
	la var system "District Number" 
	la var system_name "District Name" 
	la var subject "Subject" 
	la var subgroup "Subgroup" 
	la var grade "Grade" 
	la var valid_tests "Valid Tests" 
	la var n_below "# Below (Below Basic)"
	la var n_approaching "# Approaching (Basic)"
	la var n_on_track "# On Track (Proficient)"
	la var n_mastered "# Mastered (Advanced)"
	la var pct_below "% Below (Below Basic)"
	la var pct_approaching "% Approaching (Basic)"
	la var pct_on_track "% On Track (Proficient)"
	la var pct_mastered "% Mastered (Advanced)" 
	la var pct_on_mastered "% On Track/Mastered (Proficient/Advanced)"
	la var change_in_pct_below "% Below Change"
	la var change_in_pct_on_mastered "% On Track/Mastered Change"
	
	foreach s in 541 880 {
		preserve
		keep if system == `s'
		export excel using "$app/`s'_DistrictBaseFile_$date.xlsx", firstrow(varlabels) sheet("Public Release Data") 
		restore
	}
	
	* School numeric
	cd "$app"
	!del 541_SchoolNumericFile*
	!del 880_SchoolNumericFile*
	import delimited using "$input/$school_numeric", clear
	foreach s in 541 880 {
		preserve
		keep if system == `s'
		export excel using "$app/`s'_SchoolNumericFile_$date.xlsx", replace firstrow(var)
		restore
	}	
}

* Student level files
if `stu' == 1 {
	* Remove all previous files
	cd "$output/Student Level Files"
	!del *.csv
		
	* TNReady student level files
	use "K:/ORP_accountability/projects/2017_student_level_file/$student_level", clear
	gsort system id
	levelsof system, local(sys_list)
	
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/Student Level Files/`s'_StudentLevelFiles_$date.csv", replace
		restore
	}
}

* District accountability files
if `dis' == 1 {
	* Remove all previous files
	cd "$output/District Accountability Files"
	!del *.csv
	!del *.xlsx
	
	* Base with multiple worksheets
	import delimited using "K:/ORP_accountability/data/2017_final_accountability_files/$district_base", clear
	levelsof system, local(sys_list)
	
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/District Accountability Files/`s'_DistrictBaseFile_$date.xlsx", replace firstrow(varlabels) sheet("District Base File")
		restore
	}
	
	** Suppress state release
	import excel using "$input/$district_release", firstrow clear
	rename (Year System SystemName Subject Subgroup Grade ValidTests NBelow NApproaching NOnTrack NMastered PercentBelow PercentApproaching PercentOnTrack PercentMastered PercentOnTrackMastered BelowChange OMChange) ///
		(year system system_name subject subgroup grade valid_tests n_below n_approaching n_on_track n_mastered pct_below pct_approaching pct_on_track pct_mastered pct_on_mastered change_in_pct_below change_in_pct_on_mastered)
		
	foreach v in below approaching on_track mastered {
		foreach l in n_ pct_ {
			replace `l'`v' = . if valid_tests < 10
		}
		replace pct_`v' = . if pct_`v' > 99 | pct_`v' < 1
		replace n_`v' = . if n_`v' / valid_tests > .99 | n_`v' / valid_tests < .01
	}
	replace pct_on_mastered = . if pct_on_mastered > 99 | pct_on_mastered < 1
	foreach v in below on_mastered {
		replace change_in_pct_`v' = . if valid_tests < 10
	}
	
	la var year "Year" 
	la var system "District Number" 
	la var system_name "District Name" 
	la var subject "Subject" 
	la var subgroup "Subgroup" 
	la var grade "Grade" 
	la var valid_tests "Valid Tests" 
	la var n_below "# Below (Below Basic)"
	la var n_approaching "# Approaching (Basic)"
	la var n_on_track "# On Track (Proficient)"
	la var n_mastered "# Mastered (Advanced)"
	la var pct_below "% Below (Below Basic)"
	la var pct_approaching "% Approaching (Basic)"
	la var pct_on_track "% On Track (Proficient)"
	la var pct_mastered "% Mastered (Advanced)" 
	la var pct_on_mastered "% On Track/Mastered (Proficient/Advanced)"
	la var change_in_pct_below "% Below Change"
	la var change_in_pct_on_mastered "% On Track/Mastered Change"
	
	
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/District Accountability Files/`s'_DistrictBaseFile_$date.xlsx", firstrow(varlabels) sheet("Public Release Data") 
		restore
	}
	
	* Numeric
	import delimited using "$input/$district_numeric", clear
	rename (bb_percentile_2015 pa_percentile_2015) (bb_percentile_prior pa_percentile_prior)
	 
	levelsof system, local(sys_list)
	
	** Output files
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		*export excel using "$output/District Accountability Files/`s'_DistrictNumericFile_$date.xlsx", replace firstrow(var)
		export excel using "C:/Users/CA19130/Documents/Projects/Heat Maps/Numeric Files/`s'_DistrictNumericFile_$date.xlsx", replace firstrow(var)
		restore
	}
	
	* Heat map files
}

* School level files
if `sch' == 1 {
	* Remove all previous files
	cd "$output/School Level Files"
	!del *.csv
	!del *.xlsx
	
	* School base with second worksheet for public release
	import delimited using "$input/$school_base", clear
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/School Level Files/`s'_SchoolBaseFile_$date.xlsx", replace firstrow(varlabels)
		restore
	}
		
	** Suppress state release
	import excel using "$input/$school_release", firstrow clear
	rename (System SystemName School SchoolName Subject Subgroup Grade ValidTests NBelow NApproaching NOnTrack NMastered PercentBelow PercentApproaching PercentOnTrack PercentMastered PercentOnTrackMastered BelowChange OMChange) ///
		(system system_name school school_name subject subgroup grade valid_tests n_below n_approaching n_on_track n_mastered pct_below pct_approaching pct_on_track pct_mastered pct_on_mastered change_in_pct_below change_in_pct_on_mastered)
			
	foreach v in below approaching on_track mastered {
		foreach l in n_ pct_ {
			replace `l'`v' = . if valid_tests < 10
		}
		replace pct_`v' = . if pct_`v' > 99 | pct_`v' < 1
		replace n_`v' = . if n_`v' / valid_tests > .99 | n_`v' / valid_tests < .01
	}
	replace pct_on_mastered = . if pct_on_mastered > 99 | pct_on_mastered < 1
	foreach v in below on_mastered {
		replace change_in_pct_`v' = . if valid_tests < 10
	}	
	
	la var system "District Number" 
	la var system_name "District Name" 
	la var school "School Number"
	la var school_name "School Name"
	la var subject "Subject" 
	la var subgroup "Subgroup" 
	la var grade "Grade" 
	la var valid_tests "Valid Tests" 
	la var n_below "# Below (Below Basic)"
	la var n_approaching "# Approaching (Basic)"
	la var n_on_track "# On Track (Proficient)"
	la var n_mastered "# Mastered (Advanced)"
	la var pct_below "% Below (Below Basic)"
	la var pct_approaching "% Approaching (Basic)"
	la var pct_on_track "% On Track (Proficient)"
	la var pct_mastered "% Mastered (Advanced)" 
	la var pct_on_mastered "% On Track/Mastered (Proficient/Advanced)"
	la var change_in_pct_below "% Below Change"
	la var change_in_pct_on_mastered "% On Track/Mastered Change"
	
	levelsof system, local(sys_list)
	
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/School Level Files/`s'_SchoolBaseFile_$date.xlsx", firstrow(var) sheet("Public Release Data") 
		restore
	}
	
	* School numeric
	import delimited using "$input/$school_numeric", clear
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/School Level Files/`s'_SchoolNumericFile_$date.xlsx", replace firstrow(var)
		restore
	}
}
* School accountability files
if `sca' == 1 {
	* Remove all previous files
	cd "$output/School Accountability Files"
	!del *.csv
	!del *.xlsx
	
	* School accountability file
	import delimited using "K:/ORP_accountability/projects/2017_school_accountability/grade_pools_designation_immune.csv", clear
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/School Accountability Files/`s'_SchoolAccountabilityFile_$date.csv", replace
		restore
	}
	
	* Data summary
	import delimited using "K:/ORP_accountability/projects/2017_school_accountability/school_summary_file.csv", clear
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve 
		keep if system == `s'
		export delimited using "$output/School Accountability Files/`s'_DataSummary_$date.csv", replace
		restore
	}
	
	* Reward school file
	import delimited using "K:/ORP_accountability/projects/2017_school_accountability/reward.csv", clear
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/School Accountability Files/`s'_RewardFile_$date.csv", replace
		restore
	}
	
	* Priority exit and improving file
	import delimited using "K:/ORP_accountability/projects/2017_school_accountability/priority_exit_improving.csv", clear
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve 
		keep if system == `s'
		export delimited using "$output/School Accountability Files/`s'_PriorityExitImprove_$date.csv", replace
		restore
	}
	
	* Focus exit and improving file
	import delimited using "K:/ORP_accountability/projects/2017_school_accountability/focus_exit_improving.csv", clear
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/School Accountability Files/`s'_FocusExitImprove_$date.csv", replace
		restore
	}
	
	* School accountability lists
	cd "K:\ORP_accountability\data\2017_final_accountability_files\Accountability Application\School Accountability Files"
	!del *SchoolAccountabilityStatusList*
	cd "J:\WEBPAGES\NCLBAppeals\Accountability Web Files"
	!del *SchoolAccountabilityStatusList*
		
	import delimited using "K:/ORP_accountability/projects/2017_district_release/VBA/school_lists.csv", clear
	drop school_count
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/School Accountability Files/`s'_SchoolAccountabilityStatusList_$date.csv", replace
		export delimited using "J:\WEBPAGES\NCLBAppeals\Accountability Web Files/`s'_SchoolAccountabilityStatusList_$date.csv", replace
		restore
	}
}
* ELPA files
if `elp' == 1 {
	* Remove all previous files
	cd "$output/ELPA Files"
	!del *.csv
	!del *.xlsx
	
	* District level
	use "K:/ORP_accountability/data/2017_ELPA/system_level_elpa_JW.dta", clear
	order system*, first
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "`s'_ACCESSDistrictLevelFile_$date.csv", replace
		restore
	}
	
	* School level
	use "K:/ORP_accountability/data/2017_ELPA/school_level_elpa_JW.dta", clear
	rename schoolnumber school
	order system* school* subgroup, first
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "`s'_ACCESSSchoolLevelFile_$date.csv", replace
		restore
	}
	
	* Student level
	import delimited using "K:/ORP_accountability/projects/Jessica/Data Returns/Data/WIDA/$wida_student", clear
	gsort system unique_student_id
	keep system* school* unique_student_id districtstudentid student*name birthdate gender ///
		grade cluster* ethnicity* race* datefirst* lengthoftime* titleiii* migrant ///
		iepstatus *disability *scalescore *ylevel all_s* bhn ell swd met_prof* *lag
	order system system_name school schoolname unique_student_id districtstudentid /// 
		student*name birthdate gender grade ethnicity* race* *level prof*lag *scalescore ///
		scale*lag cluster*, first
	drop schoolnumber
	
	la var system "System Number"
	la var system_name "System Name" 
	la var school "School Number" 
	la var schoolname "School Name" 
	la var unique_student_id "State ID Number"
	la var districtstudentid "District ID Number"
	la var studentlastname "Student Last Name"
	la var studentfirstname "Student First Name" 
	la var studentmiddlename "Student Middle Name"
	la var birthdate "DOB"
	la var gender "Gender" 
	la var grade "Grade" 
	la var ethnicityhispaniclatino "Ethnicity" 
	la var raceamericanindianalaskanative "Race - Native American"
	la var raceasian "Race - Asian" 
	la var raceblackafricanamerican "Race - Black"
	la var racepacificislanderhawaiian "Race - Hawaiian or Pacific Islander" 
	la var racewhite "Race - White" 
	la var listeningproficiencylevel "Listening Performance Level"
	la var readingproficiencylevel "Reading Performance Level" 
	la var speakingproficiencylevel "Speaking Performance Level" 
	la var writingproficiencylevel "Writing Performance Level" 
	la var comprehensionproficiencylevel "Comprehension Performance Level" 
	la var oralproficiencylevel "Oral Performance Level" 
	la var literacyproficiencylevel "Literacy Performance Level" 
	la var compositeoverallproficiencylevel "Composite Performance Level" 
	la var prof_level_composite_lag "Prior Year Composite Performance Level (Rescaled)"
	la var prof_level_literacy_lag "Prior Year Literacy Performance Level (Rescaled)"
	la var listeningscalescore "Listening Scale Score" 
	la var readingscalescore "Reading Scale Score"
	la var speakingscalescore "Speaking Scale Score"
	la var writingscalescore "Writing Scale Score"
	la var comprehensionscalescore "Comprehension Scale Score"
	la var oralscalescore "Oral Scale Score" 
	la var literacyscalescore "Literacy Scale Score"
	la var compositeoverallscalescore "Composite Scale Score" 
	la var scale_score_composite_lag "Prior Year Composite Scale Score (Rescaled)"
	la var clusterlistening "Listening Cluster"
	la var clusterreading "Reading Cluster" 
	la var clusterspeaking "Speaking Cluster" 
	la var clusterwriting "Writing Cluster"
	la var datefirstenrolledusschool "Date First Enrolled in US School" 
	la var lengthoftimeinlepellprogram "Length of Time in ESL Program"
	la var titleiiistatus "Title III Status" 
	la var migrant "Migrant"
	la var iepstatus "IEP Status" 
	la var primarydisability "Primary Disability" 
	la var secondarydisability "Secondary Disability" 
	la var all_students "All Students" 
	la var bhn "BHN"
	la var ell "EL"
	la var swd "SWD" 
	la var met_proficiency_standard "Met Exit Criteria"
	
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/ELPA Files/`s'_ACCESSStudentLevelFile_3Aug2017.xlsx", replace firstrow(varlabels)
		restore
	}
}

* Grade 2 assessment files
if  `gr2' == 1 {
	* Remove all previous files
	cd "$output/Grade 2 Assessment Files"
	!del *.csv
	!del *.xlsx
	
	* District
	use "K:/ORP_accountability/projects/2017_grade_2_assessment/system_level_2017_JW_final_10242017", clear
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "`s'_Grade2DistrictFile_$date.csv", replace
		restore
	}
	
	* School
	use "K:/ORP_accountability/projects/2017_grade_2_assessment/school_level_2017_JW_final_10242017", clear
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "`s'_Grade2SchoolFile_$date.csv", replace
		restore
	}
	
	* Student
	use "K:/ORP_accountability/projects/2017_grade_2_assessment/state_student_level_2017_JW_final_10242017", clear
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "`s'_Grade2StudentFile_$date.csv", replace
		restore
	}
}

* ACT files
if `act' == 1 {
	* Remove all previous files
	cd "$output/ACT Files"
	!del *ACT_*.csv
	
	* ACT substitution student level files
	import delimited using "$input/$act_sub_student_level", clear
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/ACT Files/`s'_ACTSubstitutionStudentLevelFile_$date.csv", replace
		restore
	}
	
	* District and school level
	foreach l in district school {
		local m = strproper("`l'")
		use "K:/ORP_accountability/data/2017_ACT/ACT_`m'2018.dta", clear
		levelsof system, local(sys_list)
		
		foreach s in `sys_list' {
			preserve
			keep if system == `s'
			export delimited using "$output/ACT Files/`s'_`m'LevelACT_$date.csv", replace
			restore
		}
	}
	
	* Student level
	use "K:/ORP_accountability/data/2017_ACT/2018_ACT_student_level_actcohorthighest.dta", clear
	levelsof system, local(sys_list)
	
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/ACT Files/`s'_StudentLevelACT_$date.csv", replace
		restore
	}
	
	* District retake
	* School retake
	* Student retake
}
* AMO files
if `amo' == 1 {
	* Remove all previous files
	cd "$output/AMO Files"
	!del *AMO*
	cd "J:\WEBPAGES\NCLBAppeals\Accountability Web Files"
	!del *AMO*
	
	* District level
	** Accountability targets
	import delimited using "$amo_input/district_success_rate.csv", clear
	rename amo_target_4 double_amo_target
	tempfile amo_sr
	save `amo_sr', replace
	
	import delimited using "$amo_input/district_grad.csv", clear
	rename (grad_target grad_target_double) (amo_target double_amo_target)
	gen subject = "Graduation Rate", after(system_name)
	gen grade = "9th through 12th", after(subject)
	tempfile amo_grad
	save `amo_grad', replace
	
	import delimited using "$amo_input/district_elpa.csv", clear
	rename (amo_target_4 valid_tests) (double_amo_target valid_tests_prior)
	gen year = 2018, before(system)
	gen subject = "ELPA", after(system_name)
	gen grade = "All Grades", after(subject)
	tempfile amo_elpa
	
	save `amo_elpa', replace
	import delimited using "$amo_input/system_chronic_absenteeism.csv", clear
	gen subject = "Chronically Out of School", after(system_name)
	rename (grade_band amo_reduction_target_double) (grade double_amo_reduction_target) 
	order grade, after(subject)
	append using `amo_sr'
	append using `amo_grad'
	append using `amo_elpa'
	gsort system -subject grade subgroup
	order year system* subject grade subgroup amo_target double_amo_target amo_reduction_target ///
		double_amo_reduction_target valid_tests_prior pct_on_mastered_prior grad_cohort grad_rate ///
		n_met_growth pct_met_growth n_students n_chronically_absent pct_chronically_absent, first
		
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/AMO Files/`s'_DistrictLevelAMO_$date.xlsx", firstrow(var) sheet("Accountability Targets") 
		export excel using "$app/`s'_DistrictLevelAMO_$date.xlsx", firstrow(var) sheet("Accountability Targets")
		restore
	}
	
	** Subject level targets
	import delimited using "$amo_input/district_grade_subject.csv", clear
	rename amo_target_4 double_amo_target
	order year system system_name subject grade subgroup amo_target double_amo_target subgroup valid_tests, first
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/AMO Files/`s'_DistrictLevelAMO_$date.xlsx", firstrow(var) sheet("Subject Targets | Planning Only")
		export excel using "$app/`s'_DistrictLevelAMO_$date.xlsx", firstrow(var) sheet("Subject Targets | Planning Only")
		restore
	}
	
	* School level
	** Accountability targets
	import delimited using "$amo_input/school_success_rate.csv", clear
	rename amo_target_4 double_amo_target
	gen grade = "All Grades", after(subject)
	tempfile amo_sr
	save `amo_sr', replace
	
	import delimited using "$amo_input/school_ready_grad.csv", clear
	gen year = 2018, before(system)
	rename (grad_target grad_target_double) (amo_target double_amo_target)
	drop *act* 
	gen subject = "Graduation Rate", after(school)
	gen grade = "9th through 12th", after(subject)
	tempfile amo_grad
	save `amo_grad', replace
	
	import delimited using "$amo_input/school_ready_grad.csv", clear
	gen year = 2018, before(system)
	drop grad_target* grad_rate 
	rename (act_grad_target act_grad_target_double) (amo_target double_amo_target)
	gen subject = "Ready Graduate", after(school)
	gen grade = "9th through 12th", after(subject)
	tempfile amo_ready_grad
	save `amo_ready_grad', replace
	
	import delimited using "$amo_input/school_chronic_absenteeism.csv", clear
	gen subject = "Chronically Out of School", after(school_name)
	rename (grade_band amo_reduction_target_double) (grade double_amo_reduction_target) 
	order grade, after(subject)
	append using `amo_sr'
	append using `amo_grad'
	append using `amo_ready_grad'
	gsort system school -pool
	replace pool = pool[_n-1] if pool == "" & system == system[_n-1] & school == school[_n-1]
	gsort system school -system_name -school_name 
	foreach v in system_name school_name {
		replace `v' = `v'[_n-1] if `v' == "" & system == system[_n-1] & school == school[_n-1]
	}
	gsort system school -subject grade subgroup
	order year system* school* pool subject grade subgroup amo_target double_amo_target /// 
		amo_reduction_target double_amo_reduction_target valid_tests_prior pct_on_mastered_prior ///
		grad_cohort grad_rate valid_tests_act act_21_or_higher n_students ///
		n_chronically_absent pct_chronically_absent, first
	
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/AMO Files/`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("Accountability Targets") 
		export excel using "$app/`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("Accountability Targets") 
		restore
	}
	
	collapse (firstnm) school_name, by(system school)
	tempfile temp
	save `temp', replace
	
	** Subject level targets
	import delimited using "$amo_input/school_subject.csv", clear
	rename amo_target_4 double_amo_target
	foreach v in pct_on_mastered_prior amo_target double_amo_target {
		replace `v' = "" if `v' == "NA"
		destring `v', replace
	}
	mmerge system school using `temp', type(n:1)
	drop if _merge == 2
	drop _merge 
	gsort system school subject subgroup
	order year system* school* pool subject subgroup amo_target double_amo_target /// 
		valid_tests_prior pct_on_mastered_prior, first
	
	levelsof system, local(sys_list)
	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export excel using "$output/AMO Files/`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("Subject Targets | Planning Only")
		export excel using "$app/`s'_SchoolLevelAMO_$date.xlsx", firstrow(var) sheet("Subject Targets | Planning Only")
		restore
	}
}

* Chronic absenteeism files
if `abs' == 1 {
	* Remove all previous files
	cd "$output/Chronic Absenteeism Files"
	!del *.csv
	!del *.xlsx
	
	* District level
	import delimited using "K:/ORP_accountability/data/2017_chronic_absenteeism/$chronic_district", clear
	replace grade_band = "9th through 12th" if grade_band == "9-12"
	replace grade_band = "K through 8th" if grade_band == "K-8"
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/Chronic Absenteeism Files/`s'_ChronicAbsenteeismDistrictFile_$date.csv", replace
		restore
	}
	
	* School level
	import delimited using "K:/ORP_accountability/data/2017_chronic_absenteeism/$chronic_school", clear
	keep if grade_band == "All Grades"
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/Chronic Absenteeism Files/`s'_ChronicAbsenteeismSchoolFile_$date.csv", replace
		restore
	}
	
	* Student level
	import delimited using "K:/ORP_accountability/data/2017_chronic_absenteeism/$chronic_student", clear
	rename (isp_days instructional_calendar_days) (student_enrolled_days school_instructional_days)
	destring absentee_rate, force replace
	levelsof system, local(sys_list)

	foreach s in `sys_list' {
		preserve
		keep if system == `s'
		export delimited using "$output/Chronic Absenteeism Files/`s'_ChronicAbsenteeismStudentFile_$date.csv", replace
		restore
	}
}

* Soft release
if `sof' == 1 {
	
}

* CORE regional files
if `cor' == 1 {
	cd "K:/ORP_accountability/projects/Evan/Data Releases"
	!del *CORE*.csv
	!del *CORE*.xlsx
	
	* Base and numeric
	foreach l in base numeric {
		local m = strproper("`l'")
		import delimited using "$input/system_`l'_2017_oct11.csv", clear
		mmerge system using "C:/Users/CA19130/Documents/Data/Crosswalks/core_region_crosswalk", type(n:1)
		collapse (sum) valid_tests n_* grad_c* dropout_count, by(year region subject grade subgroup)
		foreach v in below approaching on_track mastered {
			gen pct_`v' = round(100 * n_`v' / valid_tests, 0.1) if valid_tests >= 10 & valid_tests != ., after(n_`v')
		}
		gen pct_on_mastered = round(100 * (n_on_track + n_mastered) / valid_tests, 0.1) if valid_tests >= 10 & valid_tests !=., after(pct_mastered)
		foreach v in grad dropout {
			gen `v'_rate = round(100 * `v'_count / grad_cohort, 0.1) if grad_cohort >= 10 & grad_cohort != ., after(`v'_count)
		}
		gsort -year subject subgroup
		
		levelsof region, local(core_list)
		foreach r in `core_list' {
			preserve
			keep if region == "`r'"
			export excel using "K:/ORP_accountability/projects/Evan/Data Releases/`r'_Aggregate_$date.xlsx", firstrow(var) sheet("`m'")
			restore
		}
	}	
	
	* ACT
	import delimited using "K:/ORP_accountability/data/2017_ACT/act_student_level_with_demographics_EK.csv", clear
	mmerge system using "C:/Users/CA19130/Documents/Data/Crosswalks/core_region_crosswalk", type(n:1)
	
	gen bhn = inlist(race_ethnicity, "B", "H", "I")
	foreach v in el econ_dis swd {
		replace `v' = "1" if `v' == "Y"
		destring `v', force replace
	}
	tempfile temp
	save `temp', replace
	
	gen enrolled = 1
	gen valid_tests = composite != . 
	gen n_21_or_higher = valid_tests == 1 & composite >= 21
	gen n_below_19 = valid_tests == 1 & composite < 19
	tempfile pre 
	save `pre', replace
	
	* All
	use `pre', clear
	collapse (sum) enrolled valid_tests n_*, by(region)
	foreach v in cr_english cr_math cr_reading cr_science cr_all 21_or_higher below_19 {
		gen pct_`v' = round(100 * n_`v' / valid_tests, 0.1), after(n_`v')
	}
	gen subgroup = "All Students", after(region)
	drop if region == ""
	tempfile all
	save `all', replace
	use `temp', clear
	collapse (mean) composite english math reading science, by(region)
	foreach v in composite english math reading science {
		replace `v' = round(`v', 0.1)
	}
	drop if region == ""
	mmerge region using `all', type(1:1)
	drop _merge
	tempfile all
	save `all', replace
	
	* Subgroups
	foreach s in bhn econ_dis el swd {
		use `pre', clear
		keep if `s' == 1
		collapse (sum) enrolled valid_tests n_*, by(region)
		foreach v in cr_english cr_math cr_reading cr_science cr_all 21_or_higher below_19 {
			gen pct_`v' = round(100 * n_`v' / valid_tests, 0.1), after(n_`v')
		}
		gen subgroup = "`s'"
		drop if region == ""
		tempfile `s'
		save ``s'', replace 
		use `temp', clear
		keep if `s' == 1
		collapse (mean) composite english math reading science, by(region)
		foreach v in composite english math reading science {
			replace `v' = round(`v', 0.1)
		}
		drop if region == ""
		mmerge region using ``s'', type(1:1)
		drop _merge
		tempfile `s'
		save ``s'', replace
	}
	
	use `all', clear
	append using `bhn'
	append using `econ_dis'
	append using `el'
	append using `swd'
	replace subgroup = "Black/Hispanic/Native American" if subgroup == "bhn"
	replace subgroup = "English Learners" if subgroup == "el"
	replace subgroup = "Economically Disadvantaged" if subgroup == "econ_dis"
	replace subgroup = "Students with Disabilities" if subgroup == "swd"
	order region subgroup composite english math reading science, first
	
	levelsof region, local(core_list)
	foreach r in `core_list' {
		preserve
		keep if region == "`r'"
		export excel using "K:/ORP_accountability/projects/Evan/Data Releases/`r'_Aggregate_$date.xlsx", firstrow(var) sheet("ACT")
		restore
	}
}

* File checks
if `che' == 1 {
	* Upload test
	import excel using "K:/ORP_accountability/projects/Evan/Change Requests/FileUploader List.xlsm", clear firstrow
	replace A = A[_n-1] if A == ""
	drop if _n > 33
	replace FileName = subinstr(FileName, "###", "", 1)
	replace FileName = subinstr(FileName, "<", "10", 1)
	replace FileName = subinstr(FileName, ">", "", 1)
	replace FileName = subinstr(FileName, "Date", "$date", 1)
	levelsof FileName, local(file_list)
	
	foreach f of numlist 1/30 {
		preserve
		keep if _n == `f' 
		levelsof FileName, local(fname)
		if regexm(FileName, ".csv") == 1 {
			export delimited using "H:/Common03/WEBPAGES/NCLBAppeals/Accountability Web Files/`fname'", replace
		} 
		else {
			export excel using "H:/Common03/WEBPAGES/NCLBAppeals/Accountability Web Files/`fname'", replace firstrow(var)
		}
	}
}
