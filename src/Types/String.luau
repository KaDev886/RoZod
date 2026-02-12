--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local TypeOf = require(script.Parent.Parent.TypeOf)
local Base = require(script.Parent.Parent.Base)

export type StringSchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	minLength: number,
	maxLength: number,
	
	Silent: (self: StringSchema) -> StringSchema,
	Warn: (self: StringSchema) -> StringSchema,
	Error: (self: StringSchema) -> StringSchema,
	Default: (self: StringSchema, value: any) -> StringSchema,
	Expected: (self: StringSchema, expecteds: { any }) -> StringSchema,
	Optional: (self: StringSchema) -> StringSchema,
	
	MinLength: (self: StringSchema, minLength: number) -> StringSchema,
	MaxLength: (self: StringSchema, maxLength: number) -> StringSchema,

	Coerce: (self: StringSchema, value: any) -> string,
	Validate: (self: StringSchema, value: any) -> (),
	IsValid: (self: StringSchema, value: any) -> boolean,
}

local String = {}
String.__index = String

setmetatable(String, { __index = Base })

function String:MinLength(minLength : number) : StringSchema
	self.minLength = minLength
	return self
end

function String:MaxLength(maxLength : number) : StringSchema
	self.maxLength = maxLength
	return self
end

function String:Coerce(value : any) : string
	if self:IsValid(value) then
		return value
	end
	
	local result = self.default or value
	
	if TypeOf(result) ~= "string" then
		result = ""
	end
	
	if self.minLength and #result < self.minLength then
		result = result .. string.rep(" ", self.minLength-#result)
	end
	
	if self.maxLength and #result > self.maxLength then
		result = string.sub(result, 1, self.maxLength)
	end
	
	return Base.Coerce(self, result)
end

function String:Validate(value : any, dc : DebugContext.DebugContext?)
	local newDc = self:_getValidDc(dc)
	
	if TypeOf(value) ~= "string" then
		newDc:Add(self.policy, self.type, `Expected string, got '{TypeOf(value)}'`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if self.minLength and #value < self.minLength then
		newDc:Add(self.policy, self.type, `String is too short`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if self.maxLength and #value > self.maxLength then
		newDc:Add(self.policy, self.type, `String is too long`)
		
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

function String:IsValid(value : any) : boolean
	if TypeOf(value) ~= "string" then
		return false
	end
	
	if self.minLength and #value < self.minLength then
		return false
	end
	
	if self.maxLength and #value > self.maxLength then
		return false
	end
	
	return Base.IsValid(self, value)
end

return function() : StringSchema
	local self = setmetatable(Base.new(), String) :: StringSchema
	
	self.type = script.Name
	
	self.minLength = 0
	self.maxLength = math.huge
	
	return self
end