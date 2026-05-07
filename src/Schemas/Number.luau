--!strict

local typeOf = require(script.Parent.Parent.typeOf)
local Base = require(script.Parent.Parent.Base)

export type NumberSchema = Base.BaseSchema<NumberSchema, number?> & {
	Min: (self: NumberSchema, minValue: number) -> NumberSchema,
	Max: (self: NumberSchema, maxValue: number) -> NumberSchema,
}

local Number = {}
Number.__index = Number

setmetatable(Number, Base)

function Number.new() : NumberSchema
	local self = setmetatable(Base.new(), Number) :: any
	
	self.min = -math.huge
	self.max = math.huge
	
	return self
end

function Number:_validate(value, dc, path, policy)
	if value == nil and self.optional then
		return
	end

	local newDc = self:_getValidDc(dc)

	if typeOf(value) ~= "number" then
		newDc:Add(policy, `Expected number, got '{typeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end

	if value ~= value then
		newDc:Add(policy, "Expected valid number, got NaN", path)

		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if value < self.min then
		newDc:Add(
			policy, 
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
			policy, 
			`Number is too large. Expected at most {self.max}, got {value}`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	Base._validate(self, value, newDc, path, policy)

	if dc ~= newDc then
		newDc:Throw()
	end
end

function Number:Min(minValue : number) : NumberSchema
	local newDc = self:_getValidDc()

	if typeOf(minValue) ~= "number" then
		newDc:Add("Error", `Expected number for min, got '{typeOf(minValue)}'`)
		newDc:Throw()
	end

	if minValue ~= minValue then
		newDc:Add("Error", `min cannot be NaN`)
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

	if typeOf(maxValue) ~= "number" then
		newDc:Add("Error", `Expected number for max, got '{typeOf(maxValue)}'`)
		newDc:Throw()
	end

	if maxValue ~= maxValue then
		newDc:Add("Error", `max cannot be NaN`)
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
	if value == nil then
		if self.optional then
			return nil
		end
		return self.default
	end

    local result = value
	
	if typeOf(result) ~= "number" then
		result = tonumber(result)
	end

	if result == nil or result ~= result then
		return self.default
	end

	-- Normalize (':Normalize()' method in the future)
	
	if result < self.min then
		result = self.min
	end
	
	if result > self.max then
		result = self.max
	end

	-- Normalize END
	
	return Base.Coerce(self, result)
end

function Number:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Number:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if typeOf(value) ~= "number" then
		return false
	end

	if value ~= value then
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

return setmetatable({}, {
	__call = function()
		return Number.new()
	end
})