# Grade 2 Assessment
# Evan Kramer
# 10/23/2017

library(tidyverse)
library(lubridate)
library(ggplot2)
library(haven)
library(readxl)
library(stringr)

dat = T
stu = T
sch = F
sys = T

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
    arrange(unique_student_id, content_area_code, desc(test_type)) %>% 
    group_by(unique_student_id, content_area_code) %>% 
    summarize_each(funs(first(.)), last_name:test_type) %>% 
    ungroup() 
    
student_level[is.na(student_level)] = NA

#write_csv(student_level, "K:/ORP_accountability/projects/2017_grade_2_assessment/student_level_EK.csv", na = "")
}

# School Level
if(sch == T) {
    school_level = student_level %>% 
        mutate(n_below = performance_level == 1 & test_type == "Grade 2",
               n_approaching = (performance_level == 1 & test_type == "Grade 2 ALT") | 
                   (performance_level == 2 & test_type == "Grade 2"),
               n_on_track = (performance_level == 2 & test_type == "Grade 2 ALT") | 
                   (performance_level == 3 & test_type == "Grade 2"),
               n_mastered = (performance_level == 3 & test_type == "Grade 2 ALT") | 
                   (performance_level == 4 & test_type == "Grade 2"))
    
    # All Students
    all = school_level %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "All Students", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # BHN
    bhn = school_level %>% 
        filter(reported_race %in% c(1, 3, 4)) %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Black/Hispanic/Native American", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
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
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # EL
    el = school_level %>% 
        filter(el == 1) %>% 
        group_by(system, school, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "English Learners", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
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
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # Individual racial/ethnic groups
    ind_race = as.tbl(data.frame())
    for(r in 1:6) {
        temp = school_level %>% 
            filter(reported_race == r) %>% 
            group_by(system, school, content_area_code) %>% 
            summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
            ungroup() %>% 
            rename(valid_tests = valid_test) %>% 
            mutate(subgroup = r, grade = 2, 
                   pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
                   pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
            mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
            select(system, school, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
        
        ind_race = bind_rows(ind_race, temp)
    }
    
    ind_race = ind_race %>% 
        mutate(subgroup = case_when(
            ind_race$subgroup == 1 ~ "American Indian or Alaska Native",
            ind_race$subgroup == 2 ~ "Asian",
            ind_race$subgroup == 3 ~ "Black or African American",
            ind_race$subgroup == 4 ~ "Hispanic or Latino", 
            ind_race$subgroup == 5 ~ "Native Hawaiian or Other Pacific Islander",
            ind_race$subgroup == 6 ~ "White")) 
    
    # Bind all rows together
    output = bind_rows(all, bhn, ed, el, swd, ind_race) %>% 
        arrange(system, school, subject, subgroup)
    
    write_csv(output, "K:/ORP_accountability/projects/2017_grade_2_assessment/school_level_EK.csv", na = "")
}

# District Level
if(sys == T) {
    district_level = student_level %>% 
        mutate(n_below = performance_level == 1 & test_type == "Grade 2",
               n_approaching = (performance_level == 1 & test_type == "Grade 2 ALT") | 
                   (performance_level == 2 & test_type == "Grade 2"),
               n_on_track = (performance_level == 2 & test_type == "Grade 2 ALT") | 
                   (performance_level == 3 & test_type == "Grade 2"),
               n_mastered = (performance_level == 3 & test_type == "Grade 2 ALT") | 
                   (performance_level == 4 & test_type == "Grade 2"))
    
    # All Students
    all = district_level %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "All Students", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # BHN
    bhn = district_level %>% 
        filter(reported_race %in% c(1, 3, 4)) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Black/Hispanic/Native American", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # ED 
    ed = district_level %>% 
        filter(economically_disadvantaged == 1) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Economically Disadvantaged", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # EL
    el = district_level %>% 
        filter(el == 1) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "English Learners", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # SWD
    swd = district_level %>% 
        filter(special_ed == 1) %>% 
        group_by(system, content_area_code) %>% 
        summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
        ungroup() %>% 
        rename(valid_tests = valid_test) %>% 
        mutate(subgroup = "Students with Disabilities", grade = 2, 
               pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
               pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
        mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
        select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
    
    # Individual racial/ethnic groups
    ind_race = as.tbl(data.frame())
    for(r in 1:6) {
        temp = district_level %>% 
            filter(reported_race == r) %>% 
            group_by(system, content_area_code) %>% 
            summarize_each(funs(sum(., na.rm = T)), valid_test, starts_with("n_")) %>% 
            ungroup() %>% 
            rename(valid_tests = valid_test) %>% 
            mutate(subgroup = r, grade = 2, 
                   pct_below = n_below, pct_approaching = n_approaching, pct_on_track = n_on_track, 
                   pct_mastered = n_mastered, subject = if_else(content_area_code == "ENG", "English", "Math")) %>% 
            mutate_each(funs(round(100 * . / valid_tests, 1)), starts_with("pct_")) %>% 
            select(system, subject, grade, subgroup, valid_tests, starts_with("n_"), starts_with("pct_"))
        
        ind_race = bind_rows(ind_race, temp)
    }
    
    ind_race = ind_race %>% 
        mutate(subgroup = case_when(
            ind_race$subgroup == 1 ~ "American Indian or Alaska Native",
            ind_race$subgroup == 2 ~ "Asian",
            ind_race$subgroup == 3 ~ "Black or African American",
            ind_race$subgroup == 4 ~ "Hispanic or Latino", 
            ind_race$subgroup == 5 ~ "Native Hawaiian or Other Pacific Islander",
            ind_race$subgroup == 6 ~ "White")) 
    
    # Bind all rows together
    output = bind_rows(all, bhn, ed, el, swd, ind_race) %>% 
        arrange(system, subject, subgroup)
    
    write_csv(output, "K:/ORP_accountability/projects/2017_grade_2_assessment/district_level_EK.csv", na = "")
}