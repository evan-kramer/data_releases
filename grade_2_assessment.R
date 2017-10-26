# Grade 2 Assessment
# Evan Kramer
# 10/23/2017

library(tidyverse)
library(lubridate)
library(ggplot2)
library(haven)
library(readxl)
library(stringr)

dat = F
stu = F
sch = F
sys = F
che = F

# Data
if(dat == T) {
    setwd("K:/ORP_accountability/data/2017_cdf")
    cdf = read_dta("2grade_102317.dta")
    cdf_alt = read_dta("2grade_alt_102317.dta")
}
    
# Student Level
if(stu == T) {
    student_level = bind_rows(
    cdf %>% 
        mutate(valid_test = as.numeric(!is.na(performance_level))) %>% 
        arrange(unique_student_id, content_area_code, desc(valid_test), desc(performance_level), desc(scale_score)) %>% 
        group_by(unique_student_id, content_area_code) %>% 
        summarize_each(funs(first(.)), last_name:gender, economically_disadvantaged:school_name, performance_level:valid_test) %>% 
        ungroup() %>% 
        mutate(test_type = "Grade 2"),
    cdf_alt %>% 
        mutate(valid_test = as.numeric(!is.na(performance_level))) %>% 
        arrange(unique_student_id, content_area_code, desc(valid_test), desc(performance_level), desc(scale_score)) %>% 
        group_by(unique_student_id, content_area_code) %>% 
        summarize_each(funs(first(.)), last_name:gender, economically_disadvantaged:school_name, performance_level:valid_test) %>% 
        ungroup() %>% 
        mutate(test_type = "Grade 2 ALT")
) %>% 
    arrange(unique_student_id, content_area_code, desc(test_type), desc(performance_level)) %>% 
    group_by(unique_student_id, content_area_code) %>% 
    summarize_each(funs(first(.)), last_name:test_type) %>% 
    ungroup() %>% 
    filter(!is.na(unique_student_id))
    
student_level[is.na(student_level)] = NA

#write_csv(student_level, "K:/ORP_accountability/projects/2017_grade_2_assessment/student_level_EK.csv", na = "")
}

# School Level
if(sch == T) {
    school_level = read_dta("K:/ORP_accountability/projects/2017_grade_2_assessment/state_student_level_2017_JW_final_10242017.dta") %>%
        mutate(n_below = as.numeric(str_detect(performance_level, "1.")),
               n_approaching = as.numeric(str_detect(performance_level, "2.")),
               n_on_track = as.numeric(str_detect(performance_level, "3.")),
               n_mastered = as.numeric(str_detect(performance_level, "4.")),
               reported_race = ifelse(white == 1, "White", "Unidentified"),
               reported_race = ifelse(asian == 1, "Asian", reported_race),
               reported_race = ifelse(hawaiian_pi == 1, "Hawaiian or Pacific Islander", reported_race),
               reported_race = ifelse(native_american == 1, "Native American", reported_race),
               reported_race = ifelse(black == 1, "Black", reported_race),
               reported_race = ifelse(ethnic_origin == "H", "Hispanic", reported_race))
        
    # All Students
    all = school_level %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "All Students", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # BHN
    bhn = school_level %>% 
        filter(reported_race %in% c("Black", "Hispanic", "Native American")) %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Black/Hispanic/Native American", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # ED 
    ed = school_level %>% 
        filter(economically_disadvantaged == 1) %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Economically Disadvantaged", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # EL
    el = school_level %>% 
        filter(ell == 1) %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "English Language Learners", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # EL with transitional
    el_t = school_level %>% 
        filter(ell == 1 | ell_t1t2 == 1) %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "English Language Learners with T1/T2", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # SWD
    swd = school_level %>% 
        filter(special_ed == 1) %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Students with Disabilities", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # Individual racial/ethnic groups
    ind_race = as.tbl(data.frame())
    race_list = unique(school_level$reported_race)
    for(r in seq_along(race_list)) {
        temp = school_level %>% 
            filter(reported_race == race_list[r]) %>% 
            group_by(system, school, content_area_code) %>% 
            summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
            ungroup() %>% 
            rename(valid_tests = valid_test) %>% 
            mutate(subgroup = race_list[r], grade = 2, 
                   pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
                   pct_mastered = n_mastered, subject = content_area_code) %>% 
            mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
            select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
        
        ind_race = bind_rows(ind_race, temp)
    }
    
    # Bind all rows together
    output = bind_rows(all, bhn, ed, el, el_t, swd, ind_race) %>% 
        arrange(system, school, subject, subgroup) %>% 
        filter(!is.na(system))
    
    write_csv(output, "K:/ORP_accountability/projects/2017_grade_2_assessment/school_level_EK.csv", na = "")
}

