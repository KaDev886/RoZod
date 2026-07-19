# Error Handling

## DebugContext

RoZod collects validation errors internally through `DebugContext`. Each call to `Validate` builds up messages with:

- `type` — `"Error"` or `"Warn"`
- `message` — what went wrong
- `path` — where in the data it happened

## Path Tracing

When validating nested schemas (Objects, Arrays, Records), RoZod tracks where each error occurred. This makes it easy to spot the exact field that failed.

```lua
local schema = RoZod.Object({
    Settings = RoZod.Object({
        Volume = RoZod.Number():Min(0):Max(100),
    }),
})

-- If Settings.Volume is out of range, the error shows:
-- "Settings.Volume | Number is too large. Expected at most 100, got 200"
```

Keys use dots (`.`), array indices use brackets (`[n]`):

```
Settings.Tags[2] | Expected one of: (admin | tester | vip) got 'owner'
```

## Policy Propagation

When a parent validates a child, the policy flows down:

1. If the child has a manual policy (`:Silent()`, `:Warn()`, `:Error()`), that's used.
2. Otherwise it inherits the parent's policy.
3. If neither is set, the global default applies.

```lua
local inner = RoZod.Number():Min(0)  -- no manual policy
local outer = RoZod.Object({
    value = inner,
}):Warn()

outer:Validate({ value = -1 })  -- inherits Warn from outer
```

```lua
local inner = RoZod.Number():Min(0):Silent()  -- manual policy
local outer = RoZod.Object({
    value = inner,
}):Warn()

outer:Validate({ value = -1 })  -- uses Silent
```

## Global Configuration

```lua
RoZod.setGlobalConfig({
    debugName = "MyGame",     -- prefix for messages
    defaultPolicy = "Warn",   -- "Error", "Warn", or "Silent"
})
```

- `debugName` shows up as `[MyGame] Error: ...`
- `defaultPolicy` is the fallback for schemas that don't set one

## Message Format

```
[DebugName] Policy: Path | Message
```

Examples:

```
[RoZod] Error: Expected (number) got 'string'
[RoZod] Warn: PlayerData.Score | Expected (number) got 'string'
[RoZod] Error: Items[3].Amount | Number is too small. Expected at least 1, got -10
```
