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

        echo -e "${GREEN}Installed to: $skills_dir${NC}"
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
    if [ "$TARGET" = "claude" ] || [ "$TARGET" = "all" ]; then
        echo "For Claude Code, skills are now available globally."
        echo "Restart Claude Code or start a new session to use them."
    fi
}

main "$@"
