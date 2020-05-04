# scalafmt

This hook executes [scalafmt](https://scalameta.org/scalafmt/) on your Scala code files.

# Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
    - [Modify existing configurations](#modifying-exist-configurations)
    - [Adding new configurations](#adding-new-configuration)
- [Testing](#testing)
- [Updating scalafmt Version](#updating-scalafmt-version)
- [Resources](#resources)

# Installation

You need to add `scalafmt` as a hook into your `.pre-commit-config`:
```yaml
- repo: git@github.com:AudaxHealthInc/pre-commit-hooks.git
  rev: vX.Y.Z
  hooks:
    - id: scalafmt
      args: [--conf-name=default]
```
# Configuration

This hook supports:
- [Rally default config](#default-configuration)
- [Solution specific configs](#solution-specific-configuration).

| File | Description | Base |
| ---- | ----------- | ---- |
| [`compact.conf`](conf/compact.conf) | Default with tweaks for a more compact vie (i.e. 80 columns). | [`default.conf`](conf/default.conf) |
| [`core.conf`](conf/core.conf) | Core solution's configuration. | [`default.conf`](conf/default.conf) |
| [`default.conf`](conf/default.conf) | Rally's standard Scala format, defined by many passionate and heated discussions. | |
| [`personalization.conf`](conf/personalization.conf) | Personalization solution's configuration. | [`default.conf`](conf/default.conf) |
| [`scala-lang-org-style.conf`](conf/scala-lang-org-style.conf) | Configuration based on [Scala Lang's Style Guide](https://docs.scala-lang.org/style/). | |

## Modifying exist configurations

Be _very_ careful when modifying existing configurations! Repositories are likely using that configuration, and if
you update the configuration you might introduce unexpected changes to the users of that configuration -- few people
will appreciate making a one-line change and end up with a PR that re-formats every file in the repository.

## Adding new configuration

If there is good reason for creating a new config file it should be placed in the [`conf`](conf) with a name that
matches the purpose, e.g. `<solution>.conf`, and then specify that configuration in your hook configuration in
`.pre-commit-config`.

For example if you add `conf/foo.conf` you need to update the scalafmt hook in `.pre-commit-config` like:
```yaml
...
    - id: scalafmt
        args: --conf-name=foo
```

The [default config file](conf/default.conf) intends to be a default that you can extend and make tweaks. Consider
using the [default config file](conf/default.conf) as a base.

# Testing

Obviously making changes to a scalafmt configuration should be tested. To help with this we've created a "dirty"
un-formatted code file that can be formatted so you can see your changes here before committing. See
[scalafmt-examples](../scalafmt-examples/README.md) for more details.

# Updating scalafmt Version

When you update `scalafmt` you should

1. Remove the old `scalafmt` versions [here](/), e.g.
     ```shell
     $ git rm scalafmt-*
     rm 'pre_commit_hooks/scalafmt/scalafmt-*'
     ```
2. Open [scalafmt.sh](../scalafmt.sh)
3. Update `SCALA_FMT_VERSION` to the [new version](https://github.com/scalameta/scalafmt/releases)
4. Update the `scalafmt` version in the [configuration files](conf), e.g.:
    ```hocon
    version = "x.y.z"
    ```
5. Run [`scalafmt-examples.sh`](../scalafmt-examples/README.md) to download the
new version of `scalafmt`
   ```shell
   $ pre_commit_hooks/scalafmt-examples/scalafmt-examples.sh
   Formatting with configuration pre_commit_hooks/scalafmt/conf/core.conf ...
     └ pre_commit_hooks/scalafmt-examples/confs/core/WhitespaceIsLava.scala
   Downloading scalafmt x.y.z ...
   Wrote /.../pre-commit-hooks/pre_commit_hooks/scalafmt/scalafmt-x.y.z
   Formatting with configuration pre_commit_hooks/scalafmt/conf/default.conf ...
     └ pre_commit_hooks/scalafmt-examples/confs/default/WhitespaceIsLava.scala
   ...
   ```
6. You'll also want to manually download the linux binary from the [scalafmt release page](https://github.com/scalameta/scalafmt/releases), name it `scalafmt-linux-version`, place it in the scalafmt directory, and make it executable
7. Add the new `scalafmt` versions to git, e.g.:
    ```shell
    $ git add scalafmt-*
    ```
8. Commit and push a PR

# Resources

- [scalafmt](https://scalameta.org/scalafmt/)
- [scalafmt Configuration](https://scalameta.org/scalafmt/docs/configuration.html).
