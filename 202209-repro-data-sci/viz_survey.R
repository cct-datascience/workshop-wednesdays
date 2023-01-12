library(dplyr)
library(stringr)
library(purrr)
library(tidyr)
library(ggplot2)

### Read in survey results data ###
results <- read.csv("202209-repro-data-sci/Reproducibility and data science post-workshop survey (Responses) - Form Responses 1.csv")

### Clean data ###
clean_data <- function(category, content){
  results_clean <- results %>% 
    select(starts_with(content)) %>% 
    rename_all(~str_replace(., content, "")) %>% 
    rename_all(~str_replace_all(., "\\.", " ")) %>% 
    mutate_all(~str_sub(., start = 1, end = 1)) %>% 
    mutate_all(~factor(., levels = c("1",  "2", "3", "4", "5"))) %>% 
    mutate(category = category)
  return(results_clean)
}

questions_meta <- data.frame(category = c("pre_do", "post_do", "pre_get", "post_get"), 
                             content = c("On.a.scale.of.1.to.5..what.was.your.ability.to.complete.the.following.tasks.prior.to.the.workshop...",
                                         "On.a.scale.of.1.to.5..what.is.your.ability.to.complete.the.following.tasks.now...", 
                                         "On.a.scale.of.1.to.5..what.was.your.level.of.understanding.while.completing.the.following.tasks.prior.to.the.workshop..if.you.could.not.do.the.task.at.all..select.option.1....", 
                                         "On.a.scale.of.1.to.5..what.is.your.level.of.understanding.about.these.tasks.now..if.you.can.not.do.the.task.at.all..select.option.1...."))

results_plot <- map2_dfr(questions_meta$category, questions_meta$content, clean_data) %>% 
  mutate(ind = rep(c("A", "B", "C", "D", "E", "F"), 4)) %>% 
  separate(category, into = c("time", "type")) %>% 
  pivot_longer(`Navigate around filesystem using shell commands `:`Combine descriptive text and R code using  Rmd `) %>% 
  mutate(value = as.numeric(value)) %>% 
  group_by(ind, type, name) %>% 
  summarize(diff = value - lag(value)) %>% 
  filter(!is.na(diff)) %>%
  mutate(type = case_when(type == "do" ~ "Complete task", 
                          type == "get" ~ "Understand task")) %>% 
  select(-ind) %>% 
  group_by(name, type) %>% 
  summarize(mean_diff = mean(diff)) %>% 
  mutate(zero = 0)

ordered_skills <- results_plot %>% 
  filter(type == "Complete task") %>% 
  arrange(mean_diff) 

results_plot <- results_plot %>% 
  mutate(name = factor(name, levels = ordered_skills$name))

### Plot data ###
ggplot(results_plot, aes(x = mean_diff, y = name)) +
  geom_segment(aes(x = zero, y = name, xend = mean_diff, yend = name)) +
  geom_point() +
  facet_wrap(~type) +
  theme_classic() +
  labs(x = "Average change in skill", y = "Skill")

ggsave("202209-repro-data-sci/viz_survey.png", width = 8, height = 3)
