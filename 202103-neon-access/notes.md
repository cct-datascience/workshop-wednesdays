Intro to Accessing NEON Data Workshop
================

## Workshop intro

Date: 3/31/2021 Time: 9:30am - 11am (AZ)

We will be recording this workshop.

### Who are we

We are in the Data Science Institute at UA. Our group is called DIAG, we
work on computational tools and training for agricultural and ecological
data. We want to enable researchers with their work, through training
and consulting, so let us know if we could help you in any way\!

Kristina and Jessica introduce ourselves.

### Workshop overview/logistics

Intended to be hands-on. Should have R and RStudio installed, and R
packages: dplyr and neonstore. Can do these while going over data. Will
stop a lot for questions and such, ask any time by unmuting or in the
chat.

The notes are online already.

This is only a brief introduction, we’ll only have time to start to
scratch the surface of this immense resource.

We’ll cover: summary of NEON data, R packages for downloading data, and
the NEON API.

## NEON overview

NEON is National Ecological Observatory Network. The idea is to collect
ecological data, across diverse components of ecosystems, in a
systematic way at many diverse sites across the United States. This is a
large and novel undertaking with no other similar attempts. Was
initially started well over a decade ago, with federal funding from NSF
and currently run by Battelle.

So what about the actual data? There are 81 sites across North America,
and include both terrestrial and aquatic sampling. The data is diverse,
from weather data collected by sensors to hand-collected plant and
animal data to data collected by remote sensing on planes.

Data types are organized into three kinds:

1.  Observational - human-collected data that may have been analyzed in
    a lab
2.  Instrumentation - sensor-collected data
3.  Remote sensing - collected by an airborne platform

Won’t really discuss the last type here, but it includes LIDAR-type
data.

Lots of time and effort has been put in to collect these data, and the
folks at NEON are doing a good job of providing resources for using it
all, including written documentation online, videos on YouTube, and
hosting tutorials and workshops.

### NEON links

Great FAQ: <https://www.neonscience.org/about/faq>

Lots of resources from NEON for data usage:
<https://www.neonscience.org/resources/getting-started-neon-data-resources>

They’re also collecting software for working with NEON data, to share
with the community: <https://www.neonscience.org/resources/code-hub>

## Getting data through GUI

Okay, so lets get our hands on some data.

The first way to get familiar with and download some NEON data is
through their Data Portal. This is a well-organized, user-friendly GUI
for looking through available data.

Start on the [Data Portal homepage](https://data.neonscience.org/).
There are links to the data itself, resources for working with data,
info about the API, and a FAQ.

We’ll click on [“Explore Data
Products”](https://data.neonscience.org/data-products/explore) to get
the landing page of the actual Data Portal. Scroll down to see a few of
the first available datasets.

Datasets are organized as data products. Each one has a unique
identifier that starts with “DP”. Also has brief summary of data, and
some info about what time frames the data were collected in.

Can use search using keywords, e.g., “mammals”. Will return three data
products for mammals, including DNA barcoding and mammal occurrence data
with taxonomic IDs.

Click on “Small mammal box trapping” product to get more info. Longer
summary of data with keywords. How to cite data product. Study design
info. Issue log. Visual of when and where data are available.

Nice downloading interface, can select by site and date and get
documentation and basic/expanded data. Useful for very specific or
smaller datasets.

Does take some digging into to understand the structure of data and what
is available.

## Getting data programmatically

### NEON’s R package

NEON has an R package for downloading data called `neonUtilities`, which
is [on
CRAN](https://cran.r-project.org/web/packages/neonUtilities/index.html).
They have [a
tutorial](https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data)
for how to use it.

Main function is `loadByProduct`, and there are other functions for
downloading remote sensing data and to read in individual data files.

Seems like a great package, very useful and well developed.

### neonstore R package

I’ve mostly used this other package for getting NEON data though.
Developed by Carl Boettinger at UC Berkeley.

Useful because download data once and it stores it in a database on your
computer so it can easily be accessed later on.

Should be [on
CRAN](https://cran.r-project.org/web/packages/neonstore/index.html), but
can also be installed through the [GitHub
repo](https://github.com/cboettig/neonstore).

``` r
#devtools::install_github("cboettig/neonstore")
library(neonstore)
```

There are functions for exploring what data are available.

``` r
products <- neon_products()
```

Columns of interest include `themes` and `keywords`.

``` r
unique(products$themes)
```

Can look for certain words of interest.

``` r
library(dplyr)
mammals_products <- products %>% 
  filter(grepl("mammals", productDescription))

plant_products <- products %>% 
  filter(grepl("Plant", productName))
```

Download data using `neon_download` function. Look at manual for this
function by doing `?neon_download`.

Only required argument is the unique data product ID. We can get this
from our filtered data.

We can download all of the mammal trapping data for all sites by just
using the data product code. But that will take a while, so let’s just
get it for one site.

``` r
neon_download(product = mammals_products$productCode[1], 
              site = "HARV")
```

If you run this again, it will not re-download anything that you’ve
already downloaded. Downloaded data is stored in a local database on
your computer.

Useful to have a record of how and what was downloaded, as opposed to
pointing and clicking in the GUI portal and maybe not remembering later
on.

Can see what data you’ve already downloaded, and read it in, using
`neon_index` function. I have a bunch of datasets already downloaded for
a project we’re working on.

``` r
downloaded_data <- neon_index()
mammal_downloaded_data <- downloaded_data %>% 
  filter(product == mammals_products$productCode[1])
```

Can find these data locally on computer, but shouldn’t need to.

Can read in, even after closing session, because data is still in
database. Function is called `neon_read`, and it requires the name of
the table you want. Look up function info with `?neon_read`.

``` r
mammal_harv <- neon_read(table = "mam_pertrapnight-basic")
```

How to understand what is available in this data? Use mix of Data Portal
info (see in particular links under “Documentation” section) and what’s
downloaded. Exploratory plotting is very useful.

### Faster access with API

What to do if you want to download a lot of data? Can download as much
as you want, there’s no limit on that, but there are limits on how
quickly it will download. Most APIs have rate limits.

Can increase number of requests before breaks by getting an API token
from NEON. How to do this:

1.  Sign up for a NEON account
    [here](https://data.neonscience.org/myaccount)
2.  On main account page, scroll down to “API Tokens” section (have to
    verify email address first)
3.  Click “GET API TOKEN” button
4.  It will autogenerate one that can be viewed with eye button or
    copied with paper button

NEON has [instructions for getting this
token](https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial).

Can use this with `neonstore` by directly reading it in as an argument
in `neon_download`.

``` r
neon_download(product = "DPxxxx", 
              .tokeh = Sys.getenv("random1string2of3numbers4letters5"))
```

Do not share this number\!, e.g., in code on GitHub

If using often and don’t want to risk accidentally sharing this, create
a text file with it or add to `.Renviron` file.

### Direct API access

Can use API directly by constructing URL for endpoint of interest and
using tools to pull down data. They have [a tutorial on
API](https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-usage).

Example URL for Harvard site mammal data:
`https://data.neonscience.org/api/v0/data/DP1.10072.001/HARV/2018-07`

Combine:

  - base url: `http://data.neonscience.org/api/v0`
  - endpoint: `/data`
  - target: `/DP1.10072.001/HARV/2018-07` (product code, site, and date)

This API is what the two R packages are using to get data.
