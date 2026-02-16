--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local TypeOf = require(script.Parent.Parent.TypeOf)
local Base = require(script.Parent.Parent.Base)

local Any = {}
Any.__index = Any

setmetatable(Any, { __index = Base })

export type AnySchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	Silent: (self: AnySchema) -> AnySchema,
	Warn: (self: AnySchema) -> AnySchema,
	Error: (self: AnySchema) -> AnySchema,
	Default: (self: AnySchema, value: any) -> AnySchema,
	Expected: (self: AnySchema, expecteds: { any }) -> AnySchema,
	Optional: (self: AnySchema) -> AnySchema,
	
	Coerce: (self: AnySchema, value: any) -> any,
	Validate: (self: AnySchema, value: any) -> (),
	IsValid: (self: AnySchema, value: any) -> boolean,
}

function Any:Coerce(value: any) : any
	if self:IsValid(value) then
		return value
	end

	local result = if self.default ~= nil then self.default else value

	return Base.Coerce(self, result)
end

function Any:Validate(value: any, dc : DebugContext.DebugContext?, path: string?)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end
	
	if TypeOf(value) == "NaN" then
		newDc:Add(self.policy, "Expected valid value, got NaN", path)

		if dc ~= newDc then
			newDc:Throw()
		end
	end

	if value == nil then
		newDc:Add(self.policy, "Expected valid value, got nil", path)

		if dc ~= newDc then
			newDc:Throw()
		end
	end
	
	Base.Validate(self, value, newDc, path)
	
	if dc ~= newDc then
		newDc:Throw()
	end
end

function Any:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end

	if value == nil then
		return false
	end

	if TypeOf(value) == "NaN" then
		return false
	end

	return Base.IsValid(self, value)
end

return function() : AnySchema
	local self = setmetatable(Base.new(), Any) :: AnySchema
	
	self.type = script.Name
	
	return self
end