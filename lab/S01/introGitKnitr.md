Introduction to knitr & git
================
Omid Shams Solari
8/28/2018

Thanks to Dr. Sanchez and the Berkeley SCF upon whose tutorials, the following material is based.

Basic Bash shell commands
-------------------------

> ### Learning Objectives
>
> -   Practicing with the command line
> -   Navigating the filesystem and managing files
> -   Practice basic manipulation of data files

The first part of the lab involves navigating the file system and manipulating files (and directories) with the following basic bash commands:

-   `pwd`: print working directory
-   `ls`: list files and directories
-   `cd`: change directory (move to another directory)
-   `mkdir`: create a new directory
-   `touch`: create a new (empty) file
-   `cp`: copy file(s)
-   `mv`: rename file(s)
-   `rm`: delete file(s)

Your turn
---------

Write your bash commands in a text editor (NOT a word processor) and save them in a text file: e.g. `S01.txt`.

-   Open (or launch) the command line
-   Use `mkdir` to create a new directory `stat243-S01`
-   Change to the directory `stat243-S01`
-   Use the command `curl` to download the following text file:

    ``` bash
    # the option is the letter O (Not the number 0)
    curl -O http://textfiles.com/food/bread.txt
    ```

-   Use the command `ls` to list the contents in your current directory
-   Use the command `curl` to download these other text files:
    -   <http://textfiles.com/food/btaco.txt>
    -   <http://textfiles.com/food/1st_aid.txt>
    -   <http://textfiles.com/food/beesherb.txt>
-   Use the command `curl` to download the following csv files:
    -   <http://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv>
    -   <http://www.math.uah.edu/stat/data/Fisher.csv>
    -   <http://web.pdx.edu/~gerbing/data/cars.csv>
-   Now try `ls -l` to list the contents in your current directory in long format
-   Look at the `man` documentation of `ls` to find out how to list the contents in reverse order
-   How would you list the contents in long format and by time?
-   Inside `stat243-S01` create a directory `data`
-   Change to the directory `data`
-   Create a directory `txt-files`
-   Create a directory `csv-files`
-   Use the command `mv` to move the `bread.txt` file to the folder `txt-files`
-   Use the wildcard `*` to move all the text files to the directory `txt-files`
-   Use the wildcard `*` to move all the `.csv` files to the directory `csv-files`
-   Go back to the parent directory `stat243-S01`
-   Create a directory `copies`
-   Use the command `cp` to copy the `bread.txt` file (the one inside the folder `txt-files`) to the `copies` directory
-   Use the wildcard `*` to copy all the `.txt` files in the directory `copies`
-   Use the wildcard `*` to copy all the `.csv` files in the directory `copies`
-   Change to the directory `copies`
-   Use the command `mv` to rename the file `bread.txt` as `bread-recipe.txt`
-   Rename the file `Fisher.csv` as `iris.csv`
-   Rename the file `btaco.txt` as `breakfast-taco.txt`
-   Change to the parent directory (i.e. `stat243-S01`)
-   Rename the directory `copies` as `copy-files`
-   Find out how to use the `rm` command to delete the directory `copy-files`
-   List the contents of the directory `txt-files` displaying the results in reverse (alphabetical) order

Git and GitHub Practice
=======================

> ### Learning Objectives
>
> -   Create a GitHub repository
> -   Create a local Git repository
> -   Practice adding, and committing changes to your (local) Git repo
> -   Practice pushing commited changes to a remote repo

