# Record Schema

Dictionaries where keys and values each have their own schema. Unlike `Object`, there's no fixed shape — it validates every key-value pair uniformly.

```lua
local schema = RoZod.Record(RoZod.String(), RoZod.Number())
```

Omitting a schema defaults it to `Any`.

## Modifiers

### `schema:MinLength(n)`

```lua
local s = RoZod.Record(RoZod.String(), RoZod.Number()):MinLength(1)
s:IsValid({ a = 1 })   -- true
s:IsValid({})          -- false
```

### `schema:MaxLength(n)`

```lua
local s = RoZod.Record(RoZod.String(), RoZod.Number()):MaxLength(3)
s:IsValid({ a = 1, b = 2 })        -- true
s:IsValid({ a = 1, b = 2, c = 3, d = 4 })  -- false
```

## Validation

```lua
local s = RoZod.Record(RoZod.String(), RoZod.Number())

s:IsValid({ apples = 5, oranges = 3 })   -- true
s:IsValid({ name = "John" })             -- false (value isn't a number)
s:IsValid({ [1] = "value" })             -- false (key isn't a string)
```

## Coercion

```lua
local s = RoZod.Record(RoZod.String(), RoZod.Number())

s:Coerce({ key = "42" })
-- { key = 42 }

s:Coerce("{ a = 1, b = 2 }")
-- { a = 1, b = 2 }

s:Coerce({ key = "bad" })
-- nil (couldn't coerce the value)
```

Keys and values are coerced individually. If any key or value can't be coerced, the whole thing returns `nil`.
