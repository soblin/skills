---
name: init-pre-commit
description: Use this skill to add a pre-commit setup to a repository, when the user asks to introduce pre-commit, or to add linters and formatters for specific file types. It writes a `.pre-commit-config.yaml` with the hooks that the repository's files need, and the config files of those hooks (markdownlint-cli2, markdown-link-check, prettier, yamllint, hadolint, cspell), adapted to the repository. Templates are bundled in this skill's `templates/` directory.
---

# init-pre-commit

This skill creates a `.pre-commit-config.yaml` and the config files of its hooks in the current repository, from the templates in `${CLAUDE_SKILL_DIR}/templates/`.

`${CLAUDE_SKILL_DIR}` is the directory that contains this `SKILL.md`. If your agent does not expand the variable, resolve `templates/` relative to this file instead.

## Templates

`templates/` holds the base `pre-commit-config.yaml` and the config files of the hooks. The base `pre-commit-config.yaml` only contains essential settings.

## Hooks

Add following hooks according to the prompt:

| File type                                 | `repo`                                                | `rev`            | `id`                  | Options                                                                                                                                                                            | Config template → destination                                                                    |
| ----------------------------------------- | ----------------------------------------------------- | ---------------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| JSON (`.json`)                            | `https://github.com/pre-commit/pre-commit-hooks`      | `v6.0.0`         | `check-json`          | `exclude: (^\|/)\.devcontainer/devcontainer\.json$`                                                                                                                                |                                                                                                  |
| TOML (`.toml`)                            | `https://github.com/pre-commit/pre-commit-hooks`      | `v6.0.0`         | `check-toml`          |                                                                                                                                                                                    |                                                                                                  |
| XML (`.xml`)                              | `https://github.com/pre-commit/pre-commit-hooks`      | `v6.0.0`         | `check-xml`           |                                                                                                                                                                                    |                                                                                                  |
| YAML (`.yaml`, `.yml`)                    | `https://github.com/pre-commit/pre-commit-hooks`      | `v6.0.0`         | `check-yaml`          | `args: [--unsafe]`                                                                                                                                                                 |                                                                                                  |
| Markdown (`.md`)                          | `https://github.com/DavidAnson/markdownlint-cli2`     | `v0.22.1`        | `markdownlint-cli2`   |                                                                                                                                                                                    | `markdownlint-cli2.yaml` → `.markdownlint-cli2.yaml`<br>`markdownlint.yml` → `.markdownlint.yml` |
| Markdown (`.md`)                          | `https://github.com/tcort/markdown-link-check`        | `v3.15.0`        | `markdown-link-check` | `args: [--quiet, --config=.markdown-link-check.json]`                                                                                                                              | `markdown-link-check.json` → `.markdown-link-check.json`                                         |
| Markdown, YAML, JSON, JS, CSS             | `https://github.com/pre-commit/mirrors-prettier`      | `v4.0.0-alpha.8` | `prettier`            | `args: [--no-error-on-unmatched-pattern]`                                                                                                                                          | `prettierrc.yaml` → `.prettierrc.yaml`                                                           |
| YAML (`.yaml`, `.yml`)                    | `https://github.com/adrienverge/yamllint`             | `v1.38.0`        | `yamllint`            |                                                                                                                                                                                    | `yamllint.yaml` → `.yamllint.yaml`                                                               |
| shell script (`.sh`, `.bash`)             | `https://github.com/shellcheck-py/shellcheck-py`      | `v0.11.1.1`      | `shellcheck`          |                                                                                                                                                                                    |                                                                                                  |
| shell script (`.sh`, `.bash`)             | `https://github.com/scop/pre-commit-shfmt`            | `v3.14.1-1`      | `shfmt`               | `args: [-w, -s, -i=4]`                                                                                                                                                             |                                                                                                  |
| fish script (`.fish`)                     | `https://github.com/hugoh/pre-commit-fish.git`        | `v1.2`           | `fish_syntax`         |                                                                                                                                                                                    |                                                                                                  |
| fish script (`.fish`)                     | `https://github.com/hugoh/pre-commit-fish.git`        | `v1.2`           | `fish_indent`         |                                                                                                                                                                                    |                                                                                                  |
| Dockerfile (`Dockerfile`, `*.Dockerfile`) | `https://github.com/shenxianpeng/hadolint-pre-commit` | `v2.14.0.1`      | `hadolint`            |                                                                                                                                                                                    | `hadolint.yml` → `.hadolint.yml`                                                                 |
| any                                       | `https://github.com/streetsidesoftware/cspell-cli`    | `v9.6.0`         | `cspell`              |                                                                                                                                                                                    | `cspell.json` → `.cspell.json`                                                                   |
| commit message                            | `https://github.com/streetsidesoftware/cspell-cli`    | `v9.6.0`         | `cspell`              | `name: check commit message spelling`<br>`args: [--no-must-find-files, --no-progress, --no-summary, --files, .git/COMMIT_EDITMSG]`<br>`stages: [commit-msg]`<br>`always_run: true` | `cspell.json` → `.cspell.json`                                                                   |

