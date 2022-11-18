library(dplyr)
library(stringr)
library(purrr)
library(likert)
library(cowplot)

### Read in survey results data ###
results <- read.csv("202209-repro-data-sci/Reproducibility and data science post-workshop survey (Responses) - Form Responses 1.csv")

### Functions ###


#index for loop

questions_meta <- data.frame(category = c("pre_do", "post_do", "pre_get", "post_get"), 
                             content = c("On.a.scale.of.1.to.5..what.was.your.ability.to.complete.the.following.tasks.prior.to.the.workshop...",
                                         "On.a.scale.of.1.to.5..what.is.your.ability.to.complete.the.following.tasks.now...", 
                                         "On.a.scale.of.1.to.5..what.was.your.level.of.understanding.while.completing.the.following.tasks.prior.to.the.workshop..if.you.could.not.do.the.task.at.all..select.option.1....", 
                                         "On.a.scale.of.1.to.5..what.is.your.level.of.understanding.about.these.tasks.now..if.you.can.not.do.the.task.at.all..select.option.1...."))


clean_data <- function(category, content){
  df_clean <- results %>% 
    select(starts_with(content)) %>% 
    mutate_all(~str_sub(., start = 1, end = 1)) %>% 
    rename_all(~str_replace(., content, "")) %>% 
    mutate_all(~factor(., levels = c("1",  "2", "3", "4", "5"))) %>% 
    mutate(category = category)
}
results_plot <- purrr::map2_dfr(questions_meta$category, questions_meta$content, clean_data)

# want order of questions same as they were asked

plot_data <- function(cat){
  cat_data <- results_plot %>% 
    filter(category == cat)
  print(colnames(cat_data))
  plot <- cat_data %>%
    select(-category) %>%
    likert(.) %>%
    plot(.) +
    ggtitle(cat)
  print(plot)
}

plots <- map(unique(results_plot$category), plot_data)

plot_grid(plots[[1]], plots[[2]], plots[[3]], plots[[4]])

# 
# plot_data("post_do")
# 
# 
# for(category in unique(results_plot$category)){
#   print(category)
#   plot_data(category)
# }
# 
# purrr::map_df(unique(results_plot$category), plot_data)
# 
# plot_data("pre_do")
# 
# plot(likert(results_plot, grouping = results_plot$category))


# pre_do <- "On.a.scale.of.1.to.5..what.was.your.ability.to.complete.the.following.tasks.prior.to.the.workshop..."
# results_one <- results %>% 
#   select(starts_with(pre_do)) %>% 
#   rename_all(~stringr::str_replace(., pre_do, "")) %>% 
#   mutate_all(~factor(., levels = c("1: Not able to perform task",  "2", "3", "4", "5: Perform task with no help"))) %>% 
#   mutate(treatment = "pre")
# plot_one <- results_one %>% 
#   select(-treatment) %>% 
#   likert(.) %>%
#   plot(.)
# 
# post_do <- "On.a.scale.of.1.to.5..what.is.your.ability.to.complete.the.following.tasks.now..."
# results_three <- results %>% 
#   select(starts_with(post_do)) %>% 
#   rename_all(~stringr::str_replace(., post_do, "")) %>% 
#   mutate_all(~factor(., levels = c("1: Not able to perform task",  "2", "3", "4", "5: Perform task with no help"))) %>% 
#   mutate(treatment = "post")
# plot_three <- results_three %>% 
#   select(-treatment) %>% 
#   likert(.) %>%
#   plot(.)
# 
# plot_grid(plot_one, plot_three)
# 
# all_do <- bind_rows(results_one, results_three)
# plot(likert(all_do[, c(1:13), drop = FALSE], grouping = all_do$treatment))
# 
# 
# pre_understand <- "On.a.scale.of.1.to.5..what.was.your.level.of.understanding.while.completing.the.following.tasks.prior.to.the.workshop..if.you.could.not.do.the.task.at.all..select.option.1...."
# results_two <- results %>% 
#   select(starts_with(pre_understand)) %>% 
#   rename_all(~stringr::str_replace(., pre_understand, "")) %>% 
#   mutate_all(~factor(., levels = c("1: Not able to perform task",  "2", "3", "4", "5: Perform task with no help"))) %>% 
#   likert(.) %>% 
#   plot(.)
