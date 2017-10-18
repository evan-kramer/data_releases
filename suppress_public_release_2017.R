# Suppress Public Release Files
# Evan Kramer
# 10/17/2017

library(tidyverse)
library(lubridate)
library(haven)
library(readxl)
library(stringr)

setwd("K:/ORP_accountability/data/2017_final_accountability_files/October 11")

# System (3-8 only)
system_release = read_excel("system_release_2017_JW_10112017_formatted.xlsx") %>% 
    filter(Grade != "9th through 12th") %>% 
    transmute(Year, System, `System Name`, Subject, Subgroup, Grade, `Valid Tests`,
              `N Below`, `Percent Below`, `N On Track/Mastered` = `N On Track` + `N Mastered`,
              `Percent On Track/Mastered`) %>% 
    mutate_each(funs(ifelse(. > 99 | . < 1, "**", as.character(.))), starts_with("Percent")) %>% 
    mutate_each(funs(ifelse(`Valid Tests` < 10, "*", as.character(.))), `N Below`:`Percent On Track/Mastered`)

write_csv(system_release, "K:/ORP_accountability/data/2017_final_accountability_files/suppressed_system_release_3-8_oct17.csv", na = "")

# School (3-8 and EOC)
school_release = read_excel("school_release_2017_JW_10112017_formatted.xlsx") %>% 
    transmute(Year, System, `System Name`, School, `School Name`, Subject, Subgroup, Grade, `Valid Tests`,
              `N Below`, `Percent Below`, `N On Track/Mastered` = `N On Track` + `N Mastered`,
              `Percent On Track/Mastered`) %>% 
    mutate_each(funs(ifelse(. > 95 | . < 5, "**", as.character(.))), starts_with("Percent")) %>% 
    mutate_each(funs(ifelse(`Valid Tests` < 10, "*", as.character(.))), `N Below`:`Percent On Track/Mastered`)

write_csv(school_release, "K:/ORP_accountability/data/2017_final_accountability_files/suppressed_school_release_oct17.csv", na = "")
