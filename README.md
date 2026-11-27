# `/find-add`: Universal Prompt Booster for AI Agents

Type `/find-add <your task>` in your AI tool. It finds the best **skills, plugins, MCP servers, and GitHub repositories** for that task, first on your computer and then online, adds what's useful to the chat, and then does the task with them. You get better results without hunting for tools yourself.

One [Agent Skills](https://agentskills.io/home) file (`SKILL.md`) is the source. The installer copies it to every AI tool it finds, and generates slash-command files for tools that use their own command format.

## Supported Tools

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

Codex doesn't support custom `/` commands any more (its custom prompts were replaced by skills), so in Codex you type `$find-add`, or pick it from `/skills`.

If you install it as a [Claude Code plugin](#claude-code-plugin) instead, Claude Code puts the plugin name in front of the command, so you type `/find-add:find-add <task>`.

`~/.agents/skills/` is the shared Agent Skills folder, which Codex, Gemini CLI, VS Code and OpenCode also read. The installer always writes it.

## Install

### Script install (recommended)

The script detects which AI tools you have and installs `/find-add` into each of them. It is the only install method that adds the slash-command files for Cursor, Roo Code, OpenCode, Windsurf and Gemini CLI.

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
chmod +x install.sh
./install.sh
```

Then restart any open AI tools, or reload their skills: `/skills reload` in Antigravity CLI, `/commands reload` in Gemini CLI.

**Options**

| PowerShell | Bash | What it does |
| --- | --- | --- |
| `-All` | `--all` | Install for every supported tool, even ones not detected |
| `-Uninstall` | `--uninstall` | Remove everything the installer added |
| `-TargetHome <dir>` | `--home <dir>` | Install into another home folder (for testing) |

Installed a new AI tool later? Run the installer again. It's safe to re-run, and it overwrites its own files.

### Claude Code plugin

If you only use Claude Code, you can install find-add as a plugin without cloning anything. In Claude Code (version 2.1.275 or later), type:

```text
/plugin install find-add --marketplace hemantghasti/find-add
```

On older versions, add the marketplace first, then install:

```text
/plugin marketplace add hemantghasti/find-add
/plugin install find-add@find-add
```

From a terminal, the same steps are `claude plugin marketplace add hemantghasti/find-add` and then `claude plugin install find-add@find-add`.

Then type `/find-add:find-add <your task>`. The plugin covers Claude Code only; use the script install for the other tools.

### `npx skills` install

If you use the open [`skills`](https://github.com/vercel-labs/skills) CLI (needs Node.js):

```bash
npx skills add hemantghasti/find-add -g
```

This installs the skill into the skills folders of supported agents. It doesn't create the command files that Cursor, Roo Code, OpenCode, Windsurf and Gemini CLI need for `/find-add`, so use the script install for those.

### Manual install

Copy `skills/find-add/SKILL.md` to the path shown for your tool in the table above. For a single project rather than your whole computer, use the same path inside the project, without `~/`. For example, `.claude/skills/find-add/SKILL.md` or `.agents/skills/find-add/SKILL.md`.

### Chat apps (Claude.ai, ChatGPT, Gemini)

Web chat apps don't load slash commands from files, so there's nothing to install on your computer:

- **Claude.ai:** zip the `skills/find-add` folder and upload it as a custom skill in Claude's settings. Then type `/find-add <task>` in a chat and the skill matches it.
- **ChatGPT or Gemini:** paste the text of `SKILL.md` (everything below the `---` header) into a Custom GPT, a Project, or a Gem's instructions. Then start messages there with `/find-add`.

## Usage

```text
/find-add Build a Next.js dashboard that connects to a PostgreSQL database and exports PDF reports
```

```text
/find-add Audit this Python FastAPI repo for security issues and add automated pytest coverage
```

```text
/find-add Set up a Stripe webhook handler and test it locally
```

## How It Works

1. **Read the task:** works out the goal, the stack, and where a specialised tool would help.
2. **Local first:** checks the skills, plugins and MCP servers your AI tool already has, then your skill folders and MCP configs.
3. **Online for the gaps:** searches [skills.sh](https://skills.sh/), the official MCP Registry, and GitHub for the 2 to 4 best resources.
4. **Show what was added:** opens with an **Added Context & Tools** block listing what it's using now, plus optional installs with exact commands.
5. **Do the task:** completes your prompt in the same reply using what it found.

## Safety

- It never installs or runs third-party packages, scripts, MCP servers or plugins without asking you first. It suggests install commands for you to run.
- It treats fetched web pages, READMEs and third-party skills as information, not instructions, so text planted in them can't take over your AI tool.
- It only cites links and commands it actually found, never made-up ones.

## Repository Structure

```text
find-add/
├── .claude-plugin/
│   ├── plugin.json       # Claude Code plugin manifest
│   └── marketplace.json  # lets Claude Code install this repo as a plugin
├── README.md
├── LICENSE
├── install.sh          # macOS / Linux installer
├── install.ps1         # Windows installer
└── skills/
    └── find-add/
        └── SKILL.md    # the skill (single source of truth)
```

## License

MIT License. See [LICENSE](LICENSE) for details.