For example, the rows of `pre-commit/pre-commit-hooks` for a repository with only Markdown and YAML files become:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: check-merge-conflict
      - id: detect-private-key
      - id: end-of-file-fixer
      - id: mixed-line-ending
      - id: trailing-whitespace
        args: [--markdown-linebreak-ext=md]
      - id: check-yaml
        args: [--unsafe]
```

## Workflow

### 1. Inspect the repository

1. Check whether the repository already has a `.pre-commit-config.yaml`
2. List the tracked files and count them by extension:

   ```sh
   git ls-files | sed -n 's/.*\.\([^./]*\)$/\1/p' | sort | uniq -c | sort -rn
   ```

   Also look for shell scripts without an extension (files that start with `#!/bin/sh` or `#!/bin/bash`, for example under `bin/` or `scripts/`).
   Also look for Dockerfiles, whose names have no extension (`Dockerfile`, `Dockerfile.dev`).

3. Read two or three existing files of each type to learn the current style: the indentation of shell scripts, the line width of Markdown and code, and the quoting style of YAML.

### 2. Choose the hooks

- Include the hooks of each file type that the repository contains, according to the [hook table](#hooks).
- If the user asks for a hook that this skill has no template for, add it from the hook's official repository, and pin `rev` to its latest release tag.

Report the selected hooks and the reasons in one short list before you write the files.

### 3. Write `.pre-commit-config.yaml`

1. Copy `templates/pre-commit-config.yaml` to `.pre-commit-config.yaml` at the repository root.
2. Add `repos` with the selected hooks. Take the values of each hook from the [hook table](#hooks), and keep the order of the table.
3. For files that should be not be touched by any hooks, add a top-level `exclude` with a comment for them, for example:

   ```yaml
   # keep the test fixtures verbatim; fixers and linters would rewrite them.
   exclude: ^tests/fixtures/
   ```

   Use the per-hook `exclude` instead when only some hooks must skip the files (for example, only `yamllint` and `prettier` for Helm templates).

4. If you add a hook with `stages: [commit-msg]`, also add the top-level key below. Without it, `pre-commit install` does not install the `commit-msg` hook:

   ```yaml
   default_install_hook_types: [pre-commit, commit-msg]
   ```

5. Keep the `rev` values of the hook table unless the user asks to update them. To update them, run `pre-commit autoupdate` and report the changed versions.

If the repository already has a `.pre-commit-config.yaml`, do not overwrite it. Add only the missing hooks, and keep the existing hooks, their `rev`, and their `args` where the two conflict.

### 4. Write the config files

Copy the config template of each selected hook to its destination in the [hook table](#hooks), then adapt it to the repository:

- `.markdownlint-cli2.yaml`: replace the placeholder `foo` in `ignores` with the Markdown files that markdownlint must skip, such as generated files and vendored code. Keep `config.extends`, so that the rules come from `.markdownlint.yml`. Keep the `.yaml` extension of the filename, because markdownlint-cli2 does not read `.markdownlint-cli2.yml`.
- `.markdownlint.yml`: if the existing Markdown files break a rule on purpose (for example, the heading style or the list style), set the rule to the style that the files use, instead of rewriting all files.
- `.markdown-link-check.json`: add `ignorePatterns` for links that a checker cannot reach, such as internal hosts, URLs that need login, and links to the repository's own pages that do not exist until the change is merged.
- `.prettierrc.yaml`: set `printWidth` and `tabWidth` to the values that the existing files use. If the repository has files that prettier must not format, add them to `.prettierignore`.
- `.yamllint.yaml`: add an `ignore` entry for YAML files that are not plain YAML (for example, templates with `{{ }}`).
- `shfmt`: set the indent option `-i` in `args` to the indentation of the existing shell scripts (`-i=0` means tabs).
- `.hadolint.yml`: set `trustedRegistries` to the registries that the `FROM` lines of the existing Dockerfiles use. Remove an `ignored` entry when the existing Dockerfiles already follow the rule.
- `.cspell.json`: replace the placeholder `foo` entries of the template.
  - `ignorePaths`: the files that cspell must skip, such as lockfiles, generated files, and vendored code.
  - `words`: the words that the repository uses on purpose, such as product names and identifiers. Add them here instead of rewriting the files.

If the repository already has a config file of the hook, keep it, and do not add the template. If the existing file uses another name than the one that the hook reads, point the hook to the existing file. For example, if the repository has `.markdownlint.json` instead of `.markdownlint.yml`, set `config.extends` of `.markdownlint-cli2.yaml` to `.markdownlint.json`.

### 5. Update / install hooks

Run `pre-commit install` to install the hooks.

### 5. Verify

1. Run the hooks on every file:

   ```sh
   pre-commit run --all-files
   ```

   Run it twice. The first run applies the automatic fixes, and the second run shows the problems that remain.

2. For each remaining problem, decide whether the file or the config is wrong:
   - if the file breaks a rule that the repository follows elsewhere, fix the file
   - if the repository follows another style on purpose, change the config, as in step 4
3. Report the result: the created files, the selected hooks, the files that the automatic fixes changed (`git diff --stat`), and the problems that you could not fix.

## Related skills

- For textlint, use the `textlint-ja` or `textlint-en` skill. They describe how to set up textlint with the config bundled in each skill.
