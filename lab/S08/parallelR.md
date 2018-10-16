Parallel R
================
Omid Shams Solari
10/16/2018

Many tasks that are computationally expensive are embarrassingly parallel. Here are a few common tasks that fit the description:

-   Bootstrapping
-   Cross-validation
-   Multivariate Imputation by Chained Equations (MICE)
-   Fitting multiple regression models

`lapply` Refresher
------------------

`lapply` takes one parameter (a vector/list), feeds that variable into the function, and returns a list:

``` r
lapply(1:3, function(x) c(x, x^2, x^3))
```

    ## [[1]]
    ## [1] 1 1 1
    ## 
    ## [[2]]
    ## [1] 2 4 8
    ## 
    ## [[3]]
    ## [1]  3  9 27

You can feed it additional values by adding named parameters:

``` r
lapply(1:3/3, round, digits=3)
```

    ## [[1]]
    ## [1] 0.333
    ## 
    ## [[2]]
    ## [1] 0.667
    ## 
    ## [[3]]
    ## [1] 1

These tasks are embarrassingly parallel as the elements are calculated independently, i.e. second element is independent of the result from the first element. After learning to code using `lapply` parallelizing your code is simple.

`parallel` Package
------------------

The `parallel` package is basically about doing the above in parallel. The main difference is that we need to start with setting up a cluster, a collection of "workers"" that will be doing the job. The suggested upper limit on the number of clusters is the numbers of `cores - 1`. Using all cores on my machine will cause the machine to come to a standstill until the R task has finished. One therefore may set up the cluster as follows:

``` r
library(parallel)
 
# Calculate the number of cores
no_cores <- detectCores() - 1
 
# Initiate cluster
cl <- makeCluster(no_cores)
```

Now we just call the parallel version of `lapply`, `parLapply`:

``` r
parLapply(cl, 2:4, function(exponent) 2^exponent)
```

    ## [[1]]
    ## [1] 4
    ## 
    ## [[2]]
    ## [1] 8
    ## 
    ## [[3]]
    ## [1] 16

Once we are done we need to close the cluster so that resources such as memory are returned to the operating system.

``` r
stopCluster(cl)
```

### Variable Scope

On Mac/Linux you have the option of using `makeCluster(no_core, type="FORK")` that automatically contains all environment variables (more details on this below). On Windows you have to use the Parallel Socket Cluster (PSOCK) that starts out with only the base packages loaded (note that PSOCK is default on all systems). You should therefore always specify exactly what variables and libraries that you need for the parallel function to work, e.g. the following fails:

``` r
cl<-makeCluster(no_cores)
base <- 2
 
parLapply(cl, 
          2:4, 
          function(exponent) 
            base^exponent)
```

    ## Error in checkForRemoteErrors(val): 3 nodes produced errors; first error: object 'base' not found

``` r
stopCluster(cl)
```

This one is correct:

``` r
cl<-makeCluster(no_cores)
 
base <- 2
clusterExport(cl, "base")
parLapply(cl, 
          2:4, 
          function(exponent) 
            base^exponent)
```

    ## [[1]]
    ## [1] 4
    ## 
    ## [[2]]
    ## [1] 8
    ## 
    ## [[3]]
    ## [1] 16

``` r
stopCluster(cl)
```

Note that you need the `clusterExport(cl, "base")` in order for the function to see the base variable. If you are using some special packages you will similarly need to load those through `clusterEvalQ`, e.g. `clusterEvalQ(cl, library(rms))` to load the `rms` package. Note that any changes to the variable after clusterExport are ignored:

``` r
cl<-makeCluster(no_cores)
clusterExport(cl, "base")
base <- 4
# Run
parLapply(cl, 
          2:4, 
          function(exponent) 
            base^exponent)
```

    ## [[1]]
    ## [1] 4
    ## 
    ## [[2]]
    ## [1] 8
    ## 
    ## [[3]]
    ## [1] 16

``` r
# Finish
stopCluster(cl)
```

### Using `parSapply`

Sometimes we only want to return a simple value and directly get it processed as a vector/matrix.

``` r
cl<-makeCluster(no_cores)
clusterExport(cl, "base")
parSapply(cl, 2:4, function(exponent) base^exponent)
```

    ## [1]  16  64 256

``` r
stopCluster(cl)
```

Matrix output with names (this is why we need the `as.character`):

``` r
cl<-makeCluster(no_cores)
clusterExport(cl, "base")
parSapply(cl, as.character(2:4), 
          function(exponent){
            x <- as.numeric(exponent)
            c(base = base^x, self = x^x)
          })
```

    ##       2  3   4
    ## base 16 64 256
    ## self  4 27 256

``` r
stopCluster(cl)
```

The `foreach` Package
---------------------

The idea behind the `foreach` package is to create 'a hybrid of the standard for loop and lapply function' and its ease of use has made it rather popular. The set-up is slightly different, you need "register" the cluster as below:

``` r
library(foreach)
library(doParallel)
```

    ## Loading required package: iterators

``` r
cl<-makeCluster(no_cores)
registerDoParallel(cl)
stopCluster(cl)
```

Note that you can change the last two lines to:

``` r
registerDoParallel(no_cores)
```

