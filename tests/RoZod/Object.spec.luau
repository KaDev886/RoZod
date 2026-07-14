return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

	local schema = RoZod.Object({
		key = RoZod.String(),
		optionalKey = RoZod.String():Optional(),
	})

	local nestedSchema = RoZod.Object({
		name = RoZod.String(),
		value = RoZod.Object({
			x = RoZod.Number(),
			y = RoZod.Number(),
		}),
	})
	
	describe("IsValid", function()

		it("accepts dictionaries", function()
			expect(schema:IsValid({ key = "value", optionalKey = "value" })).to.equal(true)
			expect(schema:IsValid({ key = "value" })).to.equal(true)
		end)

		it("rejects non-dictionaries", function()
			expect(schema:IsValid(123)).to.equal(false)
			expect(schema:IsValid("Hello")).to.equal(false)
			expect(schema:IsValid(true)).to.equal(false)
		end)

		it("rejects extra keys without Extra()", function()
			expect(schema:IsValid({ key = "value", extra = "bad" })).to.equal(false)
		end)

		it("accepts nested objects", function()
			expect(nestedSchema:IsValid({
				name = "test",
				value = { x = 1, y = 2 },
			})).to.equal(true)
		end)

		it("rejects invalid nested objects", function()
			expect(nestedSchema:IsValid({
				name = "test",
				value = { x = "bad", y = 2 },
			})).to.equal(false)
		end)

	end)

	describe("Coerce", function()

		it("coerces strings to dictionaries", function()
			local t = schema:Coerce("{ key = 10 }")
			expect(t).to.be.a("table")
			expect(t.key).to.equal("10")
		end)

		it("does not coerce invalid strings", function()
			expect(schema:Coerce("Not a dictionary")).to.equal(nil)
		end)

		it("coerces nested objects", function()
			local t = nestedSchema:Coerce({
				name = 123,
				value = { x = "1.5", y = "2.5" },
			})
			expect(t).to.be.a("table")
			expect(t.name).to.equal("123")
			expect(t.value.x).to.equal(1.5)
			expect(t.value.y).to.equal(2.5)
		end)

	end)
    
	describe("Validate", function()

		it("throws on invalid input", function()
			expect(function() schema:Validate(123) end).to.throw()
			expect(function() schema:Validate("Hello") end).to.throw()
			expect(function() schema:Validate(true) end).to.throw()
			expect(function() schema:Validate({ "value" }) end).to.throw()
		end)

		it("does not throw on valid input", function()
			expect(function() schema:Validate({ key = "value", optionalKey = "value" }) end).to.never.throw()
			expect(function() schema:Validate({ key = "value" }) end).to.never.throw()
		end)

		it("throws on extra keys without Extra()", function()
			expect(function() schema:Validate({ key = "value", extra = "bad" }) end).to.throw()
		end)

	end)

	describe("Extra", function()
		local extraSchema = RoZod.Object({
			key = RoZod.String(),
		}):Extra()

		it("IsValid accepts extra keys with Extra()", function()
			expect(extraSchema:IsValid({ key = "value", extra = "ok" })).to.equal(true)
		end)

		it("Validate does not throw on extra keys with Extra()", function()
			expect(function() extraSchema:Validate({ key = "value", extra = "ok" }) end).to.never.throw()
		end)
	end)
    
end