--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
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
	self.min = minValue
	return self
end

function Number:Max(maxValue : number) : NumberSchema
	self.max = maxValue
	return self
end

function Number:Coerce(value : any) : number
	if self:IsValid(value) then
		return value
	end
	
	local result = self.default or value
	
	if typeof(result) ~= "number" then
		result = 0
	end
	
	if self.min and result < self.min then
		result = self.min
	end
	
	if self.max and result > self.max then
		result = self.max
	end
	
	return Base.Coerce(self, result)
end

function Number:Validate(value : any, dc : DebugContext.DebugContext?)
	local newDc = self:_getValidDc(dc)
	
	if typeof(value) ~= "number" then
		newDc:Add(self.policy, self.type, `Expected number, got '{typeof(value)}'`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if value < self.min then
		newDc:Add(self.policy, self.type, `Number is too small`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if value > self.max then
		newDc:Add(self.policy, self.type, `Number is too large`)
		
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

function Number:IsValid(value : any) : boolean
	if typeof(value) ~= "number" then
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