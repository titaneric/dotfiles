## Version control
 
- Use GitButler (`but`) for version-control write operations, including
  branching, committing, pushing, and history edits.
- Assume multiple agents may be working in this repository. Do not move, amend,
  squash, discard, commit, push, or otherwise modify another agent's work unless
  the user asks.
- Use a dedicated GitButler branch for each agent session, unless the user asks
  for a different branch structure. Commit only changes that belong to that
  session.
- Do not push or open pull requests unless the user asks.
- Keep commit messages and pull request descriptions succinct: explain what
  changed, why it changed, and any important decision.
- For small cleanup or follow-up fixes, amend an unpublished local commit when
  the change clearly belongs with that commit's intent.
- Do not create tiny fixup commits unless I ask.
- Use GitButler to move the relevant changes into the commit where they belong.
- Ask before rewriting pushed, reviewed, shared, or ambiguous history.
- Commit after a working checkpoint, when the requested change is complete and
  relevant checks have passed or been reported.
- Treat checkpoint commits as local savepoints, not final review history.
- When I ask you to tidy the history, use GitButler to squash commits, reword
  commits, and move changes between commits where appropriate.
- Only tidy unpublished local history unless I explicitly authorize changing
  pushed or shared history.
- If this session depends on another in-flight branch, stack its branch on top
  of that dependency instead of mixing the changes.
- If this session is working in a stack, put commits on the branch where they
  belong.
- Ask before moving commits onto lower, pushed, reviewed, or shared branches.
- Use `but move` for branch stacking and restacking. Do not recreate branches
  to simulate stacking.
- For stacked branches, create pull requests with `but pr`, not `gh`, so
  GitButler keeps the right PR base branches and stack metadata.
- If the target repo is GitHub Enterprise Server, use the `gh` CLI to push and
  submit the PR, not `but pr`.
- If a pull request template exists in the repo, follow the template in the PR
  description when submitting the PR. Check common locations such as
  `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`,
  `pull_request_template.md`, `docs/pull_request_template.md`, and
  `.github/PULL_REQUEST_TEMPLATE/*.md`.
- Use Conventional Commits, such as `feat: add branch naming policy` or
  `fix: handle empty branch names`.
- When I say "ship it", commit this session's changes on its dedicated
  GitButler branch, creating one if needed.
- Push the branch and open or update its pull request with GitButler.
- Reuse the existing branch or pull request for this session when one already
  exists.
- Before squashing, splitting, moving commits between branches, or reorganizing
  multiple branches, run `but oplog snapshot -m "<reason>"`.
- Use GitButler history-edit commands such as `but move`, `but squash`,
  `but reword`, `but absorb`, and `but amend` instead of raw Git rebases.
- If an operation makes the branch or history layout worse, stop and inspect the
  operation log before attempting another fix.
- Prefer `but undo` or `but oplog restore` over trying to repair a bad state
  with more history edits.
- If one file contains unrelated changes, split them by hunk instead of
  committing the whole file.
- Keep tests with the behavior they verify.
- Split generated output, docs-only edits, or mechanical cleanup into separate
  commits when each commit remains coherent on its own.
- If the split is ambiguous, summarize the options before committing.

## ALWAYS START WITH THESE COMMANDS FOR COMMON TASKS

**Task: "List/summarize all files and directories"**

```bash
fd . -t f           # Lists ALL files recursively (FASTEST)
# OR
rg --files          # Lists files (respects .gitignore)
```

**Task: "Search for content in files"**

```bash
rg "search_term"    # Search everywhere (FASTEST)
```

**Task: "Find files by name"**

```bash
fd "filename"       # Find by name pattern (FASTEST)
```

### Directory/File Exploration

```bash
# FIRST CHOICE - List all files/dirs recursively:
fd . -t f           # All files (fastest)
fd . -t d           # All directories
rg --files          # All files (respects .gitignore)

# For current directory only:
ls -la              # OK for single directory view
```

### BANNED - Never Use These Slow Tools

* ❌ `tree` - NOT INSTALLED, use `fd` instead
* ❌ `find` - use `fd` or `rg --files`
* ❌ `grep` or `grep -r` - use `rg` instead
* ❌ `ls -R` - use `rg --files` or `fd`
* ❌ `cat file | grep` - use `rg pattern file`

### Use These Faster Tools Instead

```bash
# ripgrep (rg) - content search 
rg "search_term"                # Search in all files
rg -i "case_insensitive"        # Case-insensitive
rg "pattern" -t py              # Only Python files
rg "pattern" -g "*.md"          # Only Markdown
rg -1 "pattern"                 # Filenames with matches
rg -c "pattern"                 # Count matches per file
rg -n "pattern"                 # Show line numbers 
rg -A 3 -B 3 "error"            # Context lines
rg " (TODO| FIXME | HACK)"      # Multiple patterns

# ripgrep (rg) - file listing 
rg --files                      # List files (respects •gitignore)
rg --files | rg "pattern"       # Find files by name 
rg --files -t md                # Only Markdown files 

# fd - file finding 
fd -e js                        # All •js files (fast find) 
fd -x command {}                # Exec per-file 
fd -e md -x ls -la {}           # Example with ls 

# jq - JSON processing 
jq. data.json                   # Pretty-print 
jq -r .name file.json           # Extract field 
jq '.id = 0' x.json             # Modify field
```

### Search Strategy

1. Start broad, then narrow: `rg "partial" | rg "specific"`
2. Filter by type early: `rg -t python "def function_name"`
3. Batch patterns: `rg "(pattern1|pattern2|pattern3)"`
4. Limit scope: `rg "pattern" src/`

### INSTANT DECISION TREE

```
User asks to "list/show/summarize/explore files"?
  → USE: fd . -t f  (fastest, shows all files)
  → OR: rg --files  (respects .gitignore)

User asks to "search/grep/find text content"?
  → USE: rg "pattern"  (NOT grep!)

User asks to "find file/directory by name"?
  → USE: fd "name"  (NOT find!)

User asks for "directory structure/tree"?
  → USE: fd . -t d  (directories) + fd . -t f  (files)
  → NEVER: tree (not installed!)

Need just current directory?
  → USE: ls -la  (OK for single dir)
```
