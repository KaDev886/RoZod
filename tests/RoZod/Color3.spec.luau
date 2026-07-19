return function()

	local RoZod = require(game.ReplicatedStorage.RoZod)

	local schema = RoZod.Color3()

	describe("IsValid", function()

		it("accepts Color3 values", function()
			expect(schema:IsValid(Color3.new(1, 0.5, 0))).to.equal(true)
		end)

		it("rejects non-Color3 values", function()
			expect(schema:IsValid(123)).to.equal(false)
			expect(schema:IsValid("0.5, 0.2, 0.8")).to.equal(false)
		end)

	end)

	describe("Coerce", function()

		it("coerces strings to Color3 values", function()
			expect(schema:Coerce("0.5, 0.2, 0.8")).to.equal(Color3.new(0.5, 0.2, 0.8))
		end)

		it("does not coerce invalid strings", function()
			expect(schema:Coerce("hello")).to.equal(nil)
		end)

	end)

	describe("Validate", function()

		it("throws on invalid input", function()
			expect(function() schema:Validate(123) end).to.throw()
			expect(function() schema:Validate("0.5, 0.2, 0.8") end).to.throw()
		end)

		it("does not throw on valid input", function()
			expect(function() schema:Validate(Color3.new(1, 0.5, 0)) end).to.never.throw()
		end)

	end)

	describe("Optional", function()

		it("accepts nil when optional", function()
			local opt = RoZod.Color3():Optional()
			expect(opt:IsValid(nil)).to.equal(true)
		end)

		it("returns nil on Coerce when value is nil", function()
			local opt = RoZod.Color3():Optional()
			expect(opt:Coerce(nil)).to.equal(nil)
		end)

	end)

	describe("Default", function()

		it("returns default on Coerce for invalid input", function()
			local withDefault = RoZod.Color3():Default(Color3.new(0, 0, 0))
			expect(withDefault:Coerce("hello")).to.equal(Color3.new(0, 0, 0))
		end)

	end)

end
