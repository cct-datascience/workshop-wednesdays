Publishing Research as Reports with R Markdown
================
Kristina Riemer
03/30/2022

## Overview

#### Objective

Each participant has a published R Markdown report on their research,
and understands uses of R Markdowns

#### Schedule

| Topic                                   | Time          |
|:----------------------------------------|:--------------|
| Intros                                  | 11:00 - 11:05 |
| Defining R Markdown and markdown        | 11:05 - 11:15 |
| Uses of R Markdown documents            | 11:15 - 11:25 |
| Creating example R Markdown             | 11:25 - 11:55 |
| Two methods for publishing R Markdowns  | 11:55 - 12:15 |
| Turn R script into R Markdown & publish | 12:15 - 12:45 |
| Creating dashboard from R Markdown      | 12:45 - 1:00  |

## Curriculum & notes

#### 1. R Markdown introduction

Content based on [Data Carpentry for Biologists knitr
lecture](https://datacarpentry.org/semester-biology/materials/knitr/)

**What is R Markdown?**

-   Combine text, code, and code outputs
-   Called “literate programming”
-   Create documentation, reports or manuscripts

**What does a complete one look like?**

-   Show example of published R Markdown from research
-   [Cottonwood data
    exploration](https://rpubs.com/reamy316/npn_cottonwoods)
-   Plot map with data, create table from data

**Why do this?**

-   Remember what you did, your future self will thank you!
-   Share with collaborators, advisor, etc.

**What is the process?**

-   Do using .Rmd file, which are fairly readable
-   Show cottonwood .Rmd in RStudio next to published RPubs
-   Add formatting, e.g., bold, lists, tables, with markdown
-   Render into html, PDF, Word doc
-   Runs code and turns formatting into what we expect
-   Knit cottonwood .Rmd in RStudio
-   Called “knitting”

**How can these be shared?**

-   Save as file and send via email or Slack
-   Pushed to GitHub repository, which can render if output is
    `github_document`
-   Published online via RPubs or RStudio Connect
-   We’ll do last later

**What else can be done?**

-   Teaching notes (show these notes)
-   Code chunks of other programming languages like Python
-   Create books
    -   Example is [R package book](https://r-pkgs.org/)
    -   Each page is an R Markdown
    -   Put together with table of contents with R package `bookdown`
-   Create websites - Example is [Heidi Steiner’s
    website](https://heidiesteiner.netlify.app/) - Use R package
    `blogdown` - Blog posts are R Markdowns - Deploy for free with
    Netlify
-   Make presentations
-   Automatically generate in-text citations from bibliography
-   Include interactive components with R package `htmlwidgets` or with
    Shiny
-   Create dashboard using R package `flexdashboard` (run through
    example at end)

**Walk through for creating basic R Markdown**

Additional things to note beyond DC material:

-   Briefly explain dataset
-   Show how to do unordered list
-   Google for markdown cheat sheet
-   Cover keyboard shortcuts for chunks
-   Explain how knitting creating new R session
-   Demonstrate running code interactively in console
-   Are using tidyverse packages but out of scope to explain how dplyr
    and ggplot work
-   Talk about sharing rendered output
-   Reknit at end into pdf output with `pdf_document`, though they might
    need to install other software

Final content:

    ---
    title: "Rodent Report"
    author: "Kristina Riemer"
    date: "3/29/2022"
    output: html_document
    ---

    ## Purpose

    Exploring rodent population data at the **Portal Project**. 

    List of tasks: 

    1. Load data from [database](http://figshare.com/articles/Portal_Project_Teaching_Database/1314459)
    2. Clean data into time series
    3. Make plot

    ## Read in packages

    ```{r, message=FALSE}
    library(dplyr)
    library(ggplot2)
    ```

    ## Read in data

    ```{r, cache=TRUE}
    data <- read.csv("https://ndownloader.figshare.com/files/2292172")
    head(data)
    ```

    The data includes `r length(unique(data$species_id))` species. 

    ## Clean up data and plot

    Summarize data for number of occurrences per year and per species. 

    ```{r}
    time_series <- data %>% 
      group_by(species_id, year) %>% 
      summarize(count = n())
    head(time_series)
    ```

    Plot the time series. 

    ```{r, message=FALSE, echo=FALSE}
    ggplot(time_series, aes(x = year, y = count)) +
      geom_line() +
      facet_wrap(~species_id)
    ```

#### 2. Publish R Markdown

-   Publish so that have a publicly available document with a URL that
    can be shared with anyone
-   Two methods with their own pros and cons

|               RPubs                |      RStudio Connect      |
|:----------------------------------:|:-------------------------:|
|           Free to anyone           | Need license (UA has one) |
| Any products, including coursework |  Research products only   |
|    Can’t collaboratively update    | Collaborators can update  |
|        Updating is finicky         |   Can schedule updates    |

**Walkthrough of publishing through RPubs**

-   [Official (incomplete?)
    instructions](https://rpubs.com/about/getting-started)
-   Sign out of RPubs ahead of time
-   Knit document, then click “Publish” button in pop up window
-   Select RPubs (only option if not connected to RStudio Connect
    server)
-   Create new account or sign in on browser window pop up
    -   Account username will be part of publication URL!
-   Once signed in, can add details now or can change later
    -   Default URL is rpubs.com/username/number
    -   Add title, description, and edit URL in “Slug”
    -   Click “Save Changes” button
-   Will open up published page, can share URL with whoever
-   Change details by selecting “Edit Details” button in toolbar
-   After making changes, can hit “Republish” button on knitted document
    to update

**Walkthrough of publishing through RStudio Connect**

-   [UA RStudio Connect](https://viz.datascience.arizona.edu/connect/)
-   Register UA account for RStudio Connect
    [here](https://datascience.arizona.edu/RSConnect)
-   Connect RStudio to RStudio Connect
    -   Tools -> Global Options -> Publishing -> Connect…
    -   Input UA server address -> Next
    -   Some folks had to install R packages before RStudio Connect was
        an option
-   Click blue publish button while .Rmd is open or knitted and select
    RStudio Connect option
-   Select “Publish document with source code” or “Publish finished
    document only”
    -   First option takes longer with big files but renders on fly
    -   Second option is faster but have to remember to have knit html
-   Will open in browser window
-   Show [example published R
    Markdown](https://viz.datascience.arizona.edu/connect/#/apps/cb52ef2a-6559-498f-90b8-06bd2c385da1/access)

#### 3. Create new R Markdown

-   Purpose is to create an R Markdown from existing R code or script
-   Spend half an hour working, discussing, and troubleshooting
-   Folks discussed what they were going to work on
-   They should also try to publish on RPubs when done with a simple R
    Markdown

#### 4. Example of a use for R Markdown beyond simple report (optional)

Example of dashboard with Shiny component using rodent example data:

    ---
    title: "Rodent Dashboard"
    author: "Kristina Riemer"
    date: "10/27/2021"
    output: flexdashboard::flex_dashboard
    runtime: shiny
    ---

    ```{r}
    library(flexdashboard)
    library(dplyr)
    library(ggplot2)
    library(shiny)
    ```

    ```{r}
    data <- read.csv("https://ndownloader.figshare.com/files/2292172")
    time_series <- data %>% 
      group_by(species_id, year) %>% 
      summarize(count = n())
    ```

    Column 1
    --------------------------------------------------

    ### Number of species

    ```{r}
    valueBox(length(unique(data$species_id)), icon = "fa-tag")
    ```

    ### Time series plot

    ```{r}
    ggplot(time_series, aes(x = year, y = count)) +
      geom_line() +
      facet_wrap(~species_id)
    ```

    Column 2
    --------------------------------------------------

    ### About rodents

    This is some example content from the **Portal Project** to demonstrate how to create a dashboard from an R Markdown. 

    ### Rodent dataset by year

    ```{r}
    numericInput("chosen_year", "Input year", 1980)

    renderTable({
      head(filter(data, year == input$chosen_year))
    })
    ```

## Resources

-   [Recording of this workshop from October
    2021](https://youtube.com/watch?v=WaX2uocJ_2M)
-   [R Markdown book](https://bookdown.org/yihui/rmarkdown/)
-   [Markdown syntax](https://www.markdownguide.org/basic-syntax/)
-   [Markdown cheat sheet](https://www.markdownguide.org/cheat-sheet/)
-   [GitHub-flavored
    markdown](https://guides.github.com/features/mastering-markdown/)
-   [R Markdown cheat
    sheet](https://raw.githubusercontent.com/rstudio/cheatsheets/master/rmarkdown.pdf)
-   [UA RStudio Connect
    signup](https://datascience.arizona.edu/RSConnect)
-   [RStudio Connect user
    guide](https://docs.rstudio.com/connect/1.7.4/user/index.html)
-   [RStudio Connect server](https://viz.datascience.arizona.edu/)

## Help

Feel free to drop by the [CCT Data Science Team office
hours](https://datascience.cals.arizona.edu/office-hours), which happen
every Tuesday morning. We would love to help you with your R
Markdown-specific, and general R, questions!

You can also [make an appointment with
Kristina](https://calendar.google.com/calendar/u/0/selfsched?sstoken=UU83LWZEMmhrdWxUfGRlZmF1bHR8N2NkYWViOThjOGZlZjFhMTQyNzIyNDIxYjJkODc0Yjg)
to discuss this content and get troubleshooting help.
