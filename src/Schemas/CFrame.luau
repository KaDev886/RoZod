--!strict

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

function CFrameM:_validate(value, dc, path, policy)
	local newDc = self:_getValidDc(dc)
	
	if value == nil and self.optional then
		return
	end
	
	if typeOf(value) ~= "CFrame" then
		newDc:Add(policy, `Expected CFrame, got '{typeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	Base._validate(self, value, newDc, path, policy)
	
	if dc ~= newDc then
		newDc:Throw()
	end
end

function CFrameM:Coerce(value : any) : CFrame
	if self:IsValid(value) then
		return value
	end
	
	if self.default ~= nil then
		return self.default
	end

	local result = value
	
	if typeOf(result) ~= "CFrame" then
		result = toType.CFrame(result)
		
		if result == nil then
			return nil
		end
	end
	
	return Base.Coerce(self, result)
end

function CFrameM:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function CFrameM:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if typeOf(value) ~= "CFrame" then
		return false
	end
	
	return Base.IsValid(self, value)
end

return setmetatable({}, {
	__call = function()
		return CFrameM.new()
	end
})