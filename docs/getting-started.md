# Getting Started

## Basic usage

```lua
local RoZod = require(Packages.RoZod)

-- A simple schema
local nameSchema = RoZod.String()

-- Check a valid value (string) and an invalid one (number)
print(nameSchema:IsValid("John"))  -- true
print(nameSchema:IsValid(123))     -- false

-- Validate a correct value (string) and an incorrect one (number)
nameSchema:Validate("John")        -- ok
-- nameSchema:Validate(123)        -- error

-- Coerce — turns a number into a string
print(nameSchema:Coerce(123))      -- "123"
```

## Step by step

### 1. Create a schema

Call a constructor:

```lua
local StringSchema = RoZod.String()
local NumberSchema = RoZod.Number()
local ObjectSchema = RoZod.Object({
    Name = RoZod.String(),
    Age = RoZod.Number(),
})
```

### 2. Validate

```lua
local userSchema = RoZod.Object({
    Username = RoZod.String():MinLength(3):MaxLength(20),
    Score = RoZod.Number():Min(0),
})

local user = { Username = "Player1", Score = 100 }

if userSchema:IsValid(user) then
    -- safe to use now
end
```

### 3. Coerce

```lua
-- Data with wrong types — Username should be a string, Score a number
local rawData = { Username = 12345, Score = "50" }

-- Coerce fixes both: Username becomes a string, Score becomes a number
local cleaned = userSchema:Coerce(rawData)
-- cleaned == { Username = "12345", Score = 50 }
```

### 4. Set a policy

```lua
local schema = RoZod.String():Warn()
schema:Validate(123)  -- prints a warning

local silentSchema = RoZod.String():Silent()
silentSchema:Validate(123)  -- nothing happens
```

## Next steps

- [Core concepts](core-concepts.md)
- [API reference](api/base-schema.md)
- [Real-world examples](examples/player-data.md)
