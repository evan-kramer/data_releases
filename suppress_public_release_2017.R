# Suppress Public Release Files
# Evan Kramer
# 11/9/2017

library(tidyverse)
library(lubridate)
library(haven)
library(readxl)
library(stringr)

setwd("K:/ORP_accountability/data/2017_final_accountability_files/October 11")

# System (EOC only)
eoc_release = read_excel("C:/Users/CA19130/Downloads/data_district-level_2017_EOC_results.xlsx") %>% 
    transmute(Year, System, `System Name`, Subject, Subgroup, Grade = "9th through 12th",
              `Valid Tests`, `N Below` = `Number Below`, `Percent Below`, `N Approaching` = `Number Approaching`,
              `Percent Approaching`, `N On Track/Mastered` = `Number On Track` + `Number Mastered`,
              `Percent On Track/Mastered`, `Change in Percent On Track/Mastered`,
              `Change in Percent Below`) %>% 
    mutate_each(funs(ifelse(`Percent On Track/Mastered` < 1 | `Percent On Track/Mastered` > 99, "**", as.character(.))), 
                starts_with("N"), starts_with("Percent")) %>% 
    mutate_each(funs(ifelse(. == "**", ., 
                            ifelse(as.numeric(.) < 1 | as.numeric(.) > 99, "**", .))), `Percent Below`, `Percent Approaching`) %>% 
    mutate_each(funs(ifelse(`Percent Below` != "**" & `Percent On Track/Mastered` != "**" & `Percent Approaching` == "**",
                            "**", .)), `N Approaching`, ends_with("Below")) %>%
    mutate_each(funs(ifelse(`Percent Approaching` != "**" & `Percent On Track/Mastered` != "**" & `Percent Below` == "**",
                            "**", .)), `N Below`, ends_with("Approaching")) %>%
    mutate(`N Below` = ifelse(`Percent Below` == "**", "**", `N Below`),
           `N Approaching` = ifelse(`Percent Approaching` == "**", "**", `N Approaching`),
           `Change in Percent On Track/Mastered` = ifelse(`Percent On Track/Mastered` == "**", "**", 
                                                          as.character(round(`Change in Percent On Track/Mastered`, 1))),
           `Change in Percent Below` = ifelse(`Percent Below` == "**", "**", 
                                              as.character(round(`Change in Percent Below`, 1)))) %>% 
    mutate_each(funs(ifelse(`Valid Tests` < 10, "*", as.character(.))), `N Below`:`Change in Percent Below`)
    
#write_csv(eoc_release, "C:/Users/CA19130/Documents/Data/Achievement/data_district-level_2017_EOC_results.csv", na = "")

# System (3-8 only)
system_release = read_excel("system_release_2017_JW_10112017_formatted.xlsx") %>% 
    filter(Grade != "9th through 12th") %>% 
    transmute(Year, System, `System Name`, Subject, Subgroup, Grade, `Valid Tests`,
              `N Below`, `Percent Below`, `N Approaching`, `Percent Approaching`,
              `N On Track/Mastered` = `N On Track` + `N Mastered`, `Percent On Track/Mastered`) %>% 
    mutate_each(funs(ifelse(`Percent On Track/Mastered` < 1 | `Percent On Track/Mastered` > 99, "**", as.character(.))), 
                starts_with("N"), starts_with("Percent")) %>% 
    mutate_each(funs(ifelse(. == "**", ., 
                            ifelse(as.numeric(.) < 1 | as.numeric(.) > 99, "**", .))), `Percent Below`, `Percent Approaching`) %>% 
    mutate_each(funs(ifelse(`Percent Below` != "**" & `Percent On Track/Mastered` != "**" & `Percent Approaching` == "**",
                            "**", .)), `N Approaching`, ends_with("Below")) %>%
    mutate_each(funs(ifelse(`Percent Approaching` != "**" & `Percent On Track/Mastered` != "**" & `Percent Below` == "**",
                            "**", .)), `N Below`, ends_with("Approaching")) %>%
    mutate_each(funs(ifelse(`Valid Tests` < 10, "*", as.character(.))), `N Below`:`Percent On Track/Mastered`) %>%
    mutate(`N Below` = ifelse(`Percent Below` == "**", "**", `N Below`),
           `N Approaching` = ifelse(`Percent Approaching` == "**", "**", `N Approaching`)) 

