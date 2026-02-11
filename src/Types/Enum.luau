--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local Base = require(script.Parent.Parent.Base)

export type EnumSchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	Silent: (self: EnumSchema) -> EnumSchema,
	Warn: (self: EnumSchema) -> EnumSchema,
	Error: (self: EnumSchema) -> EnumSchema,
	Default: (self: EnumSchema, value: any) -> EnumSchema,
	Expected: (self: EnumSchema, expecteds: { any }) -> EnumSchema,
	Optional: (self: EnumSchema) -> EnumSchema,
	
	Coerce: (self: EnumSchema, value: any) -> (Enums | Enum | EnumItem),
	Validate: (self: EnumSchema, value: any) -> (),
	IsValid: (self: EnumSchema, value: any) -> boolean,
}

local EnumM = {}
EnumM.__index = EnumM

setmetatable(EnumM, { __index = Base })

local function isValidType(value : any) : boolean
	local to = typeof(value)
	return to == "Enums" or to == "Enum" or to == "EnumItem"
end

function EnumM:Coerce(value : any) : (Enums | Enum | EnumItem)
	if self:IsValid(value) then
		return value
	end
	
	local result = self.default or value
	
	if not isValidType(result) then
		result = Enum
	end
	
	return Base.Coerce(self, result)
end

function EnumM:Validate(value : any, dc : DebugContext.DebugContext?)
	local newDc = self:_getValidDc(dc)
	
	if not isValidType(value) then
		newDc:Add(self.policy, self.type, `Expected Enums, Enum or EnumItem, got '{typeof(value)}'`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if not Base.IsValid(self, value) then
		Base.Validate(self, value, newDc)

		if dc ~= newDc then
			newDc:Throw()
		end
	end
end

function EnumM:IsValid(value : any) : boolean
	if not isValidType(value) then
		return false
	end
	
	return Base.IsValid(self, value)
end

return function() : EnumSchema
	local self = setmetatable(Base.new(), EnumM) :: EnumSchema

	self.type = script.Name

	return self
end