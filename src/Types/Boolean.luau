--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local TypeOf = require(script.Parent.Parent.TypeOf)
local Base = require(script.Parent.Parent.Base)

export type BooleanSchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	Silent: (self: BooleanSchema) -> BooleanSchema,
	Warn: (self: BooleanSchema) -> BooleanSchema,
	Error: (self: BooleanSchema) -> BooleanSchema,
	Default: (self: BooleanSchema, value: any) -> BooleanSchema,
	Expected: (self: BooleanSchema, expecteds: { any }) -> BooleanSchema,
	Optional: (self: BooleanSchema) -> BooleanSchema,
	
	Coerce: (self: BooleanSchema, value: any) -> boolean,
	Validate: (self: BooleanSchema, value: any) -> (),
	IsValid: (self: BooleanSchema, value: any) -> boolean,
}

local Boolean = {}
Boolean.__index = Boolean

setmetatable(Boolean, { __index = Base })

function Boolean:Coerce(value : any) : boolean
	if self:IsValid(value) then
		return value
	end
	
	local result = if self.default ~= nil then self.default else value
	
	if TypeOf(result) ~= "boolean" then
		result = false
	end
	
	return Base.Coerce(self, result)
end

function Boolean:Validate(value : any, dc : DebugContext.DebugContext?, path : string?)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end
	
	if TypeOf(value) ~= "boolean" then
		newDc:Add(self.policy, `Expected boolean, got '{TypeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	Base.Validate(self, value, newDc, path)
	
	if dc ~= newDc then
		newDc:Throw()
	end
end

function Boolean:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if TypeOf(value) ~= "boolean" then
		return false
	end
	
	return Base.IsValid(self, value)
end

return function() : BooleanSchema
	local self = setmetatable(Base.new(), Boolean) :: BooleanSchema

	self.type = script.Name

	return self
end