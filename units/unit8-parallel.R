############################################################
### Demo code for Unit 8 of Stat243, "Parallel processing"
### Chris Paciorek, October 2018
############################################################

##########################################################
# 4: Illustrating the principles in specific case studies
##########################################################

### 4.1 Scenario 1: one model fit

## @knitr ranger

args(ranger::ranger)

## @knitr R-linalg

library(RhpcBLASctl)
x <- matrix(rnorm(5000^2), 5000)

blas_set_num_threads(4)
system.time({
   x <- crossprod(x)
   U <- chol(x)
})

##   user  system elapsed 
##  8.316   2.260   2.692 

blas_set_num_threads(1)
system.time({
   x <- crossprod(x)
   U <- chol(x)
})

##   user  system elapsed 
##  6.360   0.036   6.399 

## @knitr

### 4.2 Scenario 2: three different prediction methods

## @knitr mcparallel

library(parallel)
n <- 10000000
system.time({
	p <- mcparallel(mean(rnorm(n)))
	q <- mcparallel(mean(rgamma(n, shape = 1)))
	s <- mcparallel(mean(rt(n, df = 3)))
	res <- mccollect(list(p,q, s))
})

system.time({
	p <- mean(rnorm(n))
	q <- mean(rgamma(n, shape = 1))
	s <- mean(rt(n, df = 3))
})

## @knitr

### 4.3 Scenario 3: cross-validation

## @knitr rf-example

library(randomForest)

cvFit <- function(foldIdx, folds, Y, X, loadLib = FALSE) {
    if(loadLib)
        library(randomForest)
    out <- randomForest(y = Y[folds != foldIdx],
                        x = X[folds != foldIdx, ],
                        xtest = X[folds == foldIdx, ])
    return(out$test$predicted)
}

set.seed(23432)
## training set
n <- 1000
p <- 50
X <- matrix(rnorm(n*p), nrow = n, ncol = p)
colnames(X) <- paste("X", 1:p, sep="")
X <- data.frame(X)
Y <- X[, 1] + sqrt(abs(X[, 2] * X[, 3])) + X[, 2] - X[, 3] + rnorm(n)
nFolds <- 10
folds <- sample(rep(seq_len(nFolds), each = n/nFolds), replace = FALSE)

## @knitr foreach

library(doParallel)  # uses parallel package, a core R package

nCores <- 4  
registerDoParallel(nCores) 

result <- foreach(i = seq_len(nFolds)) %dopar% {
	cat('Starting ', i, 'th job.\n', sep = '')
	output <- cvFit(i, folds, Y, X)
	cat('Finishing ', i, 'th job.\n', sep = '')
	output # this will become part of the out object
}

length(list)
result[[1]][1:5]

## @knitr parallel-lsApply

library(parallel)
nCores <- 4  
cl <- makeCluster(nCores) 

## clusterExport(cl, c('x', 'y')) # if the processes need objects
## from main R workspace (not needed here as no global vars used)

input <- seq_len(nFolds)

## need to load randomForest package within function
## when using par{L,S}apply, the last) argument being
## set to TRUE causes this to happen (see cvFit())
system.time(
	res <- parSapply(cl, input, cvFit, folds, Y, X, loadLib = TRUE) 
)
system.time(
	res2 <- sapply(input, cvFit, folds, Y, X)
)

## @knitr

### 4.4 Scenario 4: parallelizing over multiple prediction methods

## @knitr parallel-mclapply-no-preschedule

library(parallel)

nCores <- 4

## specifically designed to be slow when have four cores and 
## and use prescheduling, because
## the slow tasks all assigned to one worker
n <- rep(c(1e7, 1e5, 1e5, 1e5), 4)


fun <- function(n) {
    cat("working on ", n, "\n")
    mean(rnorm(n))
}

system.time(
	res <- mclapply(n, fun, mc.cores = nCores) 
)
system.time(
	res <- mclapply(n, fun, mc.cores = nCores, mc.preschedule = FALSE) 
)

## @knitr

### 4.5 Scenario 5: many tasks

## @knitr doSNOW

library(doSNOW)

## Specify the machines you have access to and
##    number of cores to use on each:
machines = c(rep("beren.berkeley.edu", 1),
    rep("gandalf.berkeley.edu", 1),
    rep("arwen.berkeley.edu", 2))

## On Savio and other clusters using the SLURM scheduler:
## machines <- system('srun hostname', intern = TRUE)

cl = makeCluster(machines, type = "SOCK")
cl

registerDoSNOW(cl)

fun = function(i, n = 1e6)
  out = mean(rnorm(n))

nTasks <- 120

print(system.time(out <- foreach(i = 1:nTasks) %dopar% {
	outSub <- fun(i)
	outSub # this will become part of the out object
}))

stopCluster(cl)  

## @knitr sockets

library(parallel)

machines = c(rep("beren.berkeley.edu", 1),
    rep("gandalf.berkeley.edu", 1),
    rep("arwen.berkeley.edu", 2))
cl = makeCluster(machines)
cl

n = 1e7
## copy global variable to workers
clusterExport(cl, c('n'))

fun = function(i)
  out = mean(rnorm(n))
  
result <- parSapply(cl, 1:20, fun)

result[1:5]

stopCluster(cl) 

## @knitr

### 4.6 Scenario 6: stratified analysis on a large dataset

## @knitr parallel-copy

library(parallel)

testfun <- function(i, data, ids) {
    return(mean(data[ids[[i]], 2]))
}

nStrata <- 100
n <- 3e7
data <- cbind(rep(seq_len(nStrata), each = n/nStrata), rnorm(n))
object.size(data)

ids <- lapply(seq_len(nStrata), function(i) which(data[,1] == i))

## in terminal monitor memory use with: watch -n 0.1 free -h

cl <- makeCluster(4)
parSapply(cl, seq_len(nStrata), testfun, data, ids)
stopCluster(cl)

## @knitr parallel-nocopy

testfun_global <- function(i) {
    return(mean(data[ids[[i]], 2]))
}
   
## in terminal monitor memory use with: watch -n 0.1 free -h

## Forked processes do not make copies of 'data'
cl <- makeCluster(4, type = "FORK")
parSapply(cl, seq_len(nStrata), testfun_global)
stopCluster(cl)

## To contrast, we see what happens if not using
## a fork-based cluster.
## Note that this would also require exporting the global variable(s).

cl <- makeCluster(4)
## This errors because 'data' not available on workers
parSapply(cl, seq_len(nStrata), testfun_global)  
clusterExport(cl, 'data')
parSapply(cl, seq_len(nStrata), testfun_global)
stopCluster(cl)

## @knitr

### 4.7 Scenario 7: Simulation study and parallel RNG

## @knitr RNG-apply

library(parallel)
library(rlecuyer)

nSims <- 250
taskFun <- function(i){
	val <- runif(1)
	return(val)
}

nCores <- 4
RNGkind()
cl <- makeCluster(nCores)
iseed <- 1
clusterSetRNGStream(cl = cl, iseed = iseed)
RNGkind() # clusterSetRNGStream sets RNGkind as L'Ecuyer-CMRG
## but it doesn't show up here on the master
res <- parSapply(cl, 1:nSims, taskFun)
## now redo with same master seed to see results are the same
clusterSetRNGStream(cl = cl, iseed = iseed)
res2 <- parSapply(cl, 1:nSims, taskFun)
identical(res,res2)
stopCluster(cl)


