# pre-commit-hooks

Useful pre-commit-hooks for use with [Yelp's pre-commit](https://github.com/pre-commit/pre-commit).

### Using hooks
Add a `.pre-commit-config.yaml` to your repository. e.g.:

```
-   repo: git@github.com:AudaxHealthInc/pre-commit-hooks.git
    sha: ...
    hooks:
    -   id: ...
    -   id: ...
```

#### Hooks defined in this repo

##### csv-formatter
Formats CSVs by applying a consistent quoting standard.

```
    hooks:
    -   id: csv-formatter
```

##### scalariform
Formats Scala code by applying a set of customizable rules.

```
    hooks:
    -   id: scalariform
        args: [templatename]
```

The `args` block is optional.
If present, pass the name of a template file stored in `pre_commit_hooks/scalariform/templates/`.
If it's not present, Scalariform will fall back to the default template.
