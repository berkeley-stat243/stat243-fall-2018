Here are some instructions for installing Git on your computer. Git is the version control software we'll use in the course.

You can install Git by downloading and installing the correct binary from [here](http://git-scm.com/downloads).

Git comes installed on the SCF, so if you login to an SCF machine and want to use Git there, you don't need to install Git. 

Sidenotes on using Git with RStudio.

You can work with Git through RStudio via RStudio projects.

Here are some [instructions](http://www.molecularecologist.com/2013/11/using-github-with-r-and-rstudio/). Here are some helpful [guidelines from RStudio](https://support.rstudio.com/hc/en-us/articles/200532077-Version-Control-with-Git-and-SVN). 
  
You may need to tell RStudio where the Git executable is located as follows.
 
  * On Windows, the git executable should be installed somewhere like: `"C:/Program Files (x86)/Git/bin/git.exe"`
  * On MacOS X, you can locate the executable by executing the following in Terminal: `which git`
  * Once you locate the executable, you may then need to confirm that RStudio is looking in the right place. Go to "Tools -> Options -> Git/SVN -> Git executable" and confirm it has the correct information about the location of the git executable.
