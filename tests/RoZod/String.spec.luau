return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

    local schema = RoZod.String()
	
	describe("IsValid", function()

        it("accepts strings", function()
            expect(schema:IsValid("Hello, world!")).to.equal(true)
        end)
        
        it("rejects numbers", function()
            expect(schema:IsValid(123)).to.equal(false)
        end)
		
	end)

	describe("Coerce", function()

        it("coerces numbers to strings", function()
            expect(schema:Coerce(123)).to.equal("123")
        end)
        
	end)

	describe("Validate", function()

        it("throws on invalid input", function()
            expect(function() schema:Validate(123) end).to.throw()
        end)

        it("does not throw on valid input", function()
            expect(function() schema:Validate("Hello, world!") end).to.never.throw()
        end)

	end)
    
end