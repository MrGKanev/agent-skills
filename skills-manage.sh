#!/bin/bash
# Skills Management Script
# Helps manage upstream skills and custom skills

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
MY_SKILLS_DIR="$SCRIPT_DIR/my-skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${BLUE}Skills Management Tool${NC}"
    echo ""
    echo "Usage: ./skills-manage.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  sync              Sync skills from upstream (Automattic/agent-skills)"
    echo "  list              List all available skills"
    echo "  new <name>        Create a new custom skill"
    echo "  info <name>       Show info about a specific skill"
    echo "  install           Install skills to Claude Code"
    echo "  help              Show this help message"
    echo ""
}

sync_upstream() {
    echo -e "${YELLOW}Fetching from upstream...${NC}"
    git fetch upstream

    echo -e "${YELLOW}Merging upstream/trunk...${NC}"
    git merge upstream/trunk -m "Sync with Automattic/agent-skills upstream"

    echo -e "${GREEN}Successfully synced with upstream!${NC}"
}

list_skills() {
    echo -e "${BLUE}=== Upstream Skills (Automattic/agent-skills) ===${NC}"
    if [ -d "$SKILLS_DIR" ]; then
        for skill in "$SKILLS_DIR"/*/; do
            if [ -f "${skill}SKILL.md" ]; then
                skill_name=$(basename "$skill")
                echo -e "  ${GREEN}$skill_name${NC}"
            fi
        done
    fi

    echo ""
    echo -e "${BLUE}=== Custom Skills (my-skills/) ===${NC}"
    if [ -d "$MY_SKILLS_DIR" ]; then
        found=false
        for skill in "$MY_SKILLS_DIR"/*/; do
            if [ -d "$skill" ]; then
                skill_name=$(basename "$skill")
                echo -e "  ${GREEN}$skill_name${NC}"
                found=true
            fi
        done
        if [ "$found" = false ]; then
            echo -e "  ${YELLOW}(no custom skills yet)${NC}"
        fi
    fi
}

create_skill() {
    local name="$1"
    if [ -z "$name" ]; then
        echo -e "${RED}Error: Please provide a skill name${NC}"
        echo "Usage: ./skills-manage.sh new <skill-name>"
        exit 1
    fi

    local skill_dir="$MY_SKILLS_DIR/$name"

    if [ -d "$skill_dir" ]; then
        echo -e "${RED}Error: Skill '$name' already exists${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Creating skill: $name${NC}"
    mkdir -p "$skill_dir/references"
    mkdir -p "$skill_dir/scripts"

    # Create SKILL.md template
    cat > "$skill_dir/SKILL.md" << 'SKILLTEMPLATE'
# <SKILL_NAME>

## Purpose
<!-- Describe what this skill teaches the AI to do -->

## When to Use
<!-- Describe when this skill should be activated -->

## Key Concepts
<!-- List the main concepts this skill covers -->

## Quick Reference
<!-- Add quick reference commands, patterns, or examples -->

## References
<!-- The AI will read files from the references/ folder for deeper knowledge -->
SKILLTEMPLATE

    # Replace placeholder
    sed -i '' "s/<SKILL_NAME>/$name/g" "$skill_dir/SKILL.md"

    echo -e "${GREEN}Created skill at: $skill_dir${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Edit $skill_dir/SKILL.md with your skill content"
    echo "  2. Add reference documents to $skill_dir/references/"
    echo "  3. Add helper scripts to $skill_dir/scripts/ (optional)"
}

show_skill_info() {
    local name="$1"
    if [ -z "$name" ]; then
        echo -e "${RED}Error: Please provide a skill name${NC}"
        exit 1
    fi

    local skill_dir=""
    if [ -d "$SKILLS_DIR/$name" ]; then
        skill_dir="$SKILLS_DIR/$name"
        echo -e "${BLUE}Source: Upstream (Automattic/agent-skills)${NC}"
    elif [ -d "$MY_SKILLS_DIR/$name" ]; then
        skill_dir="$MY_SKILLS_DIR/$name"
        echo -e "${BLUE}Source: Custom (my-skills/)${NC}"
    else
        echo -e "${RED}Error: Skill '$name' not found${NC}"
        exit 1
    fi

    echo -e "${BLUE}Path: $skill_dir${NC}"
    echo ""

    if [ -f "$skill_dir/SKILL.md" ]; then
        head -50 "$skill_dir/SKILL.md"
    fi
}

install_to_claude() {
    echo -e "${YELLOW}Installing skills to Claude Code...${NC}"

    # Run the skillpack install script if it exists
    if [ -f "$SCRIPT_DIR/shared/scripts/skillpack-install.mjs" ]; then
        node "$SCRIPT_DIR/shared/scripts/skillpack-install.mjs"
    else
        echo -e "${YELLOW}Note: skillpack-install.mjs not found${NC}"
        echo ""
        echo "To use skills with Claude Code, add to your .claude/settings.json:"
        echo ""
        echo '  "skills": {'
        echo '    "skillsDir": "'$SCRIPT_DIR'/skills"'
        echo '  }'
    fi
}

# Main command handler
case "${1:-help}" in
    sync)
        sync_upstream
        ;;
    list)
        list_skills
        ;;
    new)
        create_skill "$2"
        ;;
    info)
        show_skill_info "$2"
        ;;
    install)
        install_to_claude
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
