#!/bin/bash
# Agent Skills Installer
# One-command installation for AI coding assistants

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
REPO="MrGKanev/agent-skills"
BRANCH="master"
TARGET="claude"  # claude, copilot, or cursor

show_help() {
    echo "Agent Skills Installer"
    echo ""
    echo "Usage:"
    echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/master/install.sh | bash"
    echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/master/install.sh | bash -s -- [options]"
    echo ""
    echo "Options:"
    echo "  --target=TARGET   Where to install: claude, copilot, cursor, all (default: claude)"
    echo "  --tag=TAG         Install specific version/tag (default: latest)"
    echo "  --project         Install to current project instead of global"
    echo "  --list            List available skills and exit"
    echo "  --help            Show this help"
    echo ""
    echo "Examples:"
    echo "  # Install to Claude Code (global)"
    echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/master/install.sh | bash"
    echo ""
    echo "  # Install to current project for Copilot"
    echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/master/install.sh | bash -s -- --target=copilot --project"
    echo ""
    echo "  # Install specific version"
    echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/master/install.sh | bash -s -- --tag=v1.0.0"
}

# Parse arguments
PROJECT_INSTALL=false
TAG=""
LIST_ONLY=false

for arg in "$@"; do
    case $arg in
        --target=*)
            TARGET="${arg#*=}"
            ;;
        --tag=*)
            TAG="${arg#*=}"
            BRANCH="$TAG"
            ;;
        --project)
            PROJECT_INSTALL=true
            ;;
        --list)
            LIST_ONLY=true
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
    esac
done

# Determine install directory
get_install_dir() {
    local target=$1
    local base_dir

    if [ "$PROJECT_INSTALL" = true ]; then
        base_dir="."
    else
        base_dir="$HOME"
    fi

    case $target in
        claude)
            echo "$base_dir/.claude"
            ;;
        copilot|vscode)
            echo "$base_dir/.github"
            ;;
        cursor)
            echo "$base_dir/.cursor"
            ;;
        *)
            echo "$base_dir/.claude"
            ;;
    esac
}

