linReg <- function(X, y){
  
  # Add intercept column to X
  X <- cbind(rep(1, length(y)), X)
  
  # Implement closed-form solution
  betas <- solve(t(X) %*% X) %*% t(X) %*% y
  
  return(betas)
}