# Instance Schema

Roblox `Instance` objects. Optionally filtered by class.

```lua
local schema = RoZod.Instance()
```

## Modifiers

### `schema:IsA(className)`

Only instances of this class (uses `:IsA()` internally).

```lua
local partSchema = RoZod.Instance():IsA("BasePart")
partSchema:IsValid(workspace.Part)              -- true
partSchema:IsValid(workspace.Model)             -- false (Model isn't a BasePart)
```

## Validation

```lua
local s = RoZod.Instance()

s:IsValid(workspace.Baseplate)    -- true
s:IsValid("not an instance")      -- false
s:IsValid(nil)                    -- false (unless :Optional())
```

## Coercion

```lua
local s = RoZod.Instance()

s:Coerce(workspace.Baseplate)     -- workspace.Baseplate
s:Coerce("some string")           -- nil (or default)
s:Coerce(nil)                     -- nil (or default)
```

Non-Instance values can't be coerced and return `nil` (or `default`).
