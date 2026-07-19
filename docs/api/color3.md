# Color3 Schema

RGB color values. Also accepts strings like `"0.5, 1, 0.25"`.

```lua
local schema = RoZod.Color3()
```

## Validation

```lua
local s = RoZod.Color3()

s:IsValid(Color3.new(1, 0, 0))   -- true (red)
s:IsValid("1, 0, 0")            -- false (string != Color3)
```

## Coercion

```lua
s:Coerce(Color3.new(0.5, 1, 0.25))    -- Color3.new(0.5, 1, 0.25)
s:Coerce("0.5, 1, 0.25")             -- Color3.new(0.5, 1, 0.25)
s:Coerce("1, 0")                     -- Color3.new(1, 0, 0)
s:Coerce("abc")                      -- nil
s:Coerce(nil)                        -- nil
```

String format: comma-separated `r, g, b` floats (0–1 range). Missing channels default to `0`.
