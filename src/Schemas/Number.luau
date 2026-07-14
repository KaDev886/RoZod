--!strict
--!native
--!optimize 2

const getValidDc = require(script.Parent.Parent.getValidDc)
const typeOf = require(script.Parent.Parent.typeOf)
const Base = require(script.Parent.Parent.Base)

export type NumberSchema = Base.BaseSchema<NumberSchema, number?> & {
	Min: (self: NumberSchema, minValue: number) -> NumberSchema,
	Max: (self: NumberSchema, maxValue: number) -> NumberSchema,
}

local Number = {}
Number.__index = Number

setmetatable(Number, Base)

local KIND_SET = { number = true }

function Number.new() : NumberSchema
	local self = setmetatable(Base.new(), Number) :: any
	
	self.kindStr = "number"
	self.kindSet = KIND_SET

	self.min = -math.huge
	self.max = math.huge
	
	return self
end

function Number:_matchesRules(value : any)
	if value < self.min then
		return false
	end
	
	if value > self.max then
		return false
	end

	return true
end

function Number:_validate(value, dc, path, policy)
	if policy == "Silent" then return end

	if value == nil and self.optional then
		return
	end

	const newDc = getValidDc(dc)

	Base._validate(self, value, newDc, path, policy)

	if newDc:HasMessages() then
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
	end
end

function Number:Min(minValue : number) : NumberSchema
	const newDc = getValidDc()

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
	self:_validateSchema()
	
	return self :: any
end

function Number:Max(maxValue : number) : NumberSchema
	const newDc = getValidDc()

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
	self:_validateSchema()

	return self :: any
end

function Number:Coerce(value : any) : number?
	const min = self.min
	const max = self.max
	
	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end

	if typeof(result) ~= "number" then
		result = tonumber(result)
	end

	if result == nil then
		return self.default
	end
	
	if result < min then
		result = min
	end
	
	if result > max then
		result = max
	end
	
	return result
end

return Number.new