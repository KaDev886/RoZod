--!strict

local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local tableUtils = require(script.Parent.Parent.tableUtils)
local Base = require(script.Parent.Parent.Base)

export type ObjectSchema = Base.BaseSchema<ObjectSchema, ({} | {[any] : any})?> & {
	Extra: (self: ObjectSchema) -> ObjectSchema,
}

local Object = {}
Object.__index = Object

setmetatable(Object, Base)

function Object.new(shape : {[any] : any}) : ObjectSchema
	local self = setmetatable(Base.new(), Object) :: any
	
	local newDc = self:_getValidDc()
	
	if typeOf(shape) ~= "table" then
		newDc:Add("Error", `Expected a table for shape, got '{typeOf(shape)}'`)
		newDc:Throw()
	end
	
	for key, value in shape do
		if typeOf(key) == "number" then
			newDc:Add("Error", `Shape container a number keys`)
			newDc:Throw()
		end
		
		if typeOf(value) ~= "Schema" then
			newDc:Add("Error", `Expected a schema for value, got '{typeOf(value)}'`, key)
			newDc:Throw()
		end
	end
	
	self.shape = shape
	self.extra = false
	
	return self
end

function Object:_validate(value, dc, path, policy)
	if value == nil and self.optional then
		return
	end

	local newDc = self:_getValidDc(dc)

	if typeOf(value) ~= "table" then
		newDc:Add(policy, `Expected a table, got '{typeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	local result = true
	
	for key, rule in self.shape do
		if not rule:IsValid(value[key]) then
			if value[key] == nil then
				newDc:Add(policy, `Missing required key '{tostring(key)}'`, path)
			else
				newDc:Add(policy, `Invalid value for key '{tostring(key)}'`, path)
			end

			local newPath = path and `{path}.{tostring(key)}` or `{tostring(key)}`
			local newPolicy = rule.manualPolicy and rule.policy or policy or rule.policy
			
			rule:_validate(value[key], newDc, newPath, newPolicy)

			result = false
		end
	end
	
	if not result then
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if not self.extra then
		local result = true
		
		for key, _ in value do
			if not self.shape[key] then
				newDc:Add(policy, `Unexpected extra key '{tostring(key)}'`, path)
				
				result = false
			end
		end
		
		if not result then
			if dc ~= newDc then
				newDc:Throw()
			end
		end
	end

	Base._validate(self, value, newDc, path, policy)

	if dc ~= newDc then
		newDc:Throw()
	end
end

function Object:Extra() : ObjectSchema
	self.extra = true
	return self
end

function Object:Coerce(value : any) : ({} | {[any] : any})?
	if value == nil then
		if self.optional then
			return nil
		end
		return self.default
	end

	local result = value
	
	if typeOf(result) ~= "table" then
		result = toType.DistTable(result)
	end

	if result == nil then
		return self.default
	end

	-- Normalize (':Normalize()' method in the future)

	result = tableUtils.copyTable(result)
	
	local shape = self.shape :: {[any] : any}

	for key, rule in shape do
		result[key] = rule:Coerce(result[key])
	end

	if not self.extra then
		for key in result do
			if not shape[key] then
				result[key] = nil
			end
		end
	end

	-- Normalize END
	
	return Base.Coerce(self, result)
end

function Object:Validate(value : ({} | {[any] : any}))
	self:_validate(value, nil, nil, self.policy)
end

function Object:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end

	if typeOf(value) ~= "table" then
		return false
	end
	
	for key, rule in self.shape do
		if not (rule :: any):IsValid(value[key]) then
			return false
		end
	end
	
	if not self.extra then
		for key, _ in value do
			if not self.shape[key] then
				return false
			end
		end
	end
	
	return Base.IsValid(self, value)
end

return setmetatable({}, {
	__call = function(_, shape : {[any] : any})
		return Object.new(shape)
	end
})