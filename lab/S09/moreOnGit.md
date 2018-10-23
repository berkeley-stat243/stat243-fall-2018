More On GIT
================
Omid Shams Solari
10/23/2018

> ### Objectives
>
> -   How to import a new project into Git
> -   Make changes to a git repo
> -   Share changes with other developers

### Getting Help

You can get documentation for a command such as `git log --graph` with:

``` bash
man git-log
```

    ## GIT-LOG(1)                        Git Manual                        GIT-LOG(1)
    ## 
    ## 
    ## 
    ## NNAAMMEE
    ##        git-log - Show commit logs
    ## 
    ## SSYYNNOOPPSSIISS
    ##        _g_i_t _l_o_g [<options>] [<revision range>] [[--] <path>...]
    ## 
    ## 
    ## DDEESSCCRRIIPPTTIIOONN
    ##        Shows the commit logs.
    ## 
    ##        The command takes options applicable to the ggiitt rreevv--lliisstt command to
    ##        control what is shown and how, and options applicable to the ggiitt ddiiffff--**
    ##        commands to control how the changes each commit introduces are shown.
    ## 
    ## OOPPTTIIOONNSS
    ##        --follow
    ...

or

``` bash
git help log
```

You can introduce yourself to Git with your name and public email address before doing any operation. The easiest way to do so is:

``` bash
git config --global user.name "osolari"
git config --global user.email solari@berkeley.edu
```

### Importing A Project

Assume you have a tarball linReg.tar.gz with your initial work. You can place it under Git revision control as follows.

``` bash
tar xzf project.tar.gz
cd project
git init
```

Git will reply

``` bash
Initialized empty Git repository in .git/
```

You've now initialized the working directory-you may notice a new directory created, named ".git".

Next, tell Git to take a snapshot of the contents of all files under the current directory (note the .), with git add:

``` bash
git add .
```

This snapshot is now stored in a temporary staging area which Git calls the *index*. You can permanently store the contents of the index in the repository with `git commit`:

``` bash
git commit -m "add"
```

This will prompt you for a commit message. You've now stored the first version of your project in Git.

### Making Changes

``` bash
git add file1 file2 file3
```

You are now ready to commit. You can see what is about to be committed using `git diff` with the `--cached` option:

``` bash
git diff --cached
```

