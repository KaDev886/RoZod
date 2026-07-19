# Core Concepts

## What is a Schema?

A schema describes the shape and constraints of a value. You create one with a constructor function (`RoZod.String()`, `RoZod.Object({...})`) and chain modifiers onto it.

```lua
local schema = RoZod.Number():Min(1):Max(100)
```

## Validation vs Coercion

RoZod has two modes:

### Validation

`IsValid` and `Validate` check a value against the schema.

- `IsValid` returns `true` or `false`
- `Validate` prints a message depending on the schema's policy (error, warn, or silent)

```lua
local schema = RoZod.Number():Min(1)

print(schema:IsValid(5))    -- true
print(schema:IsValid(-1))   -- false
```

### Coercion

`Coerce` tries to return a valid value. If it can't convert it, it returns `nil` or a default value if one was set on the schema.

```lua
local schema = RoZod.Number():Min(1)

print(schema:Coerce(5))      -- 5 stays as is
print(schema:Coerce("3"))    -- "3" gets converted to 3
print(schema:Coerce(-5))     -- 1 (clamped)
print(schema:Coerce("abc"))  -- nil (couldn't coerce it)
```

## Policies

Policies control what `Validate` does with bad data:

| Policy | Effect |
|--------|--------|
| `Error` | Calls `error()` — stops |
| `Warn` | Calls `warn()` — keeps going |
| `Silent` | Does nothing |

```lua
-- Default policy for all schemas (Error by default)
RoZod.setGlobalConfig({ defaultPolicy = "Warn" })

-- This schema overrides its policy from Warn to Silent
local schema = RoZod.String():Silent()
```

Policies propagate to child schemas. For example, if the parent's policy is `Warn`, the child also gets `Warn`. But if the child overrides its policy, it won't inherit the parent's.

## Modifiers

These work on every schema:

| Modifier | What it does |
|----------|-------------|
| `:OneOf({...})` | Only these values are allowed |
| `:Optional()` | `nil` is valid |
| `:Default(x)` | Fallback when value is `nil` or coercion can't fix it |
| `:Silent()` | Policy override |
| `:Warn()` | Policy override |
| `:Error()` | Policy override |

```lua
local schema = RoZod.String()
    :OneOf({ "admin", "user", "guest" })
    :Optional()
    :Default("guest")
    :Warn()
```

## Type-specific modifiers

| Schema | Modifiers |
|--------|-----------|
| `Number` | `:Min(n)`, `:Max(n)` |
| `String` | `:MinLength(n)`, `:MaxLength(n)` |
| `Array` | `:MinLength(n)`, `:MaxLength(n)` |
| `Record` | `:MinLength(n)`, `:MaxLength(n)` |
| `Object` | `:Extra()` |
| `Instance` | `:IsA("ClassName")` |
