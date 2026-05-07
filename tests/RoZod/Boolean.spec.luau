return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

    local schema = RoZod.Boolean()
	
	describe("IsValid", function()

        it("accepts booleans", function()
            expect(schema:IsValid(true)).to.equal(true)
            expect(schema:IsValid(false)).to.equal(true)
        end)
        
        it("rejects non-booleans", function()
            expect(schema:IsValid(123)).to.equal(false)
            expect(schema:IsValid("true")).to.equal(false)
        end)

	end)

	describe("Coerce", function()

        it("coerces strings to booleans", function()
            expect(schema:Coerce("true")).to.equal(true)
            expect(schema:Coerce("false")).to.equal(false)
        end)

        it("does not coerce non-boolean strings", function()
            expect(schema:Coerce("yes")).to.equal(nil)
            expect(schema:Coerce("no")).to.equal(nil)
        end)

	end)

	describe("Validate", function()

        it("throws on invalid input", function()
            expect(function() schema:Validate(123) end).to.throw()
        end)

        it("does not throw on valid input", function()
            expect(function() schema:Validate(true) end).to.never.throw()
            expect(function() schema:Validate(false) end).to.never.throw()
        end)

	end)
    
end