# find-add

**Stop hunting for skills, MCP servers and repos. Type `/find-add` and your AI finds them, loads them, and gets to work.**

[![Works with 11 AI tools](https://img.shields.io/badge/works%20with-11%20AI%20tools-8A2BE2)](#works-with)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-D97757)](#claude-code-plugin)
[![License: MIT](https://img.shields.io/github/license/hemantghasti/find-add)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/hemantghasti/find-add?style=social)](https://github.com/hemantghasti/find-add/stargazers)

One command. Claude Code, Copilot, Cursor, Codex, Cline, Windsurf and more. No more digging through awesome-lists before every task.

## The problem

There are thousands of agent skills, MCP servers and starter repos out there. Your AI uses none of them unless you go find them, install them and point it at them. Most people never do, so their AI works from general knowledge when a purpose-built tool was one search away.

## The fix

```text
/find-add <your task>
```

1. **Checks what you already have.** Installed skills, connected MCP servers, plugins, and your project's stack.
2. **Searches for what's missing.** [skills.sh](https://skills.sh/), the official MCP Registry, and GitHub. Keeps only the 2 to 4 best.
3. **Shows its work.** What it's using right now, and what you could install, with the exact command.
4. **Does the task.** In the same reply. No extra prompt needed.

## See it work

A real run in Claude Code, shortened:

```text
/find-add Add a GitHub Actions check that lints install.sh with ShellCheck and install.ps1 with PSScriptAnalyzer on every push
```

> **Added Context & Tools**
>
> Using now:
> - `agent-protocols:ci-cd-and-automation` (installed skill): GitHub Actions workflow layout and quality-gate conventions.
> - [ShellCheck wiki: GitHub Actions](https://shellcheck.net/wiki/GitHub-Actions): ShellCheck is preinstalled on GitHub's Ubuntu runners, so no install step is needed.
> - [GitHub Docs: Building and testing PowerShell](https://docs.github.com/en/actions/tutorials/build-and-test-code/powershell): install PSScriptAnalyzer, then run `Invoke-ScriptAnalyzer`.
>
> Optional installs (not installed):
> - GitHub MCP server: configured but not signed in. Signing in with `/mcp` would let the AI open the pull request itself.

Then it wrote the workflow: a ShellCheck job on Ubuntu and a PSScriptAnalyzer job on Windows. One command, three sources found, task done.

## Works with

| AI tool | Type this | What the installer adds |
| --- | --- | --- |
| Claude Code | `/find-add <task>` | `~/.claude/skills/find-add/SKILL.md` |
| GitHub Copilot (VS Code, Copilot CLI) | `/find-add <task>` | `~/.copilot/skills/find-add/SKILL.md` |
| Cursor | `/find-add <task>` | `~/.cursor/commands/find-add.md` |
| Cline | `/find-add <task>` | `~/.cline/skills/find-add/SKILL.md` |
| Roo Code | `/find-add <task>` | `~/.roo/commands/find-add.md` |
| OpenCode | `/find-add <task>` | `~/.config/opencode/commands/find-add.md` |
| Windsurf | `/find-add <task>` | `~/.codeium/windsurf/global_workflows/find-add.md` |
| Antigravity CLI | `/find-add <task>` | `~/.gemini/skills/find-add/SKILL.md` |
| Antigravity IDE and app | Ask for find-add, or `/find-add` where skills show as commands | `~/.gemini/config/skills/find-add/SKILL.md` |
| Gemini CLI | `/find-add <task>` | `~/.gemini/commands/find-add.toml` |
| OpenAI Codex (CLI, IDE) | `$find-add <task>` | `~/.agents/skills/find-add/SKILL.md` |

Codex replaced custom `/` commands with skills, so there you type `$find-add`. As a [Claude Code plugin](#claude-code-plugin), the command is `/find-add:find-add`.

## Install in 30 seconds

The installer detects every AI tool on your computer and sets up `/find-add` in each one.

**Windows (PowerShell)**

```powershell
git clone https://github.com/hemantghasti/find-add.git
cd find-add
.\install.ps1
```

**macOS / Linux**

```bash
git clone https://github.com/hemantghasti/find-add.git
cd find-add
./install.sh
```

Restart your AI tools and type `/find-add`. Done.

| PowerShell | Bash | What it does |
| --- | --- | --- |
| `-All` | `--all` | Install for every supported tool, even ones not detected |
| `-Uninstall` | `--uninstall` | Remove everything the installer added |
| `-TargetHome <dir>` | `--home <dir>` | Install into another home folder (for testing) |

New AI tool later? Run the installer again. It's safe to re-run.

### Claude Code plugin

One line, nothing to clone. In Claude Code 2.1.275 or later:

```text
/plugin install find-add --marketplace hemantghasti/find-add
```

On older versions:

```text
/plugin marketplace add hemantghasti/find-add
/plugin install find-add@find-add
```

Then type `/find-add:find-add <your task>`.

### `npx skills`

```bash
npx skills add hemantghasti/find-add -g
```

This adds the skill to supported agents' skill folders. For the Cursor, Roo Code, OpenCode, Windsurf and Gemini CLI slash commands, use the installer.

### Manual

Copy `skills/find-add/SKILL.md` to your tool's path from the table. For one project only, use the same path inside the project, without `~/`.

### Chat apps (Claude.ai, ChatGPT, Gemini)

Experimental, not tested yet:

- **Claude.ai:** zip the `skills/find-add` folder, upload it as a custom skill in settings, then ask for find-add in a chat.
- **ChatGPT or Gemini:** paste `SKILL.md` (below the `---` header) into a Custom GPT, Project or Gem, then start messages with `/find-add`.

## Built to ask first

- It **suggests** install commands instead of running them. You decide what goes on your machine.
- It treats web pages, READMEs and other people's skills as **information, not orders**. It's told never to follow instructions planted in them.
- It only links to things it **actually found**.

find-add is a set of instructions your AI follows, so keep your tool's permission prompts on as the final safety net.

## Tested

- **Claude Code:** verified. The run above is real, and the plugin installs cleanly from GitHub.
- **Installers:** verified on Windows in PowerShell 5.1, PowerShell 7 and bash.
- **Everything else:** installs to each tool's documented location. Tried it in another tool? [Tell us how it went](https://github.com/hemantghasti/find-add/issues).

## Help it spread

If find-add saved you a search, **⭐ star the repo** so other people find it too. Ideas, bugs and new tool support are welcome as [issues](https://github.com/hemantghasti/find-add/issues) and pull requests.

## License

MIT. See [LICENSE](LICENSE).
