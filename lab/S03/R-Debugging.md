Debugging In R
================
Omid Shams Solari
9/11/2018

Debugging `gamma_jackknife()`
-----------------------------

Material is based on [Chris's tutorial on debugging](https://github.com/berkeley-scf/tutorial-R-debugging) along with an example.

Let's walk through the debugging procedure of the function `gamma_jackknife()` in `debuggingJackKnifeEst.R`.

A More Involved Example: `logitBoot()`
--------------------------------------

-   Load `data.csv`
-   Fit a logistic regression model `y~x` called `mod` in the script provided.
-   What is the std of the coefficient of `x` from `summary(mod)`?
-   Now find the estimate of the same parameter now using bootstrap by simply calling `logitBoot()` as provided in the script.
-   Why is this estimate so much larger?
-   Use debugging tools to figure out the bug.
