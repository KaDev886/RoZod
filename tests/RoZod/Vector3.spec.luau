return function()

	local RoZod = require(game.ReplicatedStorage.RoZod)

	local schema = RoZod.Vector3()

	describe("IsValid", function()

		it("accepts Vector3 values", function()
			expect(schema:IsValid(Vector3.new(1, 2, 3))).to.equal(true)
		end)

		it("rejects non-Vector3 values", function()
			expect(schema:IsValid("123")).to.equal(false)
		end)

		it("rejects NaN Vector3 values", function()
			local nan = 0 / 0

			expect(schema:IsValid(Vector3.new(nan, 0, 0))).to.equal(false)
		end)

	end)

	describe("Coerce", function()

		it("coerces strings to Vector3 values", function()
			expect(schema:Coerce("1, 2, 3")).to.equal(Vector3.new(1, 2, 3))
		end)

		it("does not coerce invalid strings", function()
			expect(schema:Coerce("hello")).to.equal(nil)
		end)

	end)

	describe("Validate", function()

		it("throws on invalid input", function()
			expect(function() schema:Validate("abc") end).to.throw()
		end)

		it("does not throw on valid input", function()
			expect(function() schema:Validate(Vector3.new(1, 2, 3)) end).to.never.throw()
		end)

	end)

	describe("Optional", function()

		it("accepts nil when optional", function()
			local opt = RoZod.Vector3():Optional()
			expect(opt:IsValid(nil)).to.equal(true)
		end)

		it("returns nil on Coerce when value is nil", function()
			local opt = RoZod.Vector3():Optional()
			expect(opt:Coerce(nil)).to.equal(nil)
		end)

	end)

	describe("Default", function()

		it("returns default on Coerce for invalid input", function()
			local withDefault = RoZod.Vector3():Default(Vector3.new(0, 0, 0))
			expect(withDefault:Coerce("hello")).to.equal(Vector3.new(0, 0, 0))
		end)

	end)

end