#write_csv(system_release, "K:/ORP_accountability/data/2017_final_accountability_files/suppressed_system_release_3-8_oct17.csv", na = "")

# School (3-8 and EOC)
school_release = read_excel("school_release_2017_JW_10112017_formatted.xlsx") %>% 
    filter(Year == 2017) %>% 
    transmute(Year, System, `System Name`, School, `School Name`, Subject, Subgroup, Grade, 
              `Valid Tests`, `N Below`, `Percent Below`, `N Approaching`, `Percent Approaching`,
              `N On Track/Mastered` = `N On Track` + `N Mastered`, `Percent On Track/Mastered`) %>% 
    mutate_each(funs(ifelse(`Percent On Track/Mastered` < 5 | `Percent On Track/Mastered` > 95, "**", as.character(.))), 
                starts_with("N"), starts_with("Percent")) %>% 
    mutate_each(funs(ifelse(. == "**", ., 
                            ifelse(as.numeric(.) < 5 | as.numeric(.) > 95, "**", .))), `Percent Below`, `Percent Approaching`) %>% 
    mutate_each(funs(ifelse(`Percent Below` != "**" & `Percent On Track/Mastered` != "**" & `Percent Approaching` == "**",
                            "**", .)), `N Approaching`, ends_with("Below")) %>%
    mutate_each(funs(ifelse(`Percent Approaching` != "**" & `Percent On Track/Mastered` != "**" & `Percent Below` == "**",
                            "**", .)), `N Below`, ends_with("Approaching")) %>%
    mutate_each(funs(ifelse(`Valid Tests` < 10, "*", as.character(.))), `N Below`:`Percent On Track/Mastered`) %>%
    mutate(`N Below` = ifelse(`Percent Below` == "**", "**", `N Below`),
           `N Approaching` = ifelse(`Percent Approaching` == "**", "**", `N Approaching`))

#write_csv(school_release, "K:/ORP_accountability/data/2017_final_accountability_files/suppressed_school_release_oct17.csv", na = "")

# WIDA system level
wida_system = read_dta("K:/ORP_accountability/data/2017_ELPA/system_level_elpa_JW.dta") %>% 
    mutate_each(funs(ifelse(met_exit_criteriaNEW / valid_tests > .99 | met_exit_criteriaNEW / valid_tests < .01,
                            "**", as.character(.))), pct_met_exit_criteriaNEW, met_exit_criteriaNEW) %>% 
    mutate_each(funs(ifelse(met_growth_standard / n_validtests_growth > .99 | met_growth_standard/ n_validtests_growth < .01,
                            "**", as.character(.))), pct_met_growth_standard, met_growth_standard) %>% 
    mutate_each(funs(ifelse(valid_tests < 10, "*", as.character(.))), contains("met_exit"),
                contains("avg")) %>% 
    mutate_each(funs(ifelse(n_validtests_growth < 10, "*", as.character(.))), contains("met_growth"))
wida_system = replace(wida_system, is.na(wida_system), NA)
write_csv(wida_system, "K:/ORP_accountability/data/2017_ELPA/suppressed_system_level_ELPA.csv", na = "")

# WIDA school level
wida_school = read_dta("K:/ORP_accountability/data/2017_ELPA/school_level_elpa_JW.dta") %>% 
    mutate_each(funs(ifelse(met_exit_criteriaNEW / valid_tests > .95 | met_exit_criteriaNEW / valid_tests < .05,
                            "**", as.character(.))), pct_met_exit_criteriaNEW, met_exit_criteriaNEW) %>% 
    mutate_each(funs(ifelse(met_growth_standard / n_validtests_growth > .95 | met_growth_standard/ n_validtests_growth < .05,
                            "**", as.character(.))), pct_met_growth_standard, met_growth_standard) %>% 
    mutate_each(funs(ifelse(valid_tests < 10, "*", as.character(.))), contains("met_exit"),
                contains("avg")) %>% 
    mutate_each(funs(ifelse(n_validtests_growth < 10, "*", as.character(.))), contains("met_growth"))
wida_school = replace(wida_school, is.na(wida_school), NA)
write_csv(wida_school, "K:/ORP_accountability/data/2017_ELPA/suppressed_school_level_ELPA.csv", na = "")
    