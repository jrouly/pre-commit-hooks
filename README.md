# pre-commit-hooks

Useful pre-commit-hooks for use with [Yelp's pre-commit](https://github.com/pre-commit/pre-commit).

### Using hooks
Add a `.pre-commit-config.yaml` to your repository. e.g.:

```yaml
-   repo: git@github.com:AudaxHealthInc/pre-commit-hooks.git
    sha: ...
    hooks:
    -   id: ...
    -   id: ...
```

#### Hooks defined in this repo

##### csv-formatter
Formats CSVs by applying a consistent quoting standard.

```yaml
    hooks:
    -   id: csv-formatter
```

##### scalariform
Formats Scala code by applying a set of customizable rules.

```yaml
    hooks:
    -   id: scalariform
        args: [templatename]
```

##### [scalastyle](http://www.scalastyle.org/)
Scala style checker.
If project has `scalastyle-config.xml` in the project folder, example [`project/scalastyle-config.xml`](https://github.com/AudaxHealthInc/proton/project/scalastyle-config.xml) the script will use that config file, otherwise it will use the provided [default config](./pre_commit_hooks/scalastyle/configs/default.xml)

```yaml
    hooks:
    -   id: scalastyle
```


The `args` block is optional.
If present, pass the name of a template file stored in `pre_commit_hooks/scalariform/templates/`.
If it's not present, Scalariform will fall back to the default template.

##### scalafmt
An opinionated code formatter for Scala.

http://scalameta.org/scalafmt/

```yaml
    hooks:
    -   id: scalafmt
```

[`.scalafmt.conf`](http://scalameta.org/scalafmt/#Configuration) in the project's root directory will be used for configuration if present.

### Testing 
- Go to your repo with pre-commit
- Run `pre-commit try-repo ../pre-commit-hooks scalastyle --ref 2ebef2966cee0e5e27e244007bc7677fbcdd4a85  --verbose --all-files`
  - `--ref` is reference to `git sha` of your changes
