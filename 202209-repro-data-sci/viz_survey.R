library(dplyr)
library(stringr)
library(purrr)
library(likert)
library(cowplot)

### Read in survey results data ###
results <- read.csv("202209-repro-data-sci/Reproducibility and data science post-workshop survey (Responses) - Form Responses 1.csv")

### Functions to clean and plot data ###
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

plot_data <- function(cat){
  results_plot_by_cat <- results_plot %>% 
    filter(category == cat)
  plot <- results_plot_by_cat %>%
    select(-category) %>%
    likert(.) %>%
    plot(group.order = names(.$items)) +
    ggtitle(cat)
}

### Clean and plot data ###
questions_meta <- data.frame(category = c("pre_do", "post_do", "pre_get", "post_get"), 
                             content = c("On.a.scale.of.1.to.5..what.was.your.ability.to.complete.the.following.tasks.prior.to.the.workshop...",
                                         "On.a.scale.of.1.to.5..what.is.your.ability.to.complete.the.following.tasks.now...", 
                                         "On.a.scale.of.1.to.5..what.was.your.level.of.understanding.while.completing.the.following.tasks.prior.to.the.workshop..if.you.could.not.do.the.task.at.all..select.option.1....", 
                                         "On.a.scale.of.1.to.5..what.is.your.level.of.understanding.about.these.tasks.now..if.you.can.not.do.the.task.at.all..select.option.1...."))

results_plot <- map2_dfr(questions_meta$category, questions_meta$content, clean_data)

plots <- map(unique(results_plot$category), plot_data)
combined_plots <- plot_grid(plots[[1]], plots[[2]], plots[[3]], plots[[4]])
ggsave("202209-repro-data-sci/viz_survey.png", width = 18, height = 9)
