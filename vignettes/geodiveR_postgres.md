---
title: "DeepDive Working"
author: "Simon Goring"
date: "August 14, 2018"
output:
  html_document:
    code_folding: show
    theme: flatly
    highlight: pygment
    keep_md: yes
    number_sections: no
    self_contained: true
  pdf_document:
    latex_engine: xelatex
---



## Setting Up the `geoDiveR` Environment

Using geoDiverR efficiently requires the use of a postgres server, and a local DeepDive database.  Postgres is a free and open source database with support for a number of extensions, including geospatial analysis with [PostGIS](https://postgis.net/).  Postgres is an application that runs in the background on your computer, or on a server in the cloud.  It is accessed through a `connection`, using a username and a password, and a single instance of a Postgres server can contain one or many different databases.

The `geodiveR` package assumes you have a Postgres database initialized on your computer that you will be using for your work.  If you do not yet have one, follow these instructions, otherwise, skip ahead to the [Creating a new Database section]().

## Getting Set up with postgreSQL

### Installing postgreSQL

Postgres can be installed on almost every platform.  Follow the [installation instructions on the official postgres webpage](https://www.postgresql.org/download/) to install postgres for your particular OS.

Once you have installed Postgres you will need to create a new user for the server.  This will let you give the user a different set of permissions, and provide some security if you choose to run this project elsewhere.

### Local Development Tools

Although postgres comes with a commandline tool `psql`, a number of people find graphical interfaces much less foreboding.  There are a number of software applications that can interact with your postgres installation.  [pgAdmin4](https://www.pgadmin.org/) is a browser-based application that can be used with postgres installations.  Because postgres is so widely supported, there is a long list of applications that can be found on the [postgres wiki](https://wiki.postgresql.org/wiki/Community_Guide_to_PostgreSQL_GUI_Tools).  Among them, [DBeaver](http://dbeaver.jkiss.org/) is often recommended, along with [dbForge](https://www.devart.com/dbforge/postgresql/studio/), and [JetBrains](http://www.jetbrains.com/).

With Postgres GUI tools, database management (such as creating a new database, or adding a new user) may be relatively straightforward.  A drawback is that some implementations may not be as feature rich or as extensible as direct commandline interaction.  We leave this choice to the user.

### Creating a new user

This step is optional.  If you expect others to work collaboratively, or are hosting the project in the cloud, it may be worthwhile creating a new user for your server.

By default postgres is set up with a user `postgres` with no password.  To create a new user you can use the command:

```
psql -U postgres -c "CREATE ROLE newuser WITH PASSWORD 'newpassword' LOGIN NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;"
```

In this case you will have logged in using the user `postgres` to create a new user `newuser`.  `CREATE ROLE` creates a new user who must `LOGIN`.  The `newuser` is required to `LOGIN` using the `PASSWORD` defined in quotes.  Here we are using very restrictive settings for the new user.  They cannot bypass other restrictions, nor create a new database or create other roles.

The R implementation for most databases will require you to `connect` to your database, using your username, password, through a host port.  By default Postgres is installed on `localhost` port `5432`.

### Creating a new database

Since you are required to create a database for use, we need to create a database on the Postgres server.  We will create a database called `deepdive` for the purposes of this exercise:

```
psql -U postgres -c "CREATE DATABASE geodeepdive;"
```

If you are using a GUI you can use it to create new roles and new databases.  If you are using the GUI, you should now see it in the browser window for the database.

## Connecting to `geodeepdive` using R

When you connect to DeepDive for the first time you will obtain two files, one is a JSON formatted bibliography file, the other is the Stanford NLP output file.  Presuming you have set up a new Postgres Database (here as a local server), we can load the database and connect.  I am using the default postgres user and connecting to a database I created called `deepdive`.

The R package `geodiveR` includes a test dataset and associated bibliographic information for 150 papers that can be loaded using `data()`.  These objects are similar to the files you would obtain from GeoDeepDive.


```r
library(geodiveR)
library(RPostgreSQL)
```

```
## Loading required package: methods
```

```
## Loading required package: DBI
```

```r
# Connect to a database:
con <- dbConnect(drv = "PostgreSQL",
                 user = "postgres",
                 password = "postgres",
                 host = "localhost",
                 port = "5432",
                 dbname = "deepdive")

# Replace these with text strings pointing to file locations, or JSON files.
data("nlp")
data("publications")

con <- load_dd(con, bib = publications, sent = nlp, clean = TRUE)
```

```
## Creating the `publications` table.
```

```
## Creating the `authors` table.
```

```
## Creating the `links` table.
```

```
## Creating the `sentences` table.
```

After the database is loaded (or connected), we can look to make sure that things have been loaded as we might expect:


```r
summaryGdd(con)
```

```
##           table          fields  rows
## 1  publications       publisher   150
## 2  publications           title   150
## 3  publications            year   150
## 4  publications          number   150
## 5  publications          volume   150
## 6  publications           gddid   150
## 7  publications            type   150
## 8  publications           pages   150
## 9  publications    journal.name   150
## 10      authors           gddid   763
## 11      authors            name   763
## 12        links           gddid   300
## 13        links            type   300
## 14        links              id   300
## 15    sentences           gddid 87181
## 16    sentences        sentence 87181
## 17    sentences      word_index 87181
## 18    sentences           words 87181
## 19    sentences parts_of_speech 87181
## 20    sentences    named_entity 87181
## 21    sentences          lemmas 87181
## 22    sentences       dep_paths 87181
## 23    sentences     dep_parents 87181
```

Looking over the database structure you can see that `geodiveR` creates four different tables: `publications` contains the list of unique bibliographic information for each paper within the GDD resource; `authors` contains the names of all the authors of each publication (and is a one to many table, there can be many authors for any one paper); `links` includes all the link types for a paper, for example DOIs or URLs (one to many); `sentences` provides the full NLP output for the record.

These tables become the basis for our future analysis.

## Viewing Data

Our test set contains 150 publications and 8.7181\times 10^{4} total sentences.  This can be an overwhelming amount of data, particularly with the complex outputs from the NLP data.

Much of the GDD workflow relies on feature detection.  To begin to understand the data we may wish to view small subsets.  First it might be useful to take a look at some of the tables, or fields to see what the database actually looks like internally:


```r
skim(con, table = 'authors')
```

```
##                       gddid                     name
## 1  5804c1f8cf58f15c39fc6017 van Hardenbroek, Maarten
## 2  583a3aa3cf58f15fc57a4eb8        Lotter, Elisabeth
## 3  5792688ecf58f12668028eef     Genson, Gwenaelle S.
## 4  54b43277e138239d86852045     Henderson, Gideon M.
## 5  58bcd0c6cf58f152cfe8fa29      Valero-Garcés, B.L.
## 6  55ccab4ecf58f190b49048ad       Keddadouche, Karim
## 7  5801ff6acf58f11d2d408685        Aghamohammadi, A.
## 8  5749c086cf58f1aa78e6f4f5          GARLAN, Thierry
## 9  58bcd7d4cf58f155c047f508           Knutz, Paul C.
## 10 54cc6b86e138236bcc92a002             Asami, Ryuji
```

The `skim()` function returns a random subset of rows within a table. You can apply it to any table in the database, or a `data.frame`.  In the case where columns might be very long (for example the `sentences` column), the `skim()` function can be applied to single columns:


```r
skim(con, table = 'sentences', column = 'words', n = 5)
```

```
##                                                                                                                                                                                                                                                                                                       words
## 1                                                                                                                                                                                                                                                                                       {110,",",344e360,.}
## 2                                                                                                                                                                            {26,-LRB-,8,-RRB-,839,--,853,-LRB-,2011,-RRB-,LATE,HOLOCENE,ENVIRONMENTS,OF,CORONATION,GULF,853,Smith,JN,",",Walton,A.,1980,.}
## 3                                                                                                                                                                                                                                                         {Foucault,",",A.,",",Stanley,",",D.J.,",",1989,.}
## 4 {That,the,moraine,system,identiﬁed,by,McCabe,et,al.,-LRB-,1998,-RRB-,represented,a,readvance,rather,than,a,recessional,phase,of,the,ice,sheet,",",however,",",is,based,on,clearly,expressed,geomorphic,evidence,of,cross-cutting,relations,of,ice-ﬂow,indicators,related,to,the,younger,moraine,system,.}
## 5                                                                                                                                                                                                                                     {Present,dynamics,and,future,prognosis,of,a,slowly,surging,glacier,.}
```

The `setseed` flag is used if there is a need to establish entirely reproducible workflows, where results must remain static from one iteration to another.

## Applying Queries

With the data placed into the database it is possible to apply queries to the database, and, possibly chain them.  For example, we are interested in knowing which papers have the term "pollen" in them as a stand-alone sentence.  We also want to find papers that discuss pollen in the context of summer months:


```r
pollen <- gddMatch(con,
                   table = "sentences",
                   col = "words",
                   pattern = ",pollen,",
                   name = "pollenQuery")

summer <- gddMatch(con,
                   table = "sentences",
                   col = "words",
                   pattern = "((July)|(June)|(August)|(summer))",
                   name = "summerQuery",
                   rows = TRUE)
```

This gives us two subsets of data, managed as `list()` objects in R, but also with a class `gddMatch()`. The object contains the original query (as `pollen$query`) and a vector of `TRUE`/`FALSE` values indicating whether a particular sentence matched the text pattern.  If you want the function to return the explicit matches then you can use the `rows` flag.

The package should combine results as well.  Currently there is an `and()` function implemented:


```r
combines <- and(pollen, summer)
```

