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

	describe("Min / Max", function()
		local minMax = RoZod.Number():Min(5):Max(10)

		it("IsValid respects Min and Max", function()
			expect(minMax:IsValid(7)).to.equal(true)
			expect(minMax:IsValid(3)).to.equal(false)
			expect(minMax:IsValid(12)).to.equal(false)
		end)

		it("Coerce clamps to Min and Max", function()
			expect(minMax:Coerce(3)).to.equal(5)
			expect(minMax:Coerce(12)).to.equal(10)
			expect(minMax:Coerce(7)).to.equal(7)
		end)

		it("Validate respects Min and Max", function()
			expect(function() minMax:Validate(3) end).to.throw()
			expect(function() minMax:Validate(7) end).to.never.throw()
			expect(function() minMax:Validate(12) end).to.throw()
		end)
	end)

	describe("Optional", function()
		local opt = RoZod.Number():Optional()

		it("accepts nil when optional", function()
			expect(opt:IsValid(nil)).to.equal(true)
		end)

		it("returns nil on Coerce when value is nil", function()
			expect(opt:Coerce(nil)).to.equal(nil)
		end)

		it("does not throw on Validate with nil", function()
			expect(function() opt:Validate(nil) end).to.never.throw()
		end)
	end)

	describe("Default", function()
		local withDefault = RoZod.Number():Default(0)

		it("returns default on Coerce for invalid input", function()
			expect(withDefault:Coerce("abc")).to.equal(0)
		end)

		it("returns default on Coerce for nil", function()
			expect(withDefault:Coerce(nil)).to.equal(0)
		end)
	end)

	describe("OneOf", function()
		local oneOfSchema = RoZod.Number():OneOf({1, 2, 3})

		it("IsValid respects OneOf", function()
			expect(oneOfSchema:IsValid(1)).to.equal(true)
			expect(oneOfSchema:IsValid(4)).to.equal(false)
		end)

		it("Coerce returns nil for value not in OneOf", function()
			expect(oneOfSchema:Coerce(4)).to.equal(nil)
		end)
	end)
    
end