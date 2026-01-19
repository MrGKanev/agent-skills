#!/usr/bin/env python3
"""
Git Safety Guard - PreToolUse hook for Claude Code
Blocks destructive git commands that can cause data loss.
"""

import json
import re
import sys

# Destructive patterns that should be blocked
DESTRUCTIVE_PATTERNS = [
    # git reset --hard (destroys uncommitted changes)
    (r'git\s+reset\s+.*--hard', 'git reset --hard destroys uncommitted changes. Use "git stash" first.'),

    # git checkout -- (discards uncommitted changes to files)
    (r'git\s+checkout\s+--\s+', 'git checkout -- discards uncommitted changes. Use "git stash" first.'),
    (r'git\s+checkout\s+\.\s*$', 'git checkout . discards all uncommitted changes. Use "git stash" first.'),

    # git restore without --staged (discards working tree changes)
    (r'git\s+restore\s+(?!.*--staged).*\S', 'git restore discards uncommitted changes. Use --staged or "git stash" first.'),

    # git clean -f (removes untracked files permanently)
    (r'git\s+clean\s+.*-[a-zA-Z]*f', 'git clean -f permanently removes untracked files. Use --dry-run first.'),

    # git push --force (overwrites remote history)
    (r'git\s+push\s+.*(-f|--force)', 'git push --force overwrites remote history. This is dangerous.'),

    # git branch -D (force deletes branch)
    (r'git\s+branch\s+.*-D', 'git branch -D force deletes a branch. Use -d for safe deletion.'),

    # git stash drop/clear (permanently removes stashed changes)
    (r'git\s+stash\s+(drop|clear)', 'git stash drop/clear permanently removes stashed changes.'),

    # git rebase without -i on main/master
    (r'git\s+rebase\s+.*(main|master)', 'Rebasing onto main/master can be destructive. Be careful.'),

    # rm -rf on non-temp directories
    (r'rm\s+(-rf|-fr|--recursive\s+--force)\s+(?!/tmp)(?!/var/tmp)\.?/', 'rm -rf can permanently delete important files.'),
]

# Safe patterns that should be allowed even if they match destructive patterns
SAFE_PATTERNS = [
    r'git\s+checkout\s+-b',           # Create new branch
    r'git\s+checkout\s+[a-zA-Z]',     # Switch to branch (not -- or .)
    r'git\s+clean\s+.*--dry-run',     # Dry run is safe
    r'git\s+clean\s+.*-n',            # -n is dry run
    r'git\s+restore\s+--staged',      # Unstaging is safe
    r'git\s+reset\s+(?!.*--hard)',    # Soft reset without --hard
    r'git\s+stash\s+(?!drop|clear)',  # stash push/pop/list are safe
]


def extract_command(tool_input: dict) -> str:
    """Extract the command string from tool input."""
    command = tool_input.get('command', '')

    # Handle shell wrappers like bash -c "..."
    shell_wrapper = re.search(r'(?:bash|sh|zsh)\s+-c\s+["\'](.+?)["\']', command)
    if shell_wrapper:
        command = shell_wrapper.group(1)

    return command


def is_safe_command(command: str) -> bool:
    """Check if command matches a known safe pattern."""
    for pattern in SAFE_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    return False


def check_destructive(command: str) -> tuple[bool, str]:
    """Check if command matches any destructive pattern."""
    for pattern, reason in DESTRUCTIVE_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True, reason
    return False, ""


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # If we can't parse input, allow the command
        print(json.dumps({"continue": True}))
        return

    tool_name = input_data.get('tool_name', '')
    tool_input = input_data.get('tool_input', {})

    # Only check Bash commands
    if tool_name != 'Bash':
        print(json.dumps({"continue": True}))
        return

    command = extract_command(tool_input)

    # Check if it's a known safe pattern first
    if is_safe_command(command):
        print(json.dumps({"continue": True}))
        return

    # Check for destructive patterns
    is_destructive, reason = check_destructive(command)

    if is_destructive:
        result = {
            "decision": "block",
            "reason": f"BLOCKED: {reason}\nCommand: {command}\n\nUse 'git stash' to save changes before running destructive commands."
        }
        print(json.dumps(result))
    else:
        print(json.dumps({"continue": True}))


if __name__ == '__main__':
    main()
