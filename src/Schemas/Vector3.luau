--!strict

local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local Base = require(script.Parent.Parent.Base)

export type Vector3Schema = Base.BaseSchema<Vector3Schema, Vector3?>

local Vector3M = {}
Vector3M.__index = Vector3M

setmetatable(Vector3M, Base)

function Vector3M.new() : Vector3Schema
	return setmetatable(Base.new(), Vector3M) :: any
end

function Vector3M:_validate(value, dc, path, policy)
	local newDc = self:_getValidDc(dc)
	
	if value == nil and self.optional then
		return
	end

	if typeOf(value) ~= "Vector3" then
		newDc:Add(policy, `Expected Vector3, got '{typeOf(value)}'`, path)
		
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

function Vector3M:Coerce(value : any) : Vector3?
	if self:IsValid(value) then
		return value
	end

	if self.default ~= nil then
		return self.default
	end
	
	local result = value

	if typeOf(result) ~= "Vector3" then
		result = toType.Vector3(result)

		if result == nil then
			return nil
		end
	end
	
	return Base.Coerce(self, result)
end

function Vector3M:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Vector3M:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end

	if typeOf(value) ~= "Vector3" then
		return false
	end
	
	return Base.IsValid(self, value)
end

return setmetatable({}, {
	__call = function()
		return Vector3M.new()
	end,
})