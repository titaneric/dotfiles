# Cherri Migration Reference

Source doc: `https://cherrilang.org/migration.html`.

## Decompile

From an iCloud URL:

```bash
cherri --import=https://www.icloud.com/shortcuts/abc123def456
```

From a local unsigned `.shortcut` file:

```bash
cherri --import=path/to/MyShortcut.shortcut
```

No output means success. A decompiled `.cherri` file is created in the current directory.

## What Decompiled Code Usually Needs

- Missing `#include` directives for standard action categories.
- `rawAction(...)` calls for third-party actions or standard actions not in Cherri's standard library.
- Magic-variable-like references that can be made clearer with constants.
- Repeated action sequences that should become functions.
- Mutable placeholders that can become control-flow output.
- Large single files that should be split into includes.
- Unused action outputs that should be cleared with `nothing()`.

## Include Fix

Before:

```cherri
#define color blue
#define glyph hand

const location = getCurrentLocation()
const weather = getCurrentWeather(location)
```

After:

```cherri
#include 'actions/location'

#define color blue
#define glyph hand

const location = getCurrentLocation()
const weather = getCurrentWeather(location)
```

For undefined standard actions, check action docs with `cherri --action=action_name` or the relevant docs category.

## Constants Over Variables

Before:

```cherri
@number = 42
show("{@number}")
```

After:

```cherri
const number = 42
show("{number}")
```

Use `const` for values that never change. It produces smaller shortcuts than mutable variables.

## Duplicate Code To Functions

Before:

```cherri
@price1 = 10
@tax1 = @price1 * 0.08
@total1 = @price1 + @tax1

@price2 = 20
@tax2 = @price2 * 0.08
@total2 = @price2 + @tax2
```

After:

```cherri
function calculateTotal(number price): number {
    const tax = @price * 0.08
    const total = @price + tax
    output("{total}")
}

const total1 = calculateTotal(10)
const total2 = calculateTotal(20)
```

Functions cannot read outer variables. Pass every required value as an argument.

## Control Flow Output

Before:

```cherri
const condition = true
@result
if condition {
    @result = "Yes"
} else {
    @result = "No"
}
show("{@result}")
```

After:

```cherri
const condition = true
const result = if condition {
    text("Yes")
} else {
    text("No")
}
show("{result}")
```

## Split Large Shortcuts

`main.cherri`:

```cherri
#include 'config.cherri'
#include 'helpers.cherri'
#include 'actions/network'

// Main logic here
```

`config.cherri`:

```cherri
#define name My Shortcut
#define color yellow
#define glyph smileyFace

const API_URL = "https://api.example.com"
const TIMEOUT = 30
```

`helpers.cherri`:

```cherri
function validateInput(text input): bool {
    // implementation
    output("{isValid}")
}
```

## Third-Party Actions

Keep one-off app actions raw:

```cherri
rawAction("net.shinyfrog.bear.create-note", {
    "title": "My Note",
    "text": "{content}"
})
```

Wrap repeated app actions:

```cherri
action 'net.shinyfrog.bear.create-note' createBearNote(
    text title: 'title',
    text content: 'text'
)

createBearNote("My Note", "{content}")
```

Do not invent parameter keys. Extract them from shortcut data or verify against docs/app output.

## Unused Outputs

```cherri
heavyAction()
nothing()
```

Use `nothing()` when an output should not implicitly feed the next action.

## Troubleshooting

- Standard action appears as `rawAction(...)`: it may be missing from Cherri's standard library. Define a custom action, keep raw, or report it upstream.
- Missing action include: add the appropriate `#include 'actions/category'`.
- Type errors: add explicit type annotations or coercions, such as `@myVar: text` or `@value.number`.
- Shortcut will not import on device: ensure it is signed; on non-macOS use `--hubsign`.

## Testing

```bash
cherri migrated.cherri
cherri migrated.cherri --debug
```

Then test on device with valid inputs, edge cases, all conditional branches, and menu options. Compare outputs and side effects with the original shortcut.
