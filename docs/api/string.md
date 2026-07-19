# String Schema

String values with optional length limits.

```lua
local schema = RoZod.String()
```

## Modifiers

### `schema:MinLength(n)`

Short strings won't pass.

```lua
local s = RoZod.String():MinLength(3)
s:IsValid("abc")    -- true
s:IsValid("ab")     -- false
```

### `schema:MaxLength(n)`

Long strings won't pass.

```lua
local s = RoZod.String():MaxLength(10)
s:IsValid("short")  -- true
s:IsValid("a very long string")  -- false
```

## Coercion

```lua
local s = RoZod.String():MinLength(1):MaxLength(10)

s:Coerce("hello")            -- "hello"
s:Coerce(123)                -- "123"       (tostring)
s:Coerce("")                 -- nil         (too short)
s:Coerce("very long string") -- nil         (too long)
s:Coerce(nil)                -- nil
```

Non-strings get turned into strings via `tostring`. If the result is too short or too long, it returns `nil`.
