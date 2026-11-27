<#
.SYNOPSIS
    Installs /find-add for every AI tool found on this computer.

.DESCRIPTION
    Copies skills/find-add/SKILL.md into each tool's skills folder, and writes a
    slash-command file for tools that use their own command format (Cursor,
    Roo Code, OpenCode, Windsurf, Gemini CLI). Command files are generated from
    SKILL.md, so SKILL.md stays the single source of truth.

.PARAMETER All
    Install for every supported tool, including tools that were not detected.

.PARAMETER Uninstall
    Remove everything this script installs.

.PARAMETER TargetHome
    Home folder to install into. Defaults to your user profile; useful for testing.

.EXAMPLE
    .\install.ps1
.EXAMPLE
    .\install.ps1 -All
.EXAMPLE
    .\install.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [switch]$All,
    [switch]$Uninstall,
    [string]$TargetHome = $HOME
)

$ErrorActionPreference = "Stop"

$SourceFile = Join-Path $PSScriptRoot "skills\find-add\SKILL.md"
if (-not (Test-Path $SourceFile)) {
    Write-Error "Source file not found: $SourceFile"
    exit 1
}

# ---- Build the command text from SKILL.md (frontmatter stripped) ----------

$Raw = [System.IO.File]::ReadAllText($SourceFile) -replace "`r`n", "`n"
$Match = [regex]::Match($Raw, '(?s)\A\s*---\n.*?\n---[ \t]*\n(.*)\z')
if (-not $Match.Success) {
    Write-Error "Could not find the YAML frontmatter in $SourceFile"
    exit 1
}
$Body = $Match.Groups[1].Value.Trim()
if ($Body.Contains("'''")) {
    Write-Error "SKILL.md must not contain ''' (it is used to quote the Gemini CLI prompt)."
    exit 1
}

$Description = "Find and add the best skills, plugins, MCP servers and repos for a task, then do the task"
$Intro = "The user ran /find-add. Their task is the text they typed after the command, either in the same message or appended below these instructions. If there is no task, ask what they want done."
$CommandText = "$Intro`n`n$Body`n"

$Contents = @{
    plain       = $CommandText
    frontmatter = "---`ndescription: `"$Description`"`nargument-hint: <task>`n---`n`n$CommandText"
    toml        = "description = `"$Description`"`nprompt = '''`n$CommandText'''`n"
}

# ---- Helpers ---------------------------------------------------------------

function Join-HomePath([string]$Relative) {
    return Join-Path $TargetHome ($Relative -replace '/', [System.IO.Path]::DirectorySeparatorChar)
}

function Test-HomeFolder([string]$Relative) {
    return Test-Path (Join-HomePath $Relative)
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
function Write-Utf8File([string]$Path, [string]$Text) {
    $Folder = Split-Path $Path -Parent
    New-Item -ItemType Directory -Force -Path $Folder | Out-Null
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

$HasGeminiCli = [bool](Get-Command gemini -ErrorAction SilentlyContinue)

# ---- What to install where -------------------------------------------------
# Kind "skill" copies SKILL.md into <Path>/SKILL.md; other kinds write <Path>.

$Targets = @(
    @{ Tool = "Agent Skills standard (Codex, Gemini CLI, VS Code, OpenCode)"; Found = $true;                                    Kind = "skill";       Path = ".agents/skills/find-add" },
    @{ Tool = "Claude Code";                     Found = (Test-HomeFolder ".claude");                                         Kind = "skill";       Path = ".claude/skills/find-add" },
    @{ Tool = "GitHub Copilot (VS Code and CLI)"; Found = (Test-HomeFolder ".copilot");                                       Kind = "skill";       Path = ".copilot/skills/find-add" },
    @{ Tool = "Cline";                           Found = (Test-HomeFolder ".cline");                                          Kind = "skill";       Path = ".cline/skills/find-add" },
    @{ Tool = "Gemini CLI / Antigravity CLI";    Found = (Test-HomeFolder ".gemini");                                         Kind = "skill";       Path = ".gemini/skills/find-add" },
    @{ Tool = "Antigravity IDE and app";         Found = (Test-HomeFolder ".gemini");                                         Kind = "skill";       Path = ".gemini/config/skills/find-add" },
    @{ Tool = "Gemini CLI slash command";        Found = ($HasGeminiCli -or (Test-HomeFolder ".gemini/commands"));            Kind = "toml";        Path = ".gemini/commands/find-add.toml" },
    @{ Tool = "Cursor";                          Found = (Test-HomeFolder ".cursor");                                         Kind = "plain";       Path = ".cursor/commands/find-add.md" },
    @{ Tool = "Roo Code";                        Found = (Test-HomeFolder ".roo");                                            Kind = "frontmatter"; Path = ".roo/commands/find-add.md" },
    @{ Tool = "OpenCode";                        Found = (Test-HomeFolder ".config/opencode");                                Kind = "frontmatter"; Path = ".config/opencode/commands/find-add.md" },
    @{ Tool = "Windsurf";                        Found = (Test-HomeFolder ".codeium/windsurf");                               Kind = "frontmatter"; Path = ".codeium/windsurf/global_workflows/find-add.md" }
)

# Paths written by older versions of this installer.
$LegacyPaths = @(".cursor/skills/find-add")

# ---- Uninstall ---------------------------------------------------------------

if ($Uninstall) {
    $Removed = 0
    $Paths = @($Targets | ForEach-Object { $_.Path }) + $LegacyPaths
    foreach ($Relative in $Paths) {
        $Full = Join-HomePath $Relative
        if (Test-Path $Full -PathType Container) {
            # Only remove a skill folder that really is find-add.
            $Skill = Join-Path $Full "SKILL.md"
            if ((Test-Path $Skill) -and (Select-String -Path $Skill -Pattern '^name:\s*find-add\s*$' -Quiet)) {
                Remove-Item -Recurse -Force -Confirm:$false $Full
                Write-Host "Removed    $Full"
                $Removed++
            }
        } elseif (Test-Path $Full -PathType Leaf) {
            Remove-Item -Force -Confirm:$false $Full
            Write-Host "Removed    $Full"
            $Removed++
        }
    }
    Write-Host ""
    Write-Host "Done. Removed $Removed item(s)."
    exit 0
}

# ---- Install -----------------------------------------------------------------

$Installed = 0
foreach ($Target in $Targets) {
    $Full = Join-HomePath $Target.Path
    if (-not ($All -or $Target.Found)) {
        Write-Host ("Skipped    {0} (not found; use -All to install anyway)" -f $Target.Tool)
        continue
    }
    if ($Target.Kind -eq "skill") {
        New-Item -ItemType Directory -Force -Path $Full | Out-Null
        $Full = Join-Path $Full "SKILL.md"
        Copy-Item -Path $SourceFile -Destination $Full -Force
    } else {
        Write-Utf8File $Full $Contents[$Target.Kind]
    }
    Write-Host ("Installed  {0} -> {1}" -f $Target.Tool, $Full)
    $Installed++
}

Write-Host ""
Write-Host "Done. Installed $Installed item(s). Restart open AI tools (or reload their skills), then type:"
Write-Host "  /find-add <your task>     Claude Code, Copilot, Cursor, Cline, Roo Code, OpenCode, Windsurf, Gemini CLI, Antigravity"
Write-Host "  `$find-add <your task>     Codex"
