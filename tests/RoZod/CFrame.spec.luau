return function()
	
	local RoZod = require(game.ReplicatedStorage.RoZod)

    local schema = RoZod.CFrame()
	
	describe("IsValid", function()

        it("accepts CFrames", function()
            expect(schema:IsValid(CFrame.new())).to.equal(true)
        end)

        it("rejects non-CFrames", function()
            expect(schema:IsValid(123)).to.equal(false)
            expect(schema:IsValid("CFrame.new()")).to.equal(false)
        end)

	end)

	describe("Coerce", function()

        it("coerces strings to CFrames", function()
            expect(schema:Coerce("0,0,5")).to.equal(CFrame.new(0, 0, 5))
            expect(schema:Coerce(Vector3.new(1, 2, 3))).to.equal(CFrame.new(1, 2, 3))
        end)

        it("does not coerce invalid strings", function()
            expect(schema:Coerce("Not a CFrame")).to.equal(nil)
        end)
        
	end)

	describe("Validate", function()

        it("throws on invalid input", function()
            expect(function() schema:Validate(123) end).to.throw()
            expect(function() schema:Validate("CFrame.new()") end).to.throw()
        end)

        it("does not throw on valid input", function()
            expect(function() schema:Validate(CFrame.new()) end).to.never.throw()
        end)

	end)
    
end