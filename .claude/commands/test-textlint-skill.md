---
description: Test the textlint-en / textlint-ja skills against the before/after fixtures under tests/
argument-hint: "[en|ja]"
---

# Test the textlint skills

Run the `textlint-en` and `textlint-ja` skills on the fixtures under `tests/` and check that the results match the expected output.

Arguments: `$ARGUMENTS`

- 1st argument: `en` or `ja` to test only `textlint-en` or `textlint-ja`. Test both when omitted.

## Fixtures

```text
tests/textlint-<lang>/
├── before.md  # input with lint problems
└── after.md   # expected result after following the skill
```

- Each fixture contains only problems that `textlint --fix` fixes, so the result is deterministic and must match `after.md` exactly. Do not add problems that need a manual rewrite, because the rewritten wording varies between runs.
- Each section (`##`) of a fixture covers one rule, and its heading names the rule. The last section holds text that the skill must leave as is (inline code, code blocks, and `<!-- textlint-disable -->` regions).
- `tests/textlint-ja/before.md` contains invisible characters (a zero-width space and an NFD character). Edit it with a tool that keeps them.
- `.pre-commit-config.yaml` excludes `tests/textlint-*/` so that the hooks do not rewrite the fixtures.

## Procedure

For each selected `<lang>`:

1. Prepare an isolated work directory, outside this repository so that no project textlint config applies and the skill uses its bundled config:

   ```sh
   W=<scratchpad>/textlint-<lang>
   rm -rf "$W" && mkdir -p "$W"
   cp tests/textlint-<lang>/before.md "$W/test.md"
   git -C "$W" init -q && git -C "$W" add . && git -C "$W" -c user.name=test -c user.email=test@example.com commit -qm before
   ```

   The Git repository lets the skill review its fixes with `git diff`. The one-off identity lets the commit succeed on machines without a global Git identity.

2. Invoke the `textlint-<lang>` skill with the Skill tool on `$W/test.md` and follow its whole workflow. Do not read `after.md` before this step finishes, so the expected output does not bias the fixes.

   Repeat the workflow until the result is idempotent: a pass of `--fix` changes nothing (`cmp` against a copy taken before the pass) and the command without `--fix` reports no problems. Stop after 5 passes and judge the skill as FAIL if it has not converged. Record the number of passes for the report. `textlint --fix` can print `Remaining N errors` for problems that are already fixed, so trust the run without `--fix`, not that summary.

3. Check the result:
   1. Run the skill's bundled-config command without `--fix` on `$W/test.md`. It must report no problems (no errors and no warnings).
   2. Compare with `diff -u tests/textlint-<lang>/after.md "$W/test.md"`.

4. Judge the result:
   - **PASS:** lint-clean and identical to `after.md`.
   - **FAIL:** any other result, for example remaining problems, no convergence within 5 passes, or a result that differs from `after.md`.

Do not edit the fixtures or the skills to make a test pass.

## Report

Print a table with one row per skill. Its columns are `skill`, `passes`, `result` and `note`. `passes` is the number of passes that step 2 needed. Show the `diff -u` output for each FAIL, and the textlint output when problems remain.
