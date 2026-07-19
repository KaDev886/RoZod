# Boolean Schema

Only `true` or `false` — and optionally `"true"` / `"false"` strings.

```lua
local schema = RoZod.Boolean()
```

## Validation

```lua
local s = RoZod.Boolean()
s:IsValid(true)     -- true
s:IsValid(false)    -- true
s:IsValid(1)        -- false
s:IsValid("true")   -- false
```

## Coercion

```lua
s:Coerce(true)       -- true
s:Coerce(false)      -- false
s:Coerce("true")     -- true
s:Coerce("false")    -- false
s:Coerce("yes")      -- nil
s:Coerce(nil)        -- nil
```

Only the exact strings `"true"` and `"false"` (case-sensitive) get converted. Everything else returns `nil` (or `default` if set).
