# scalafmt-examples

Examples of scalafmt formatting, so we can see the effects in a PR and agree _before_ they get applied everywhere.

# Table of Contents

- [Overview](#overview)
- [Usage](#usage)
- [Notes](#notes)

# Overview

The script [`scalafmt-examples.sh`](scalafmt-examples.sh) will format a test code file
[`WhitespaceisLava.scala`](templates/WhitespaceIsLava.scala) using all [configurations](../scalafmt/conf).

The purpose of the script is to ensure that any PR that changes the formatting will contain a diff showing
the changes so everyone can see the effects before approving and merging.

# Usage

| :exclamation: You can only run  [`scalafmt-examples.sh`](scalafmt-examples.sh) from the [root](/). |
|-----|

The script will be run one for each configuration into a sub-directory under [`confs`](confs) with the same name as
the configuration. You can that then use `git diff` (or your favorite diff tool) to see the actual changes.

## Example

So if you have a configuration file `scalafmt/conf/foo.conf` running this script will format
[`WhitespaceisLava.scala`](templates/WhitespaceIsLava.scala) into `confs/foo/WhitespaceisLava.scala`

```shell script
$ pre_commit_hooks/scalafmt-examples/scalafmt-examples.sh
...
Formatting with configuration pre_commit_hooks/scalafmt/conf/foo.conf ...
  └ pre_commit_hooks/scalafmt-examples/confs/foo/WhitespaceIsLava.scala
...
```

# Notes

The [`scalafmt-examples.sh`](scalafmt-examples.sh) script will also be run via pre-commit so you can't mistakenly
forget to run this script.
