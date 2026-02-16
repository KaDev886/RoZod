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
	local newDc = self:_getValidDc()

	if TypeOf(minLength) ~= "number" then
		newDc:Add("Error", `Expected number for minLength, got '{TypeOf(minLength)}'`)
		newDc:Throw()
	end

	if minLength == math.huge then
		newDc:Add("Error", `minLength cannot be infinity`)
		newDc:Throw()
	end

	if minLength > self.maxLength then
		newDc:Add(
			"Error", 
			`minLength cannot be greater than maxLength. Expected at most {self.maxLength}, got {minLength}`
		)
		newDc:Throw()
	end

	self.minLength = minLength
	self:_validateDefault()
	
	return self
end

function String:MaxLength(maxLength : number) : StringSchema
	local newDc = self:_getValidDc()
	
	if TypeOf(maxLength) ~= "number" then
		newDc:Add("Error", `Expected number for maxLength, got '{TypeOf(maxLength)}'`)
		newDc:Throw()
	end

	if maxLength < 0 then
		newDc:Add("Error", `maxLength cannot be negative`)
		newDc:Throw()
	end
	
	if maxLength < self.minLength then
		newDc:Add(
			"Error", 
			`maxLength cannot be less than minLength. Expected at least {self.minLength}, got {maxLength}`
		)
		newDc:Throw()
	end

	self.maxLength = maxLength
	self:_validateDefault()

	return self
end

function String:Coerce(value : any) : string
	if self:IsValid(value) then
		return value
	end
	
	local result = if self.default ~= nil then self.default else value
	
	if TypeOf(result) ~= "string" then
		result = ""
	end
	
	if #result < self.minLength then
		result = result .. string.rep(" ", self.minLength-#result)
	end
	
	if #result > self.maxLength then
		result = string.sub(result, 1, self.maxLength)
	end
	
	return Base.Coerce(self, result)
end

function String:Validate(value : any, dc : DebugContext.DebugContext?, path : string?)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end

	if TypeOf(value) ~= "string" then
		newDc:Add(self.policy, `Expected string, got '{TypeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if #value < self.minLength then
		newDc:Add(
			self.policy, 
			`String is too short. Expected at least {self.minLength} characters, got {#value}`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if #value > self.maxLength then
		newDc:Add(
			self.policy, 
			`String is too long. Expected at most {self.maxLength} characters, got {#value}`,
			path
		)
		
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

function String:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if TypeOf(value) ~= "string" then
		return false
	end
	
	if #value < self.minLength then
		return false
	end
	
	if #value > self.maxLength then
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