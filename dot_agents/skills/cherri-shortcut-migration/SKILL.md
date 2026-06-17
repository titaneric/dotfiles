---
name: cherri-shortcut-migration
description: Migrate existing Apple Shortcuts into idiomatic Cherri code. Use this skill whenever the user mentions decompiling, importing, migrating, refactoring, version-controlling, or cleaning up an existing Shortcut, iCloud shortcut URL, .shortcut file, rawAction output, missing Cherri includes, third-party actions, or converting Shortcuts app workflows into .cherri files.
---

# Cherri Shortcut Migration

Use this skill to turn existing Apple Shortcuts into maintainable Cherri source and to refactor decompiled output into idiomatic code.

## Workflow

1. Identify the source: iCloud Shortcut URL, unsigned `.shortcut` file, existing decompiled `.cherri`, or pasted raw action output.
2. If a URL or file is available, decompile with `cherri --import=...` before manual rewriting.
3. Expect decompiled code to be functional but not idiomatic. Standard actions may map correctly, third-party actions may remain `rawAction(...)`, and includes may be missing.
4. Refactor in small passes: includes, constants, duplicate code, control-flow output, helper files, third-party action wrappers, and unused outputs.
5. Verify by compiling, comparing behavior against the original, and testing on device.

## Reference

Read `references/migration.md` for the migration playbook, common fixes, and troubleshooting.

If exact action signatures are needed, check them locally when possible:

```bash
cherri --action=action_name
cherri migrated.cherri --action=action_name
```

## Refactoring Priorities

- Add missing `#include 'actions/category'` directives before using standard actions outside the basic set.
- Convert immutable `@variable = value` assignments to `const name = value` when the value is never changed.
- Replace duplicated action sequences with functions, but pass all data explicitly because functions use isolated scope.
- Use control-flow output instead of mutable placeholder variables when branches naturally return a value.
- Split large shortcuts into `main.cherri`, `config.cherri`, and focused helper includes when it improves readability.
- Keep third-party actions as `rawAction(...)` only once; wrap repeated third-party actions in reusable `action` definitions.
- Add `nothing()` after expensive or irrelevant outputs that should not feed later actions.

## Verification

- Compile: `cherri migrated.cherri`.
- Debug and inspect plist: `cherri migrated.cherri --debug`.
- On non-macOS platforms, sign with `--hubsign` or a configured signing server before importing.
- Test valid inputs, edge cases, all conditionals, and menu branches on device.
- Compare important outputs and side effects with the original shortcut.

## Output Style

When proposing a migration, separate mechanical decompile steps from idiomatic refactors. If action signatures or app-specific parameters are unverified, call that out instead of inventing them.
