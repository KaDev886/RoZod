return function()

	local RoZod = require(game.ReplicatedStorage.RoZod)

	local schema = RoZod.Instance()

	describe("IsValid", function()

		it("accepts Instances", function()
			expect(schema:IsValid(Instance.new("Part"))).to.equal(true)
			expect(schema:IsValid(Instance.new("Script"))).to.equal(true)
		end)

		it("rejects non-Instance values", function()
			expect(schema:IsValid(123)).to.equal(false)
			expect(schema:IsValid("Instance")).to.equal(false)
		end)

	end)

	describe("Coerce", function()

		it("passes through valid Instance", function()
			local part = Instance.new("Part")
			expect(schema:Coerce(part)).to.equal(part)
		end)

	end)

	describe("Validate", function()

		it("throws on invalid input", function()
			expect(function() schema:Validate(123) end).to.throw()
			expect(function() schema:Validate("Instance") end).to.throw()
		end)

		it("does not throw on valid input", function()
			expect(function() schema:Validate(Instance.new("Part")) end).to.never.throw()
		end)

	end)

	describe("IsA", function()
		local partSchema = RoZod.Instance():IsA("Part")

		it("IsValid respects IsA filter", function()
			expect(partSchema:IsValid(Instance.new("Part"))).to.equal(true)
			expect(partSchema:IsValid(Instance.new("Script"))).to.equal(false)
		end)

		it("Validate respects IsA filter", function()
			expect(function() partSchema:Validate(Instance.new("Part")) end).to.never.throw()
			expect(function() partSchema:Validate(Instance.new("Script")) end).to.throw()
		end)

	end)

	describe("Optional", function()

		it("accepts nil when optional", function()
			local opt = RoZod.Instance():Optional()
			expect(opt:IsValid(nil)).to.equal(true)
		end)

		it("returns nil on Coerce when value is nil", function()
			local opt = RoZod.Instance():Optional()
			expect(opt:Coerce(nil)).to.equal(nil)
		end)

	end)

	describe("Default", function()

		it("returns default on Coerce for invalid input", function()
			local part = Instance.new("Part")
			local withDefault = RoZod.Instance():Default(part)
			expect(withDefault:Coerce(123)).to.equal(part)
		end)

	end)

end
