--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local TypeOf = require(script.Parent.Parent.TypeOf)
local Utils = require(script.Parent.Parent.Utils)
local Base = require(script.Parent.Parent.Base)

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
	self.minLength = minLength
	return self
end

function Array:MaxLength(maxLength : number) : ArraySchema
	self.maxLength = maxLength
	return self
end

function Array:Coerce(value : any) : ({} | { any })
	if self:IsValid(value) then
		return value
	end
	
	local result = self.default or value
	
	if not self.arrayType then
		return {}
	end
	
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
	
	for key, val in result do
		result[key] = self.arrayType:Coerce(val)
	end
	
	return result
end

function Array:Validate(value : any, dc : DebugContext.DebugContext?)
	local newDc = self:_getValidDc(dc)
	
	if TypeOf(value) ~= "table" then
		newDc:Add(self.policy, self.type, `Expected array, got '{TypeOf(value)}'`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if self.minLength and #value < self.minLength then
		newDc:Add(self.policy, self.type, `Array is too small`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if self.maxLength and #value > self.maxLength then
		newDc:Add(self.policy, self.type, `Array is too large`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	for _, val in value do
		self.arrayType:Validate(val, newDc)
	end
end

function Array:IsValid(value : any) : boolean
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
	
	return true
end

return function(arrayType : any) : ArraySchema
	local self = setmetatable(Base.new(), Array) :: ArraySchema
	
	self.type = script.Name
	
	self.arrayType = arrayType
	
	self.minLength = 0
	self.maxLength = math.huge
	
	return self
end