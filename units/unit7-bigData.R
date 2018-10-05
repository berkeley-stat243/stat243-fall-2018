############################################################
### Demo code for Unit 7 of Stat243, "Databases and Big Data"
### Chris Paciorek, October 2018
############################################################

#####################################################
# 2: Databases
#####################################################

### 2.5 Accessing databases in R

## @knitr database-access

library(RSQLite)
drv <- dbDriver("SQLite")
dir <- '../data' # relative or absolute path to where the .db file is
dbFilename <- 'stackoverflow-2016.db'
db <- dbConnect(drv, dbname = file.path(dir, dbFilename))
# simple query to get 5 rows from a table
dbGetQuery(db, "select * from questions limit 5")  


## @knitr database-tables

dbListTables(db)
dbListFields(db, "questions")
dbListFields(db, "answers")


## @knitr database-queries
results <- dbGetQuery(db, 'select * from questions limit 5')
class(results)

query <- dbSendQuery(db, "select * from questions")
results2 <- fetch(query, 5)
identical(results, results2)
dbClearResult(query)  # clear to prepare for another query

## @knitr database-disconnect
dbDisconnect(db)

## @knitr 

### 2.6 Basic SQL for choosing rows and columns from a table

## @knitr database-queries-examples

## find the largest viewcounts in the questions table
dbGetQuery(db,
'select distinct viewcount from questions order by viewcount desc limit 10')
## now get the questions that are viewed the most
dbGetQuery(db, 'select * from questions where viewcount > 100000')

## @knitr

### 2.7 Simple SQL joins

