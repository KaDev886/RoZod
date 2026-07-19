# Example: Player Inventory

Validating and fixing a player inventory, then loading it from a DataStore.

## Schema

```lua
local itemName = {"Wood", "Sword", "Helmet"}
local itemTypes = {"Resource", "Weapon", "Armor"}

local itemSchema = RoZod.Object({
    Name = RoZod.String():OneOf(itemName),
    Type = RoZod.String():OneOf(itemTypes),
    Amount = RoZod.Number():Min(1),
})

local inventorySchema = RoZod.Object({
    Items = RoZod.Array(itemSchema),
})

local playerDataSchema = RoZod.Object({
    Inventory = inventorySchema,
})
```

## Usage

```lua
local rawData = {
    Inventory = {
        Items = {
            { Name = "Wood", Type = "Resource", Amount = 10 },
            { Name = "Sword", Type = "Weapon", Amount = 1 },
            { Name = "Helmet", Type = "Armor", Amount = -10 }, -- invalid
        },
    },
}

-- Check first
if not playerDataSchema:IsValid(rawData) then
    warn("Player data contains invalid values")
end

-- Fix it
local fixed = playerDataSchema:Coerce(rawData)
-- fixed.Inventory.Items[3].Amount = 1 (clamped to min)
```

## Loading from DataStore

```lua
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

local DATA_TEMPLATE = {
    Inventory = {
        Items = {},
    },
}

local function loadPlayerData(playerId)
    local success, data = pcall(function()
        return playerDataStore:GetAsync(playerId)
    end)

    if not success or not data then
        return DATA_TEMPLATE
    end

    return playerDataSchema:Coerce(data) or DATA_TEMPLATE
end
```
