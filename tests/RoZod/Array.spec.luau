return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

	local schema = RoZod.Array(RoZod.Number())
	local schema2 = RoZod.Array(RoZod.Array(RoZod.Number()))
	
	describe("IsValid", function()

		it("accepts arrays of valid items", function()
			expect(schema:IsValid({1, 2, 3})).to.equal(true)
		end)

		it("rejects non-arrays", function()
			expect(schema:IsValid(123)).to.equal(false)
			expect(schema:IsValid("Not an array")).to.equal(false)
		end)

		it("rejects arrays with invalid items", function()
			expect(schema:IsValid({1, "two", 3})).to.equal(false)
		end)

		it("accepts nested arrays", function()
			expect(schema2:IsValid({{1, 2}, {3, 4}})).to.equal(true)
		end)

	end)

	describe("Coerce", function()

		it("coerces strings to arrays", function()
			local t = schema:Coerce("{1, 2, 3}")
			expect(t).to.be.a("table")
			expect(t[1]).to.equal(1)
			expect(t[2]).to.equal(2)
			expect(t[3]).to.equal(3)
		end)

		it("does not coerce non-table values", function()
			expect(schema:Coerce(123)).to.equal(nil)
			expect(schema:Coerce("Not an array")).to.equal(nil)
		end)

		it("does not coerce tables with invalid items", function()
			expect(schema:Coerce({1, "two", 3})).to.equal(nil)
			expect(schema:Coerce("{1, two, 3}")).to.equal(nil)
		end)

		it("coerces nested arrays", function()
			local t = schema2:Coerce("{{1, 2}, {3, 4}}")
			expect(t).to.be.a("table")
			expect(t[1]).to.be.a("table")
			expect(t[1][1]).to.equal(1)
			expect(t[1][2]).to.equal(2)
			expect(t[2]).to.be.a("table")
			expect(t[2][1]).to.equal(3)
			expect(t[2][2]).to.equal(4)
		end)

	end)

	describe("Validate", function()

		it("throws on invalid input", function()
			expect(function() schema:Validate(123) end).to.throw()
			expect(function() schema:Validate({1, "two", 3}) end).to.throw()
		end)

		it("does not throw on valid input", function()
			expect(function() schema:Validate({1, 2, 3}) end).to.never.throw()
		end)

		it("validates nested arrays", function()
			expect(function() schema2:Validate({{1, 2}, {3, 4}}) end).to.never.throw()
		end)

	end)

	describe("MinLength / MaxLength", function()
		local minMax = RoZod.Array(RoZod.Number()):MinLength(2):MaxLength(4)

		it("IsValid respects MinLength and MaxLength", function()
			expect(minMax:IsValid({1, 2})).to.equal(true)
			expect(minMax:IsValid({1})).to.equal(false)
			expect(minMax:IsValid({1, 2, 3, 4, 5})).to.equal(false)
		end)

		it("Validate respects MinLength and MaxLength", function()
			expect(function() minMax:Validate({1}) end).to.throw()
			expect(function() minMax:Validate({1, 2}) end).to.never.throw()
			expect(function() minMax:Validate({1, 2, 3, 4, 5}) end).to.throw()
		end)
	end)

	describe("Optional", function()
		local opt = RoZod.Array(RoZod.Number()):Optional()

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
		local withDefault = RoZod.Array(RoZod.Number()):Default({})

		it("returns default on Coerce for nil", function()
			local result = withDefault:Coerce(nil)
			expect(result).to.be.a("table")
			expect(#result).to.equal(0)
		end)
	end)
    
end