# RoZod Benchmarks

These tests were performed in the Roblox Live Server environment using `os.clock()`. Performance is measured in **Operations per second (Ops/sec)** and **Latency (ms)**.

---

## Simple Schema (RoZod.Number)

| Function | Data Type | Avg Ops/sec | Avg Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 13,513,293 | 0.00007 ms |
| **IsValid** | Totally Broken Data | 20,394,732 | 0.00005 ms |
| **Coerce** | Good Data | 18,936,140 | 0.00005 ms |
| **Coerce** | Totally Broken Data | 8,336,475 | 0.00012 ms |
| **Validate (Silent)** | Good Data | 26,197,844 | 0.00004 ms |
| **Validate (Silent)** | Totally Broken Data | 23,458,089 | 0.00004 ms |
| **Validate (Warn)** | Good Data | 534,026 | 0.00187 ms |
| **Validate (Warn)** | Totally Broken Data | 71,801 | 0.01393 ms |

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
| **IsValid** | Good Data | 910,836 | 0.00110 ms |
| **IsValid** | Partially Broken Data | 675,039 | 0.00148 ms |
| **IsValid** | Totally Broken Data | 3,250,924 | 0.00031 ms |
| **Coerce** | Good Data | 787,532 | 0.00127 ms |
| **Coerce** | Partially Broken Data | 259,807 | 0.00385 ms |
| **Coerce** | Totally Broken Data | 338,438 | 0.00295 ms |
| **Validate (Silent)** | Good Data | 20,668,198 | 0.00005 ms |
| **Validate (Silent)** | Partially Broken Data | 20,800,149 | 0.00005 ms |
| **Validate (Silent)** | Totally Broken Data | 20,975,004 | 0.00005 ms |
| **Validate (Warn)** | Good Data | 146,180 | 0.00684 ms |
| **Validate (Warn)** | Partially Broken Data | 46,585 | 0.02147 ms |
| **Validate (Warn)** | Totally Broken Data | 61,083 | 0.01637 ms |

### With OneOf

| Function | Scenario | Avg Ops/sec | Avg Latency |
| :--- | :--- | :--- | :--- |
| **IsValid** | Good Data | 887,283 | 0.00113 ms |
| **IsValid** | Partially Broken Data | 986,143 | 0.00101 ms |
| **IsValid** | Totally Broken Data | 6,592,839 | 0.00015 ms |
| **Coerce** | Good Data | 773,811 | 0.00129 ms |
| **Coerce** | Partially Broken Data | 241,999 | 0.00413 ms |
| **Coerce** | Totally Broken Data | 391,960 | 0.00255 ms |
| **Validate (Silent)** | Good Data | 21,820,211 | 0.00005 ms |
| **Validate (Silent)** | Partially Broken Data | 21,500,253 | 0.00005 ms |
| **Validate (Silent)** | Totally Broken Data | 20,632,854 | 0.00005 ms |
| **Validate (Warn)** | Good Data | 125,840 | 0.00795 ms |
| **Validate (Warn)** | Partially Broken Data | 35,644 | 0.02805 ms |
| **Validate (Warn)** | Totally Broken Data | 56,742 | 0.01762 ms |

* **Good Data:** Matches the schema perfectly.
* **Partially Broken Data:** Includes extra keys that RoZod filters out and some type mismatches.
* **Totally Broken Data:** Multiple incorrect types deep within the structure.
