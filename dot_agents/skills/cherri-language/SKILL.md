---
name: cherri-language
description: Write, review, debug, or explain Cherri programming language code for Apple Shortcuts. Use this skill whenever the user mentions Cherri, .cherri files, cherrilang.org language docs, Shortcuts code generation, Cherri actions/includes/functions/control flow/types, or asks to compile/debug/refactor a Cherri shortcut, even if they only describe an Apple Shortcut they want to build.
---

# Cherri Language

Use this skill to help users author, review, and troubleshoot Cherri code that compiles into Apple Shortcuts.

## First Steps

1. Identify whether the user is asking to author new Cherri code, review existing Cherri code, debug a compiler/runtime issue, or explain syntax.
2. If exact action names, argument order, output types, or include paths matter, verify them from the project or official docs before finalizing code.
3. Prefer small, idiomatic Cherri: constants for immutable values, variables only when mutation is needed, explicit includes for non-basic actions, and `nothing()` after unused outputs.
4. When editing code, compile or recommend compiling with `cherri file.cherri`; use `--debug` when diagnosis needs stack traces or plist output.

## Reference

Read `references/cherri-syntax.md` when writing or reviewing code. It summarizes syntax, pitfalls, CLI checks, and links into the official docs.

For exact standard action signatures, prefer the local compiler when available:

```bash
cherri --action=action_name
cherri main.cherri --action=action_name
cherri --docs=category --subcat=optional
```

If the compiler is unavailable or the action is not local, use the official action docs at `https://cherrilang.org/language/actions.html` and the relevant category page.

## Authoring Checklist

- Put `#include` directives before code that uses non-basic standard action categories.
- Add shortcut metadata such as `#define name`, `#define color`, and `#define glyph` when producing a complete shortcut file.
- Use `const name = ...` for immutable action outputs and values; use `@name` only when the value must be assigned, appended, or modified.
- Use string interpolation deliberately: constants interpolate as `{name}` and variables as `{@name}`.
- Use typed empty variables such as `@items: array`, `@message: text`, or `@obj: dictionary` instead of slow empty literals when practical.
- Make functions pure with explicit arguments; functions run in isolated shortcut instances and cannot read outer variables.
- Use control-flow output when it removes mutable state, for example `const result = if condition { ... } else { ... }`.
- Add `nothing()` after an action whose output should not feed the next action.
- Do not invent action signatures. If uncertain, say which signature must be checked and how.

## Debugging Checklist

- Reproduce with `cherri path/to/file.cherri` when a file exists.
- Use `cherri path/to/file.cherri --debug` for stack traces, verbose compilation, and `.plist` inspection.
- For undefined action errors, check whether the right `#include 'actions/category'` exists.
- For type errors, add explicit declarations or coercions such as `@value: text`, `@n.number`, or `@file.file`.
- For import/signing issues on non-macOS platforms, compile with `--hubsign` or a configured signing server.

## Output Style

When producing Cherri code, include only necessary explanation. If the code may need unverified action signatures, mark those assumptions explicitly and provide the `cherri --action=...` checks.
