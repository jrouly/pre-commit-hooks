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

Add `scalafmt` as a hook into your repo's `.pre-commit-config`:

```yaml
- repo: git@github.com:AudaxHealthInc/pre-commit-hooks.git
  rev: vX.Y.Z
  hooks:
    - id: scalafmt
```

# Configuration

This hook supports:
- [Rally default config (`default.conf`)](#default-configuration)
- [Solution specific configs](#solution-specific-configuration).

| File | Description | Base |
| ---- | ----------- | ---- |
| [`compact.conf`](conf/compact.conf) | Default with tweaks for a more compact vie (i.e. 80 columns). | [`default.conf`](conf/default.conf) |
| [`core.conf`](conf/core.conf) | Core solution's configuration. | [`default.conf`](conf/default.conf) |
| [`default.conf`](conf/default.conf) | Rally's standard Scala format, defined by many passionate and heated discussions. | |
| [`personalization.conf`](conf/personalization.conf) | Personalization solution's configuration. | [`default.conf`](conf/default.conf) |
| [`scala-lang-org-style.conf`](conf/scala-lang-org-style.conf) | Configuration based on [Scala Lang's Style Guide](https://docs.scala-lang.org/style/). | |

## Extending existing configurations

If you like most of an existing configuration but would like to tweak it slightly without entirely duplicating it,
consider using `includes`:

```hocon
include "default.conf"
```

## Modifying existing configurations

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
        args: [--conf-name=foo]
```

The [default config file](conf/default.conf) intends to be a default that you can extend and make tweaks. Consider
using the [default config file](conf/default.conf) as a base.

# Testing

Obviously making changes to a scalafmt configuration should be tested. To help with this we've created a "dirty"
un-formatted code file that can be formatted so you can see your changes here before committing. See
[scalafmt-examples](../scalafmt-examples/README.md) for more details.

# Updating scalafmt Version

Bumping scalafmt version can have a significant impact on formatting due to bugfixes and new features. After updating
the version, be sure to update all configs that require changes to maintain existing behavior. Some formatting changes
will be unavoidable, but try to ensure there are no major changes to the code style.

[`scalafmt.py`](../scalafmt.py) allows you to customize the version of `scalafmt-native` being used, like so:

```yaml
...
    - id: scalafmt
        args: [--scalafmt-version=x.y.z]
```

**Caveat emptor**: `scalafmt-native` will refuse to consume config files with a different `version` key.
If you would like to use version `x.y.z` of `scalafmt-native`, be _certain_ that the config file you are
selecting specifies `version=x.y.z` as well.

# Resources

- [scalafmt](https://scalameta.org/scalafmt/)
- [scalafmt Configuration](https://scalameta.org/scalafmt/docs/configuration.html).
