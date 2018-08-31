##################################################
### Demo code for Unit 3 of Stat243,
### "Data input/output and webscraping"
### Chris Paciorek, August 2018
##################################################

## @knitr

#####################################################
# 2: Reading data from text files into R
#####################################################

### 2.1 Core R functions

## @knitr readcsv
dat <- read.table(file.path('..', 'data', 'RTADataSub.csv'),
                  sep = ',', head = TRUE)
sapply(dat, class)
## whoops, there is an 'x', presumably indicating missingness:
levels(dat[ ,2])
## let's treat 'x' as a missing value indicator
dat2 <- read.table(file.path('..', 'data', 'RTADataSub.csv'),
                   sep = ',', head = TRUE,
   na.strings = c("NA", "x"), stringsAsFactors = FALSE)
unique(dat2[ ,2])
## hmmm, what happened to the blank values this time?
which(dat[ ,2] == "")
dat2[which(dat[, 2] == "")[1], ] # pull out a line with a missing string

# using 'colClasses'
sequ <- read.table(file.path('..', 'data', 'hivSequ.csv'),
  sep = ',', header = TRUE,
  colClasses = c('integer','integer','character',
    'character','numeric','integer'))
## let's make sure the coercion worked - sometimes R is obstinant
sapply(sequ, class)
## that made use of the fact that a data frame is a list

## @knitr readLines
dat <- readLines(file.path('..', 'data', 'precip.txt'))
id <- as.factor(substring(dat, 4, 11) )
year <- substring(dat, 18, 21)
year[1:5]
class(year)
year <- as.integer(substring(dat, 18, 21))
month <- as.integer(substring(dat, 22, 23))
nvalues <- as.integer(substring(dat, 28, 30))

## @knitr connections
dat <- readLines(pipe("ls -al"))
dat <- read.table(pipe("unzip dat.zip"))
dat <- read.csv(gzfile("dat.csv.gz"))
dat <- readLines("http://www.stat.berkeley.edu/~paciorek/index.html")

## @knitr curl
wikip1 <- readLines("https://wikipedia.org")
wikip2 <- readLines(url("https://wikipedia.org"))
library(curl)
wikip3 <- readLines(curl("https://wikipedia.org"))

## @knitr streaming
con <- file(file.path("..", "data", "precip.txt"), "r")
## "r" for 'read' - you can also open files for writing with "w"
## (or "a" for appending)
class(con)
blockSize <- 1000 # obviously this would be large in any real application
nLines <- 300000
for(i in 1:ceiling(nLines / blockSize)){
    lines <- readLines(con, n = blockSize)
    # manipulate the lines and store the key stuff
}
close(con)

## @knitr stream-curl
URL <- "https://www.stat.berkeley.edu/share/paciorek/2008.csv.gz"
con <- gzcon(curl(URL, open = "r"))
## url() in place of curl() works too
for(i in 1:8) {
	print(i)
	print(system.time(tmp <- readLines(con, n = 100000)))
	print(tmp[1])
}
close(con)

## @knitr text-connection
dat <- readLines('../data/precip.txt')
con <- textConnection(dat[1], "r")
read.fwf(con, c(3,8,4,2,4,2))

## @knitr

### 2.2 File paths

## @knitr relative-paths

dat <- read.csv('../data/cpds.csv')

## @knitr path-separators

## good: will work on Windows
dat <- read.csv('../data/cpds.csv')
## bad: won't work on Mac or Linux
dat <- read.csv('..\\data\\cpds.csv')  

## @knitr file.path

## good: operating-system independent
dat <- read.csv(file.path('..', 'data', 'cpds.csv'))  

## @knitr 

### 2.3 The readr package

## @knitr readr
library(readr)
## I'm violating the rule about absolute paths here!!
## (airline.csv is big enough that I don't want to put it in the
##    course repository)
setwd('~/staff/workshops/r-bootcamp-2018/data') 
system.time(dat <- read.csv('airline.csv', stringsAsFactors = FALSE)) 
system.time(dat2 <- read_csv('airline.csv'))

## @knitr

#####################################################
# 3: Webscraping and working with XML and JSON
#####################################################

## 3.1 Reading HTML 

## @knitr https
library(rvest)  # uses xml2
URL <- "https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population"
html <- read_html(URL)
tbls <- html_table(html_nodes(html, "table"))
sapply(tbls, nrow)
pop <- tbls[[2]]
head(pop)

## @knitr https-pipe
library(magrittr)
tbls <- URL %>% read_html("table") %>% html_table()

## @knitr https-old
## XML package appears to be unmaintained
library(XML)  
library(curl)
URL <- "https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population"
html <- readLines(URL)
## alternative
## library(RCurl); html <- getURLContent(URL)
tbls <- readHTMLTable(html)
sapply(tbls, nrow)
pop <- readHTMLTable(html, which = 2)
head(pop)

## @knitr htmlLinks

