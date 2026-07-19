return function()

	local RoZod = require(game.ReplicatedStorage.RoZod)

	local schema = RoZod.Record(RoZod.String(), RoZod.Number())

	describe("IsValid", function()

		it("accepts records with valid keys and values", function()
			expect(schema:IsValid({ a = 1, b = 2 })).to.equal(true)
		end)

		it("rejects non-table values", function()
			expect(schema:IsValid(123)).to.equal(false)
			expect(schema:IsValid("record")).to.equal(false)
		end)

		it("rejects records with invalid keys", function()
			expect(schema:IsValid({ [1] = 10 })).to.equal(false)
		end)

		it("rejects records with invalid values", function()
			expect(schema:IsValid({ a = "not a number" })).to.equal(false)
		end)

	end)

	describe("Coerce", function()

		it("coerces keys and values", function()
			local result = schema:Coerce({ a = "10", b = "20" })
			expect(result).to.be.a("table")
			expect(result.a).to.equal(10)
			expect(result.b).to.equal(20)
		end)

	end)

	describe("Validate", function()

		it("throws on invalid input", function()
			expect(function() schema:Validate(123) end).to.throw()
			expect(function() schema:Validate({ a = "not a number" }) end).to.throw()
		end)

		it("does not throw on valid input", function()
			expect(function() schema:Validate({ a = 1, b = 2 }) end).to.never.throw()
		end)

	end)

	describe("MinLength / MaxLength", function()
		local minMax = RoZod.Record(RoZod.String(), RoZod.Number()):MinLength(2):MaxLength(4)

		it("IsValid respects MinLength and MaxLength", function()
			expect(minMax:IsValid({ a = 1, b = 2 })).to.equal(true)
			expect(minMax:IsValid({ a = 1 })).to.equal(false)
			expect(minMax:IsValid({ a = 1, b = 2, c = 3, d = 4, e = 5 })).to.equal(false)
		end)

		it("Validate respects MinLength and MaxLength", function()
			expect(function() minMax:Validate({ a = 1 }) end).to.throw()
			expect(function() minMax:Validate({ a = 1, b = 2 }) end).to.never.throw()
			expect(function() minMax:Validate({ a = 1, b = 2, c = 3, d = 4, e = 5 }) end).to.throw()
		end)

		it("Coerce respects MinLength and MaxLength", function()
			local minOnly = RoZod.Record(RoZod.String(), RoZod.Number()):MinLength(2)
			expect(minOnly:Coerce({ a = "1" })).to.equal(nil)
			expect(minOnly:Coerce({ a = "1", b = "2" })).to.be.a("table")
		end)

	end)

	describe("Optional", function()
		local opt = RoZod.Record(RoZod.String(), RoZod.Number()):Optional()

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
		local withDefault = RoZod.Record(RoZod.String(), RoZod.Number()):Default({})

		it("returns default on Coerce for nil", function()
			local result = withDefault:Coerce(nil)
			expect(result).to.be.a("table")
			local count = 0
			for _ in result do count += 1 end
			expect(count).to.equal(0)
		end)
	end)

end