A nice tutorial is available on the [Berkeley SCF github repo](https://github.com/berkeley-scf/tutorial-git-basics).

    git clone https://github.com/berkeley-scf/tutorial-git-basics

There are two ways to start a repository:

-   create the repository on Github using your browser and then use `git clone`
-   use `git init` on your machine and then linking it to a remote server e.g. github.

### 1) Create a New GitHub Repository

-   Open your browser and Sign in to your github account.
-   Locate the `+` button (next to your avatar).
-   Select the `New repository` option.
-   Choose a name for your repository: e.g. `demo-repo`.
-   In the **Description** field add a brief description: e.g. "this is a demo repo"
-   Use the default settings, and click the green button **Create repository**.

Let's go through the following code chunk in detail.

``` bash
echo "# Demo Repo" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/osolari/demo-repo.git
git push -u origin master
```

### 2) Create a local Git Repository

-   Open the terminal (Mac Terminal, or Git-Bash for Windows users).
-   Optional: change directory to your preferred location e.g. your `Desktop`

    ``` bash
    cd Desktop
    ```

-   Create a directory with the name of your github repo

    ``` bash
    mkdir demo-repo
    ```

-   Change to the directory you just created

    ``` bash
    cd demo-repo
    ```

-   Initialize the directory as a git repository

    ``` bash
    git init
    ```

It's possible that you encounter some error message, e.g. Mac users may get a message related with a missing component for `CommandLineTools`. If this your case, then type in the terminal console:

``` bash
# Mac users may need to run this command
xcode-select --install
```

The command `git init` will set-up your directory `demo-repo` as a Git repository (NOT to confuse with your GitHub repository). This is basically your **local** repository.

### 3) Adding a README file

-   It is customary to add a `README.md` file at the top level. This file must contain (at least) a description of what the repository is about. The following command will create a `README.md` file with some minimalist content:

    ``` bash
    echo "# Demo Repo" >> README.md
    ```

-   So far there you have a "new" file in your local repo, but this change has not been recorded by Git. You can confirm this by checking the status of the repo:

    ``` bash
    git status
    ```

-   Notice that Git knows that `README.md` is untracked. So let's add the changes to Git's database:

    ``` bash
    git add README.md
    ```

-   Check the status of the repo again:

    ``` bash
    git status
    ```

-   Now Git is tracking the file `README.md`.
-   Next thing consists of **committing** the changes

    ``` bash
    git commit -m "first commit"
    ```

### 4) Adding a remote

Right now you have a (local) Git repository in your computer. And you also have a GitHub repository in your GitHub account. Both repositories should have the same name, and the goal is to link them. To do this, you need to tell Git that a *remote* repository (i.e. the one in GitHub) will be added:

-   To add a remote repository use the command below **with your own username**:

    ``` bash
    git remote add origin https://github.com/username/demo-repo.git
    ```

-   Verify your new remote

    ``` bash
    git remote -v
    ```

-   If everything is okay, you should be able to see a message (with your own username) like this:

        # Verify new remote
        origin  https://github.com/username/demo-repo.git (fetch)
        origin  https://github.com/username/demo-repo.git (push)

### 5) Pushing changes to a remote repo

-   Now that you have linked your local repo with your remote repo, you can start pushing (i.e. uploading) commits to GitHub.
-   As part of the basic workflow with git and github, you want to constantly check the status of your repo

        git status

-   Now let's push your recent commit to the remote branch (`origin`) from the local branch (`master`):

    ``` bash
    git push origin master
    ```

-   Go to your Github repository and refresh the browser. If everything went fine, you should be able to see the contents of your customized `README.md` file.

------------------------------------------------------------------------

Introduction to R Markdown files
--------------------------------

> ### Learning Objectives:
>
> -   Differentiate between `.R` and `.Rmd` files
> -   To understand dynamic documents
> -   To gain familiarity with R Markdown `.Rmd` files
> -   To gain familiarity with code chunks

------------------------------------------------------------------------

Besides using R script files to write source code, you will be using other type of source files known as *R markdown* files.

### 1) Opening and knitting an `Rmd` file

In the menu bar of RStudio, click on **File**, then **New File**, and choose **R Markdown**. Select the default option (Document), and click **Ok**. RStudio will open a new `.Rmd` file in the source pane. And you should be able to see a file with some default content.

Locate the button **Knit HTML**, the one with an icon of a ball of yarn and two needles. Click the button (knit to HTML) so you can see how `Rmd` files are rendered and displayed as HTML documents. Alternatively, you can use a keyboard shortcut: in Mac `Command+Shift+K`, in Windows `Ctrl+Shift+K`

### 2) What is an `Rmd` file?

**Rmd** files are a special type of file, referred to as a *dynamic document*. This is the fancy term we use to describe a document that allows us to combine narrative (text) with R code in one single file.

Rmd files are plain text files. This means that you can open an Rmd file with any text editor (not just RStudio) and being able to see and edit its contents.

The main idea behind dynamic documents is simple yet very powerful: instead of working with two separate files, one that contains the R code, and another one that contains the narrative, you use an `.Rmd` file to include both the commands and the narrative.

One of the main advantages of this paradigm, is that you avoid having to copy results from your computations and paste them into a report file. In fact, there are more complex ways to work with dynamic documents and source files. But the core idea is the same: combine narrative and code in a way that you let the computer do the manual, repetitive, and time consuming job.

Rmd files is just one type of dynamic document that you will find in RStudio. In fact, RStudio provides other file formats that can be used as dynamic documents: e.g. `.Rnw`, `.Rpres`, `.Rhtml`, etc.

### 3) Anatomy of an `Rmd` file

The structure of an `.Rmd` file can be divided in two parts: 1) a **YAML header**, and 2) the **body** of the document. In addition to this structure, you should know that `.Rmd` files use three types of syntaxes: YAML, Markdown, and R.