(Without --cached, git diff will show you any changes that you've made but not yet added to the index.)

You can also get a brief summary of the situation with `git status`:

``` bash
git status
```

Alternatively, instead of running `git add` before `git commit`, you can use:

``` bash
git commit -a
```

which will automatically notice any modified (but not new) files, add them to the index, and commit, all in one step.

### Git Tracks Contents, Not Files

Many revision control systems provide an `add` command that tells the system to start tracking changes to a new file. Git's `add` command does something simpler and more powerful: `git add` is used both for new and newly modified files, and in both cases it takes a snapshot of the given files and stages that content in the index, ready for inclusion in the next commit.

### Viewing Project History

At any point you can view the history of your changes using:

``` bash
git log
```

If you also want to see complete diffs at each step, use

``` bash
git log -p
```

Often the overview of the change is useful to get a feel of each step:

``` bash
git log --stat --summary
```

### Managing Branches

A single Git repository can maintain multiple branches of development. To create a new branch named "experimental", use

``` bash
git branch experimental
```

If you now run

``` bash
git branch
```

The "experimental" branch is the one you just created, and the "master" branch is a default branch that was created for you automatically. The asterisk marks the branch you are currently on; type

``` bash
git checkout experimental
```

to switch to the experimental branch. Now edit a file, commit the change, and switch back to the master branch:

``` bash
git commit -a "edit"
git checkout master
```

Check that the change you made is no longer visible, since it was made on the experimental branch and you're back on the master branch.

You can make a different change on the master branch and commit. At this point the two branches have diverged, with different changes made in each. To merge the changes made in experimental into master, run:

``` bash
git merge experimental
```

If the changes don't conflict, you're done. If there are conflicts, markers will be left in the problematic files showing the conflict;

``` bash
git diff
```

Do you have a clear idea now what changes cause conflicts?

will show this. Once you've edited the files to resolve the conflicts,

``` bash
git commit -a
```

will commit the result of the merge. Finally,

``` bash
gitk
```

will show a nice graphical representation of the resulting history.

At this point you could delete the experimental branch with

``` bash
git branch -d experimental
```

This command ensures that the changes in the experimental branch are already in the current branch.

If you develop on a branch `secretions-of-a-sick-mind`, then regret it, you can always delete the branch with

``` bash
git branch -D crazy-idea
```

### Using Git For Collaboration

Suppose that Ugur has started a new project with a Git repository in /home/ugur/project, and that Omid, who has a home directory on the same machine, wants to contribute.

This creates a new directory "myrepo" containing a clone of Ugur's repository. The clone is on an equal footing with the original project, possessing its own copy of the original project's history. Omid then makes some changes and commits them. When he's ready, he tells Ugur to pull changes from the repository at /home/omid/myrepo. He does this with:

``` bash
ugur$ cd /home/ugur/project
ugur$ git pull /home/omid/myrepo master
```

This merges the changes from Omid's "master" branch into Ugur's current branch. If Ugur has made her own changes in the meantime, then he may need to manually fix any conflicts.

The `pull` command thus performs two operations: it fetches changes from a remote branch, then merges them into the current branch.

Note that in general, Ugur would want his local changes committed before initiating this `pull`. If Omid's work conflicts with what Ugur did since their histories forked, Ugur will use his working tree and the index to resolve conflicts, and existing local changes will interfere with the conflict resolution process (Git will still perform the fetch but will refuse to merge --- Ugur will have to get rid of his local changes in some way and pull again when this happens).

Ugur can peek at what Omid did without merging first, using the "fetch" command; this allows Ugur to inspect what Omid did, using a special symbol "FETCH\_HEAD", in order to determine if he has anything worth pulling, like this:

``` bash
ugur$ git fetch /home/omid/myrepo master
ugur$ git log -p HEAD..FETCH_HEAD
```

This operation is safe even if Ugur has uncommitted local changes. The range notation "HEAD..FETCH\_HEAD" means "show everything that is reachable from the FETCH\_HEAD but exclude anything that is reachable from HEAD". Ugur already knows everything that leads to his current state (HEAD), and reviews what Omid has in his state (FETCH\_HEAD) that he has not seen with this command.

If Ugur wants to visualize what Omid did since their histories forked he can issue the following command:

``` bash
gitk HEAD..FETCH_HEAD
```

Ugur may want to view what both of them did since they forked. He can use three-dot form instead of the two-dot form:

``` bash
gitk HEAD...FETCH_HEAD
```

This means "show everything that is reachable from either one, but exclude anything that is reachable from both of them".

Please note that these range notation can be used with both gitk and `git log`.

After inspecting what Omid did, if there is nothing urgent, Ugur may decide to continue working without pulling from Omid If Omid's history does have something Ugur would immediately need, he may choose to stash his work-in-progress first, do a `pull`, and then finally unstash his work-in-progress on top of the resulting history.

When you are working in a small closely knit group, it is not unusual to interact with the same repository over and over again. By defining remote repository shorthand, you can make it easier:

``` bash
ugur$ git remote add omid /home/omid/myrepo
```

With this, Ugur can perform the first part of the `pull` operation alone using the git fetch command without merging them with his own branch, using:

``` bash
ugur$ git fetch omid
```

Unlike the longhand form, when Ugur fetches from Omid using a remote repository shorthand set up with git remote, what was fetched is stored in a remote-tracking branch, in this case omid/master. So after this:

``` bash
ugur$ git log -p master..omid/master
```

shows a list of all the changes that Omid made since he branched from Ugur's master branch.

After examining those changes, Ugur could merge the changes into his master branch:

``` bash
ugur$ git merge omid/master
```

This merge can also be done by pulling from his own remote-tracking branch, like this:

``` bash
ugur$ git pull . remotes/omid/master
```

Note that git pull always merges into the current branch, regardless of what else is given on the command line.

Later, Omid can update his repo with Ugur's latest changes using

``` bash
omid$ git pull
```

Note that he doesn't need to give the path to Ugur's repository; when Omid cloned Ugur's repository, Git stored the location of his repository in the repository configuration, and that location is used for pulls:

``` bash
omid$ git config --get remote.origin.url 
```

/home/ugur/project

Git also keeps a pristine copy of Ugur's master branch under the name "origin/master":

``` bash
omid$ git branch -r
```

``` bash
ugur$ git fetch omid
```
