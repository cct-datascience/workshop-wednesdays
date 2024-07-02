# Options


``` r
library(ggplot2)
```

    Warning: package 'ggplot2' was built under R version 4.3.3

``` r
library(ggrepel)
```

    Warning: package 'ggrepel' was built under R version 4.3.3

``` r
hardness_data <- data.frame(
  option = c("dplyr + tidyr",
             "data.table",
             "DBI + SQL",
             "DBI + dbplyr",
             "duckdb/arrow",
             "Wrangle data externally"),
  data_size = c(1,
                1.5,
                3,
                3,
                3,
                3),
  ease_of_use = c(4,
                  1,
                  1,
                  2,
                  4,
                  .5),
  covered_today = c("No",
                    "No",
                    "No",
                    "No",
                    "Yes",
                    "No")
)

ggplot(hardness_data, aes(ease_of_use, data_size, label = option)) +
  geom_text_repel() +
  theme_minimal() +
  xlim(0.5, 4) + 
  ylim(0.5,4) +
  xlab("- Easier to use +") +
  ylab("- Bigger datasets +") +
  theme(axis.text = element_blank(),
        panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    text = element_text(face = "bold", size = 15)) 
```

![](options_files/figure-commonmark/unnamed-chunk-2-1.png)
