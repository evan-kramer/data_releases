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
sys = F

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
        summarize_each(funs(first(.)), last_name:gender, economically_disadvantaged:school_name) %>% 
        ungroup() %>% 
        mutate(test_type = "Grade 2"),
    cdf_alt %>% 
        mutate(valid_test = as.numeric(!is.na(performance_level))) %>% 
        arrange(unique_student_id, content_area_code, desc(valid_test), desc(performance_level), desc(scale_score)) %>% 
        group_by(unique_student_id, content_area_code) %>% 
        summarize_each(funs(first(.)), last_name:gender, economically_disadvantaged:school_name) %>% 
        ungroup() %>% 
        mutate(test_type = "Grade 2 ALT")
) %>% 
    arrange(unique_student_id, content_area_code, desc(test_type)) %>% 
    group_by(unique_student_id, content_area_code) %>% 
    summarize_each(funs(first(.)), last_name:school_name) %>% 
    ungroup() 
    
student_level[is.na(student_level)] = NA

write_csv(student_level, "K:/ORP_accountability/projects/2017_grade_2_assessment/student_level_EK.csv", na = "")
}

# School Level
if(sch == T) {
    
}

# District Level
if(sys == T) {
    
}