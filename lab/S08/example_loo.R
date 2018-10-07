# --------------------------------------------------------------------------- #
#
# Data/Modeling Setup
#
# --------------------------------------------------------------------------- #

library(randomForest) # randomForest 4.6-12

## Training Set
set.seed(1)
n <- 500
p <- 50
X <- matrix(rnorm(n*p), nrow = n)
X <- data.frame(X)
Y <- X[, 1] + sqrt(abs(X[, 2] * X[, 3])) + X[, 2] - X[, 3] + rnorm(n)

looFit <- function(i, Y, X, loadLib = FALSE) {
  # Performs leave-one-out validation of a random forest, withholding the 
  # ith observation from the training set (Y, X).
  # 
  # Input
  #   i (integer): Observation to withhold from the training set
  #   Y (numeric): length-n vector of response values
  #   X (data frame): n x p design matrix
  #   loadLib (logical): indicates whether or not the randomForest library
  #     needs to be loaded
  # Output
  #   (numeric): Fitted value of the ith observation
  
  if (loadLib) library(randomForest)
  
  out <- randomForest(
    y = Y[-i], 
    x = X[-i, ], 
    xtest = X[i, ]
  )
  
  return(out$test$predicted)
}
  
# --------------------------------------------------------------------------- #
#
# Modeling Setup
#
# --------------------------------------------------------------------------- #
  
library(parallel)     # one of the core R packages
library(doParallel)
library(foreach)

# Windows users have to convert to integer or else it thinks this variable
# is vector of host names
nCores <- as.integer(Sys.getenv("SLURM_CPUS_ON_NODE"))
registerDoParallel(nCores)

nSub <- 30 # do only first 30 for this example.  Should actually be n

result <- foreach(i = 1:nSub,
                  .packages = c("randomForest"), # libraries to load onto each worker
                  .combine = c,                  # how to combine results
                  .verbose = TRUE) %dopar% {     # print statuses of each job
       
  cat('Starting ', i, 'th job.\n', sep = '')
  output <- looFit(i, Y, X)
  cat('Finishing ', i, 'th job.\n', sep = '')
  output # this will become part of the result object
  }

print(result[1:5])