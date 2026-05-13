--!strict

local getValidDc = require(script.Parent.Parent.getValidDc)
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
	
	local newDc = getValidDc()
	
	if typeOf(shape) ~= "table" then
		newDc:Add("Error", `Expected a table for shape, got '{typeOf(shape)}'`)
		newDc:Throw()
	end
	
	for key, value in shape do
		if typeOf(key) == "number" then
			newDc:Add("Error", `Shape container a number keys`)
			newDc:Throw()
		end
		
		if typeOf(value) == "table" and value then
			newDc:Add("Error", `Expected a schema for value, got '{typeOf(value)}'`, key)
			newDc:Throw()
		end
	end
	
	self.shape = shape
	self.extra = false
	
	return self
end

function Object:_matchesType(value : any) : boolean
	return tableUtils.isDictionary(value)
end

function Object:_matchesRules(value : any) : boolean
	for key, rule in self.shape do
		if not rule:IsValid(value[key]) then
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

	return true
end

function Object:_validate(value, dc, path, policy)
	if policy == "Silent" then return end
	
	local newDc = getValidDc(dc)

	local oneOfSet = self.oneOfSet
	local shape = self.shape

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

	for key, rule in shape do
		i += 1

		if key == i then
			newDc:Add(policy, "table don't is dictionary", path)
			return
		end

		if value[key] == nil and not rule.optional then
			newDc:Add(policy, `Missing required key '{tostring(key)}'`, path)
		end
		
		local newPath = path and `{path}.{tostring(key)}` or `{tostring(key)}`
		local newPolicy = rule.manualPolicy and rule.policy or policy or rule.policy
		
		rule:_validate(value[key], newDc, newPath, newPolicy)
	end
	
	if dc ~= newDc and newDc:HasMessages() then
		newDc:Throw()
		return
	end
	
	if not self.extra then
		local result = true
		
		for key, _ in value do
			if not shape[key] then
				newDc:Add(policy, `Unexpected extra key '{key}'`, path)
				
				result = false
			end
		end
		
		if not result then
			if dc ~= newDc then
				newDc:Throw()
			end
		end
	end
end

function Object:Extra() : ObjectSchema
	self.extra = true
	return self
end

function Object:Coerce(value : any) : ({} | {[any] : any})?
	local oneOfSet = self.oneOfSet
	local shape = self.shape

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

	if not tableUtils.isDictionary(result) then
		result = toType.DictTable(result)
	else
		result = tableUtils.copyTable(result)
	end

	if result then
		for key, rule in shape do
			result[key] = rule:Coerce(result[key])
		end
	end

	if result == nil then
		return self.default
	end

	if not self.extra then
		for key in result do
			if not shape[key] then
				result[key] = nil
			end
		end
	end

	return result
end

function Object:Validate(value : ({} | {[any] : any}))
	self:_validate(value, nil, nil, self.policy)
end

function Object:IsValid(value : any)
	local oneOf = self.oneOf
	local shape = self.shape

	if value == nil and self.optional then 
		return true
	end
	
	if oneOf and not oneOf[value] then
		return false
	end

	if typeOf(value) ~= "table" then
		return false
	end

	local i = 0

	for key, rule in shape do
		i += 1

		if key == i then
			return false
		end

		if not rule:IsValid(value[key]) then
			return false
		end
	end

	if not self.extra then
		for key, _ in value do
			if not shape[key] then
				return false
			end
		end
	end

	return true
end

return setmetatable({}, {
	__call = function(_, shape : {[any] : any})
		return Object.new(shape)
	end
})