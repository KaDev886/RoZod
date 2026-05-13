# RoZod Benchmarks

These tests were performed in the Roblox Studio Server environment using `os.clock()`. Performance is measured in **Operations per second (Ops/sec)** and **Latency (ms)**.

---

## Simple Schema (RoZod.Number)

| Function | Data Type | Avg Ops/sec | Avg Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 5,644,618 | 0.00018 ms |
| **IsValid** | Bad Data | 6,748,899 | 0.00015 ms |
| **Coerce** | Good Data | 5,821,413 | 0.00017 ms |
| **Coerce** | Bad Data | 3,057,310 | 0.00033 ms |
| **Validate (Silent)** | Good Data | 11,008,245 | 0.00009 ms |
| **Validate (Silent)** | Bad Data | 11,173,558 | 0.00009 ms |
| **Validate (Warn)** | Good Data | 289,503 | 0.00345 ms |
| **Validate (Warn)** | Bad Data | 7,209 | 0.13872 ms |

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
| **IsValid** | Good Data | 327,428 | 0.00305 ms |
| **IsValid** | Realistic Data | 260,029 | 0.00385 ms |
| **IsValid** | Bad Data | 2,587,860 | 0.00039 ms |
| **Coerce** | Good Data | 113,058 | 0.00885 ms |
| **Coerce** | Realistic Data | 80,464 | 0.01243 ms |
| **Coerce** | Bad Data | 72,360 | 0.01382 ms |
| **Validate (Silent)** | Good Data | 10,968,761 | 0.00009 ms |
| **Validate (Silent)** | Realistic Data | 11,335,170 | 0.00009 ms |
| **Validate (Silent)** | Bad Data | 11,193,169 | 0.00009 ms |
| **Validate (Warn)** | Good Data | 70,312 | 0.01422 ms |
| **Validate (Warn)** | Realistic Data | 6,663 | 0.15008 ms |
| **Validate (Warn)** | Bad Data | 6,046 | 0.16541 ms |

* **Good Data:** Matches the schema perfectly.
* **Realistic Data:** Includes extra keys that RoZod filters out.
* **Bad Data:** Multiple incorrect types deep within the structure.