return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

    local schema = RoZod.Any()
	
	describe("IsValid", function()

        it("accepts any value", function()
            expect(schema:IsValid(123)).to.equal(true)
            expect(schema:IsValid("Hello")).to.equal(true)
            expect(schema:IsValid(true)).to.equal(true)
            expect(schema:IsValid({})).to.equal(true)
        end)

        it("rejects nil", function()
            expect(schema:IsValid(nil)).to.equal(false)
        end)

	end)

	describe("Coerce", function()

        it("does not coerce values", function()
            expect(schema:Coerce(123)).to.equal(123)
            expect(schema:Coerce("Hello")).to.equal("Hello")
            expect(schema:Coerce(true)).to.equal(true)

            local t = {}

            expect(schema:Coerce(t)).to.equal(t)
        end)

	end)
    
	describe("Validate", function()

        it("does not throw on any value", function()
            expect(function() schema:Validate(123) end).to.never.throw()
            expect(function() schema:Validate("Hello") end).to.never.throw()
            expect(function() schema:Validate(true) end).to.never.throw()
            expect(function() schema:Validate({}) end).to.never.throw()
        end)

        it("throws on nil", function()
            expect(function() schema:Validate(nil) end).to.throw()
        end)

	end)
    
end