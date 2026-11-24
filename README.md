# skills

Personal collection of Agent Skills maintained by soblin.
The repository is a plugin marketplace for Claude Code and Codex, and it ships one plugin, `soblin-skills`, that bundles every skill under [`skills/`](skills/):

| Skill                                                  | Description                                                       |
| ------------------------------------------------------ | ----------------------------------------------------------------- |
| [`github-markdown-math`](skills/github-markdown-math/) | Write LaTeX/KaTeX math in Markdown that renders on GitHub         |
| [`init-pre-commit`](skills/init-pre-commit/)           | Add a pre-commit setup with hooks for the repository's file types |
| [`ja-technical-writing`](skills/ja-technical-writing/) | Writing rules for Japanese technical documents                    |
| [`textlint-en`](skills/textlint-en/)                   | Proofread English prose in Markdown with textlint                 |
| [`textlint-ja`](skills/textlint-ja/)                   | Proofread Japanese prose in Markdown with textlint                |

## claude

Add this repository as a marketplace, then install the `soblin-skills` plugin from it:

```sh
claude plugin marketplace add soblin/skills
claude plugin install soblin-skills@soblin-skills
```

Inside a Claude Code session, run the same steps as slash commands:

```text
/plugin marketplace add soblin/skills
/plugin install soblin-skills@soblin-skills
```

## codex

Add this repository as a marketplace, then install the `soblin-skills` plugin from it:

```sh
codex plugin marketplace add soblin/skills
codex plugin add soblin-skills@soblin-skills
```

## Release

The workflows bump `"version"` in `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`, tag it, and draft the release.
Do not edit the version by hand.

### Automatic flow

1. `release-label` labels a PR `release:minor` when it adds `skills/<name>/SKILL.md`, and `release:patch` when it changes other files under `skills/`.
   Set `release:major` by hand when needed; the workflow keeps it.
2. When a PR with a `release:*` label is merged, `release-pr` opens a `chore(release): vX.Y.Z` PR that bumps both manifests, and sets it to auto-merge.
3. When the bump reaches `main`, `release` creates the `vX.Y.Z` tag and a draft release with generated notes.
4. Review the draft release and publish it.

### Manual bump

To bump the version without a labeled PR, for example after a PR that changed only files outside `skills/`:

1. Open **Actions** → **release-pr** → **Run workflow**.
2. Choose `patch`, `minor`, or `major`, and run it.

Steps 3 and 4 of the automatic flow follow.

### GitHub App setup

`release-pr` uses a GitHub App token, because PRs and commits made with `GITHUB_TOKEN` do not trigger the required checks.
To set up the App once:

1. Create a GitHub App at **Settings** → **Developer settings** → **GitHub Apps** → **New GitHub App**:
   - **Homepage URL**: the URL of this repository
   - **Webhook**: clear **Active**
   - **Repository permissions**: **Contents** and **Pull requests** set to **Read and write**
   - **Where can this GitHub App be installed?**: **Only on this account**
2. Note the **App ID**, and generate a private key under **Private keys**.
3. Install the App on this repository only, from **Install App**.
4. Register the App ID as the repository variable `RELEASE_APP_ID`, and the private key as the repository secret `RELEASE_APP_PRIVATE_KEY`:

   ```sh
   gh variable set RELEASE_APP_ID --repo soblin/skills --body <app-id>
   gh secret set RELEASE_APP_PRIVATE_KEY --repo soblin/skills < <private-key>.pem
   ```

5. Delete the local private key file.
