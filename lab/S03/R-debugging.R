data <- read.csv('data.csv')

logitBoot <- function(y, x, nBoot = 500) {
  set.seed(1)
  out <- sapply(seq_len(nBoot), myglm, y, x)
  boot_se <- sd(out)
  return(boot_se)
}

myglm <- function(i, y, x) {
  n <- length(y)
  if(i==48) browser()
  ind <- sample(seq_len(n), n, replace = TRUE)
  out <- glm(y[ind]~x[ind], family='binomial')
  return(out$coef[2])
}

mod <- glm(y ~ x, data = data, family = 'binomial')
summary(mod)
## note that the standard error for the regression coefficient is ~3

logitBoot(y, x)
