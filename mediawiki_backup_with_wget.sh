#!/bin/bash
#
# Explanation:
# `--adjust-extension`
# Add `.html` file extension to any files of type `application/xhtml + xml` or `text/html`.
# Add `.css` file extension to any files of type `text/css`.
#
# `--convert-links`
# Convert full links to relative.
#
# `--level=inf` (`-l inf`)
# Descend an infinite number of levels.
#
# `--mirror` (`-m`)
# Mirror the source (download only "changed" files, based on timestamp).
#
# `--page-requisities` (`-p`)
# Download any page prerequisites (images etc.).
#
# `--random-wait`
# Wait for (0.5 * `wait`) to (1.5 * `wait`) between requests.
#
# `--recursive` (`-r`)
# Recursively download the files.
#
# `--wait=1` (`-w 1`)
# Wait for 1 second between requests (randomised by `--random-wait`).
#

WEBSITE=wiki-oar.imag.fr
TOPURL=http://$WEBSITE

wget \
  --no-check-certificate \
  --adjust-extension \
  --convert-links \
  --level=inf \
  --mirror \
  --no-verbose \
  --page-requisites \
  --recursive \
  --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/39.0' \
  $TOPURL 2>&1 | perl -ne 's|^.*URL:(https?://.*?) .*|\1|; print "$1\n"' | tee -a log.txt

mkdir -p $WEBSITE/txt/

for page in $(grep "$WEBSITE/index.php/" log.txt | sed "s,^.*$WEBSITE/index.php/,," | grep -v Special: | grep -v File:)
do
wget -nv -O "$WEBSITE/txt/${page}.txt" "$TOPURL/index.php?index=$page&action=raw"
ln -sf "../txt/${page}.txt" "$WEBSITE/index.php/${page}.txt"
done
