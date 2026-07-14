# RoZod Benchmarks

These tests were performed in the Roblox Studio Server environment using `os.clock()`. Performance is measured in **Operations per second (Ops/sec)** and **Latency (ms)**.

---

## Simple Schema (RoZod.Number)

| Function | Data Type | Avg Ops/sec | Avg Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 4,417,886 | 0.00023 ms |
| **IsValid** | Totally Broken Data | 6,816,726 | 0.00015 ms |
| **Coerce** | Good Data | 6,478,891 | 0.00015 ms |
| **Coerce** | Totally Broken Data | 3,322,791 | 0.00030 ms |
| **Validate (Silent)** | Good Data | 10,450,194 | 0.00010 ms |
| **Validate (Silent)** | Totally Broken Data | 10,473,178 | 0.00010 ms |
| **Validate (Warn)** | Good Data | 435,635 | 0.00230 ms |
| **Validate (Warn)** | Totally Broken Data | 8,464 | 0.11814 ms |

---

## Complex Schema (Nested Objects)

**Schema used:**

```lua
local testSchema = RoZod.Object({
    Id = RoZod.String(),
    Data = RoZod.Object({
        Timestamp = RoZod.Number(),
        Tags = RoZod.Array(
            RoZod.String():OneOf({ "admin", "tester", "vip" })
        ),
        Settings = RoZod.Object({
            Enabled = RoZod.Boolean(),
            Value = RoZod.Number()
        })
    })
})
```

**Results:**

### Without OneOf

| Function | Scenario | Avg Ops/sec | Avg Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 256,664 | 0.00390 ms |
| **IsValid** | Partially Broken Data | 202,974 | 0.00493 ms |
| **IsValid** | Totally Broken Data | 2,128,719 | 0.00047 ms |
| **Coerce** | Good Data | 241,357 | 0.00414 ms |
| **Coerce** | Partially Broken Data | 84,185 | 0.01188 ms |
| **Coerce** | Totally Broken Data | 108,742 | 0.00920 ms |
| **Validate (Silent)** | Good Data | 10,929,320 | 0.00009 ms |
| **Validate (Silent)** | Partially Broken Data | 10,996,503 | 0.00009 ms |
| **Validate (Silent)** | Totally Broken Data | 10,677,623 | 0.00009 ms |
| **Validate (Warn)** | Good Data | 88,225 | 0.01133 ms |
| **Validate (Warn)** | Partially Broken Data | 7,307 | 0.13685 ms |
| **Validate (Warn)** | Totally Broken Data | 8,263 | 0.12103 ms |

### With OneOf

| Function | Scenario | Avg Ops/sec | Avg Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 268,861 | 0.00372 ms |
| **IsValid** | Partially Broken Data | 341,361 | 0.00293 ms |
| **IsValid** | Totally Broken Data | 2,109,308 | 0.00047 ms |
| **Coerce** | Good Data | 246,669 | 0.00405 ms |
| **Coerce** | Partially Broken Data | 87,492 | 0.01143 ms |
| **Coerce** | Totally Broken Data | 137,656 | 0.00726 ms |
| **Validate (Silent)** | Good Data | 9,756,859 | 0.00010 ms |
| **Validate (Silent)** | Partially Broken Data | 10,264,306 | 0.00010 ms |
| **Validate (Silent)** | Totally Broken Data | 10,246,007 | 0.00010 ms |
| **Validate (Warn)** | Good Data | 86,327 | 0.01158 ms |
| **Validate (Warn)** | Partially Broken Data | 5,834 | 0.17141 ms |
| **Validate (Warn)** | Totally Broken Data | 8,003 | 0.12495 ms |

* **Good Data:** Matches the schema perfectly.
* **Partially Broken Data:** Includes extra keys that RoZod filters out and some type mismatches.
* **Totally Broken Data:** Multiple incorrect types deep within the structure.