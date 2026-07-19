# 🛡️ RoZod – Schema Validator & Coercion

RoZod is a schema validator inspired by Zod from TypeScript. It helps validate both good and malformed data.

---

## Why I made RoZod

I made RoZod because I wanted to create a library the community would use and that would actually be useful. I know there are other alternatives like 't' that are faster and lighter, but I decided to focus on ease of use and safety.

---

## Install

### Wally

```toml
RoZod = "kadev886/rozod@2.1.0"
```

```bash
wally install
```

### Manual

Download `RoZod.rbxm` from [Releases](https://github.com/KaDev886/RoZod/releases), stick it in `ReplicatedStorage`, require it.

---

## Example

```lua
local schema = RoZod.String()

print(schema:IsValid("John")) -- true
print(schema:IsValid(123))    -- false
```

---

## Docs

- [Getting Started](docs/getting-started.md)
- [Core Concepts](docs/core-concepts.md)
- [API Reference](docs/api/base-schema.md)
- [Error Handling](docs/error-handling.md)
- [Examples](docs/examples/player-data.md)
- [Benchmarks](BENCHMARKS.md)

---

## License

MIT
