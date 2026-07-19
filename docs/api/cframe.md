# CFrame Schema

CFrame values. Also accepts Vector3 (position-only) and strings.

```lua
local schema = RoZod.CFrame()
```

## Validation

```lua
local s = RoZod.CFrame()

s:IsValid(CFrame.new(1, 2, 3))          -- true
s:IsValid(Vector3.new(1, 2, 3))        -- false (Vector3 != CFrame)
```

## Coercion

```lua
s:Coerce(CFrame.new(1, 2, 3))           -- CFrame.new(1, 2, 3)
s:Coerce(Vector3.new(1, 2, 3))         -- CFrame.new(1, 2, 3)
s:Coerce("1, 2, 3")                    -- CFrame.new(1, 2, 3)
s:Coerce("abc")                        -- nil
s:Coerce(nil)                          -- nil
```

Accepts Vector3 (converts to a position-only CFrame) and strings in the same comma-separated format as Vector3.
