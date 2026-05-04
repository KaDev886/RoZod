--!strict

local typeOf = require(script.Parent.Parent.typeOf)
local Base = require(script.Parent.Parent.Base)

local Any = {}
Any.__index = Any

setmetatable(Any, Base)

export type AnySchema = Base.BaseSchema<AnySchema, any?>

function Any.new() : AnySchema
	return setmetatable(Base.new(), Any) :: any
end

function Any:_validate(value, dc, path, policy)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end
	
	if typeOf(value) == "NaN" then
		newDc:Add(policy, "Expected valid value, got NaN", path)

		if dc ~= newDc then
			newDc:Throw()
		end
	end

	if value == nil then
		newDc:Add(policy, "Expected valid value, got nil", path)

		if dc ~= newDc then
			newDc:Throw()
		end
	end
	
	Base._validate(self, value, newDc, path, policy)
	
	if dc ~= newDc then
		newDc:Throw()
	end
end

function Any:Coerce(value: any) : any
	if self:IsValid(value) then
		return value
	end

	if self.default ~= nil then
		return self.default
	end

	return Base.Coerce(self, value)
end

function Any:Validate(value: any)
	self:_validate(value, nil, nil, self.policy)
end

function Any:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end

	if value == nil then
		return false
	end

	if typeOf(value) == "NaN" then
		return false
	end

	return Base.IsValid(self, value)
end

return setmetatable({}, {
	__call = function()
		return Any.new()
	end
})