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

	describe("Optional", function()
		local opt = RoZod.Boolean():Optional()

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
		local withDefault = RoZod.Boolean():Default(false)

		it("returns default on Coerce for invalid input", function()
			expect(withDefault:Coerce(123)).to.equal(false)
		end)
	end)

	describe("OneOf", function()
		local oneOfSchema = RoZod.Boolean():OneOf({true})

		it("IsValid respects OneOf", function()
			expect(oneOfSchema:IsValid(true)).to.equal(true)
			expect(oneOfSchema:IsValid(false)).to.equal(false)
		end)

		it("Coerce returns nil for value not in OneOf", function()
			expect(oneOfSchema:Coerce(false)).to.equal(nil)
		end)
	end)
    
end