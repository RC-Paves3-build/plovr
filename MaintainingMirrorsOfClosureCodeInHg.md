# Introduction #

The plovr repository contains mirrored versions of the Closure Tools (Library, Compiler, Templates) repositories. The mirror for each tool is maintained in its own branch, and all changes from each branch are merged into the default branch of plovr. Any modifications to the source of the Closure Tools that are necessary for plovr are maintained in the default branch. This has two important advantages:

  * By containing the source code for all of the Closure Tools in plovr, it is possible to build plovr without any external dependencies.
  * This makes it far easier to maintain the changes to the Closure Tools that are necessary for plovr. For example, the published Closure Compiler and Closure Templates jars are built using different versions of [Guava](http://code.google.com/p/guava-libraries/), so rather than include their binaries in plovr, they are compiled directly into plovr with a recent Guava release.

Maintaining these mirrors and merging their changes into the default branch requires a bit of setup, though once the procedure is in place, it is easy to follow. This page documents the setup commands, as other projects may want to set up a similar system.

This setup was originally devised by Ilia Mirkin for the purpose of maintaining our own version of the Closure Library at Yext so that we could keep Yext-specific patches on top of incoming changes to the Closure Library. The [closure-library option in plovr](http://plovr.com/options.html#closure-library) is designed to make it possible to use plovr with a forked version of the Closure Library.

# Setup #

Here we will go through an example of setting up the branch for the Closure Library.

## Create a Local Repository ##

Ironically, the first step is to create a local SVN repository of the Closure Library repository. Note that this is not a local _checkout_, but a local _repository_. This is because the [hg convert extension](http://mercurial.selenic.com/wiki/ConvertExtension) that is instrumental in setting up the mirror requires a lot of communication with an SVN repository, so it is excruciatingly slow to create the mirror from a remote repository.

The following steps are based off of those provided in the documentation for using the
[hg convert extension with an SVN repository](http://mercurial.selenic.com/wiki/ConvertExtension#Working_around_Network_and_Bindings_Issues):

```
cd ~
svnadmin create closure-library-mirror
echo '#!/bin/sh' > closure-library-mirror/hooks/pre-revprop-change
chmod +x closure-library-mirror/hooks/pre-revprop-change
svnsync init file://`pwd`/closure-library-mirror http://closure-library.googlecode.com/svn/trunk/
svnsync sync file://`pwd`/closure-library-mirror
```

## Change the UUID of the Local Repository ##

The next step is critical and does not appear in the [hg convert documentation](http://mercurial.selenic.com/wiki/ConvertExtension#Working_around_Network_and_Bindings_Issues), which is to change the UUID of your local repository to match that of the remote repository. To see what the current UUID of your local repository is, run:

```
svnlook uuid closure-library-mirror
```

which should print out something like:

```
c58d5b2e-e0dc-4f3c-e794-7be0ce408061
```

To determine the UUID of the remote closure-library repository,grab it from the `svn info` command:

```
svn info http://closure-library.googlecode.com/svn/trunk/ | awk '/Repository UUID/{print $3}'
```

This should print:

```
0b95b8e8-c90f-11de-9d4f-f947ee5921c8
```

Then to set it, run:

```
svnadmin setuuid closure-library-mirror 0b95b8e8-c90f-11de-9d4f-f947ee5921c8
```

To make sure it succeeded, run the `svnlook` command again:

```
svnlook uuid closure-library-mirror
```

which should display `0b95b8e8-c90f-11de-9d4f-f947ee5921c8`, as you would expect.

## Use hg convert with the Local Repository ##

First, you need to enable the `hg convert` extension if you have not done so already. Do this by adding the following to your `.hgrc` file:

```
[extensions]
hgext.convert =
```

We will use `hg convert` to:

  * Create the `closure-library` branch in our repository.
  * Take commits from the remote SVN closure-library repository and push them as changes on the `closure-library` branch in our repository.

Because we will be running `hg convert` periodically to get new changes from the remote repository, we store the `hg convert` command in a script, `update.sh`. As you can see, `update.sh` is stored under `tools/imports` in the default branch, as are the other two files it uses, `branchmap` and `filemap`.

The contents of [update.sh](http://plovr.googlecode.com/hg/tools/imports/closure-library/update.sh) are:
```
#!/bin/sh

SVNREPO=${SVNREPO:-http://closure-library.googlecode.com/svn/}
BRANCH="closure-library"

HG=${HG:-hg}
HGROOT=${HGROOT:-$(${HG} root)}

${HG} convert \
  --branchmap ${HGROOT}/tools/imports/${BRANCH}/branchmap \
  --filemap ${HGROOT}/tools/imports/${BRANCH}/filemap \
  ${SVNREPO} \
  ${HGROOT} \
  ${HGROOT}/tools/imports/${BRANCH}/shamap
```

Note that there are two other files that are used as arguments to `hg convert`, which are `branchmap` and `filemap`. The contents of [branchmap](http://plovr.googlecode.com/hg/tools/imports/closure-library/branchmap) are:

```
 closure-library
```

(There is deliberately a leading single space in front of `closure-library` in case white space gets gunked up.)

The contents of [filemap](http://plovr.googlecode.com/hg/tools/imports/closure-library/filemap) are:

```
rename "." "closure/closure-library"
```

In the steady state, we will pull changes from the remote repository, but for the initial branch creation, we will pull changes from the local repository, so run `update.sh` with the value of `SVNREPO` modified as follows:

```
cd PATH/TO/PLOVR/
chmod +x tools/imports/closure-library/update.sh
SVNREPO=file:///home/$USER/closure-library-mirror/ tools/imports/closure-library/update.sh
```

After running this command for the first time, you should see one Hg changeset for each SVN commit. (This also has the side-effect of creating the `closure-library` branch.) Run `hg out` to see the list of changes.

You also likely have the following uncommitted files, which you can see from running `hg status`:

```
? tools/imports/closure-library/branchmap
? tools/imports/closure-library/filemap
? tools/imports/closure-library/shamap
? tools/imports/closure-library/update.sh
```

Three of these files you have created, but `shamap` was created as a byproduct of `hg convert`. This file contains metadata about which changes from the remote SVN repository have already been imported.

**After running `update.sh`, you must always commit the updated version of `shamap`, as well. If you fail to do so, subsequent executions of `update.sh` will not work correctly.**

Therefore, be sure to add these files and commit them:

```
hg add tools/imports/closure-library/
hg commit -m "Scripts for pulling changes from closure-library SVN repository."
```

When you push after running `update.sh` for the first time, you will have to use the `--new-branch` flag because you are creating a new remote branch, `closure-library`.

```
hg push --new-branch
```

Now that you have used your local copy of the Closure Library repository to do your initial import, you do not need it anymore, so you can delete `~/closure-library-mirror`. In the future, to pull down the recent changes to the remote Closure Library repository, run:

```
tools/imports/closure-library/update.sh
hg commit -m "Pull latest changes from Closure Library SVN repository." tools/imports/closure-library/shamap
```

## Merge Changes From the Mirrored Branch Into the Default Branch ##

The final step is to merge the changes from the `closure-library` branch into the `default` branch. By merging the changeset that is the tip of the `closure-library` branch, it will pull all of its parent changesets with it.

The first step is to determine the tip revision of the `closure-library` branch, which you can do by running `hg heads`. This will print something like:

```
changeset:   621:4dde21cef9cd
branch:      closure-library
tag:         tip
user:        ankit@google.com
date:        Thu Dec 30 01:41:09 2010 +0000
summary:     Automated g4 rollback.
```

As you can see, the tip is `4dde21cef9cd`, so merging is simply a matter of running the `hg merge` command and committing the merge:

```
hg merge -r 4dde21cef9cd
hg commit -m "merge from closure-library branch"
```

Now the directory `closure/closure-library` is available in your working copy!

## Steady State Maintenance ##

Once you have set all of this up, you will want to create a script to take care of updating a branch and merging it into the default branch. In plovr, such a script is available in the repository ([./scripts/update-repository.sh](http://code.google.com/p/plovr/source/browse/scripts/update-repository.sh)):

```
#!/bin/bash
#
# Use this script to update the specified Closure Tool. Usage:
#
# ./scripts/update-repository.sh closure-library

HG=${HG:-hg}
HGROOT=${HGROOT:-$(${HG} root)}

# Make sure that exactly one argument is specified.
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "Must specify one of: closure-library, closure-compiler, closure-templates"
  exit 1
fi

# Make sure that the argument correctly identifies a repository.
REPOSITORY=$1
if [ ! -d "${HGROOT}/tools/imports/${REPOSITORY}" ]; then
  echo "No repository for ${REPOSITORY}"
  exit 1
fi

REVISION=`svn info http://${REPOSITORY}.googlecode.com/svn/ | \
    grep Revision | awk '{print $2}'`

cd ${HGROOT}
tools/imports/${REPOSITORY}/update.sh
hg commit -m "Pull latest changes from ${REPOSITORY} SVN repository at r${REVISION}." \
    tools/imports/${REPOSITORY}/shamap

# REV is something like 1648:af131e4e3231
REV=`hg branches | grep ${REPOSITORY} | awk '{print $2}'`

# REV2 will be the part after the colon: af131e4e3231
REV2=`echo $REV | awk -F ":" '{print $2}'`

hg merge -r $REV2
hg commit -m "merge from ${REPOSITORY} branch at ${REPOSITORY} revision ${REVISION}"

echo "merge from ${REPOSITORY} committed: run hg push to check in"
```