URL <- "http://www1.ncdc.noaa.gov/pub/data/ghcn/daily/by_year"
## approach 1: search for elements with href attribute
links <- read_html(URL) %>% html_nodes("[href]") %>% html_attr('href')
## approach 2: search for HTML 'a' tags
links <- read_html(URL) %>% html_nodes("a") %>% html_attr('href')
head(links, n = 10)

## @knitr htmlLinks-old
URL <- "http://www1.ncdc.noaa.gov/pub/data/ghcn/daily/by_year"
html <- readLines(URL)
links <- getHTMLLinks(html)
head(links, n = 10)

links <- getHTMLLinks(html, baseURL = URL, relative = FALSE)
head(links, n = 10)

## @knitr XPath
## find all 'a' nodes that have attribute href; then
## extract the 'href' attribute
links <- read_html(URL) %>% html_nodes(xpath = "//a[@href]") %>%
    html_attr('href')
head(links)

## we can extract various information
listOfANodes <- read_html(URL) %>% html_nodes(xpath = "//a[@href]")
listOfANodes %>% html_attr('href') %>% head(n = 10)
listOfANodes %>% html_name() %>% head(n = 10)
listOfANodes %>% html_text()  %>% head(n = 10)

## @knitr XPath-old
tutorials <- htmlParse("http://statistics.berkeley.edu/computing/training/tutorials")
listOfANodes <- getNodeSet(tutorials, "//a[@href]")
head(listOfANodes)
sapply(listOfANodes, xmlGetAttr, "href")[1:10]
sapply(listOfANodes, xmlValue)[1:10]

## @knitr XPath2
URL <- "https://www.nytimes.com"
headlines <- read_html(URL) %>% html_nodes("h2") %>% html_text()
head(headlines)

## @knitr XPath2-old
doc <- htmlParse(readLines("https://www.nytimes.com"))
storyDivs <- getNodeSet(doc, "//h2")
sapply(storyDivs, xmlValue)[1:5]


## @knitr

### 3.2 XML

## @knitr xml
library(xml2)
doc <- read_xml("https://api.kivaws.org/v1/loans/newest.xml")
data <- as_list(doc)
names(data)
names(data$response)
length(data$response$loans)
data$response$loans[[2]][c('name', 'activity',
                           'sector', 'location', 'loan_amount')]

## alternatively, extract only the 'loans' info (and use pipes)
loansNode <- doc %>% xml_nodes('loans')
loanInfo <- loansNode %>% xml_children() %>% as_list()
length(loanInfo)
names(loanInfo[[1]])
names(loanInfo[[1]]$location)

## suppose we only want the country locations of the loans (using XPath)
xml_find_all(loansNode, '//location//country') %>% xml_text()

## or extract the geographic coordinates
xml_find_all(loansNode, '//location//geo/pairs')

## @knitr xml-old
doc <- xmlParse("http://api.kivaws.org/v1/loans/newest.xml")
data <- xmlToList(doc, addAttributes = FALSE)
names(data)
length(data$loans)
data$loans[[2]][c('name', 'activity', 'sector', 'location', 'loan_amount')]
## let's try to get the loan data into a data frame
loansNode <- xmlRoot(doc)[["loans"]]
length(xmlChildren(loansNode))
loans <- xmlToDataFrame(xmlChildren(loansNode))
dim(loans)
head(loans)
## suppose we only want the country locations of the loans
countries <- sapply(xmlChildren(loansNode), function(node) 
   xmlValue(node[['location']][['country']]))
countries[1:10]
## this fails because node is not a standard list:
countries <- sapply(xmlChildren(loansNode), function(node) 
   xmlValue(node$location$country)) 


## @knitr

### 3.3 Reading JSON

## @knitr json
library(jsonlite)
data <- fromJSON("http://api.kivaws.org/v1/loans/newest.json")
names(data)
class(data$loans) # nice!
head(data$loans)

## @knitr

### 3.4 Using web APIs to get data

### 3.4.1 HTTP requests

## @knitr http-byURL

## example URL:
##"http://data.un.org/Handlers/DownloadHandler.ashx?DataFilter=
##itemCode:526;year:2003,2004,2005,2006,2007&DataMartId=FAO&
##Format=csv&c=2,3,4,5,6,7&s=countryName:asc"
itemCode <- 526
baseURL <- "http://data.un.org/Handlers/DownloadHandler.ashx"
yrs <- paste(as.character(2003:2007), collapse = ",")
filter <- paste0("?DataFilter=itemCode:", itemCode, ";year:", yrs)
args1 <- "&DataMartId=FAO&Format=csv&c=2,3,4,5,6,7&"
args2 <- "s=countryName:asc,elementCode:asc,year:desc"
url <- paste0(baseURL, filter, args1, args2)
## if the website provided a CSV we could just do this:
## apricots <- read.csv(url)
## but it zips the file
temp <- tempfile()  ## give name for a temporary file
download.file(url, temp)
dat <- read.csv(unzip(temp))  ## using a connection (see Section 2)

head(dat)
                     

## @knitr http-get2
library(httr)
output2 <- GET(baseURL, query = list(
               DataFilter = paste0("itemCode:", itemCode, ";year:", yrs),
               DataMartID = "FAO", Format = "csv", c = "2,3,4,5,6,7",
               s = "countryName:asc,elementCode:asc,year:desc"))
