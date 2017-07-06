# pre-commit-hooks

Useful pre-commit-hooks for use with [Yelp's pre-commit](https://github.com/pre-commit/pre-commit).

## Hooks offered

* `csv-formatter` - Format CSVs with consistent quoting and delimiters.
  * Set preferred delimiter `['--delimiter ,']`
  * Set preferred quoting behavior `['--quotechar 0']`
    * `csv.QUOTE_MINIMAL=0`
    * `csv.QUOTE_ALL=1`
    * `csv.QUOTE_NONNUMERIC=2`
    * `csv.QUOTE_NONE=3`
* `google-java-format` - Format Java code with Google's [`google-java-format`](https://github.com/google/google-java-format) tool.
