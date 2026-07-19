# Any Schema

Accepts anything. Useful as a placeholder or as the default element type for `Array` and `Record`.

```lua
local schema = RoZod.Any()
```

## Validation

```lua
local s = RoZod.Any()

s:IsValid("any string")  -- true
s:IsValid(42)            -- true
s:IsValid(true)          -- true
s:IsValid({})            -- true
s:IsValid(nil)           -- false (unless :Optional())
```

## Coercion

Returns the value as-is, unless `nil` and a default is set.

```lua
local s = RoZod.Any()

s:Coerce("hello")     -- "hello"
s:Coerce(42)          -- 42
s:Coerce(nil)         -- nil
```
