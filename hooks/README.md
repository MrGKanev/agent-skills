# Safety Hooks for Claude Code

This directory contains pre-tool-use hooks that protect against destructive commands.

## git-safety-guard.py

Blocks destructive git and filesystem commands:

**Blocked commands:**
- `git reset --hard` - destroys uncommitted changes
- `git checkout --` / `git checkout .` - discards changes
- `git restore` (without --staged) - discards changes
- `git clean -f` - removes untracked files permanently
- `git push --force` - overwrites remote history
- `git branch -D` - force deletes branches
- `git stash drop/clear` - permanently removes stashes
- `rm -rf` on non-temp directories

**Safe patterns (allowed):**
- `git checkout -b` - create new branch
- `git checkout <branch>` - switch branches
- `git clean --dry-run` - preview mode
- `git restore --staged` - unstaging
- `git stash push/pop/list` - safe stash operations

## Installation

Hooks are automatically installed when you run:
```bash
curl -fsSL https://raw.githubusercontent.com/MrGKanev/agent-skills/master/install.sh | bash
```

## Manual Installation

1. Copy `git-safety-guard.py` to `~/.claude/hooks/`
2. Make it executable: `chmod +x ~/.claude/hooks/git-safety-guard.py`
3. Add to `~/.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/git-safety-guard.py"
          }
        ]
      }
    ]
  }
}
```
4. Restart Claude Code
