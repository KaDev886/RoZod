# Example: DataStore Save/Load

A complete save/load cycle with coercion as a safety net.

## Schema

```lua
local playerSaveSchema = RoZod.Object({
    Gold = RoZod.Number():Min(0):Max(999999):Default(0),
    Level = RoZod.Number():Min(1):Max(999):Default(1),
    XP = RoZod.Number():Min(0):Default(0),
    Inventory = RoZod.Array(
        RoZod.Object({
            Id = RoZod.String(),
            Quantity = RoZod.Number():Min(1):Max(9999):Default(1),
        })
    ):Default({}),
    LastLogin = RoZod.String():Optional(),
    Settings = RoZod.Object({
        MusicVolume = RoZod.Number():Min(0):Max(100):Default(50),
        SFXVolume = RoZod.Number():Min(0):Max(100):Default(50),
    }):Default({ MusicVolume = 50, SFXVolume = 50 }),
})
```

## Save

```lua
local DataStore = DataStoreService:GetDataStore("PlayerSaves")

local function savePlayer(playerId, data)
    if not playerSaveSchema:IsValid(data) then
        warn(`Attempted to save invalid data for {playerId}`)
        return false
    end

    local success, err = pcall(function()
        DataStore:SetAsync(playerId, data)
    end)

    if not success then
        warn(`Failed to save {playerId}: {err}`)
    end

    return success
end
```

## Load

```lua
local DATA_TEMPLATE = {
    Gold = 0,
    Level = 1,
    XP = 0,
    Inventory = {},
    Settings = { MusicVolume = 50, SFXVolume = 50 },
}

local function loadPlayer(playerId)
    local success, rawData = pcall(function()
        return DataStore:GetAsync(playerId)
    end)

    if not success or not rawData then
        return DATA_TEMPLATE
    end

    return playerSaveSchema:Coerce(rawData) or DATA_TEMPLATE
end
```

## Why coercion works here

DataStores can return data from an older version of your schema. `Coerce` handles that:

- **Missing keys** → filled by `Default`
- **Wrong types** → converted when possible
- **Out of range** → clamped
- **Extra keys** → removed (unless `:Extra()` is used)

> `:Default()` is safer than a raw `DATA_TEMPLATE` because defaults get validated against the schema at definition time. A raw table might accidentally contain invalid values.
