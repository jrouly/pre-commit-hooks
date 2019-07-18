# scalafmt code style config

This hook provides a default config file and supports additional, pillar-specific configs. The default 
config intends to be as close to the scalafmt defaults as possible while being as opinionated as possible 
(meaning code should be formatted exactly the same way, every time, where possible). This config should be 
preferred.

If a pillar must provide its own config, a PR should be made against this repo with the config added to a 
sub-folder within this folder with the format `<pillar>.conf`.

Example pre-commit-config:
```yaml
    hooks:
    -   id: scalafmt
        args: [--conf-name=default]
```

Documentation for scalafmt config can be found [here](https://scalameta.org/scalafmt/docs/configuration.html).