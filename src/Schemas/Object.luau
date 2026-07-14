--!strict
--!native
--!optimize 2

const getValidDc = require(script.Parent.Parent.getValidDc)
const typeOf = require(script.Parent.Parent.typeOf)
const toType = require(script.Parent.Parent.toType)
const tableUtils = require(script.Parent.Parent.tableUtils)
const Base = require(script.Parent.Parent.Base)

export type ObjectSchema = Base.BaseSchema<ObjectSchema, ({} | {[any] : any})?> & {
	Extra: (self: ObjectSchema) -> ObjectSchema,
}

local Object = {}
Object.__index = Object

setmetatable(Object, Base)

local KIND_SET = { table = true }

function Object.new(shape : {[any] : any}) : ObjectSchema
	local self = setmetatable(Base.new(), Object) :: any
	
	const newDc = getValidDc()
	
	if typeOf(shape) ~= "table" then
		newDc:Add("Error", `Expected a table for shape, got '{typeOf(shape)}'`)
		newDc:Throw()
	end
	
	for key, value in shape do
		if typeOf(key) == "number" then
			newDc:Add("Error", `Shape contains numeric keys`)
			newDc:Throw()
		end
		
		if typeOf(value) ~= "Schema" then
			newDc:Add("Error", `Expected a schema for value, got '{typeOf(value)}'`, key)
			newDc:Throw()
		end
	end
	
	self.kindStr = "table"
	self.kindSet = KIND_SET

	self.shape = shape
	self.extra = false
	
	local shapeKeys = {}
	local shapeKeysCount = 0

	for key in shape do
		shapeKeysCount += 1
		shapeKeys[shapeKeysCount] = key
	end

	self.shapeKeys = shapeKeys
	
	return self
end

function Object:_matchesRules(value : any) : boolean
	const shape = self.shape
	const shapeKeys = self.shapeKeys

	for i = 1, #shapeKeys do
		local key = shapeKeys[i]
		local rule = shape[key]

		if not rule:IsValid(value[key]) then
			return false
		end
	end
	
	if not self.extra then
		for key in value do
			if not shape[key] then
				return false
			end
		end
	end

	return true
end

function Object:_validate(value, dc, path, policy)
	if policy == "Silent" then return end

	if value == nil and self.optional then
		return
	end
	
	const newDc = getValidDc(dc)

	const shape = self.shape
	const shapeKeys = self.shapeKeys

	Base._validate(self, value, newDc, path, policy)

	if newDc:HasMessages() then
		if dc ~= newDc then
			newDc:Throw()
		end
		return
	end

	if not tableUtils.isDictionary(value) then
		newDc:Add(policy, "Table is not a dictionary", path)
	else
		for i = 1, #shapeKeys do
			local key = shapeKeys[i]
			local rule = shape[key]

			if value[key] == nil and not rule.optional then
				newDc:Add(policy, `Missing required key '{key}'`, path)
				continue
			end

			local newPath = { parent = path, key = key, isIndex = false }
			local newPolicy = rule.manualPolicy and rule.policy or policy or rule.policy
			
			rule:_validate(value[key], newDc, newPath, newPolicy)
		end
	end
	
	if newDc:HasMessages() then
		if dc ~= newDc then
			newDc:Throw()
		end
		return
	end
	
	if not self.extra then
		local result = true
		
		for key in value do
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
	return self :: any
end

function Object:Coerce(value : any) : ({} | {[any] : any})?
	local shape = self.shape

	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end

	if self:IsValid(result) then
		return result
	end

	if not tableUtils.isDictionary(result) then
		result = toType.DictTable(result)
	else
		result = table.clone(result)
	end

	if result then
		const shapeKeys = self.shapeKeys

		for i = 1, #shapeKeys do
			local key = shapeKeys[i]
			result[key] = shape[key]:Coerce(result[key])
		end
	end

	if result == nil then
		return self.default
	end

	if not self.extra then
		local keysToRemove = {}

		for key in result do
			if not shape[key] then
				keysToRemove[#keysToRemove + 1] = key
			end
		end

		for _, key in keysToRemove do
			result[key] = nil
		end
	end

	return result
end

return Object.new