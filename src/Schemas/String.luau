--!strict

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
	
	self.type = script.Name
	
	self.minLength = 0
	self.maxLength = math.huge
	
	return self
end

function String:_validate(value, dc, path, policy)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end

	if typeOf(value) ~= "string" then
		newDc:Add(policy, `Expected string, got '{typeOf(value)}'`, path)
		
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
	
	Base._validate(self, value, newDc, path, policy)

	if dc ~= newDc then
		newDc:Throw()
	end
end

function String:MinLength(minLength : number) : StringSchema
	local newDc = self:_getValidDc()

	if typeOf(minLength) ~= "number" then
		newDc:Add("Error", `Expected number for minLength, got '{typeOf(minLength)}'`)
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

	if typeOf(maxLength) ~= "number" then
		newDc:Add("Error", `Expected number for maxLength, got '{typeOf(maxLength)}'`)
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

function String:Coerce(value : any) : string?
	if self:IsValid(value) then
		return value
	end

	if self.default ~= nil then
		return self.default
	end
	
	local result = value
	
	if typeOf(result) ~= "string" then
		result = tostring(result)

		if result == nil then
			return nil	
		end
	end
	
	if #result < self.minLength then
		result = result .. string.rep(" ", self.minLength-#result)
	end
	
	if #result > self.maxLength then
		result = string.sub(result, 1, self.maxLength)
	end
	
	return Base.Coerce(self, result)
end

function String:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function String:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
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
	
	return Base.IsValid(self, value)
end

return setmetatable({}, {
	__call = function()
		return String.new()
	end
})