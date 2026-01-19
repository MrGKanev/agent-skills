# Git Safety Rules

CRITICAL: Never run destructive git or filesystem commands without explicit user confirmation.

## Blocked Commands - NEVER run these automatically:

### Git Commands That Destroy Data
- `git reset --hard` - Destroys all uncommitted changes permanently
- `git checkout -- <file>` or `git checkout .` - Discards uncommitted changes
- `git restore <file>` (without --staged) - Discards working tree changes
- `git clean -f` - Permanently removes untracked files
- `git push --force` or `git push -f` - Overwrites remote history
- `git branch -D` - Force deletes a branch without merge check
- `git stash drop` or `git stash clear` - Permanently removes stashed changes
- `git rebase` on main/master - Can rewrite shared history

### Filesystem Commands That Destroy Data
- `rm -rf` on project directories - Permanently deletes files
- `rm -r` without confirmation on important paths

## Safe Alternatives - Use these instead:

| Dangerous Command | Safe Alternative |
|-------------------|------------------|
| `git reset --hard` | `git stash` first, then reset |
| `git checkout -- .` | `git stash` to save changes |
| `git clean -f` | `git clean --dry-run` first |
| `git push --force` | `git push --force-with-lease` |
| `git branch -D` | `git branch -d` (safe delete) |

## Before Any Destructive Operation:

1. Ask the user for explicit confirmation
2. Explain what data will be lost
3. Suggest running `git stash` first
4. For `git clean`, always run with `--dry-run` first

## Safe Patterns (Always OK):

- `git checkout -b <branch>` - Creating new branch
- `git checkout <branch>` - Switching branches
- `git restore --staged <file>` - Unstaging files
- `git stash push/pop/list` - Managing stashes
- `git clean --dry-run` - Preview what would be deleted
