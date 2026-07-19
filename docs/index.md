# RoZod

Runtime schema validation for Roblox Luau.

## Why

Data from DataStores, RemoteEvents, or external sources can be anything. RoZod checks it against a schema and optionally fixes it.

- Validate data structures at runtime
- Catch invalid values early
- Fix common issues automatically
- Apply the same rules everywhere

## Example

```lua
local schema = RoZod.String()

print(schema:IsValid("John")) -- true
print(schema:IsValid(123))    -- false
```

## Supported types

| Schema | Description |
|--------|-------------|
| `Any` | Accepts anything |
| `String` | With MinLength / MaxLength |
| `Number` | With Min / Max range |
| `Boolean` | True or false |
| `Object` | Dictionary with a fixed shape |
| `Array` | Typed sequential list |
| `Record` | Map with typed keys and values |
| `Enum` | Roblox Enum / EnumItem |
| `Instance` | Roblox Instance, optionally filtered by class |
| `Vector3` | Position |
| `CFrame` | Position + rotation |
| `Color3` | RGB color |

## Methods

| Method | What it does |
|--------|-------------|
| `IsValid(value)` | Returns `true` or `false` |
| `Validate(value)` | Throws or warns depending on the policy |
| `Coerce(value)` | Tries to fix the value, returns `nil` if it can't |

## Quick links

- [Installation](installation.md)
- [Getting Started](getting-started.md)
- [Core Concepts](core-concepts.md)
- [API Reference](api/base-schema.md)
- [Error Handling](error-handling.md)
- [Examples](examples/player-data.md)
- [Benchmarks](../BENCHMARKS.md)
- [Contributing](../CONTRIBUTING.md)
