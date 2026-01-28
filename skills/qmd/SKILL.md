---
name: qmd
description: "Use for local hybrid search across markdown notes, documentation, and knowledge bases. Ideal for finding related content, retrieving documents from indexed collections, or searching personal notes."
compatibility: "Requires Bun >= 1.0.0. macOS needs SQLite via brew. Works on darwin and linux. PATH must include $HOME/.bun/bin."
homepage: https://github.com/tobi/qmd
---

# QMD - Quick Markdown Search

Local search engine for Markdown notes, docs, and knowledge bases. Index once, search fast.

## When to use

Use this skill when the user wants to:

- search notes, docs, or a knowledge base
- find related markdown content
- retrieve documents from indexed collections
- search local markdown files for specific topics or keywords

## Inputs required

- Collection name or path to markdown files
- Search query (keywords or semantic intent)
- Preferred search mode (keyword vs semantic vs hybrid)

## Procedure

### 0) Verify installation

Check if qmd is installed:

```bash
which qmd || echo "qmd not installed"
```

If not installed:

```bash
# Install Bun first (macOS)
brew install oven-sh/bun/bun

# macOS also needs SQLite
brew install sqlite

# Install qmd globally
bun install -g https://github.com/tobi/qmd
```

### 1) Set up a collection (first time only)

```bash
# Add a collection with path and file mask
qmd collection add /path/to/notes --name notes --mask "**/*.md"

# Optional: add context description
qmd context add qmd://notes "Personal notes and documentation"

# Enable semantic search (one-time, can be slow)
qmd embed
```

### 2) Choose the right search mode

**Default to `qmd search` (BM25 keyword matching)**
- Instant results
- Best for exact terms, filenames, specific phrases

**Use `qmd vsearch` only when keyword search fails**
- Semantic similarity via vectors
- Can take ~60 seconds on cold start (loads local LLM model)
- Better for conceptual queries

**Avoid `qmd query` unless explicitly requested**
- Hybrid search with LLM reranking
- Slowest option, may timeout
- Only when highest quality results are worth the wait

### 3) Execute the search

```bash
# Default keyword search (fastest)
qmd search "your query"

# Search specific collection
qmd search "query" -c notes

# More results
qmd search "query" -n 10

# JSON output for parsing
qmd search "query" --json

# All matches above threshold
qmd search "query" --all --min-score 0.3

# Semantic search (last resort)
qmd vsearch "query"
```

### 4) Retrieve full documents

```bash
# By file path
qmd get "path/to/file.md"

# By document ID from search results
qmd get "#docid"

# Multiple documents
qmd multi-get "journals/2025-05*.md"
qmd multi-get "doc1.md, doc2.md, #abc123" --json
```

## Verification

- `qmd status` shows index health and collection info
- Search returns relevant results with scores
- Document retrieval works for indexed files

## Maintenance

Keep indexes fresh:

```bash
# Re-index changed files (fast)
qmd update

# Update embeddings (slower, for semantic search)
qmd embed
```

Optional cron automation:

```bash
# Hourly keyword index update
0 * * * * export PATH="$HOME/.bun/bin:$PATH" && qmd update

# Nightly embedding refresh
0 5 * * * export PATH="$HOME/.bun/bin:$PATH" && qmd embed
```

## Failure modes / debugging

- **Search returns nothing:**
  - Check collection exists: `qmd status`
  - Verify files match the mask pattern
  - Run `qmd update` to refresh index

- **Semantic search is very slow:**
  - Normal on cold start (~60s) - model loading
  - Consider keeping process warm for repeated searches
  - Default to keyword search when possible

- **vsearch/query times out:**
  - Local LLM model loading can be slow
  - Fall back to `qmd search` for immediate results

- **Collection not found:**
  - List collections: `qmd collection list`
  - Re-add if missing: `qmd collection add /path --name name --mask "**/*.md"`

## Escalation

- For detailed usage, see: https://github.com/tobi/qmd
- Use `qmd --help` or `qmd <command> --help` for command-specific options

## Important distinction

- `qmd` searches **local files** (notes/docs on disk that you index)
- Agent memory search searches **agent memory** (saved facts from prior interactions)
- Use both: memory for "what did we discuss?", qmd for "what's in my notes?"
