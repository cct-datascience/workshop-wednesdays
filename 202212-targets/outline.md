Workflow Managment in R Projects with {targets}
================
Eric Scott

**Tagline**: “As data analysis projects grow, they can get complicated
to update and time consuming to re-run. Learn how to save time and
reduce confusion by using the `targets` package to manage the workflow
of your analyses in R.”

### PART 1:

1.  What problems does workflow management solve?
    1.  Scenario 1: you have data, a wrangling script that produces
        multiple datasets, and more scripts that run long-running models
        on different subsets of data. Your collaborator sends you
        updated data. Which pieces of your code need to be re-run?

    2.  Scenario 2: You took one of our previous workshops that gave you
        the very good advice to number scripts like `01-read_data.R`,
        `02-analyze_data.R`, `03-plot_data.R`, but now you’re at number
        20 and some of those are really not dependent on the previous
        step—like maybe `02a-analysis_one_way.R`
        `02b-analysis_alternate.R` or `03a-barplot.R`,
        `03b-complicated_line_plot.R`. You try writing a master script
        that `source()`s your other scripts, but it’s getting unwieldy
        and difficult to maintain when you make changes to your code.
2.  Quick demo of `targets`
    1.  Start with existing project

    2.  Explain contents of `_targets.R`

    3.  Show `tar_visnetwork()`

    4.  Run `tar_make()`

    5.  Make a change and run `tar_visnetwork()` and `tar_make()` again

    6.  Show `targets/` and explain what it is and why you don’t need to
        touch it manually

#### PARTICIPATORY LIVE CODING:

1.  How to setup a project to use `targets` with `use_targets()`

    1.  Start a new RStudio project and run `use_targets()`

    2.  Anatomy of `targets` project

    3.  Writing your first targets

    4.  Visualize with `tar_visnetwork()`

    5.  Make changes and re-run `tar_make()`

### PART 2:

1.  How to refactor an existing project to use `targets`
    1.  Define “refactor”
    2.  Converting code to functions using RStudio “extract function”
        feature
    3.  Writing “re-usable enough” functions
2.  Good practices for creating targets
    1.  Have a naming convention
    2.  Discussion about how many targets to have
        (e.g. `read_wrangle_transform_data` vs. `read_data`,
        `wrangle_data`, `transform_data)`
3.  Debugging targets
    1.  use `tar_load()` and match argument names to target names
    2.  Official debug features of `targets` (need to do more research)

#### EXERCISE:

Convert existing simple project to use `targets`:

1\) Run `use_targets()` and create a `tar_plan()`

2\) turn scripts or portions of scripts into functions in the `R/`
folder

4\) check workflow with `tar_visnetwork()`

3\) checking if it works with `tar_make()`

4\) debug functions if necessary

### PART 4 (if time):

1.  Parallelization
    1.  Demo ‘multisession’ parallelization with `tar_make_clustermq()`
    2.  Multi-core OOD RStudio session as way to use HPC
2.  Demo branching (?)
    1.  Just so they are aware it exists
    2.  Dynamic branching only is enough probably
3.  Collaborating with `targets`
    1.  Intermediates in `_targets` not tracked with git/GitHub
    2.  Cloud storage a possibility, but extra setup
    3.  Save intermediate results with `tar_file()`

### Closing discussion:

1.  When to use `targets` for a project?
    1.  Consider complexity, time to re-run—how much time will you save?
    2.  Consider your collaborators—do they need to just see results
        (+`targets`) or do they need to contribute code (±`targets`)?
    3.  As you get more comfortable with `targets`, you may find
        yourself using it for even simple projects!
2.  Point people to template on GitHub
    1.  README with instructions
    2.  GitHub actions to render README
    3.  Cool mermaid.js graph
