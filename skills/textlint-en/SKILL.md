---
name: textlint-en
description: Use this skill to proofread English prose in Markdown files with textlint (terminology, misspellings, parentheses spacing, and write-good style checks), for example before committing or opening a PR. Also use it to set up textlint in a project when the user asks. A default config is bundled in this skill's `config/` directory, so it works in projects without their own textlint setup.
---

# textlint

This skill covers two use cases:

- run textlint on the specified files, with the project's own textlint setup or with the config bundled in this skill
- set up textlint in the current project, only when the user asks for it

## Run textlint

### Choose the command

1. If the target project has its own textlint config (`.textlintrc`, `.textlintrc.{json,yaml,yml,js,cjs}`, or a `textlint` key in `package.json`) and installs textlint, use them as is:

   ```sh
   npx textlint <files>
   ```

2. Otherwise, use the config bundled with this skill, `${CLAUDE_SKILL_DIR}/config/.textlintrc.yaml`. Pass every rule package to `npx`, because a plain `npx textlint` cannot resolve rules that the project does not install:

   ```sh
   npx -y \
     -p textlint \
     -p textlint-rule-terminology \
     -p textlint-rule-common-misspellings \
     -p textlint-rule-write-good \
     -p textlint-rule-prh \
     -p textlint-filter-rule-comments \
     textlint --config "${CLAUDE_SKILL_DIR}/config/.textlintrc.yaml" <files>
   ```

`${CLAUDE_SKILL_DIR}` is the directory that contains this `SKILL.md`. If your agent does not expand the variable, resolve `config/` relative to this file instead.

`npx` caches the packages under `~/.npm/_npx`, so only the first run downloads them.

Do not copy the bundled config into the target project unless the user asks for it.

### Workflow

1. Run with `--fix` to apply the automatic fixes.
2. Review the changes with `git diff`. Automatic fixes can be wrong (for example, a parentheses rule that splits an identifier), so revert those by hand.
3. Run the command once more without `--fix` and fix the remaining problems.

## Handle the results

- Fix each reported problem by rewriting the sentence, not by suppressing the rule.
- Use `<!-- textlint-disable -->` / `<!-- textlint-enable -->` only for text that must stay verbatim (quotations, code-like identifiers, and so on).
- For a document that mixes Japanese and English prose, run the `textlint-ja` skill first and then this skill, each with its own config. The two configs do not know about each other, so review the `git diff` after both runs.

## Set up textlint for the project

Only when the user asks for it:

1. Install the packages as dev dependencies:

   ```sh
   npm install --save-dev \
     textlint \
     textlint-rule-terminology \
     textlint-rule-common-misspellings \
     textlint-rule-write-good \
     textlint-rule-prh \
     textlint-filter-rule-comments
   ```

   Use the project's package manager (`pnpm`, `yarn`, and so on) when it does not use `npm`.

2. Copy `config/.textlintrc.yaml` and `config/.textlint.prh-en-parentheses.yaml` to the project root, unless the project already has a textlint config.
3. Add the scripts to `package.json` (for example, for Markdown files):

   ```json
   {
     "scripts": {
       "lint:text": "textlint \"**/*.md\"",
       "lint:text:fix": "textlint --fix \"**/*.md\""
     }
   }
   ```
