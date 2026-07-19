# Enum Schema

Roblox `Enum` and `EnumItem` values.

```lua
local schema = RoZod.Enum()
```

## Validation

```lua
local s = RoZod.Enum()

s:IsValid(Enum.Material.Wood)      -- true (EnumItem)
s:IsValid(Enum.Material)           -- true (Enum)
s:IsValid("Enum.Material.Wood")    -- false (string != Enum)
s:IsValid(123)                     -- false
```

## Coercion

```lua
s:Coerce(Enum.Material.Wood)          -- Enum.Material.Wood
s:Coerce("Enum.Material.Wood")        -- Enum.Material.Wood
s:Coerce("Enum.Material")             -- Enum.Material
s:Coerce("Material.Wood")             -- nil (missing "Enum." prefix)
s:Coerce("not.a.valid.path")          -- nil
```

Strings must start with `Enum.` — for example `"Enum.Material.Wood"`.
