--!strict

local getValidDc = require(script.Parent.Parent.getValidDc)
local typeOf = require(script.Parent.Parent.typeOf)
local Base = require(script.Parent.Parent.Base)

export type StringSchema = Base.BaseSchema<StringSchema, string?> & {
	MinLength: (self: StringSchema, minLength: number) -> StringSchema,
	MaxLength: (self: StringSchema, maxLength: number) -> StringSchema,
}

local String = {}
String.__index = String

setmetatable(String, Base)

function String.new() : StringSchema
	local self = setmetatable(Base.new(), String) :: any
	
	self.minLength = 0
	self.maxLength = math.huge
	
	return self
end

function String:_matchesType(value : any) : boolean
	return typeOf(value) == "string"
end

function String:_matchesRules(value : any) : boolean
	if #value < self.minLength then
		return false
	end
	
	if #value > self.maxLength then
		return false
	end

	return true
end

function String:_validate(value, dc, path, policy)
	if policy == "Silent" then return end

	local newDc = getValidDc(dc)

	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then
		return
	end
	
	if oneOfSet and not oneOfSet[value] then
		newDc:Add(
			policy, 
			`Expected one of: {table.concat(self.oneOf, " | ")} got '{value}'`,
			path
		)
				
		if dc ~= newDc then
			newDc:Throw()
		end

		return
	end

	local to = typeOf(value)
	
	if to ~= "string" then
		newDc:Add(policy, `Expected string, got '{to}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if #value < self.minLength then
		newDc:Add(
			policy, 
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
			policy, 
			`String is too long. Expected at most {self.maxLength} characters, got {#value}`,
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
end

function String:MinLength(minLength : number) : StringSchema
	local newDc = getValidDc()

	if typeOf(minLength) ~= "number" then
		newDc:Add("Error", `Expected number for minLength, got '{typeOf(minLength)}'`)
		newDc:Throw()
	end

	if minLength ~= minLength then
		newDc:Add("Error", `minLength cannot be NaN`)
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
	self:_validateSchema()
	
	return self
end

function String:MaxLength(maxLength : number) : StringSchema
	local newDc = getValidDc()

	if typeOf(maxLength) ~= "number" then
		newDc:Add("Error", `Expected number for maxLength, got '{typeOf(maxLength)}'`)
		newDc:Throw()
	end

	if maxLength ~= maxLength then
		newDc:Add("Error", `maxLength cannot be NaN`)
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
	self:_validateSchema()

	return self
end

function String:Coerce(value : any) : string?
	local oneOfSet = self.oneOfSet
	
	local result = value

	if value == nil then
		if self.optional then
			return nil
		end
		return self.default
	end
	
	if oneOfSet and not oneOfSet[value] then
		return self.default
	end

	if typeOf(result) ~= "string" then
		result = tostring(result)
	end

	if result == nil then
		return self.default
	end
	
	return result
end

function String:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function String:IsValid(value : any)
	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then 
		return true
	end

	if oneOfSet and not oneOfSet[value] then
		return false
	end

	if typeOf(value) ~= "string" then
		return false
	end

	if #value < self.minLength then
		return false
	end
	
	if #value > self.maxLength then
		return false
	end

	return true
end

return setmetatable({}, {
	__call = function()
		return String.new()
	end
})