# scalafmt-examples

Examples of scalafmt formatting so we can see the effects in a PR and agree _before_ they get applied everywhere.

# `scalafmt-examples.sh`

The script [`scalafmt-examples.sh`](scalafmt-examples.sh) will format a test code file
[`WhitespaceisLava.scala`](templates/WhitespaceIsLava.scala) using all [configurations](../scalafmt/conf).

| :exclamation: You can only run  [`scalafmt-examples.sh`](scalafmt-examples.sh) from the [root](/). |
|-----|

The purpose of the script is to ensure that any PR that changes the formatting will contain a diff showing
the changes so everyone can see the effects before approving and merging.

The script will be run one for each configuration into a sub-directory under [`confs`](confs/) with the same name as
the configuration. So if you have a configuration file `scalafmt/conf/foo.conf` running this script will format
[`WhitespaceisLava.scala`](templates/WhitespaceIsLava.scala) into `confs/foo/WhitespaceisLava.scala`

Example:
```shell
$ pre_commit_hooks/scalafmt-examples/scalafmt-examples.sh
Formatting for pre_commit_hooks/scalafmt/conf/personalization.conf ...
Formatting pre_commit_hooks/scalafmt-examples/confs/personalization/WhitespaceIsLava.scala ...
Formatting for pre_commit_hooks/scalafmt/conf/default.conf ...
Formatting pre_commit_hooks/scalafmt-examples/confs/default/WhitespaceIsLava.scala ...
Formatting for pre_commit_hooks/scalafmt/conf/core.conf ...
Formatting pre_commit_hooks/scalafmt-examples/confs/core/WhitespaceIsLava.scala ...
```

# Notes

The [`scalafmt-examples.sh`](scalafmt-examples.sh) script will also be run via pre-commit so you can't mistakenly
forget to run this script.
