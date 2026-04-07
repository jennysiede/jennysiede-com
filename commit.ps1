# ─────────────────────────────────────────────────────────────
# Jenny Siede — PowerShell Commit Script
# Usage:
#   .\commit.ps1                         # auto timestamped message
#   .\commit.ps1 "your message"          # custom message
#   .\commit.ps1 -Push                   # commit + push, no prompt
#   .\commit.ps1 "your message" -Push    # custom message + push
# ─────────────────────────────────────────────────────────────
param(
    [string]$Message = "",
    [switch]$Push
)

Set-Location $PSScriptRoot

function Write-Rule  { Write-Host ("-" * 50) -ForegroundColor DarkGray }
function Write-Label([string]$text) { Write-Host $text -ForegroundColor Cyan }
function Write-Ok([string]$text)    { Write-Host $text -ForegroundColor Green }
function Write-Warn([string]$text)  { Write-Host $text -ForegroundColor Yellow }
function Write-Err([string]$text)   { Write-Host $text -ForegroundColor Red }

# Git check
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Err "ERROR: git not found. Install Git for Windows."
    exit 1
}

# Status
Write-Host ""
Write-Label "-- Git Status"
Write-Rule
git status --short
Write-Rule

# Nothing to commit?
$staged = git status --porcelain
if (-not $staged) {
    Write-Warn "Nothing to commit -- working tree clean."
    exit 0
}

# Commit message
if ($Message -eq "") {
    $ts      = Get-Date -Format "yyyy-MM-dd HH:mm"
    $Message = "update $ts"
}

# Stage all
git add -A

# Confirm
Write-Host ""
Write-Label "Commit message: " -NoNewline
Write-Host "`"$Message`"" -ForegroundColor White
Write-Host ""
$confirm = Read-Host "Proceed? [Y/n]"
if ($confirm -match "^[Nn]$") {
    Write-Warn "Aborted."
    exit 0
}

# Commit
git commit -m $Message
Write-Host ""
Write-Ok "-- Committed"
Write-Rule
git log --oneline -5
Write-Rule

# Push
if ($Push) {
    Write-Host ""
    Write-Label "Pushing..."
    git push
    Write-Ok "Pushed."
} else {
    Write-Host ""
    $doPush = Read-Host "Push to remote? [Y/n]"
    if ($doPush -notmatch "^[Nn]$") {
        git push
        Write-Ok "Pushed."
    }
}

Write-Host ""
Write-Ok "Done."
