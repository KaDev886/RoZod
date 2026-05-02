-- init.spec.luau

local TestEZ = require(game.ReplicatedStorage.TestEZ)
local RoZod = require(gane.ReplicatedStorage.RoZod)

local function runStringTests()
    local schema = RoZod.string()
    TestEZ.Dedent([[
        TestEZ | Running String Tests
    ]])

    -- Test for valid strings
    TestEZ.it('Valid string test', function()
        local result = schema:IsValid('Hello')
        assert(result == true, 'Expected result to be true')
    end)

    -- Test for invalid strings
    TestEZ.it('Invalid string test', function()
        local result = schema:IsValid(123)
        assert(result == false, 'Expected result to be false')
    end)
end

local function runNumberTests()
    local schema = RoZod.number()
    TestEZ.Dedent([[
        TestEZ | Running Number Tests
    ]])

    -- Test for valid numbers
    TestEZ.it('Valid number test', function()
        local result = schema:IsValid(123)
        assert(result == true, 'Expected result to be true')
    end)

    -- Test for invalid numbers
    TestEZ.it('Invalid number test', function()
        local result = schema:IsValid('String')
        assert(result == false, 'Expected result to be false')
    end)
end

local function runBooleanTests()
    local schema = RoZod.boolean()
    TestEZ.Dedent([[
        TestEZ | Running Boolean Tests
    ]])

    -- Test for valid booleans
    TestEZ.it('Valid boolean test true', function()
        local result = schema:IsValid(true)
        assert(result == true, 'Expected result to be true')
    end)

    TestEZ.it('Valid boolean test false', function()
        local result = schema:IsValid(false)
        assert(result == true, 'Expected result to be true')
    end)
end

local function runArrayTests()
    local schema = RoZod.array(RoZod.number())
    TestEZ.Dedent([[
        TestEZ | Running Array Tests
    ]])

    -- Test for valid arrays
    TestEZ.it('Valid array test', function()
        local result = schema:IsValid({1, 2, 3})
        assert(result == true, 'Expected result to be true')
    end)

    -- Test for invalid arrays
    TestEZ.it('Invalid array test', function()
        local result = schema:IsValid({1, '2', 3})
        assert(result == false, 'Expected result to be false')
    end)
end

local function runObjectTests()
    local schema = RoZod.object({
        name = RoZod.string(),
        age = RoZod.number()
    })
    TestEZ.Dedent([[
        TestEZ | Running Object Tests
    ]])

    -- Test for valid objects
    TestEZ.it('Valid object test', function()
        local result = schema:IsValid({name = 'John', age = 30})
        assert(result == true, 'Expected result to be true')
    end)

    -- Test for invalid objects
    TestEZ.it('Invalid object test', function()
        local result = schema:IsValid({name = 123, age = 'thirty'})
        assert(result == false, 'Expected result to be false')
    end)
end

-- Run all tests
runStringTests()
runNumberTests()
runBooleanTests()
runArrayTests()
runObjectTests()
