return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

	local schema = RoZod.Enum()
	
	describe("IsValid", function()

		it("accepts valid enum values", function()
			expect(schema:IsValid(Enum.Material.Air)).to.equal(true)
			expect(schema:IsValid(Enum.Material)).to.equal(true)
		end)

		it("rejects invalid enum values", function()
			expect(schema:IsValid(123)).to.equal(false)
			expect(schema:IsValid("Air")).to.equal(false)
			expect(schema:IsValid("Enum.Material.Air")).to.equal(false)
		end)

	end)
    
	describe("Coerce", function()

		it("coerces strings to enums", function()
			expect(schema:Coerce("Enum.Material.Air")).to.equal(Enum.Material.Air)
			expect(schema:Coerce("Enum.Material")).to.equal(Enum.Material)
		end)

		it("does not coerce invalid strings", function()
			expect(schema:Coerce("Air")).to.equal(nil)
		end)

	end)

	describe("Validate", function()

		it("throws on invalid input", function()
			expect(function() schema:Validate(123) end).to.throw()
			expect(function() schema:Validate("Enum.Material.Air") end).to.throw()
		end)

		it("does not throw on valid input", function()
			expect(function() schema:Validate(Enum.Material.Air) end).to.never.throw()
			expect(function() schema:Validate(Enum.Material) end).to.never.throw()
		end)

	end)

	describe("Optional", function()
		local opt = RoZod.Enum():Optional()

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
		local withDefault = RoZod.Enum():Default(Enum.Material.Air)

		it("returns default on Coerce for invalid input", function()
			expect(withDefault:Coerce(123)).to.equal(Enum.Material.Air)
		end)
	end)
    
end