The *YAML header* consists of the first few lines at the top of the file. This header is established by a set of three dashes `---` as delimiters (one starting set, and one ending set). This part of the file requires you to use YAML syntax (Yet Another Markup Language.) Within the delimiter sets of dashes, you specify settings (or metadata) that will apply to the entire document. Some of the common options are things like:

-   `title`
-   `author`
-   `date`
-   `output`

The *body* of the document is everything below the YAML header. It consists of a mix of narrative and R code. All the text that is narrative is written in a markup syntax called **Markdown** (although you can also use LaTeX math notation). In turn, all the text that is code is written in R syntax inside *blocks of code*.

There are two types of blocks of code: 1) **code chunks**, and 2) **inline code**. Code chunks are lines of text separated from any lines of narrative text. Inline code is code inserted within a line of narrative text .

### 4) How does an Rmd file work?

Rmd files are plain text files. All that matters is the syntax of its content. The content is basically divided in the header, and the body.

-   The header uses YAML syntax.
-   The narrative in the body uses Markdown syntax.
-   The code and commands use R syntax.

The process to generate a nice rendered document from an Rmd file is known as **knitting**. When you *knit* an Rmd file, various R packages and programs run behind the scenes. But the process can be broken down in three main phases: 1) Parsing, 2) Execution, and 3) Rendering.

1.  Parsing: the content of the file is parsed (examined line by line) and each component is identified as yaml header, or as markdown text, or as R code.

Each component receives a special treatment and formatting.

The most interesting part is in the pieces of text that are R code. Those are separated and executed if necessary. The commands may be included in the final document. Also, the output may be included in the final document. Sometimes, nothing is executed nor included.

Depending on the specified output format (e.g. HTML, pdf, word), all the components are assembled, and one single document is generated.

### 5) Yet Another Syntax to Learn

R markdown (`Rmd`) files use [markdown](https://daringfireball.net/projects/markdown/) as the main syntax to write content. Markdown is a very lightweight type of markup language, and it is relatively easy to learn.

One of the most common sources of confusion when learning about R and Rmd files has to do with the hash symbol `#`. As you know, `#` is the character used by R to indicate comments. The issue is that the `#` character has a different meaning in markdown syntax. Hashes in markdown are used to define levels of headings.

In an Rmd file, a hash `#` that is inside a code chunk will be treated as an R comment. A hash outside a code chunk, will be treated as markdown syntax, making its associated text a given type of heading.

6) Code chunks
--------------

There are dozens of options available to control the executation of the code, the formatting and display of both the commands and the output, the display of images, graphs, and tables, and other fancy things. Here's a list of the basic options you should become familiar with:

-   `eval`: whether the code should be evaluated
    -   `TRUE`
    -   `FALSE`
-   `echo`: whether the code should be displayed
    -   `TRUE`
    -   `FALSE`
    -   numbers indicating lines in a chunk
-   `error`: whether to stop execution if there is an error
    -   `TRUE`
    -   `FALSE`
-   `results`: how to display the output
    -   `markup`
    -   `asis`
    -   `hold`
    -   `hide`
-   `comment`: character used to indicate output lines
    -   the default is a double hash `##`
    -   `""` empty character (to have a cleaner display)

Consult the [R Markdown cheatsheet](https://www.rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf) for syntax clarification.

------------------------------------------------------------------------

Submitting problem sets
-----------------------

We will go over submitting problem sets. You can find more info at `howtos/submitting-electronically.txt` in this repo.
