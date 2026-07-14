return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

	local schema = RoZod.String()
	
	describe("IsValid", function()

		it("accepts strings", function()
			expect(schema:IsValid("Hello, world!")).to.equal(true)
		end)
		
		it("rejects non-string values", function()
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

	describe("MinLength / MaxLength", function()
		local minMax = RoZod.String():MinLength(2):MaxLength(5)

		it("IsValid respects MinLength and MaxLength", function()
			expect(minMax:IsValid("abc")).to.equal(true)
			expect(minMax:IsValid("a")).to.equal(false)
			expect(minMax:IsValid("abcdef")).to.equal(false)
		end)

		it("Validate respects MinLength and MaxLength", function()
			expect(function() minMax:Validate("a") end).to.throw()
			expect(function() minMax:Validate("abc") end).to.never.throw()
			expect(function() minMax:Validate("abcdef") end).to.throw()
		end)
	end)

	describe("Optional", function()
		local opt = RoZod.String():Optional()

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
		local withDefault = RoZod.String():Default("default")

		it("returns default on Coerce for invalid input", function()
			expect(withDefault:Coerce(nil)).to.equal("default")
		end)
	end)

	describe("OneOf", function()
		local oneOfSchema = RoZod.String():OneOf({"a", "b", "c"})

		it("IsValid respects OneOf", function()
			expect(oneOfSchema:IsValid("a")).to.equal(true)
			expect(oneOfSchema:IsValid("d")).to.equal(false)
		end)

		it("Coerce returns nil for value not in OneOf", function()
			expect(oneOfSchema:Coerce("d")).to.equal(nil)
		end)
	end)
    
end