-- init.spec.luau

return function()
	local RoZod = require(game.ReplicatedStorage.RoZod)

	describe("RoZod", function()
        
		describe("String", function()
			local schema = RoZod.String()

			it("accepts valid strings", function()
				expect(schema:IsValid("Hello")).to.equal(true)
			end)

			it("rejects non-strings", function()
				expect(schema:IsValid(123)).to.equal(false)
			end)
		end)

		describe("Number", function()
			local schema = RoZod.Number()

			it("accepts numbers", function()
				expect(schema:IsValid(123)).to.equal(true)
			end)

			it("rejects strings", function()
				expect(schema:IsValid("123")).to.equal(false)
			end)
		end)

		describe("Boolean", function()
			local schema = RoZod.Boolean()

			it("accepts true/false values", function()
				expect(schema:IsValid(true)).to.equal(true)
				expect(schema:IsValid(false)).to.equal(true)
			end)
		end)

		describe("Array", function()
			local schema = RoZod.Array(RoZod.Number())

			it("valid array", function()
				expect(schema:IsValid({1, 2, 3})).to.equal(true)
			end)

			it("invalid array", function()
				expect(schema:IsValid({1, "2", 3})).to.equal(false)
			end)
		end)

		describe("Object", function()
			local schema = RoZod.Object({
				name = RoZod.String(),
				age = RoZod.Number()
			})

			it("valid object", function()
				expect(schema:IsValid({
					name = "John",
					age = 30
				})).to.equal(true)
			end)

			it("invalid object", function()
				expect(schema:IsValid({
					name = 123,
					age = "30"
				})).to.equal(false)
			end)
		end)

	end)
end