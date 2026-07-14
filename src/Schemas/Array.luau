--!strict
--!native
--!optimize 2

const getValidDc = require(script.Parent.Parent.getValidDc)
const typeOf = require(script.Parent.Parent.typeOf)
const toType = require(script.Parent.Parent.toType)
const tableUtils = require(script.Parent.Parent.tableUtils)
const Base = require(script.Parent.Parent.Base)
const Any = require(script.Parent.Any)

export type ArraySchema = Base.BaseSchema<ArraySchema, ({} | { any })?> & {
	MinLength : (self : ArraySchema, minLength : number) -> ArraySchema,
	MaxLength : (self : ArraySchema, maxLength : number) -> ArraySchema,
}

local Array = {}
Array.__index = Array

setmetatable(Array, Base)

local KIND_SET = { table = true }

function Array.new(arrayType : Any.AnySchema?) : ArraySchema
	local self = setmetatable(Base.new(), Array) :: any
	
	self.kindStr = "table"
	self.kindSet = KIND_SET

	self.arrayType = if typeOf(arrayType) == "Schema" then arrayType else Any()

	self.minLength = nil
	self.maxLength = nil
	
	return self
end

function Array:_matchesRules(value : any) : boolean
	local i = 0
	
	for k, val in value do
		i += 1
		if k ~= i then
			return false
		end
		if not self.arrayType:IsValid(val) then
			return false
		end
	end

	if self.minLength and #value < self.minLength then
		return false
	end
	
	if self.maxLength and #value > self.maxLength then
		return false
	end

	return true
end

function Array:_validate(value, dc, path, policy)
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

	local i = 0

	for key, val in value do
		i += 1

		if key ~= i then
			newDc:Add(policy, "Table is not an array", path)
			break
		end

		local newPath = { parent = path, key = key, isIndex = true }
		
		local newPolicy = self.arrayType.manualPolicy and 
		                  self.arrayType.policy or 
						  policy or 
						  self.arrayType.policy
						  
		self.arrayType:_validate(val, newDc, newPath, newPolicy)
	end

	if newDc:HasMessages() then
		if dc ~= newDc then
			newDc:Throw()
		end
		return
	end

	if self.minLength and #value < self.minLength then
		newDc:Add(
			policy, 
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
			policy, 
			`Array is too large. Expected at most {self.maxLength} elements, got {#value}`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
	end
end

function Array:MinLength(minLength : number) : ArraySchema
	const newDc = getValidDc()

	if typeOf(minLength) ~= "number" then
		newDc:Add("Error", `Expected number for minLength, got '{typeOf(minLength)}'`)
		newDc:Throw()
	end

	if minLength < 0 then
		newDc:Add("Error", `minLength cannot be negative`)
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
	self:_validateSchema()
	
	return self :: any
end

function Array:MaxLength(maxLength : number) : ArraySchema
	const newDc = getValidDc()

	if typeOf(maxLength) ~= "number" then
		newDc:Add("Error", `Expected number for maxLength, got '{typeOf(maxLength)}'`)
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
	self:_validateSchema()

	return self :: any
end

function Array:Coerce(value : any) : ({} | { any })?
	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end

	if self:IsValid(result) then
		return result
	end

	if not tableUtils.isArray(result) then
		result = toType.Array(result)
	else
		result = table.clone(result)
	end

	if result then
		for key, val in result do
			local coerced = self.arrayType:Coerce(val)
				
			if coerced == nil then
				result = nil
				break
			end
				
			result[key] = coerced
		end
	end
	
	if result == nil then
		return self.default
	end

	if self.minLength and #result < self.minLength then
		return nil
	end

	if self.maxLength and #result > self.maxLength then
		return nil
	end

	return result
end

return Array.new