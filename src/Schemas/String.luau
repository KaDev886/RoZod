--!strict
--!native
--!optimize 2

const getValidDc = require(script.Parent.Parent.getValidDc)
const typeOf = require(script.Parent.Parent.typeOf)
const Base = require(script.Parent.Parent.Base)

export type StringSchema = Base.BaseSchema<StringSchema, string?> & {
	MinLength: (self: StringSchema, minLength: number) -> StringSchema,
	MaxLength: (self: StringSchema, maxLength: number) -> StringSchema,
}

local String = {}
String.__index = String

setmetatable(String, Base)

local KIND_SET = { string = true }

function String.new() : StringSchema
	local self = setmetatable(Base.new(), String) :: any

	self.kindStr = "string"
	self.kindSet = KIND_SET
	
	self.minLength = 0
	self.maxLength = math.huge
	
	return self
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
	end
end

function String:MinLength(minLength : number) : StringSchema
	const newDc = getValidDc()

	if typeOf(minLength) ~= "number" then
		newDc:Add("Error", `Expected number for minLength, got '{typeOf(minLength)}'`)
		newDc:Throw()
	end

	if minLength ~= minLength then
		newDc:Add("Error", `minLength cannot be NaN`)
		newDc:Throw()
	end

	if minLength < 0 then
		newDc:Add("Error", `minLength cannot be negative`)
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
	
	return self :: any
end

function String:MaxLength(maxLength : number) : StringSchema
	const newDc = getValidDc()

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

	return self :: any
end

function String:Coerce(value : any) : string?
	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end

	if typeof(result) ~= "string" then
		result = tostring(result)
	end

	if #result < self.minLength or #result > self.maxLength then
		return nil
	end
	
	return result
end

return String.new