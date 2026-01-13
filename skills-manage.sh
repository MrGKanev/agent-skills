#!/bin/bash
# Skills & Evals Management Script
# Helps manage upstream skills, custom skills, and eval scenarios

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
MY_SKILLS_DIR="$SCRIPT_DIR/my-skills"
EVALS_DIR="$SCRIPT_DIR/eval/scenarios"
MY_EVALS_DIR="$SCRIPT_DIR/my-evals"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${BLUE}Skills & Evals Management Tool${NC}"
    echo ""
    echo "Usage: ./skills-manage.sh <command> [options]"
    echo ""
    echo -e "${GREEN}Skills Commands:${NC}"
    echo "  list              List all available skills"
    echo "  new <name>        Create a new custom skill"
    echo "  info <name>       Show info about a specific skill"
    echo ""
    echo -e "${GREEN}Eval Commands:${NC}"
    echo "  evals             List all eval scenarios"
    echo "  new-eval <name>   Create a new custom eval scenario"
    echo "  run-evals         Run eval validation"
    echo ""
    echo -e "${GREEN}Other Commands:${NC}"
    echo "  sync              Sync from upstream (Automattic/agent-skills)"
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
    echo -e "${BLUE}=== Upstream Skills ===${NC}"
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
            echo -e "  ${YELLOW}(none)${NC}"
        fi
    fi
}

list_evals() {
    echo -e "${BLUE}=== Upstream Evals ===${NC}"
    if [ -d "$EVALS_DIR" ]; then
        for eval_file in "$EVALS_DIR"/*.json; do
            if [ -f "$eval_file" ]; then
                eval_name=$(basename "$eval_file" .json)
                echo -e "  ${GREEN}$eval_name${NC}"
            fi
        done
    fi

    echo ""
    echo -e "${BLUE}=== Custom Evals (my-evals/) ===${NC}"
    if [ -d "$MY_EVALS_DIR" ]; then
        found=false
        for eval_file in "$MY_EVALS_DIR"/*.json; do
            if [ -f "$eval_file" ]; then
                eval_name=$(basename "$eval_file" .json)
                echo -e "  ${GREEN}$eval_name${NC}"
                found=true
            fi
        done
        if [ "$found" = false ]; then
            echo -e "  ${YELLOW}(none)${NC}"
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

    # Create SKILL.md template with frontmatter
    cat > "$skill_dir/SKILL.md" << EOF
---
name: $name
description: TODO - Add description
compatibility: Works with any project
---

# $name

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
EOF

    echo -e "${GREEN}Created skill at: $skill_dir${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Edit $skill_dir/SKILL.md with your skill content"
    echo "  2. Add reference documents to $skill_dir/references/"
    echo "  3. Add helper scripts to $skill_dir/scripts/ (optional)"
}

create_eval() {
    local name="$1"
    if [ -z "$name" ]; then
        echo -e "${RED}Error: Please provide an eval name${NC}"
        echo "Usage: ./skills-manage.sh new-eval <eval-name>"
        exit 1
    fi

    local eval_file="$MY_EVALS_DIR/$name.json"

    if [ -f "$eval_file" ]; then
        echo -e "${RED}Error: Eval '$name' already exists${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Creating eval: $name${NC}"
    mkdir -p "$MY_EVALS_DIR"

    # Create eval JSON template
    cat > "$eval_file" << EOF
{
  "name": "$name",
  "skills": ["skill-1", "skill-2"],
  "query": "What should the AI do in this scenario?",
  "expected_behavior": [
    "Step 1: First action",
    "Step 2: Second action",
    "Step 3: Third action"
  ],
  "success_criteria": [
    "Criterion 1: What must happen",
    "Criterion 2: What must be verified"
  ]
}
EOF

    echo -e "${GREEN}Created eval at: $eval_file${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Edit $eval_file"
    echo "  2. Update 'skills' array with skills being tested"
    echo "  3. Write the scenario query"
    echo "  4. Define expected behavior steps"
    echo "  5. Set success criteria"
}

run_evals() {
    echo -e "${YELLOW}Running eval validation...${NC}"

    if [ -f "$SCRIPT_DIR/eval/harness/run.mjs" ]; then
        node "$SCRIPT_DIR/eval/harness/run.mjs"
    else
        echo -e "${RED}Error: eval/harness/run.mjs not found${NC}"
        exit 1
    fi
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
        echo -e "${BLUE}Source: Upstream${NC}"
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
    evals)
        list_evals
        ;;
    new)
        create_skill "$2"
        ;;
    new-eval)
        create_eval "$2"
        ;;
    run-evals)
        run_evals
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