# District Level
if(sys == T) {
    school_level = read_dta("K:/ORP_accountability/projects/2017_grade_2_assessment/state_student_level_2017_JW_final_10242017.dta") %>%
        mutate(n_below = as.numeric(str_detect(performance_level, "1.")),
               n_approaching = as.numeric(str_detect(performance_level, "2.")),
               n_on_track = as.numeric(str_detect(performance_level, "3.")),
               n_mastered = as.numeric(str_detect(performance_level, "4.")),
               reported_race = ifelse(white == 1, "White", "Unidentified"),
               reported_race = ifelse(asian == 1, "Asian", reported_race),
               reported_race = ifelse(hawaiian_pi == 1, "Hawaiian or Pacific Islander", reported_race),
               reported_race = ifelse(native_american == 1, "Native American", reported_race),
               reported_race = ifelse(black == 1, "Black", reported_race),
               reported_race = ifelse(ethnic_origin == "H", "Hispanic", reported_race))
    
    # All Students
    all = school_level %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "All Students", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # BHN
    bhn = school_level %>% 
        filter(reported_race %in% c("Black", "Hispanic", "Native American")) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Black/Hispanic/Native American", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # ED 
    ed = school_level %>% 
        filter(economically_disadvantaged == 1) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Economically Disadvantaged", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # EL
    el = school_level %>% 
        filter(ell == 1) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "English Language Learners", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # EL with transitional
    el_t = school_level %>% 
        filter(ell == 1 | ell_t1t2 == 1) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "English Language Learners with T1/T2", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # SWD
    swd = school_level %>% 
        filter(special_ed == 1) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Students with Disabilities", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = content_area_code) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # Individual racial/ethnic groups
    ind_race = as.tbl(data.frame())
    race_list = unique(school_level$reported_race)
    for(r in seq_along(race_list)) {
        temp = school_level %>% 
            filter(reported_race == race_list[r]) %>% 
            group_by(system, content_area_code) %>% 
            summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
            ungroup() %>% 
            rename(valid_tests = valid_test) %>% 
            mutate(subgroup = race_list[r], grade = 2, 
                   pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
                   pct_mastered = n_mastered, subject = content_area_code) %>% 
            mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
            select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
        
        ind_race = bind_rows(ind_race, temp)
    }
    
    # Bind all rows together
    output = bind_rows(all, bhn, ed, el, el_t, swd, ind_race) %>% 
        arrange(system, subject, subgroup) %>% 
        filter(!is.na(system))
    
    write_csv(output, "K:/ORP_accountability/projects/2017_grade_2_assessment/district_level_EK.csv", na = "")
}

# Check against Jessica's files
if(che == T) {
## Student
    setwd("K:/ORP_accountability/projects/2017_grade_2_assessment")
               
    # School
    sl = read_dta("K:/ORP_accountability/projects/2017_grade_2_assessment/state_student_level_2017_JW_final_10242017.dta")
    ek = read_csv("school_level_EK.csv")
    jw = read_dta("school_level_2017_JW_final_10242017.dta")
    
    check = full_join(
        filter(ek, subgroup != "Unidentified"),
        jw %>% 
            filter(str_detect(subgroup, "Non-") == F & subgroup != "Super Subgroup"), 
        by = c("system", "school", "subject", "subgroup")
    ) %>% 
        ## Valid tests
        # filter(valid_tests.x != valid_tests.y | 
        #            (is.na(valid_tests.x) & !is.na(valid_tests.y)) | 
        #            (is.na(valid_tests.y) & !is.na(valid_tests.x))) %>% 
        ## Performance Levels
        filter(n_below != n_below_bsc | n_approaching != n_approach_bsc | 
                   n_on_track != n_ontrack_prof | n_mastered != n_mastered_adv | 
                   (is.na(n_below) & !is.na(n_below_bsc)) | 
                   (!is.na(n_below) & is.na(n_below_bsc)) | 
                   (is.na(n_approaching) & !is.na(n_approach_bsc)) | 
                   (!is.na(n_approaching) & is.na(n_approach_bsc)) |
                   (is.na(n_on_track) & !is.na(n_ontrack_prof)) | 
                   (!is.na(n_on_track) & is.na(n_ontrack_prof)) |
                   (is.na(n_mastered) & !is.na(n_mastered_adv)) | 
                   (!is.na(n_mastered) & is.na(n_mastered_adv)))
    
    anti_join(
        filter(ek, subgroup != "Unidentified"),
        jw %>% 
            filter(str_detect(subgroup, "Non-") == F & subgroup != "Super Subgroup"),
        by = c("system", "school", "subject", "subgroup")
    )
                   
    # District
    sl = read_dta("K:/ORP_accountability/projects/2017_grade_2_assessment/state_student_level_2017_JW_final_10242017.dta")
    ek = read_csv("district_level_EK.csv")
    jw = read_dta("system_level_2017_JW_final_10242017.dta")
    
    check = full_join(
        filter(ek, subgroup != "Unidentified"),
        jw %>% 
            filter(str_detect(subgroup, "Non-") == F & subgroup != "Super Subgroup"), 
        by = c("system", "subject", "subgroup")
    ) %>% 
        ## Valid tests
        # filter(valid_tests.x != valid_tests.y |
        #            (is.na(valid_tests.x) & !is.na(valid_tests.y)) |
        #            (is.na(valid_tests.y) & !is.na(valid_tests.x)))
        ## Performance Levels
        filter(n_below != n_below_bsc | n_approaching != n_approach_bsc |
                   n_on_track != n_ontrack_prof | n_mastered != n_mastered_adv |
                   (is.na(n_below) & !is.na(n_below_bsc)) |
                   (!is.na(n_below) & is.na(n_below_bsc)) |
                   (is.na(n_approaching) & !is.na(n_approach_bsc)) |
                   (!is.na(n_approaching) & is.na(n_approach_bsc)) |
                   (is.na(n_on_track) & !is.na(n_ontrack_prof)) |
                   (!is.na(n_on_track) & is.na(n_ontrack_prof)) |
                   (is.na(n_mastered) & !is.na(n_mastered_adv)) |
                   (!is.na(n_mastered) & is.na(n_mastered_adv)))
    
    anti_join(filter(ek, subgroup != "Unidentified"),
              jw %>% 
                  filter(str_detect(subgroup, "Non-") == F & subgroup != "Super Subgroup"),
              by = c("system", "subject", "subgroup"))
}
