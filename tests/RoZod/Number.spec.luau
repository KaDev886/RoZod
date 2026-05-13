return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

    local schema = RoZod.Number()
	
	describe("IsValid", function()

		it("accepts numbers", function()
			expect(schema:IsValid(123)).to.equal(true)
		end)
		
		it("rejects non-number values", function()
			expect(schema:IsValid("123")).to.equal(false)
		end)

		it("rejects NaN number values", function()
			expect(schema:IsValid(0/0)).to.equal(false)
		end)
		
	end)

	describe("Coerce", function()

		it("coerces strings to numbers", function()
			expect(schema:Coerce("123")).to.equal(123)
		end)

		it("does not coerce non-numeric strings", function()
			expect(schema:Coerce("abc")).to.equal(nil)
		end)

	end)

	describe("Validate", function()

		it("throws on invalid input", function()
			expect(function() schema:Validate("123") end).to.throw()
		end)

		it("does not throw on valid input", function()
			expect(function() schema:Validate(123) end).to.never.throw()
		end)

	end)
    
end