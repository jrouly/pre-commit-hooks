# scalafmt

This hook executes [scalafmt](https://scalameta.org/scalafmt/) on your Scala code files.

# Installation

You need to add `scalafmt` as a hook into your `.pre-commit-config`:
```yaml
- repo: git@github.com:AudaxHealthInc/pre-commit-hooks.git
  rev: vX.Y.Z
  hooks:
    - id: csv-formatter
    - id: scalafmt
```

# Configuration

This hook supports:
- [Rally default config](#default-configuration)
- [Solution specific configs](#solution-specific-configuration).

## Default Configuration

The [default config file](conf/default.conf) intends to be as close to the scalafmt defaults as possible while being as
opinionated as possible (meaning code should be formatted exactly the same way, every time, where possible).

| :notebook: The [default config file](conf/default.conf) should be preferred. |
|-----|

## Solution Specific Configuration

If a solution must provide its own config file it should be placed in the [`conf`](conf/) with a name that matches the
solution, e.g.`<solution>.conf`, and then specify that configuration in your hook configuration in `.pre-commit-config`.

For example if you add `conf/foo.conf` you need to update the scalafmt hook in `.pre-commit-config` like:
```yaml
...
    - id: scalafmt
        args: --conf-name=foo
```

# Updating scalafmt Version

1. Remove the old `scalafmt` versions [here](/), e.g.
     ```shell
     $ git rm scalafmt-*
     rm 'pre_commit_hooks/scalafmt/scalafmt-x.y.z'
     ```
1. Open [scalafmt.sh](../scalafmt.sh)
1. Update `SCALA_FMT_VERSION` to the new version
    1. If necessary you can also update `COURSIER_VERSION` to a newer version
1. Update the versions in the [configuration files](conf/), e.g.:
    ```hocon
    version = "x.y.z"
    ```
1. Run [`scalafmt-examples.sh`](../scalafmt-examples/README.md) to download the
new version of `scalafmt` (which may also download
[coursier](https://get-coursier.io/docs/cli-overview.html#specific-versions))
   ```shell
   $ pre_commit_hooks/scalafmt-examples/scalafmt-examples.sh
   Formatting with configuration pre_commit_hooks/scalafmt/conf/core.conf ...
     └ pre_commit_hooks/scalafmt-examples/confs/core/WhitespaceIsLava.scala
   Downloading coursier vA.B.C ...
   ########################################################################################## 100.0%
   Downloading scalafmt x.y.z using coursier ...
   Wrote /.../pre-commit-hooks/pre_commit_hooks/scalafmt/scalafmt-x.y.z
   Formatting with configuration pre_commit_hooks/scalafmt/conf/default.conf ...
     └ pre_commit_hooks/scalafmt-examples/confs/default/WhitespaceIsLava.scala
   Formatting with configuration pre_commit_hooks/scalafmt/conf/personalization.conf ...
     └ pre_commit_hooks/scalafmt-examples/confs/personalization/WhitespaceIsLava.scala
   ```
1. Add the new `scalafmt` versions to git, e.g.:
    ```shell
    $ git add -v scala-x.y.z
    add 'pre_commit_hooks/scalafmt/scalafmt-x.y.z'
    ```
1. Commit and push a PR

# Resources

- [scalafmt](https://scalameta.org/scalafmt/)
- [scalafmt Configuration](https://scalameta.org/scalafmt/docs/configuration.html).
