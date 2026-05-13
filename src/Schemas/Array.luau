--!strict

local getValidDc = require(script.Parent.Parent.getValidDc)
local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local tableUtils = require(script.Parent.Parent.tableUtils)
local Base = require(script.Parent.Parent.Base)
local Any = require(script.Parent.Any)

export type ArraySchema = Base.BaseSchema<ArraySchema, ({} | { any })?> & {
	MinLength : (self : ArraySchema, minLength : number) -> ArraySchema,
	MaxLength : (self : ArraySchema, maxLength : number) -> ArraySchema,
}

local Array = {}
Array.__index = Array

setmetatable(Array, Base)

function Array.new(arrayType : Any.AnySchema?) : ArraySchema
	local self = setmetatable(Base.new(), Array) :: any
	
	self.arrayType = if typeOf(arrayType) == "Schema" then arrayType else Any()

	self.minLength = nil
	self.maxLength = nil
	
	return self
end

function Array:_matchesType(value : any) : boolean
	return tableUtils.isArray(value)
end

function Array:_matchesRules(value : any) : boolean
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

function Array:_validate(value, dc, path, policy)
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
	
	if to ~= "table" then
		newDc:Add(policy, `Expected table, got '{to}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end

	local i = 0

	for key, val in value do
		i += 1

		if key ~= i then
			newDc:Add(policy, "table don't is array", path)
			return
		end

		local newPath = path and `{path}[{key}]` or `[{key}]`

		local newPolicy = self.arrayType.manualPolicy and 
		                  self.arrayType.policy or 
						  policy or 
						  self.arrayType.policy
						  
		self.arrayType:_validate(val, newDc, newPath, newPolicy)
	end

	if dc ~= newDc and newDc:HasMessages() then
		newDc:Throw()
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
	local newDc = getValidDc()

	if typeOf(minLength) ~= "number" then
		newDc:Add("Error", `Expected number for minLength, got '{typeOf(minLength)}'`)
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
	self:_validateSchema()
	
	return self
end

function Array:MaxLength(maxLength : number) : ArraySchema
	local newDc = getValidDc()

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

	return self
end

function Array:Coerce(value : any) : ({} | { any })?
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

	if not tableUtils.isArray(result) then
		result = toType.Array(result)
	else
		result = tableUtils.copyTable(result)
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
	
	if result == nil or #result == 0 then
		return self.default
	end

	-- I might remove this in the future
	if self.minLength and #result < self.minLength then
		result = tableUtils.fillTable(result, self.minLength, self.arrayType:Coerce())
	end
	
	if self.maxLength and #result > self.maxLength then
		result = tableUtils.sliceTable(result, 1, self.maxLength)
	end
	
	return result
end

function Array:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Array:IsValid(value : any)
	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then 
		return true
	end

	if oneOfSet and not oneOfSet[value] then
		return false
	end

	if typeOf(value) ~= "table" then
		return false
	end
	
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

return setmetatable({}, {
	__call = function(_, arrayType : Any.AnySchema?)
		return Array.new(arrayType)
	end
})