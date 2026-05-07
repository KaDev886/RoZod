return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

    local schema = RoZod.Object({
        key = RoZod.String(),
        optionalKey = RoZod.String():Optional(),
    })
	
	describe("IsValid", function()

        it("accepts dictionaries", function()
            expect(schema:IsValid({ key = "value", optionalKey = "value" })).to.equal(true)
            expect(schema:IsValid({ key = "value" })).to.equal(true)
        end)

        it("rejects non-dictionaries", function()
            expect(schema:IsValid(123)).to.equal(false)
            expect(schema:IsValid("Hello")).to.equal(false)
            expect(schema:IsValid(true)).to.equal(false)
        end)

	end)

	describe("Coerce", function()

        it("coerces strings to dictionaries", function()
           local t = schema:Coerce("{ key = 10 }")
           expect(t).to.be.a("table")
           expect(t.key).to.equal("10")
        end)

        it("does not coerce invalid strings", function()
            expect(schema:Coerce("Not a dictionary")).to.equal(nil)
        end)

	end)
    
	describe("Validate", function()

        it("throws on invalid input", function()
            expect(function() schema:Validate(123) end).to.throw()
            expect(function() schema:Validate("Hello") end).to.throw()
            expect(function() schema:Validate(true) end).to.throw()
            expect(function() schema:Validate({ "value" }) end).to.throw()
        end)

        it("does not throw on valid input", function()
            expect(function() schema:Validate({ key = "value", optionalKey = "value" }) end).to.never.throw()
            expect(function() schema:Validate({ key = "value" }) end).to.never.throw()
        end)

	end)
    
end