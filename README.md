# pre-commit-hooks

Useful pre-commit-hooks for use with [Yelp's pre-commit](https://github.com/pre-commit/pre-commit).

# Using hooks
Add a `.pre-commit-config.yaml` to your repository. e.g.:

```yaml
-   repo: git@github.com:AudaxHealthInc/pre-commit-hooks.git
    sha: ...
    hooks:
    -   id: ...
    -   id: ...
```

# Hooks defined in this repo

## csv-formatter

Formats CSVs by applying a consistent quoting standard.

```yaml
    hooks:
    -   id: csv-formatter
```

## [scalastyle](http://www.scalastyle.org/)

Scala style checker.

If project has `scalastyle-config.xml` in the project folder, example
[`project/scalastyle-config.xml`](https://github.com/AudaxHealthInc/proton/project/scalastyle-config.xml)
the script will use that config file, otherwise it will use the provided
[default config](./pre_commit_hooks/scalastyle/configs/default.xml).

```yaml
    hooks:
    -   id: scalastyle
```

### Testing

- Go to your repo with pre-commit
- Run `pre-commit try-repo ../pre-commit-hooks scalastyle --verbose --all-files`

## scalafmt

[scalafmt](http://scalameta.org/scalafmt/) is an opinionated code formatter for Scala.

```yaml
    hooks:
    -   id: scalafmt
        args: [--conf-name=default]
```

### Configuration

The `args` block is optional. If present, pass the name of a config file stored in
[`pre_commit_hooks/scalafmt/conf/`](pre_commit_hooks/scalafmt/conf). If it's not present, scalafmt will fall back to
[default.conf](pre_commit_hooks/scalafmt/conf/default.conf).

Info on modifying config files can be found [here](pre_commit_hooks/scalafmt/README.md).

### Intellij

Intellij [officially](https://www.jetbrains.com/help/idea/work-with-scala-formatter.html) supports scalafmt via a
[plugin](https://plugins.jetbrains.com/plugin/8236-scalafmt). It is recommended to use this plugin to allow Intellij to
format your code while you are working.

When the pre-commit hooks runs [our script](pre_commit_hooks/scalafmt.sh) will copy the configuration to
`/.scalafmt.conf` (overwriting the file if it exists). This is where the Intellij plugin expects the configuration file.
Copying and overwriting ensures intellij and pre-commit are both formatting files the same way.

## scalariform ❌
| :warning: [scalariform](https://github.com/scala-ide/scalariform) is no longer well-maintained, and is expected to reach the end of life when Scala 3 lands. At this point, we recommend using scalafmt instead. |
|-----|

[scalariform](https://github.com/scala-ide/scalariform) formats Scala code by applying a set of customizable rules.

```yaml
    hooks:
    -   id: scalariform
        args: [templatename]
```

The `args` block is optional. If present, pass the name of a template file stored in
[`pre_commit_hooks/scalariform/templates/`](pre_commit_hooks/scalariform/templates). If it's not present,
Scalariform will fall back to the [default template](pre_commit_hooks/scalariform/templates/default.properties).
