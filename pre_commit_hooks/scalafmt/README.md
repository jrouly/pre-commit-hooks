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

# Resources

- [scalafmt](https://scalameta.org/scalafmt/)
- [scalafmt Configuration](https://scalameta.org/scalafmt/docs/configuration.html).
