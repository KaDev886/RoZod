# RoZod Benchmarks

These tests were performed in the Roblox Studio Server environment using `os.clock()`. Performance is measured in **Operations per second (Ops/sec)** and **Latency (ms)**.

---

## Simple Schema (RoZod.Number)

| Function | Data Type | Avg Ops/sec | Avg Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 5,028,410 | 0.00020 ms |
| **IsValid** | Bad Data | 10,275,380 | 0.00009 ms |
| **Coerce** | Good Data | 5,367,686 | 0.00021 ms |
| **Coerce** | Bad Data | 2,941,176 | 0.00034 ms |
| **Validate (Silent)** | Good Data | 842,034 | 0.00125 ms |
| **Validate (Silent)** | Bad Data | 854,993 | 0.00133 ms |
| **Validate (Warn)** | Good Data | 352,112 | 0.00341 ms |
| **Validate (Warn)** | Bad Data | 8,675 | 0.14165 ms |

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

| Function | Scenario | Avg Ops/sec | Avg Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 285,196 | 0.00397 ms |
| **IsValid** | Realistic Data | 217,325 | 0.00476 ms |
| **IsValid** | Bad Data | 3,204,511 | 0.00031 ms |
| **Coerce** | Good Data | 103,543 | 0.00966 ms |
| **Coerce** | Realistic Data | 70,773 | 0.01417 ms |
| **Coerce** | Bad Data | 67,616 | 0.01489 ms |
| **Validate (Silent)** | Good Data | 216,057 | 0.00467 ms |
| **Validate (Silent)** | Realistic Data | 145,968 | 0.00688 ms |
| **Validate (Silent)** | Bad Data | 51,781 | 0.01937 ms |
| **Validate (Warn)** | Good Data | 119,904 | 0.00823 ms |
| **Validate (Warn)** | Realistic Data | 4,449 | 0.23963 ms |
| **Validate (Warn)** | Bad Data | 4,806 | 0.21176 ms |

*   **Good Data:** Matches the schema perfectly.
*   **Realistic Data:** Includes extra keys that RoZod filters out.
*   **Bad Data:** Multiple incorrect types deep within the structure.