# How to submit a change to plovr #

Changes to plovr are reviewed using [Rietveld](http://code.google.com/p/rietveld/), which runs on Google App Engine at http://codereview.appspot.com/.

The [upload.py](http://code.google.com/p/plovr/source/browse/upload.py) script that you need to use with Rietveld is in the root of the plovr repository. Therefore, in order to make a change and upload it to Rietveld, do the following:

```
# Clone the repository and navigate to it if you have not already done so.
hg clone https://code.google.com/p/plovr/
cd plovr

# Edit your local files to make your change and commit it.
hg commit

# Make sure that all build targets succeed:
ant all

# See what your tip revision number is, R.
# For example, if "hg tip" prints:
#
# changeset:   3103:d6db24beeb7f
# tag:         tip
# user:        Michael Bolin <bolinfest@gmail.com>
# date:        Tue Nov 08 00:23:59 2011 -0500
# summary:     Fix an error in the Ant target "serve-prod-documentation".
#
# then R would be 3103, the value before the colon.
hg tip

# Upload to codereview.appspot.com by specifiying the range of revisions.
# If you have just one commit, it is from R-1 to R.
# If the upper bound of the range is tip, then you can omit it from --rev:
python upload.py --base_url=https://code.google.com/p/plovr/ --rev=(R-1)

# The script will ask for an email address for a subject name for the code review,
# Google Account, and password. Once you enter this information, an issue will
# be created at http://codereview.appspot.com/#######. The ####### is the id for
# your code review.

# I have hardcoded values for the --send_mail and --reviewers flags so that I
# get sent the review by default.

# I receive an email for your code review. There will probably be a little
# back-and-forth. Perhaps you make an additional two local commits in
# response to the review. You should upload a new snapshot:
python upload.py --base_url=https://code.google.com/p/plovr/ --rev=(R-1):(R+1) --issue=#######

# upload.py will ask you for a name for this patchset. Often it will be
# something like: "Replying to comments".

# It is imperative to include the --issue option so that the original issue
# on codereview.appspot.com is updated.

# Once I declare the code review done, I will download the patch from
# codereview.appspot.com and commit it to plovr.
```