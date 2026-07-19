# Object Schema

Dictionaries with a fixed shape. Each key maps to a schema.

```lua
local schema = RoZod.Object({
    Name = RoZod.String(),
    Age = RoZod.Number(),
    Email = RoZod.String():Optional(),
})
```

## Modifiers

### `schema:Extra()`

By default, objects reject keys that aren't in the shape. `:Extra()` lets unknown keys through.

```lua
local strict = RoZod.Object({ name = RoZod.String() })
strict:IsValid({ name = "John", extra = 1 })  -- false

local relaxed = RoZod.Object({ name = RoZod.String() }):Extra()
relaxed:IsValid({ name = "John", extra = 1 })  -- true
```

## Validation

```lua
local s = RoZod.Object({
    key = RoZod.String(),
    opt = RoZod.String():Optional(),
})

s:IsValid({ key = "hello" })              -- true
s:IsValid({ key = "hello", opt = "x" })   -- true
s:IsValid({ key = "hello", bad = "x" })   -- false (extra key)
s:IsValid({})                             -- false (missing required key)
s:IsValid("not a table")                  -- false
```

## Coercion

```lua
local s = RoZod.Object({
    x = RoZod.Number(),
    y = RoZod.Number(),
})

s:Coerce({ x = "1.5", y = "2.5" })
-- { x = 1.5, y = 2.5 }

s:Coerce("{ x = 10, y = 20 }")
-- { x = 10, y = 20 }

s:Coerce({ x = 1, y = 2, extra = 3 })
-- { x = 1, y = 2 }  (extra keys removed unless :Extra() is set)
```

Coercion runs each value through its schema's `Coerce`, removes extra keys (unless `:Extra()` is set), and returns `nil` if the input can't be parsed as a dictionary.
