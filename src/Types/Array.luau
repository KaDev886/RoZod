--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local TypeOf = require(script.Parent.Parent.TypeOf)
local Utils = require(script.Parent.Parent.Utils)
local Base = require(script.Parent.Parent.Base)
local Any = require(script.Parent.Any)

export type ArraySchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	arrayType: any,
	minLength: number,
	maxLength: number,
	
	Silent: (self: ArraySchema) -> ArraySchema,
	Warn: (self: ArraySchema) -> ArraySchema,
	Error: (self: ArraySchema) -> ArraySchema,
	Default: (self: ArraySchema, value: any) -> ArraySchema,
	Expected: (self: ArraySchema, expecteds: { any }) -> ArraySchema,
	Optional: (self: ArraySchema) -> ArraySchema,
	
	MinLength: (self: ArraySchema, minLength: number) -> ArraySchema,
	MaxLength: (self: ArraySchema, maxLength: number) -> ArraySchema,
	
	Coerce: (self: ArraySchema, value: any) -> ({} | { any }),
	Validate: (self: ArraySchema, value: any) -> (),
	IsValid: (self: ArraySchema, value: any) -> boolean,
}

local Array = {}
Array.__index = Array

setmetatable(Array, { __index = Base })

function Array:MinLength(minLength : number) : ArraySchema
	local newDc = self:_getValidDc()

	if TypeOf(minLength) ~= "number" then
		newDc:Add("Error", `Expected number for minLength, got '{TypeOf(minLength)}'`)
		newDc:Throw()
	end

	if minLength == math.huge then
		newDc:Add("Error", `minLength cannot be infinity`)
		newDc:Throw()
	end

	if self.maxLength and minLength > self.maxLength then
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

function Array:MaxLength(maxLength : number) : ArraySchema
	local newDc = self:_getValidDc()

	if TypeOf(maxLength) ~= "number" then
		newDc:Add("Error", `Expected number for maxLength, got '{TypeOf(maxLength)}'`)
		newDc:Throw()
	end

	if maxLength < 0 then
		newDc:Add("Error", `maxLength cannot be negative`)
		newDc:Throw()
	end

	if self.minLength and maxLength < self.minLength then
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

function Array:Coerce(value : any) : ({} | { any })
	if self:IsValid(value) then
		return value
	end
	
	local result = if self.default ~= nil then self.default else value
	
	if TypeOf(result) ~= "table" then
		result = {}
	else
		result = Utils.copyTable(value)
	end
	
	if self.minLength and #result < (self.minLength :: number) then
		result = Utils.fillTable(result, self.minLength, self.arrayType:Coerce(nil))
	end
	
	if self.maxLength and #result > (self.maxLength :: number) then
		result = Utils.sliceTable(result, 1, self.maxLength)
	end
	
	for key, val in ipairs(result) do
		result[key] = self.arrayType:Coerce(val)
	end
	
	return Base.Coerce(self, result)
end

function Array:Validate(value : any, dc : DebugContext.DebugContext?, path : string?)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end
	
	if TypeOf(value) ~= "table" then
		newDc:Add(self.policy, `Expected array, got '{TypeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if self.minLength and #value < self.minLength then
		newDc:Add(
			self.policy, 
			`Array is too small. Expected at least {self.minLength} elements, got {#value}`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if self.maxLength and #value > self.maxLength then
		newDc:Add(
			self.policy, 
			`Array is too large. Expected at most {self.maxLength} elements, got {#value}`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	for key, val in value do
		local newPath = path and `{path}[{tostring(key)}]` or `[{tostring(key)}]`

		self.arrayType:Validate(val, newDc, newPath)
	end

	Base.Validate(self, value, newDc, path)

	if dc ~= newDc then
		newDc:Throw()
	end
end

function Array:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if TypeOf(value) ~= "table" then
		return false
	end
	
	if self.minLength and #value < self.minLength then
		return false
	end
	
	if self.maxLength and #value > self.maxLength then
		return false
	end
	
	for _, val in value do
		if not self.arrayType:IsValid(val) then
			return false
		end
	end
	
	return Base.IsValid(self, value)
end

return function(arrayType : any) : ArraySchema
	local self = setmetatable(Base.new(), Array) :: ArraySchema
	
	self.type = script.Name

	self.arrayType = if TypeOf(arrayType) == "Schema" then arrayType else Any()

	self.minLength = 0
	self.maxLength = math.huge
	
	return self
end