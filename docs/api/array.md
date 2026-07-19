# Array Schema

Arrays where every element passes a schema.

```lua
local schema = RoZod.Array(RoZod.String())
```

If you don't pass an element schema, it defaults to `Any`.

## Modifiers

### `schema:MinLength(n)`

Too few elements won't pass.

```lua
local s = RoZod.Array(RoZod.Number()):MinLength(1)
s:IsValid({ 1, 2 })   -- true
s:IsValid({})          -- false
```

### `schema:MaxLength(n)`

Too many elements won't pass.

```lua
local s = RoZod.Array(RoZod.Number()):MaxLength(5)
s:IsValid({ 1, 2, 3 })     -- true
s:IsValid({ 1, 2, 3, 4, 5, 6 })  -- false
```

## Validation

```lua
local s = RoZod.Array(RoZod.Number():Min(0))

s:IsValid({ 1, 2, 3 })        -- true
s:IsValid({ 1, "bad", 3 })    -- false (string not allowed)
s:IsValid({ 1, -1, 3 })       -- false (-1 below min)
s:IsValid({ key = "value" })  -- false (not an array)
```

## Coercion

```lua
local s = RoZod.Array(RoZod.Number())

s:Coerce({ 1, "2", 3 })
-- { 1, 2, 3 }

s:Coerce("{ 1, 2, 3 }")
-- { 1, 2, 3 }

s:Coerce({ 1, "bad", 3 })
-- nil (couldn't coerce one element)
```

Each element goes through the array's element schema `Coerce`. If any element fails, the whole thing returns `nil`.