But then you need to remember to instead of stopCluster() at the end do:

``` r
stopImplicitCluster()
```

The `foreach` function can be viewed as being a more controlled version of the `parSapply` that allows combining the results into a suitable format. By specifying the `.combine` argument we can choose how to combine our results, below is a vector, matrix, and a list example:

``` r
base <- 2
cl<-makeCluster(no_cores)
registerDoParallel(cl)
foreach(exponent = 2:4, 
        .combine = c)  %dopar%  
  base^exponent
```

    ## [1]  4  8 16

``` r
stopCluster(cl)
```

Now using `rbind`

``` r
base <- 2
cl<-makeCluster(no_cores)
registerDoParallel(cl)
foreach(exponent = 2:4, 
        .combine = rbind)  %dopar%  
  base^exponent
```

    ##          [,1]
    ## result.1    4
    ## result.2    8
    ## result.3   16

``` r
stopCluster(cl)
```

Now a list,

``` r
base <- 2
cl<-makeCluster(no_cores)
registerDoParallel(cl)
foreach(exponent = 2:4, 
        .combine = list,
        .multicombine = TRUE)  %dopar%  
  base^exponent
```

    ## [[1]]
    ## [1] 4
    ## 
    ## [[2]]
    ## [1] 8
    ## 
    ## [[3]]
    ## [1] 16

``` r
stopCluster(cl)
```

Note that the last is the default and can be achieved without any tweaking, just `foreach(exponent = 2:4) %dopar%`. In the example it is worth noting the `.multicombine` argument that is needed to avoid a nested list. The nesting occurs due to the sequential `.combine` function calls, i.e. `list(list(result.1, result.2), result.3)`:

``` r
base <- 2
cl<-makeCluster(no_cores)
registerDoParallel(cl)
foreach(exponent = 2:4, 
        .combine = list,
        .multicombine = FALSE)  %dopar%  
  base^exponent
```

    ## [[1]]
    ## [[1]][[1]]
    ## [1] 4
    ## 
    ## [[1]][[2]]
    ## [1] 8
    ## 
    ## 
    ## [[2]]
    ## [1] 16

``` r
stopCluster(cl)
```

### Variable Scope

The variable scope constraints are slightly different for the `foreach` package. Variable within the same local environment are by default available:

``` r
base <- 2
cl<-makeCluster(2)
registerDoParallel(cl)
foreach(exponent = 2:4, 
        .combine = c)  %dopar%  
  base^exponent
```

    ## [1]  4  8 16

``` r
stopCluster(cl)
```

While variables from a parent environment will not be available, i.e. the following will throw an error:

``` r
test <- function (exponent) {
  foreach(exponent = 2:4, 
          .combine = c)  %dopar%  
    base^exponent
}
cl<-makeCluster(2)
registerDoParallel(cl)
test()
```

    ## Error in base^exponent: task 1 failed - "object 'base' not found"

``` r
stopCluster(cl)
```

A nice feature is that you can use the `.export` option instead of the `clusterExport`. Note that as it is part of the parallel call it will have the latest version of the variable, i.e. the following change in "base" will work:

``` r
base <- 2
cl<-makeCluster(2)
registerDoParallel(cl)
 
base <- 4
test <- function (exponent) {
  foreach(exponent = 2:4, 
          .combine = c,
          .export = "base")  %dopar%  
    base^exponent
}
test()
```

    ## [1]  16  64 256

``` r
stopCluster(cl)
```

Similarly you can load packages with the .packages option, e.g. `.packages = c("rms", "mice")`. I strongly recommend always exporting the variables you need as it limits issues that arise when encapsulating the code within functions.

Memory Handling
---------------

Unless you are using multiple computers or Windows or planning on sharing your code with someone using a Windows machine, you should try to use `FORK` option. It is leaner on the memory usage by linking to the same address space. Below you can see that the memory address space for variables exported to PSOCK are not the same as the original:

``` r
library(pryr, quietly = TRUE) # Used for memory analyses
a <- "o"
cl<-makeCluster(no_cores)
clusterExport(cl, "a")
clusterEvalQ(cl, library(pryr))
```

    ## [[1]]
    ## [1] "pryr"      "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [7] "methods"   "base"     
    ## 
    ## [[2]]
    ## [1] "pryr"      "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [7] "methods"   "base"     
    ## 
    ## [[3]]
    ## [1] "pryr"      "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [7] "methods"   "base"     
    ## 
    ## [[4]]
    ## [1] "pryr"      "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [7] "methods"   "base"     
    ## 
    ## [[5]]
    ## [1] "pryr"      "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [7] "methods"   "base"     
    ## 
    ## [[6]]
    ## [1] "pryr"      "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [7] "methods"   "base"     
    ## 
    ## [[7]]
    ## [1] "pryr"      "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [7] "methods"   "base"

``` r
parSapply(cl, X = 1:10, function(x) {address(a)}) == address(a)
```

    ##  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE

``` r
stopCluster(cl)
```

While they are for FORK clusters:

``` r
cl<-makeCluster(no_cores, type="FORK")
parSapply(cl, X = 1:10, function(x) address(a)) == address(a)
```

    ##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE

``` r
stopCluster(cl)
```

Now move on to `intro.md`
