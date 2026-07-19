# Base Schema

These modifiers and methods are available on every schema type.

## Methods

### `schema:IsValid(value)`

Returns `true` if the value fits the schema.

```lua
local s = RoZod.Number():Min(1)
print(s:IsValid(5))   -- true
print(s:IsValid(-1))  -- false
```

### `schema:Validate(value)`

Validates and reacts according to the schema's policy — throws, warns, or does nothing.

```lua
local s = RoZod.String()
s:Validate("hello")   -- ok
-- s:Validate(123)    -- error: Expected (string) got 'number'
```

### `schema:Coerce(value)`

Tries to fix the value. Returns the result or `nil` if it can't.

```lua
local s = RoZod.Number()
print(s:Coerce("42"))  -- 42
print(s:Coerce("x"))   -- nil
```

## Modifiers

### `schema:OneOf(values)`

Only these values are allowed.

```lua
local role = RoZod.String():OneOf({ "admin", "user", "guest" })
role:IsValid("admin")  -- true
role:IsValid("owner")  -- false
```

### `schema:Optional()`

Allows `nil`. When the value is `nil`, `IsValid` returns `true`, `Validate` passes, and `Coerce` returns `nil`.

```lua
local s = RoZod.String():Optional()
print(s:IsValid(nil))   -- true
print(s:IsValid("hi"))  -- true
```

### `schema:Default(value)`

Fallback when the input is `nil` or coercion can't fix it. The default gets validated against the schema's rules when you set it.

```lua
local s = RoZod.Number():Default(0)
print(s:Coerce(nil))    -- 0
print(s:Coerce("abc"))  -- 0
```

### `schema:Silent()`

Policy override — silently ignores validation errors.

### `schema:Warn()`

Policy override — prints a warning, keeps going.

### `schema:Error()`

Policy override — throws on errors. This is the default.

```lua
local s = RoZod.String():Warn()
s:Validate(123)  -- prints warning, keeps going
```
