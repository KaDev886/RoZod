--!strict

local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local Base = require(script.Parent.Parent.Base)

export type BooleanSchema = Base.BaseSchema<BooleanSchema, boolean?>

local Boolean = {}
Boolean.__index = Boolean

setmetatable(Boolean, Base)

function Boolean.new() : BooleanSchema
	return setmetatable(Base.new(), Boolean) :: any
end

function Boolean:_validate(value, dc, path, policy)
	if value == nil and self.optional then
		return
	end
	
	local newDc = self:_getValidDc(dc)
	
	if typeOf(value) ~= "boolean" then
		newDc:Add(policy, `Expected boolean, got '{typeOf(value)}'`, path)
		
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

function Boolean:Coerce(value : any) : boolean
	if value == nil then
		if self.optional then
			return nil
		end
		return self.default
	end

	local result = value
	
	if typeOf(result) ~= "boolean" then
		result = toType.Boolean(result)
	end
	
	if result == nil then
		return self.default
	end
	
	return Base.Coerce(self, result)
end

function Boolean:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Boolean:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if typeOf(value) ~= "boolean" then
		return false
	end
	
	return Base.IsValid(self, value)
end

return setmetatable({}, {
	__call = function()
		return Boolean.new()
	end
})