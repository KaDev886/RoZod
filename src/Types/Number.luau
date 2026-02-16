--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local TypeOf = require(script.Parent.Parent.TypeOf)
local Base = require(script.Parent.Parent.Base)

export type NumberSchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	min: number,
	max: number,
	
	Silent: (self: NumberSchema) -> NumberSchema,
	Warn: (self: NumberSchema) -> NumberSchema,
	Error: (self: NumberSchema) -> NumberSchema,
	Default: (self: NumberSchema, value: any) -> NumberSchema,
	Expected: (self: NumberSchema, expecteds: { any }) -> NumberSchema,
	Optional: (self: NumberSchema) -> NumberSchema,
	
	Min: (self: NumberSchema, min: number) -> NumberSchema,
	Max: (self: NumberSchema, max: number) -> NumberSchema,
	
	Coerce: (self: NumberSchema, value: any) -> number,
	Validate: (self: NumberSchema, value: any) -> (),
	IsValid: (self: NumberSchema, value: any) -> boolean,
}

local Number = {}
Number.__index = Number

setmetatable(Number, { __index = Base })

function Number:Min(minValue : number) : NumberSchema
	local newDc = self:_getValidDc()

	if TypeOf(minValue) ~= "number" then
		newDc:Add("Error", `Expected number for min, got '{TypeOf(minValue)}'`)
		newDc:Throw()
	end

	if minValue > self.max then
		newDc:Add(
			"Error", 
			`min cannot be greater than max. Expected at most {self.max}, got {minValue}`
		)
		newDc:Throw()
	end
	
	self.min = minValue
	self:_validateDefault()
	
	return self
end

function Number:Max(maxValue : number) : NumberSchema
	local newDc = self:_getValidDc()

	if TypeOf(maxValue) ~= "number" then
		newDc:Add("Error", `Expected number for max, got '{TypeOf(maxValue)}'`)
		newDc:Throw()
	end

	if maxValue < self.min then
		newDc:Add(
			"Error", 
			`max cannot be less than min. Expected at least {self.min}, got {maxValue}`
		)
		newDc:Throw()
	end

	self.max = maxValue
	self:_validateDefault()

	return self
end

function Number:Coerce(value : any) : number
	if self:IsValid(value) then
		return value
	end
	
	local result = if self.default ~= nil then self.default else value
	
	if TypeOf(result) ~= "number" then
		result = 0
	end
	
	if result < self.min then
		result = self.min
	end
	
	if result > self.max then
		result = self.max
	end
	
	return Base.Coerce(self, result)
end

function Number:Validate(value : any, dc : DebugContext.DebugContext?, path : string?)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end
	
	if TypeOf(value) ~= "number" then
		newDc:Add(self.policy, `Expected number, got '{TypeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if value < self.min then
		newDc:Add(
			self.policy, 
			`Number is too small. Expected at least {self.min}, got {value}`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if value > self.max then
		newDc:Add(
			self.policy, 
			`Number is too large. Expected at most {self.max}, got {value}`, 
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

function Number:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if TypeOf(value) ~= "number" then
		return false
	end
	
	if value < self.min then
		return false
	end
	
	if value > self.max then
		return false
	end
	
	return Base.IsValid(self, value)
end

return function() : NumberSchema
	local self = setmetatable(Base.new(), Number) :: NumberSchema
	
	self.type = script.Name
	
	self.min = -math.huge
	self.max = math.huge

	return self
end