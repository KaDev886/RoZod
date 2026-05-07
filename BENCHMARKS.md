# RoZod Benchmarks

These tests were performed in the Roblox Studio Server environment using `os.clock()`. Performance is measured in **Operations per second (Ops/sec)** and **Latency (ms)**.

---

## Simple Schema (RoZod.Number)

| Function | Data Type | Ops/sec | Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 4,106,900 | 0.00024 ms |
| **IsValid** | Bad Data | 6,851,445 | 0.00014 ms |
| **Coerce** | Good Data | 4,470,012 | 0.00022 ms |
| **Coerce** | Bad Data | 3,892,868 | 0.00025 ms |
| **Validate (Silent)** | Good Data | 784,322 | 0.00127 ms |
| **Validate (Silent)** | Bad Data | 843,561 | 0.00118 ms |
| **Validate (Warn)** | Good Data | 327,911 | 0.00304 ms |
| **Validate (Warn)** | Bad Data | 8,447 | 0.11837 ms |

---

## Complex Schema (Nested Objects)

**Schema used:**

```lua
local testSchema = RoZod.Object({
    Id = RoZod.String(),
    Data = RoZod.Object({
        Timestamp = RoZod.Number(),
        Tags = RoZod.Array(RoZod.String()),
        Settings = RoZod.Object({
            Enabled = RoZod.Boolean(),
            Value = RoZod.Number()
        })
    })
})
```

**Results:**

| Function | Scenario | Ops/sec | Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 326,197 | 0.00306 ms |
| **IsValid** | Realistic Data | 266,489 | 0.00375 ms |
| **IsValid** | Bad Data | 3,404,764 | 0.00029 ms |
| **Coerce** | Good Data | 113,057 | 0.00884 ms |
| **Coerce** | Realistic Data | 82,788 | 0.01207 ms |
| **Coerce** | Bad Data | 76,789 | 0.01302 ms |
| **Validate (Silent)** | Good Data | 235,031 | 0.00425 ms |
| **Validate (Silent)** | Realistic Data | 166,367 | 0.00601 ms |
| **Validate (Silent)** | Bad Data | 54,791 | 0.01825 ms |
| **Validate (Warn)** | Good Data | 140,797 | 0.00710 ms |
| **Validate (Warn)** | Bad Data | 4,474 | 0.22350 ms |

*   **Good Data:** Matches the schema perfectly.
*   **Realistic Data:** Includes extra keys that RoZod filters out.
*   **Bad Data:** Multiple incorrect types deep within the structure.