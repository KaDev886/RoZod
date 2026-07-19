# Number Schema

Numbers with optional min/max range.

```lua
local schema = RoZod.Number()
```

## Modifiers

### `schema:Min(value)`

Anything below this gets clamped or rejected.

```lua
local s = RoZod.Number():Min(0)
s:IsValid(5)    -- true
s:IsValid(-1)   -- false
```

### `schema:Max(value)`

Anything above this gets clamped or rejected.

```lua
local s = RoZod.Number():Max(100)
s:IsValid(50)   -- true
s:IsValid(200)  -- false
```

## Coercion

```lua
local s = RoZod.Number():Min(0):Max(100)

s:Coerce(42)        -- 42
s:Coerce("42")      -- 42       (tonumber)
s:Coerce(-10)       -- 0        (clamped)
s:Coerce(200)       -- 100      (clamped)
s:Coerce(nil)       -- nil
s:Coerce("abc")     -- nil      (can't convert)
```

Numbers below `min` get bumped up to `min`. Numbers above `max` get brought down to `max`. Non-numeric strings return `nil` (or `default` if you set one).
