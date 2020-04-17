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

The [default config file](conf/default.conf) intends to be as close to the
scalafmt defaults as possible while being as opinionated as possible (meaning code should be formatted exactly the
same way, every time, where possible).

| :notebook: The [default config file](conf/default.conf) should be included as a base. |
|-----|

## Solution Specific Configuration

If a solution must provide its own config file it should be placed in the [`conf`](conf) with a name that matches the
solution, e.g.`<solution>.conf`, and then specify that configuration in your hook configuration in `.pre-commit-config`.

For example if you add `conf/foo.conf` you need to update the scalafmt hook in `.pre-commit-config` like:
```yaml
...
    - id: scalafmt
        args: --conf-name=foo
```

# Testing

Obviously making changes to a scalafmt configuration should be tested. To help with this we've created a "dirty"
un-formatted code file that can be formatted so you can see your changes here before committing. See
[scalafmt-examples](../scalafmt-examples/README.md) for more details.

# Updating scalafmt Version

We run `scalafmt` using [`coursier`](https://get-coursier.io/), so when you update `scalafmt` you should probably
update `coursier` at the same time:

1. Remove the old `coursier` and `scalafmt` versions [here](/), e.g.
     ```shell
     $ git rm scalafmt-*
     rm 'pre_commit_hooks/scalafmt/coursier-*'
     rm 'pre_commit_hooks/scalafmt/scalafmt-*'
     ```
1. Open [scalafmt.sh](../scalafmt.sh)
1. Update `COURSIER_VERSION` to the [new version](https://github.com/coursier/coursier/releases)
1. Update `SCALA_FMT_VERSION` to the [new version](https://github.com/scalameta/scalafmt/releases)
1. Update the `scalafmt` version in the [configuration files](conf), e.g.:
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
   ...
   ```
1. Add the new `coursier` and `scalafmt` versions to git, e.g.:
    ```shell
    $ git add coursier-*
    $ git add scalafmt-*
    ```
1. Commit and push a PR

# Resources

- [scalafmt](https://scalameta.org/scalafmt/)
- [scalafmt Configuration](https://scalameta.org/scalafmt/docs/configuration.html).
