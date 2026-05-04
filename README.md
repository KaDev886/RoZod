# 🛡️ RoZod – Schema Validator & Coercion

RoZod helps prevent invalid or unexpected data from reaching your game logic in Roblox Luau by validating and optionally correcting (coercing) values at runtime.

It is designed for data systems where consistency matters, such as inventories, player stats, settings, or saved data.

---

## Why RoZod exists

In Roblox games, data often arrives from:

* DataStores
* RemoteEvents
* External inputs
* Player manipulation

These sources can produce invalid or unexpected values that silently break systems.

RoZod provides a way to:

* Validate data structures at runtime
* Detect invalid values early
* Optionally coerce invalid values into safe defaults
* Apply consistent rules across your entire data layer

---

## Getting Started

### Installation

#### Option 1: Manual (.rbxm)

1. Download `RoZod.rbxm` from the [Releases](https://github.com/KaDev886/RoZod/releases)
2. Insert it into your place (ReplicatedStorage / ServerScriptService)
3. Require it:

```lua
local RoZod = require(path.to.RoZod)
```

---

#### Option 2: Wally

Add to `wally.toml`:

```toml
RoZod = "kadev886/rozod@1.0.5"
```

Install:

```bash
wally install
```

Require:

```lua
local RoZod = require(Packages.RoZod)
```

---

## Basic Example

```lua
local schema = RoZod.String()

print(schema:IsValid("John")) -- true
print(schema:IsValid(123))     -- false
```

---

## Example: Player Inventory

Invalid values are common in game data (for example negative amounts or wrong types).

RoZod can validate and optionally fix them.

```lua
local itemsName = {"Wood", "Sword", "Helmet"}
local itemsTypes = {"Resource", "Weapon", "Armor"}

local itemSchema = RoZod.Object({
    Name = RoZod.String():Expected(itemsName),
    Type = RoZod.String():Expected(itemsTypes),
    Amount = RoZod.Number():Min(1),
})

local inventorySchema = RoZod.Object({
    Items = RoZod.Array(itemSchema),
})

local playerDataSchema = RoZod.Object({
    Inventory = inventorySchema,
})

local playerData = {
    Inventory = {
        Items = {
            { Name = "Wood", Type = "Resource", Amount = 10 },
            { Name = "Sword", Type = "Weapon", Amount = 1 },
            { Name = "Helmet", Type = "Armor", Amount = -10 }, -- invalid
        },
    },
}

playerDataSchema:Validate(playerData)
```

---

## Validation vs Coercion

RoZod supports two approaches:

### Validation (strict)

```lua
print(playerDataSchema:IsValid(playerData)) -- false
```

### Coercion (safe correction)

```lua
local fixed = playerDataSchema:Coerce(playerData)

print(playerDataSchema:IsValid(fixed)) -- true
```

Coercion attempts to ensure the output matches the schema by applying safe defaults or corrections when possible; otherwise it may return `nil` if no valid coercion path exists.

---

## Core API

Coercion behavior note: depending on the schema and input, `Coerce` may return either a valid coerced value or `nil` when coercion is not possible (similar in spirit to `tonumber` / `tostring` behavior patterns in Luau).

| Function          | Description                                                 |
| ----------------- | ----------------------------------------------------------- |
| `IsValid(value)`  | Checks if a value matches the schema (no errors thrown)     |
| `Validate(value)` | Validates and reports errors depending on policy            |
| `Coerce(value)`   | Attempts to fix invalid values and return a valid structure |

---

## Supported Types

* Any
* Object
* Array
* Enum
* Number
* String
* Boolean
* Vector3
* CFrame

---

## Policies

RoZod can behave differently depending on the policy:

* `Error` → stops execution on invalid data
* `Warn` → prints warning but continues
* `Silent` → ignores validation issues

```lua
local schema = RoZod.String():Warn()
```

---

## Design Goal

RoZod is not meant to replace game logic.

It is meant to:

* Reduce silent data bugs
* Centralize validation rules
* Make game data safer and more predictable

---

## Contributing

Issues and pull requests are welcome.

If proposing changes, it is recommended to open an issue first.

---

## License

MIT
