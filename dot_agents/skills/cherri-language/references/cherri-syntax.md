# Cherri Syntax Reference

Source docs: `https://cherrilang.org/language/` and linked language pages.

## CLI And Docs

- Compile: `cherri file.cherri`.
- Debug compile: `cherri file.cherri --debug`.
- Import on macOS with open: `cherri file.cherri --open`.
- Sign on non-macOS: `cherri file.cherri --hubsign`.
- Action lookup: `cherri --action=action_name`.
- Project action lookup: `cherri main.cherri --action=action_name`.
- Category docs: `cherri --docs=category --subcat=optional`.

## File Shape

```cherri
#include 'actions/device'

#define name My Shortcut
#define color yellow
#define glyph smileyFace

const deviceName = getDeviceDetail("Device Name")
show("Device: {deviceName}")
```

Use includes for standard action categories other than basic actions. Include paths use single quotes.

## Values

```cherri
const immutable = 5
@mutable = 5
@empty
@items: array
@obj: dictionary
```

- Constants are magic-variable style action output references and cannot be reassigned or appended.
- Variables create Set Variable actions and can be mutated with `+=`, `-=`, `*=`, and `/=`.
- Prefer constants for immutable values because they produce smaller shortcuts.
- Use typed empty variables instead of `""`, `[]`, or `{}` when practical.

## Interpolation And Access

```cherri
const immutable = 5
@mutable = 6
show("const={immutable}, var={@mutable}")

@dict = {"Name":"Ada"}
@name = @dict['Name']
@number = @dict['Count'].number
```

- Variables interpolate as `{@name}`.
- Constants and globals interpolate as `{name}` or `{ShortcutInput}`.
- Dictionary key access supports raw keys and type coercion suffixes.

## Common Types

- Primitive declarations: `text`, `number`, `bool`, `dictionary`, `array`, `var`, `float`.
- Content item coercions include `app`, `article`, `contact`, `date`, `email`, `folder`, `file`, `image`, `itunes`, `location`, `maplink`, `media`, `pdf`, `phonenumber`, `richtext`, `webpage`, `text`.
- Raw text uses single quotes and does not interpolate except escaped single quotes. It compiles faster but is not allowed inside JSON dictionary/array literals.
- `nil` can represent empty values and skip optional arguments.

## Globals And Ask

```cherri
@input = ShortcutInput
@date = CurrentDate
@clipboard = Clipboard
@device = Device
wait(Ask: 'How many seconds?')
@prompt = "My name is {Ask}"
```

Globals are case-sensitive. `Ask` is valid in action arguments or inline strings, not as a standalone variable value.

## Operators

- Arithmetic: `+`, `-`, `*`, `/`, `%`.
- Assignment: `=`, `+=`, `-=`, `*=`, `/=`.
- Conditional: `==`, `!=`, `contains`, `!contains`, `beginsWith`, `endsWith`, `>`, `>=`, `<`, `<=`, `isToday`.
- Between: `if @n <> 5 7 { ... }`.
- Logical conditions: all conditions must be joined by the same operator, `&&` or `||`.

## Control Flow

```cherri
if @name {
    show("Hello, {@name}")
} else {
    show("Hello")
}

repeat i for 6 {
    show("{@i}")
}

for item in @items {
    show("{@item}")
}
```

The first operand of an `if` comparison must be a variable. `repeat` and `for` create variables for repeat index and item.

Control flow can produce output:

```cherri
const result = if @deviceModel == "iPhone" {
    getCellularDetail("Carrier Name")
} else {
    getWifiDetail("Network Name")
}
```

Use control-flow output to avoid a mutable result variable when both branches produce a value.

## Menus

```cherri
const picked = menu "Choose" {
    item "One":
        text("1")
    item "Two":
        text("2")
}
```

Menus can be used like switch statements and can return output when assigned to a constant.

## Functions

```cherri
function add(number a, number b): number {
    const result = @a + @b
    output("{result}")
}

const sum = add(2, 2)
```

- Arguments are defined as `type name`.
- Optional arguments use `?name`.
- Literal-only arguments use `type! name`.
- Defaults use `type name = value`.
- Return with `output(...)` and optionally declare output type after `): type`.
- Functions run via `runSelf()` in isolated scope. Pass all needed data as arguments; outer variables are not accessible.

## Action Definitions And Raw Actions

Reusable custom action definition:

```cherri
action 'com.example.app.action' createNote(
    text title: 'title',
    text content: 'text'
)
```

Raw action:

```cherri
rawAction("is.workflow.actions.alert", {
    "WFAlertActionMessage": "Hello, world!",
    "WFAlertActionCancelButtonShown": false
})
```

For variable-only raw parameters, use `${@var}`:

```cherri
rawAction("is.workflow.actions.documentpicker.save", {
    "WFInput": "${@file}"
})
```

Prefer action definitions when a raw action will be reused.

## Best Practices

- Prefer constants over variables when values are immutable.
- Add `nothing()` after unused action output to prevent implicit input chaining.
- Avoid large top-level predefined arrays because they compile to repeated Add to Variable actions.
- Use default/optional action arguments only when needed; use `nil` to skip optional values before later arguments.
- Use raw text where interpolation is unnecessary and valid.
- Verify exact standard action signatures instead of guessing.
