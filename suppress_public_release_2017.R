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

write_csv(system_release, "K:/ORP_accountability/data/2017_final_accountability_files/suppressed_system_release_3-8_oct17.csv", na = "")

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


write_csv(school_release, "K:/ORP_accountability/data/2017_final_accountability_files/suppressed_school_release_oct17.csv", na = "")


system_release %>% 
    filter(as.numeric(`N Below`) / as.numeric(`Valid Tests`) < .01 | as.numeric(`N Below`) / as.numeric(`Valid Tests`) > .99 | 
               as.numeric(`N Approaching`) / as.numeric(`Valid Tests`) < .01 | as.numeric(`N Approaching`) / as.numeric(`Valid Tests`) > .99 | 
               as.numeric(`N On Track/Mastered`) / as.numeric(`Valid Tests`) < .01 | as.numeric(`N On Track/Mastered`) / as.numeric(`Valid Tests`) > .99) %>% 
    View()

