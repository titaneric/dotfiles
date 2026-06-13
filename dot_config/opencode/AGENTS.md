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