## @knitr join-without-join
result1 <- dbGetQuery(db, "select * from questions, questions_tags
        where questions.questionid = questions_tags.questionid and
        tag = 'python'")

## @knitr join-with-join

result2 <- dbGetQuery(db, "select * from questions join questions_tags
        on questions.questionid = questions_tags.questionid
        where tag = 'python'")

head(result1)
identical(result1, result2)

## @knitr three-way-join
result1 <- dbGetQuery(db, "select * from
        questions Q, questions_tags T, users U where
        Q.questionid = T.questionid and
        Q.ownerid = U.userid and
        tag = 'python' and
        age < 18")

result2 <- dbGetQuery(db, "select * from
        questions Q
        join questions_tags T on Q.questionid = T.questionid
        join users U on Q.ownerid = U.userid
        where tag = 'python' and
        age < 18")

identical(result1, result2)

## @knitr

### 2.8 Grouping / stratifying

## @knitr group-by

dbGetQuery(db, "select tag, count(*) as n from questions_tags
                group by tag order by n desc limit 25")

## @knitr

### 2.9 Getting unique results (DISTINCT)

## @knitr distinct

tagNames <- dbGetQuery(db, "select distinct tag from questions_tags")
head(tagNames)
dbGetQuery(db, "select count(distinct tag) from questions_tags")

## @knitr

### 2.10 Indexes

## @knitr indexes

system.time(dbGetQuery(db,
  "select * from questions where viewcount > 10000"))   # 10 seconds
system.time(dbGetQuery(db,
  "create index count_index on questions (viewcount)")) # 19 seconds
system.time(dbGetQuery(db,
  "select * from questions where viewcount > 10000"))   # 3 seconds

## @knitr

## 2.11 Temporary tables and views

## @knitr drop-view
dbGetQuery(db, "drop view questionsAugment") # drop so can create again in next step


## @knitr view

## note there is a creationdate in users too, hence disambiguation
dbGetQuery(db, "create view questionsAugment as select
                questionid, questions.creationdate, score, viewcount,
                title, ownerid, age, displayname
                from questions join users
                on questions.ownerid = users.userid")
## don't be confused by the "data frame with 0 columns and 0 rows"
## message -- it just means that nothing is returned to R;
## the view HAS been created
               
dbGetQuery(db, "select * from questionsAugment where age < 15 limit 5")

## @knitr

### 2.12 Creating database tables

## @knitr create-table

## Option 1: pass directly from CSV to database
dbWriteTable(conn = db, name = "student", value = "student.csv",
             row.names = FALSE, header = TRUE)

## Option 2: pass from data in an R data frame
## create data frame 'student' in some fashion
#student <- data.frame(...)
#student <- read.csv(...)
dbWriteTable(conn = db, name = "student", value = student,
             row.names = FALSE, append = FALSE)

## @knitr

#####################################################
# 3: R and big data
#####################################################

## @knitr airline-prep, engine='bash'

for yr in {1987..2008}; do
 curl http://stat-computing.org/dataexpo/2009/${yr}.csv.bz2 -o /scratch/users/paciorek/243/AirlineData/${yr}.csv.bz2
done

cd /scratch/users/paciorek/243/AirlineData/
cp 1987.csv.bz2 AirlineDataAll.csv.bz2
bunzip2 AirlineDataAll.csv.bz2
for yr in {1988..2008}; do
  bunzip2 ${yr}.csv.bz2 -c | tail -n +2 >> AirlineDataAll.csv
done

# try to determine types and values of fields...
cut -d',' -f11 AirlineDataAll.csv | sort | uniq | less
cut -d',' -f29 AirlineDataAll.csv | sort | uniq | less

cp /scratch/users/paciorek/AirlineDataAll.csv /tmp/.

# create a small test file for testing our code
head -n 10000 AirlineDataAll.csv > test.csv


## @knitr

### 3.1 Working with big datasets in memory: data.table

## @knitr data.table-read

require(data.table)
dir = '/tmp'
fileName <- file.path(dir, 'AirlineDataAll.csv')

dt <- fread(fileName, colClasses=c(rep("numeric", 8), "factor",
                            "numeric", "factor", rep("numeric", 5),
                            rep("factor", 2), rep("numeric", 4),
                            "factor", rep("numeric", 6)))
#Read 123534969 rows and 29 (of 29) columns from
#    11.203 GB file in 00:05:16


class(dt)
# [1] "data.table" "data.frame"

## @knitr data.table-subset

system.time(sfo <- subset(dt, Origin == "SFO"))
## 8.8 seconds 
system.time(sfoShort <- subset(dt, Origin == "SFO" & Distance < 1000))
## 12.7 seconds

system.time(setkey(dt, Origin, Distance))
## 33 seconds:
## takes some time, but will speed up later operations
tables()
##     NAME            NROW    MB
##[1,] dt       123,534,969 27334
##[2,] sfo        2,733,910   606
##[3,] sfoShort   1,707,171   379
##     COLS                                                                            
##[1,] Year,Month,DayofMonth,DayOfWeek,DepTime,CRSDepTime,ArrTime,CRSArrTime,UniqueCarr
##[2,] Year,Month,DayofMonth,DayOfWeek,DepTime,CRSDepTime,ArrTime,CRSArrTime,UniqueCarr
##[3,] Year,Month,DayofMonth,DayOfWeek,DepTime,CRSDepTime,ArrTime,CRSArrTime,UniqueCarr
##     KEY            
##[1,] Origin,Distance
##[2,]                
##[3,]                
##Total: 28,319MB

## vector scan
system.time(sfo <- subset(dt, Origin == "SFO"))
## 8.5 seconds
system.time(sfoShort <- subset(dt, Origin == "SFO" & Distance < 1000 ))
## 12.4 seconds

## binary search
system.time(sfo <- dt[.('SFO'), ])
## 0.8 seconds

## @knitr 

### 3.2 Working with big datasets on disk: ff


## @knitr ff

require(ff)
require(ffbase)

# I put the data file on local disk on the machine I am using
# (/tmp on radagast)
# it's good to test with a small subset before
# doing the full operations
fileName <- file.path(dir, 'test.csv')
dat <- read.csv.ffdf(file = fileName, header = TRUE,
     colClasses = c('integer', rep('factor', 3),
     rep('integer', 4), 'factor', 'integer', 'factor',
     rep('integer', 5), 'factor','factor', rep('integer', 4),
     'factor', rep('integer', 6)))


fileName <- '/tmp/AirlineDataAll.csv'
system.time(  dat <- read.csv.ffdf(file = fileName, header = TRUE,
    colClasses = c('integer', rep('factor', 3), rep('integer', 4),
    'factor', 'integer', 'factor', rep('integer', 5), 'factor',
    'factor', rep('integer', 4), 'factor', rep('integer', 6))) )
## takes about 22 minutes

system.time(ffsave(dat, file = file.path(dir, 'AirlineDataAll')))
## takes 11 minutes
## file is saved (in a binary format) as AirlineDataAll.ffData
## with metadata in AirlineDataAll.RData

rm(dat) # pretend we are in a new R session

system.time(ffload(file.path(dir, 'AirlineDataAll')))
# this is much quicker:
# 107 seconds

## @knitr tableInfo

ffload(file.path(dir, 'AirlineDataAll'))
# [1] "tmp/RtmpU5Uw6z/ffdf4e684aecd7c4.ff" "tmp/RtmpU5Uw6z/ffdf4e687fb73a88.ff"
# [3] "tmp/RtmpU5Uw6z/ffdf4e6862b1033f.ff" "tmp/RtmpU5Uw6z/ffdf4e6820053932.ff"
# [5] "tmp/RtmpU5Uw6z/ffdf4e681e7d2235.ff" "tmp/RtmpU5Uw6z/ffdf4e686aa01c8.ff"
# ...

dat$Dest
# ff (closed) integer length=123534969 (123534969) levels: BUR LAS LAX OAK PDX RNO SAN SFO SJC SNA
# ABE ABQ ACV ALB ALO AMA ANC ATL AUS AVP AZO BDL BFL BGR BHM BIL BLI BNA BOI BOS BTV BUF BWI CAE
# CAK CCR CHS CID CLE CLT CMH CMI COS CPR CRP CRW CVG DAB DAL DAY DCA DEN DFW DLH DRO DSM DTW ELP
# EUG EVV EWR FAI FAR FAT FLG FLL FOE FSD GCN GEG GJT GRR GSO GSP GTF HNL HOU HPN HRL HSV IAD IAH
# ICT ILG ILM IND ISP JAN JAX JFK KOA LBB LEX LGA LGB LIH LIT LMT LNK MAF MBS MCI MCO MDT MDW MEM
# MFR MHT MIA MKE MLB MLI MOB MRY MSN MSP MSY OGG OKC OMA ONT ORD ORF PBI PHL PHX PIA PIT PNS PSC
# ...

# let's do some basic tabulation
DestTable <- sort(table.ff(dat$Dest), decreasing = TRUE)
# table is a generic, so shouldn't need explicit table.ff,
# unless dat$Dest is not see as an ff object

# takes a while

#    ORD     ATL     DFW     LAX     PHX     DEN     DTW     IAH     MSP     SFO

# 6638035 6094186 5745593 4086930 3497764 3335222 2997138 2889971 2765191 2725676

#    STL     EWR     LAS     CLT     LGA     BOS     PHL     PIT     SLC     SEA

#  2720250 2708414 2629198 2553157 2292800 2287186 2162968 2079567 2004414 1983464 

# looks right - the busiest airports are ORD (O'Hare in Chicago) and ATL (Atlanta)

dat$DepDelay[1:50]
#opening ff /tmp/RtmpU5Uw6z/ffdf4e682d8cd893.ff
#  [1] 11 -1 11 -1 19 -2 -2  1 14 -1  5 16 17  1 21  3 13 -1 87 19 31 17 32  0  1
# [26] 29 26 15  5 54  0 25 -2  0 12 14 -1  2  1 16 15 44 20 15  3 21 -1  0  7 23

min.ff(dat$DepDelay, na.rm = TRUE)
# [1] -1410
max.ff(dat$DepDelay, na.rm = TRUE)
# [1] 2601

# why do I need to call min.ff and max.ff rather than min/max?

# tmp <- clone(dat$DepDelay) # make an explicit copy

## @knitr 

### 3.2.3 sqldf

## @knitr sqldf
require(sqldf)
dir = '/tmp'
fileName <- file.path(dir, 'AirlineDataAll.csv')
# read in file, with temporary database in memory
system.time(sfo <- read.csv.sql(fn,
      sql = "select * from file where Origin = 'SFO'",
      dbname=NULL, header = TRUE))
# read in file, with temporary database on disk
system.time(sfo <- read.csv.sql(fn,
      sql = "select * from file where Origin = 'SFO'",
      dbname=tempfile(), header = TRUE))

## @knitr

## 3.3 dplyr package

## @knitr dplyr

library(dplyr)

## with database
dir <- '../data' # relative or absolute path to where the .db file is
dbFilename <- 'stackoverflow-2016.db'

db <- src_sqlite(file.path(dir, dbFilename))
questions <- tbl(db, "questions") 
questions

## with data.table
dir <- '/tmp'
fileName <- file.path(dir, 'AirlineDataAll.csv')
flights <- tbl_dt(fread(fileName, colClasses=c(rep("numeric", 8), "factor",
                            "numeric", "factor", rep("numeric", 5),
                            rep("factor", 2), rep("numeric", 4),
                            "factor", rep("numeric", 6))))

# now use dplyr functionality on 'flights'

flights %>% group_by(UniqueCarrier) %>%
summarize(mnDelay = mean(DepDelay, na.rm=TRUE))

# Source: local data table [29 x 2]
#
#   UniqueCarrier mean(DepDelay, na.rm = TRUE)
#1             PS                     8.928104
#2             TW                     7.658251
#3             UA                     9.667930
#4             WN                     9.077167
#5             EA                     8.674051
#6             HP                     8.107790
#7             NW                     6.007974
#8         PA (1)                     5.532442
#9             PI                     9.560336
#10            CO                     7.695967
#..           ...                          ...

## @knitr

### 3.4

## @knitr airline-model

require(ffbase)
require(biglm)

dir = '/tmp'
datUse <- subset(dat, ArrDelay < 60*12 & ArrDelay > (-30) &
                 !is.na(ArrDelay) & !is.na(Distance) & !is.na(DayOfWeek))
datUse$Distance <- datUse$Distance / 1000  # helps stabilize numerics
# 119971791 records

# any concern about my model?
system.time(mod <- bigglm(ArrDelay ~ Distance + DayOfWeek, data = datUse))
# 542.149  11.248 550.779
summary(mod)

coef <- summary(mod)$mat[,1]

## @knitr significance-prep

n <- 150000000  # n*4*8/1e6 Mb of RAM (~5 Gb)
# but turns out to be 11 Gb as a text file
nChunks <- 100
chunkSize <- n/nChunks

set.seed(0)

for(p in 1:nChunks) {
  x1 <- runif(chunkSize)
  x2 <- runif(chunkSize)
  x3 <- runif(chunkSize)
  y <- rnorm(chunkSize, .001*x1, 1)
  write.table(cbind(y,x1,x2,x3), file = file.path(dir, 'signif.csv'),
     sep = ',', col.names = FALSE,  row.names = FALSE,
     append = TRUE, quote = FALSE)
}


fileName <- file.path(dir, 'signif.csv')
system.time(  dat <- read.csv.ffdf(file = fileName,
   header = FALSE, colClasses = rep('numeric', 4)))
# 922.213  18.265 951.204 -- timing is on an older machine than radagast

names(dat) <- c('y', 'x1','x2', 'x3')
ffsave(dat, file = file.path(dir, 'signif'))

## @knitr significance-model
system.time(ffload(file.path(dir, 'signif')))
# 52.323   7.856  60.802  -- timing is on an older machine

system.time(mod <- bigglm(y ~ x1 + x2 + x3, data = dat))
#  1957.358    8.900 1966.644  -- timing is on an older machine

options(digits = 12)
summary(mod)


# R^2 on a subset (why can it be negative?)
coefs <- summary(mod)$mat[,1]
wh <- 1:1000000
1 - sum((dat$y[wh] - coefs[1] + coefs[2]*dat$x1[wh] +
  coefs[3]*dat$x2[wh] + coefs[4]*dat$x3[wh])^2) /
  sum((dat$y[wh] - mean(dat$y[wh]))^2)

## @knitr endchunk

#####################################################
# 4: Sparsity
#####################################################


## @knitr spam
require(spam)
mat = matrix(rnorm(1e8), 1e4)
mat[mat > (-2)] <- 0
sMat <- as.spam(mat)
print(object.size(mat), units = 'Mb') # 762.9 Mb
print(object.size(sMat), units = 'Mb') # 26 Mb

vec <- rnorm(1e4)
system.time(mat %*% vec)  # 0.385 seconds
system.time(sMat %*% vec) # 0.015 seconds

## @knitr 

#####################################################
# 6: Hadoop, MapReduce, and Spark
#####################################################

### 6.2 MapReduce and RHadoop

## @knitr mr-example

library(rmr)

mymap <- function(k, v) {
   record <- my_readline(v)
   key <- record[['state']]
   value <- record[['income']]
   keyval(key, value)
}

myreduce <- function(k, v){
   keyval(k, c(length(v), mean(v), sd(v)))
}

incomeResults <- mapreduce(
   input = "incomeData",
   map = mymap,
   reduce = myreduce,
   combine = NULL,
   input.format = 'csv',
   output.format = 'csv')

from.dfs(incomeResults, format = 'csv', structured = TRUE)

## @knitr null

### 6.3.14 sparklyr example

## @knitr sparklyr

## see unit8-bigData.sh for starting Spark
## also invoke:
## module load r r-packages

## local installation on your own computer
if(!require(sparklyr)) {
    install.packages("sparklyr")
    # spark_install() ## if spark not already installed
}

### connect to Spark ###

## need to increase memory otherwise get hard-to-interpret Java
## errors due to running out of memory; total memory on the node is 64 GB
conf <- spark_config()
conf$spark.driver.memory <- "8G"
conf$spark.executor.memory <- "50G"

# sc <- spark_connect(master = "local")  # if doing on laptop
sc <- spark_connect(master = Sys.getenv("SPARK_URL"),
                    config = conf)  # non-local

### read data in ###

cols <- c(date = 'numeric', hour = 'numeric', lang = 'character',
          page = 'character', hits = 'numeric', size = 'numeric')
          

## takes a while even with only 1.4 GB (zipped) input data (100 sec.)
wiki <- spark_read_csv(sc, "wikistats",
                       "/global/scratch/paciorek/wikistats/dated",
                       header = FALSE, delimiter = ' ',
                       columns = cols, infer_schema = FALSE)

head(wiki)
class(wiki)
dim(wiki)   # not all operations work on a spark dataframe

### some dplyr operations on the Spark dataset ### 

library(dplyr)

wiki_en <- wiki %>% filter(lang == "en")
head(wiki_en)

table <- wiki %>% group_by(lang) %>% summarize(count = n()) %>%
    arrange(desc(count))
## note the lazy evaluation: need to look at table to get computation to run
table
dim(table)
class(table)

### distributed apply ###

## need to use spark_apply to carry out arbitrary R code
## the function transforms a dataframe partition into a dataframe
## see help(spark_apply)
## 
## however this is _very_ slow, probably because it involves
## serializing objects between java and R
wiki_plus <- spark_apply(wiki, function(data) {
    data$obama = stringr::str_detect(data$page, "Barack_Obama")
    data
}, columns = c(colnames(wiki), 'obama'))

obama <- collect(wiki_plus %>% filter(obama))

### SQL queries ###

library(DBI)
## reference the Spark table (see spark_read_csv arguments)
## not the R tbl_spark interface object
wiki_en2 <- dbGetQuery(sc,
            "SELECT * FROM wikistats WHERE lang = 'en' LIMIT 10")
wiki_en2
