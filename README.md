# skills

Personal collection of Agent Skills maintained by soblin.
The repository is a plugin marketplace for Claude Code and Codex, and it ships one plugin, `skills`, that bundles every skill under [`skills/`](skills/):

| Skill                                                  | Description                                               |
| ------------------------------------------------------ | --------------------------------------------------------- |
| [`github-markdown-math`](skills/github-markdown-math/) | Write LaTeX/KaTeX math in Markdown that renders on GitHub |
| [`ja-technical-writing`](skills/ja-technical-writing/) | Writing rules for Japanese technical documents            |
| [`textlint-en`](skills/textlint-en/)                   | Proofread English prose in Markdown with textlint         |
| [`textlint-ja`](skills/textlint-ja/)                   | Proofread Japanese prose in Markdown with textlint        |

## claude

Add this repository as a marketplace, then install the `skills` plugin from it:

```sh
claude plugin marketplace add soblin/skills
claude plugin install skills@skills
```

Inside a Claude Code session, run the same steps as slash commands:

```text
/plugin marketplace add soblin/skills
/plugin install skills@skills
```

## codex

Add this repository as a marketplace, then install the `skills` plugin from it:

```sh
codex plugin marketplace add soblin/skills
codex plugin add skills@skills
```