# Main installation
main() {
    echo -e "${BLUE}Agent Skills Installer${NC}"
    echo ""

    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    echo -e "${YELLOW}Downloading skills...${NC}"

    if [ -n "$TAG" ]; then
        DOWNLOAD_URL="https://github.com/$REPO/archive/refs/tags/$TAG.tar.gz"
        echo "Version: $TAG"
    else
        DOWNLOAD_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
        echo "Branch: $BRANCH"
    fi

    # Download and extract
    curl -fsSL "$DOWNLOAD_URL" | tar -xz -C "$TEMP_DIR" --strip-components=1

    # List only mode
    if [ "$LIST_ONLY" = true ]; then
        echo ""
        echo -e "${BLUE}Available skills:${NC}"
        echo ""
        echo -e "${GREEN}Upstream skills:${NC}"
        for skill in "$TEMP_DIR"/skills/*/; do
            if [ -f "${skill}SKILL.md" ]; then
                echo "  - $(basename "$skill")"
            fi
        done
        echo ""
        echo -e "${GREEN}Custom skills:${NC}"
        if [ -d "$TEMP_DIR/my-skills" ]; then
            found=false
            for skill in "$TEMP_DIR"/my-skills/*/; do
                if [ -d "$skill" ]; then
                    echo "  - $(basename "$skill")"
                    found=true
                fi
            done
            if [ "$found" = false ]; then
                echo "  (none)"
            fi
        fi
        exit 0
    fi

    # Install to target(s)
    install_to_target() {
        local target=$1
        local install_dir=$(get_install_dir "$target")
        local skills_dir="$install_dir/skills"

        echo -e "${YELLOW}Installing to $skills_dir...${NC}"

        # Create directory
        mkdir -p "$skills_dir"

        # Copy skills
        if [ -d "$TEMP_DIR/skills" ]; then
            cp -r "$TEMP_DIR/skills"/* "$skills_dir/" 2>/dev/null || true
        fi

        # Copy my-skills
        if [ -d "$TEMP_DIR/my-skills" ]; then
            for skill in "$TEMP_DIR"/my-skills/*/; do
                if [ -d "$skill" ]; then
                    cp -r "$skill" "$skills_dir/"
                fi
            done
        fi

        echo -e "${GREEN}Installed skills to: $skills_dir${NC}"

        # Install safety features based on target
        if [ -d "$TEMP_DIR/hooks" ]; then
            case $target in
                claude)
                    # Claude: Install executable hooks (real protection)
                    local hooks_dir="$install_dir/hooks"
                    echo -e "${YELLOW}Installing safety hooks to $hooks_dir...${NC}"

                    mkdir -p "$hooks_dir"

                    # Copy hook scripts
                    cp "$TEMP_DIR/hooks/"*.py "$hooks_dir/" 2>/dev/null || true
                    chmod +x "$hooks_dir/"*.py 2>/dev/null || true

                    # Merge or create settings.json with hooks config
                    local settings_file="$install_dir/settings.json"
                    local hooks_settings="$TEMP_DIR/hooks/settings.json"

                    if [ -f "$hooks_settings" ]; then
                        if [ -f "$settings_file" ]; then
                            cp "$settings_file" "$settings_file.backup"
                            echo -e "${YELLOW}Existing settings.json backed up${NC}"

                            python3 -c "
import json
try:
    with open('$settings_file', 'r') as f:
        existing = json.load(f)
except:
    existing = {}
with open('$hooks_settings', 'r') as f:
    hooks = json.load(f)
if 'hooks' not in existing:
    existing['hooks'] = {}
for event, event_hooks in hooks.get('hooks', {}).items():
    if event not in existing['hooks']:
        existing['hooks'][event] = []
    existing['hooks'][event].extend(event_hooks)
with open('$settings_file', 'w') as f:
    json.dump(existing, f, indent=2)
" 2>/dev/null || cp "$hooks_settings" "$settings_file"
                        else
                            cp "$hooks_settings" "$settings_file"
                        fi
                        echo -e "${GREEN}Installed safety hooks (blocks destructive commands)${NC}"
                    fi
                    ;;

                copilot)
                    # Copilot: Add safety rules to instructions file
                    local instructions_file="$install_dir/copilot-instructions.md"
                    local safety_rules="$TEMP_DIR/hooks/SAFETY_RULES.md"

                    if [ -f "$safety_rules" ]; then
                        echo -e "${YELLOW}Installing safety rules to copilot-instructions.md...${NC}"

                        if [ -f "$instructions_file" ]; then
                            # Append to existing file if not already present
                            if ! grep -q "Git Safety Rules" "$instructions_file" 2>/dev/null; then
                                echo "" >> "$instructions_file"
                                cat "$safety_rules" >> "$instructions_file"
                            fi
                        else
                            cp "$safety_rules" "$instructions_file"
                        fi
                        echo -e "${GREEN}Installed safety rules (text-based guidance)${NC}"
                    fi
                    ;;

                cursor)
                    # Cursor: Add safety rules to rules file
                    local rules_dir="$install_dir/rules"
                    local safety_rules="$TEMP_DIR/hooks/SAFETY_RULES.md"

                    if [ -f "$safety_rules" ]; then
                        echo -e "${YELLOW}Installing safety rules to .cursor/rules...${NC}"
                        mkdir -p "$rules_dir"
                        cp "$safety_rules" "$rules_dir/git-safety.md"
                        echo -e "${GREEN}Installed safety rules (text-based guidance)${NC}"
                    fi
                    ;;
            esac
        fi
    }

    if [ "$TARGET" = "all" ]; then
        install_to_target "claude"
        install_to_target "copilot"
        install_to_target "cursor"
    else
        install_to_target "$TARGET"
    fi

    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""

    # Show post-install info
    case $TARGET in
        claude)
            echo "For Claude Code:"
            echo "  - Skills installed globally"
            echo "  - Safety hooks installed (blocks destructive git commands)"
            echo ""
            echo "Restart Claude Code to activate."
            ;;
        copilot)
            echo "For GitHub Copilot:"
            echo "  - Skills installed"
            echo "  - Safety rules added to copilot-instructions.md"
            echo ""
            echo "Note: Safety rules are text-based guidance only."
            ;;
        cursor)
            echo "For Cursor:"
            echo "  - Skills installed"
            echo "  - Safety rules added to .cursor/rules/"
            echo ""
            echo "Note: Safety rules are text-based guidance only."
            ;;
        all)
            echo "Installed to all targets:"
            echo ""
            echo "Claude Code:"
            echo "  - Safety hooks (blocks destructive commands)"
            echo ""
            echo "Copilot & Cursor:"
            echo "  - Safety rules (text-based guidance)"
            echo ""
            echo "Restart your IDE/editor to activate."
            ;;
    esac
}

main "$@"
