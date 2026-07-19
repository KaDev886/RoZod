# Vector3 Schema

Vector3 values. Also accepts strings like `"1, 2, 3"`.

```lua
local schema = RoZod.Vector3()
```

## Validation

```lua
local s = RoZod.Vector3()

s:IsValid(Vector3.new(1, 2, 3))   -- true
s:IsValid("1, 2, 3")             -- false (string != Vector3)
```

## Coercion

```lua
s:Coerce(Vector3.new(1, 2, 3))    -- Vector3.new(1, 2, 3)
s:Coerce("1, 2, 3")              -- Vector3.new(1, 2, 3)
s:Coerce("1, 2")                 -- Vector3.new(1, 2, 0)
s:Coerce("abc")                  -- nil
s:Coerce(nil)                    -- nil
```

String format: comma-separated `x, y, z`. Missing values default to `0`.
