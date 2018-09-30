#########################################################
### Demo code for Unit 6 of Stat243, "Computer numbers"
### Chris Paciorek, October 2018
#########################################################

############################
# 1: Basic representations
############################

## @knitr char-bits

library(pryr)
bits('a')
bits('b')

bits('0')
bits('1')
bits('2')

bits('@')

## @knitr bits

library(pryr)
bits(0)
bytes(0)

bits(1L)
bytes(1L)

bits(2L)
bytes(2L)

bits(-1L)
bytes(-1L)

## @knitr not-closed

a <- as.integer(3423333)  # 3423333L
a * a

## @knitr storage

doubleVec <- rnorm(100000)
intVec <- 1:100000
set.seed(1)
charVec <- sample(letters, 100000, replace = TRUE)
object.size(doubleVec)
object.size(intVec) # so how many bytes per integer in R?
object.size(charVec)
charVec[1:5] <- c('a','a','b','b','c')
.Internal(inspect(charVec)) # anything jump out at you?

## @knitr int-max-bits
bits(.Machine$integer.max)
bits(-.Machine$integer.max)
bits(-1L)

## @knitr

############################
# 2: Floating point basics
############################

### 2.1 Representing real numbers

## @knitr imprecision

0.3 - 0.2 == 0.1
0.3
0.2
0.1 # Hmmm...



a <- 0.3
b <- 0.2
formatC(a, 20, format = 'f')
formatC(b, 20, format = 'f')
formatC(a - b, 20, format = 'f')
formatC(0.1, 20, format = 'f')
formatC(1/3, 20, format = 'f')
## so empirically, it looks like we're accurate up to the
##  16th decimal place

## alternative to formatC:
sprintf("%0.20f", a)

## define a wrapper function for convenience:
dg <- function(x, digits = 20) formatC(x, digits, format = 'f')

## @knitr machine-precision

dg(1e-16 + 1)
dg(1e-15 + 1)
dg(2e-16 + 1)
dg(.Machine$double.eps)
dg(.Machine$double.eps + 1)

## @knitr bits-floating

bits(2^(-1)) # 1/2
bits(2^0)  # 1
bits(2^1)  # 2
bits(2^2)  # 4

bits(-2)

## @knitr what-exact

dg(.1)
dg(.5)
dg(.25)
dg(.26)
dg(1/32)
dg(1/33)

## @knitr

### 2.2 Overflow and underflow

## @knitr double-max

log10(2^1024) # whoops ... we've actually just barely overflowed
log10(2^1023)

.Machine$double.xmax
.Machine$double.xmin

## @knitr

### 2.3 Integers or floats

## @knitr ints-represent

x <- 2^45
z <- 25
class(x)
class(z)
as.integer(x)
as.integer(z)

1e308
1e309

2^31
x <- 2147483647L
x
class(x)
x <- 2147483648L
class(x)

## @knitr force-ints

x <- 3; typeof(x)
x <- as.integer(3); typeof(x)
x <- 3L; typeof(x)
x <- 3:5; typeof(x)

## @knitr

### 2.4 Precision

## @knitr precision

# large vs. small numbers
dg(.1234123412341234)
dg(1234.1234123412341234) # not accurate to 16 places 
dg(123412341234.123412341234) # only accurate to 4 places 
dg(1234123412341234.123412341234) # no places! 
dg(12341234123412341234) # fewer than no places! 

## @knitr precision-implications

# How precision affects calculations
dg(1234567812345678 - 1234567812345677)
dg(12345678123456788888 - 12345678123456788887)
dg(12345678123456780000 - 12345678123456770000)
dg(.1234567812345678 - .1234567812345677)
dg(.12345678123456788888 - .12345678123456788887)
dg(.00001234567812345678 - .00001234567812345677)
# not as close as we'd expect, should be 1e-20
dg(.000012345678123456788888 - .000012345678123456788887)

dg(123456781234 - .0000123456781234)
## the correct answer is 123456781233.99998765....

## @knitr spacing-example

dg(1000000.1)

## @knitr spacing-ints

dgi <- function(x) formatC(x, digits = 20, format = 'g')

dgi(2^52)
dgi(2^52+1)
dgi(2^53)
dgi(2^53+1)
dgi(2^53+2)
dgi(2^54)
dgi(2^54+2)
dgi(2^54+4)

bits(2^53)
bits(2^53+1)
bits(2^53+2)
bits(2^54)
bits(2^54+2)
bits(2^54+4)

## @knitr spacing-doubles

dg(0.1234567812345678)
dg(0.12345678123456781)
dg(0.12345678123456782)
dg(0.12345678123456783)
dg(0.12345678123456784)

bits(0.1234567812345678)
bits(0.12345678123456781)
bits(0.12345678123456782)
bits(0.12345678123456783)
bits(0.12345678123456784)

## @knitr

### 2.5 Working with higher precision numbers

## @knitr higher-precision

require(Rmpfr)
piLong <- Const("pi", prec = 260) # pi "computed" to correct 260-bit precision 
piLong # nicely prints 80 digits 
mpfr(".1234567812345678", 40)
mpfr(".1234567812345678", 80)
mpfr(".1234567812345678", 600)

## @knitr

##################################################
# 3: Implications for calculation and comparisons
##################################################

### 3.1 Computer arithmetic is not mathematical arithmetic!

## @knitr non-associative

val1 <- 1/10; val2 <- 0.31; val3 <- 0.57
res1 <- val1*val2*val3
res2 <- val3*val2*val1
identical(res1, res2)
dg(res1)
dg(res2)

## @knitr

### 3.3 Comparisons

## @knitr comparisons

4L - 3L == 1L
4.0 - 3.0 == 1.0
4.1 - 3.1 == 1.0

## @knitr approx-equality

a = 12345678123456781000
b = 12345678123456782000

approxEqual = function(a, b){
  if(abs(a - b) < .Machine$double.eps * abs(a + b))
    print("approximately equal") else print ("not equal")
}

approxEqual(a,b)

a = 1234567812345678
b = 1234567812345677

approxEqual(a,b)   

## @knitr

### 3.4 Calculations

## @knitr catastrophic-cancel

# catastrophic cancellation w/ large numbers
dg(123456781234.56 - 123456781234.00)
# how many accurate decimal places?

## @knitr catastrophic-cancel-small

# catastrophic cancellation w/ small numbers
a = .000000000000123412341234
b = .000000000000123412340000

# so we know the right answer is .000000000000000000001234 EXACTLY

dg(a-b, 35)

## @knitr real-catastrophe

x <- c(-1, 0, 1) + 1e8
n <- length(x)
sum(x^2)-n*mean(x)^2  # that's not good!
sum((x - mean(x))^2)

## @knitr magnitude-diff

dg(123456781234 - 0.000001)

## @knitr

# part of the predictive density calculation example:
exp(-1000)

## @knitr numerical-linalg

xs <- 1:100
dists <- rdist(xs)
corMat <- exp(- (dists/10)^2) # this is a p.d. matrix (mathematically)
dg(eigen(corMat)$values[80:100])  # but not numerically


