# Autofix cases

## Terminology

This project uses github actions, javascript, and typescript.
Write the docs in markdown and host them on github.

## Misspellings

We recieve feedback and seperate the concerns.

## Space before an opening parenthesis

Run the linter(textlint) before committing.

## Padding inside parentheses

Wrap the term in parentheses ( like this ) carefully.

## Space after a closing parenthesis

Run the formatter (prettier)before the linter.

## Ignored text

Inline code such as `github` and `foo(bar)` stays as is.

```sh
echo "javascript(foo)bar"
```

<!-- textlint-disable -->

The comments filter keeps this github line(as is).

<!-- textlint-enable -->
