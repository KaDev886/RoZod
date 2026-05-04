--!strict

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

function Array.new(arrayType : Any.AnySchema) : ArraySchema
	local self = setmetatable(Base.new(), Array) :: any
	
	self.arrayType = if typeOf(arrayType) == "Schema" then arrayType else Any()
	self.minLength = nil
	self.maxLength = nil
	
	return self
end

function Array:_validate(value, dc, path, policy)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end
	
	if typeOf(value) ~= "table" then
		newDc:Add(policy, `Expected array, got '{typeOf(value)}'`, path)
		
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
		
		return
	end
	
	for key, val in value do
		local newPath = path and `{path}[{tostring(key)}]` or `[{tostring(key)}]`
		
		self.arrayType:_validate(val, newDc, newPath, policy or self.policy)
	end

	Base._validate(self, value, newDc, path, policy)

	if dc ~= newDc then
		newDc:Throw()
	end
end

function Array:MinLength(minLength : number) : ArraySchema
	local newDc = self:_getValidDc()

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
	self:_validateDefault()
	
	return self
end

function Array:MaxLength(maxLength : number) : ArraySchema
	local newDc = self:_getValidDc()

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
	self:_validateDefault()

	return self
end

function Array:Coerce(value : any) : ({} | { any })
	if self:IsValid(value) then
		return value
	end
	
	if self.default ~= nil then
		return self.default
	end

	local result = value
	
	if typeOf(result) ~= "table" then
		result = toType.Array(result)

		if result == nil then
			return nil
		end
	end
	
	result = tableUtils.copyTable(value)
	
	if self.minLength and #result < (self.minLength :: number) then
		result = tableUtils.fillTable(result, self.minLength, self.arrayType:Coerce())
	end
	
	if self.maxLength and #result > (self.maxLength :: number) then
		result = tableUtils.sliceTable(result, 1, self.maxLength)
	end
	
	for key, val in ipairs(result) do
		result[key] = self.arrayType:Coerce(val)
	end
	
	return Base.Coerce(self, result)
end

function Array:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Array:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if typeOf(value) ~= "table" then
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
	
	return Base.IsValid(self, value)
end

return setmetatable({}, {
	__call = function(_, arrayType : Any.AnySchema)
		return Array.new(arrayType)
	end
})