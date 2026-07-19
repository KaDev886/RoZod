# Installation

## Option 1: Wally

Add to your `wally.toml`:

```toml
[dependencies]
RoZod = "kadev886/rozod@2.1.0"
```

Then install:

```bash
wally install
```

Require in your code:

```lua
local RoZod = require(Packages.RoZod)
```

## Option 2: Manual (.rbxm)

1. Download `RoZod.rbxm` from the [Releases page](https://github.com/KaDev886/RoZod/releases)
2. Insert it into your place (e.g., `ReplicatedStorage` or `ServerScriptService`)
3. Require it:

```lua
local RoZod = require(path.to.RoZod)
```

## Dependencies

RoZod has **zero runtime dependencies**. It only requires:

- Roblox Luau (the library uses `--!strict`, `--!native`, `--!optimize 2`)
- For development/testing: [TestEZ](https://github.com/Roblox/testez) 0.4.1
