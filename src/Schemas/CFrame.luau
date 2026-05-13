--!strict

local getValidDc = require(script.Parent.Parent.getValidDc)
local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local Base = require(script.Parent.Parent.Base)

export type CFrameSchema = Base.BaseSchema<CFrameSchema, CFrame?>

local CFrameM = {}
CFrameM.__index = CFrameM

setmetatable(CFrameM, Base)

function CFrameM.new() : CFrameSchema
	return setmetatable(Base.new(), CFrameM) :: any
end

function CFrameM:_matchesType(value : any) : boolean
	return typeOf(value) == "CFrame"
end

function CFrameM:_validate(value, dc, path, policy)
	if policy == "Silent" then return end

	local newDc = getValidDc(dc)
	
	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then
		return
	end
	
	if oneOfSet and not oneOfSet[value] then
		newDc:Add(
			policy, 
			`Expected one of: {table.concat(self.oneOf, " | ")} got '{value}'`,
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end

		return
	end

	local to = typeOf(value)

	if to ~= "CFrame" then
		newDc:Add(policy, `Expected CFrame, got '{to}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
end

function CFrameM:Coerce(value : any) : CFrame?
	local oneOfSet = self.oneOfSet
	
	local result = value

	if value == nil then
		if self.optional then
			return nil
		end
		return self.default
	end
	
	if oneOfSet and not oneOfSet[value] then
		return self.default
	end
	
	if typeOf(result) ~= "CFrame" then
		result = toType.CFrame(result)
	end
	
	if result == nil then
		return self.default
	end
	
	return result
end

function CFrameM:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function CFrameM:IsValid(value : any)
	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then 
		return true
	end

	if oneOfSet and not oneOfSet[value] then
		return false
	end

	if typeOf(value) ~= "CFrame" then
		return false
	end

	return true
end

return setmetatable({}, {
	__call = function()
		return CFrameM.new()
	end
})