temp <- tempfile()  ## give name for a temporary file
writeBin(content(output2, 'raw'), temp)  ## write out as zip file
dat <- read.csv(unzip(temp))
head(dat)

## @knitr http-get2-old

output1 <- getForm(baseURL,
               DataFilter = paste0("itemCode:", itemCode, ";year:", yrs),
               DataMartID = "FAO", Format = "csv", c = "2,3,4,5,6,7",
               s = "countryName:asc,elementCode:asc,year:desc")
class(output1)
## not sure how to get output1 into a file

## @knitr http-post
if(url.exists('http://www.wormbase.org/db/searches/advanced/dumper')) {
      x = postForm('http://www.wormbase.org/db/searches/advanced/dumper',
              species="briggsae",
              list="",
              flank3="0",
              flank5="0",
              feature="Gene Models",
              dump = "Plain TEXT",
              orientation = "Relative to feature",
              relative = "Chromsome",
              DNA ="flanking sequences only",
              .cgifields = paste(c("feature", "orientation", "DNA",
                                   "dump","relative"), collapse=", "))

## @knitr

### 3.4.2 REST- and SOAP-based web services

## @knitr REST
times <- c(2080, 2099)
countryCode <- 'USA'
baseURL <- "http://climatedataapi.worldbank.org/climateweb/rest/v1/country"
##" http://climatedataapi.worldbank.org/climateweb/rest/v1/country"
type <- "mavg"
var <- "pr"
data <- read.csv(paste(baseURL, type, var, times[1], times[2],
                       paste0(countryCode, '.csv'), sep = '/'))
head(data)

## @knitr

#####################################################
# 4: Output from R
#####################################################

### 4.2 Formatting output

## @knitr print
val <- 1.5
cat('My value is ', val, '.\n', sep = '')
print(paste('My value is ', val, '.', sep = ''))

## @knitr cat

## input
x <- 7
n <- 5
## display powers
cat("Powers of", x, "\n")
cat("exponent   result\n\n")
result <- 1
for (i in 1:n) {
	result <- result * x
	cat(format(i, width = 8), format(result, width = 10),
            "\n", sep = "")
}
x <- 7
n <- 5
## display powers
cat("Powers of", x, "\n")
cat("exponent result\n\n")
result <- 1
for (i in 1:n) {
	result <- result * x
	cat(i, '\t', result, '\n', sep = '')
}

## @knitr sprintf
temps <- c(12.5, 37.234324, 1342434324.79997234, 2.3456e-6, 1e10)
sprintf("%9.4f C", temps)
city <- "Boston"
sprintf("The temperature in %s was %.4f C.", city, temps[1])
sprintf("The temperature in %s was %9.4f C.", city, temps[1])

## @knitr

#####################################################
# 5: File and string encodings
#####################################################

## @knitr ascii

## 39 in hexadecimal is '9'
## 0a is a newline (at least in Linux/Mac)
## 3a is ':'     
x <- as.raw(c('0x39','0x0a','0x3a'))  ## i.e., "9\n:" in ascii
writeBin(x, 'tmp.txt')
readLines('tmp.txt')
system('ls -l tmp.txt', intern = TRUE)
system('cat tmp.txt')

## @knitr unicode-example

euro <- '\u20ac' # Euro currency symbol as Unicode 'code point'
Encoding(euro) 
euro
writeBin(euro, 'tmp2.txt')
system('ls -l tmp2.txt') ## here the euro takes up four bytes
## so the system knows how to interpret the UTF-8 encoded file
## and represent the Unicode character on the screen:
system('cat tmp2.txt')

## @knitr locale
Sys.getlocale()

## @knitr iconv
text <- "_Melhore sua seguran\xe7a_"
Encoding(text)
Encoding(text) <- "latin1"
text

text <- "_Melhore sua seguran\xe7a_"
textUTF8 <- iconv(text, from = "latin1", to = "UTF-8")
Encoding(textUTF8)
textUTF8
iconv(text, from = "latin1", to = "ASCII", sub = "???")

## @knitr encoding
x <- "fa\xE7ile" 
Encoding(x) <- "latin1" 
x
## playing around... 
x <- "\xa1 \xa2 \xa3 \xf1 \xf2" 
Encoding(x) <- "latin1" 
x 

## @knitr encoding-error
load('../data/IPs.RData') # loads in an object named 'text'
tmp <- substring(text, 1, 15)
## the issue occurs with the 6402th element (found by trial and error):
tmp <- substring(text[1:6401],1,15)
tmp <- substring(text[1:6402],1,15)
text[6402] # note the Latin-1 character

table(Encoding(text))
## Option 1
Encoding(text) <- "latin1"
tmp <- substring(text, 1, 15)
tmp[6402]
## Option 2
load('../data/IPs.RData') # loads in an object named 'text'
tmp <- substring(text, 1, 15)
text <- iconv(text, from = "latin1", to = "UTF-8")
tmp <- substring(text, 1, 15)

