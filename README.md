# 🛡️ RoZod – Runtime Schema Validator & Coercion
[![Version](https://img.shields.io/badge/version-0.1.0--alpha-orange)](https://github.com/KaDev886/RoZod/releases)

RoZod is a **runtime schema validator** designed for Roblox Luau. It allows you to validate and coerce data safely, including tables, arrays, enums, and primitive values.

**Status:** Experimental

---

## Why use RoZod?

RoZod helps prevent common mistakes when handling player data or game configurations by automatically validating your data structures:

- Prevents invalid or unexpected values.
- Coerces broken values to always return something valid.
- Generates errors or warnings according to policy (`Error`, `Warn`, `Silent`).
- Handles objects (`Object`), lists (`Array`), and Roblox enums (`Enum`, `EnumItem`).

This is especially useful for inventories, player stats, settings, or any data system that requires consistency.

---

## Getting Started

### Installation

**Option 1: Manual (`.rbxm`)**
1. Download the latest `RoZod.rbxm` from the [Releases](https://github.com/KaDev886/RoZod/releases) page.
2. Insert the RoZod ModuleScript anywhere in your project (e.g., ReplicatedStorage or ServerScriptService) and require it from your scripts.

```lua
local RoZod = require(path.to.RoZod)
```

**Option 2: Wally**

Add RoZod to your `wally.toml`:

```toml
RoZod = "kadev886/rozod@0.1.0"
```

Run:

```bash
wally install
```

Then require it in your code:

```lua
local RoZod = require(path.to.RoZod)
```

---

## Basic Usage

```lua
-- Define a simple schema
local nameSchema = RoZod.String()

-- Validate a value
print(nameSchema:IsValid("John"))  -- true
print(nameSchema:IsValid(123))      -- false
```

---

## Example: Player Data Schema

```lua
-- Define item schema
local itemsName = {"Wood", "Sword", "Helmet"}
local itemsTypes = {"Resource", "Weapon", "Armor"}

local itemSchema = RoZod.Object({
	Name = RoZod.String():Expected(itemsName),
	Type = RoZod.String():Expected(itemsTypes),
	Amount = RoZod.Number():Min(1),
})

-- Define inventory schema
local inventorySchema = RoZod.Object({
	Items = RoZod.Array(itemSchema),
})

-- Define player data schema
local playerDataSchema = RoZod.Object({
	Inventory = inventorySchema,
})

-- Example player data
local playerData = {
	Inventory = {
		Items = {
			{ Name = "Wood", Type = "Resource", Amount = 10 },
			{ Name = "Sword", Type = "Weapon", Amount = 1 },
			{ Name = "Helmet", Type = "Armor", Amount = -10 }, -- invalid amount
		},
	},
}

-- Validate player data
playerDataSchema:Validate(playerData) -- this gives error
```

---

## Example 2: Player Data Schema
```lua
-- Define item schema
local itemsName = {"Wood", "Sword", "Helmet"}
local itemsTypes = {"Resource", "Weapon", "Armor"}

local itemSchema = RoZod.Object({
	Name = RoZod.String():Expected(itemsName),
	Type = RoZod.String():Expected(itemsTypes),
	Amount = RoZod.Number():Min(1),
})

-- Define inventory schema
local inventorySchema = RoZod.Object({
	Items = RoZod.Array(itemSchema),
})

-- Define player data schema
local playerDataSchema = RoZod.Object({
	Inventory = inventorySchema,
})

-- Example player data
local playerData = {
	Inventory = {
		Items = {
			{ Name = "Wood", Type = "Resource", Amount = 10 },
			{ Name = "Sword", Type = "Weapon", Amount = 1 },
			{ Name = "Helmet", Type = "Armor", Amount = -10 }, -- invalid amount
		},
	},
}

print(playerDataSchema:IsValid(playerData)) -- false

-- Coerce player data
local coercedPlayerData = playerDataSchema:Coerce(playerData)

print(playerDataSchema:IsValid(coercedPlayerData)) -- true
```

---

## Main Functions

| Function | Description |
|---------|-------------|
| `IsValid(value)` | Returns `true` if the value matches the schema, `false` otherwise. Does not throw errors. |
| `Validate(value)` | Validates the value and throws warnings/errors depending on policy. |
| `Coerce(value)` | Returns a valid value even if the original is invalid, applying defaults and coercion. |

---

## Types and Policies

- **Types**:
  - `Any`
  - `Object`
  - `Array`
  - `Enum`
  - `Number`
  - `String`
  - `Boolean`
  - `Vector3`
  - `CFrame`
  
- **Policies**:
  - `Error` → blocks execution and shows error.
  - `Warn` → shows warning, does not block.
  - `Silent` → ignores error/warning.

```lua
local schema = RoZod.String():Warn()
```

---

## Notes

- Error paths are not implemented yet.  
- The library is **experimental**: functional but still in development.  
- Use `IsValid` for quick checks and `Validate` for debugging.  
- `Coerce` always returns a consistent and valid value.

---

## Future Improvements

- Full error paths (`Inventory[2].Price`)
- More detailed and consistent messages
- More types

---

*Developed by [Kecase_no_se]()*
