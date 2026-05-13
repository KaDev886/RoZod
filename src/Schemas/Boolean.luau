--!strict

local getValidDc = require(script.Parent.Parent.getValidDc)
local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local Base = require(script.Parent.Parent.Base)

export type BooleanSchema = Base.BaseSchema<BooleanSchema, boolean?>

local Boolean = {}
Boolean.__index = Boolean

setmetatable(Boolean, Base)

function Boolean.new() : BooleanSchema
	return setmetatable(Base.new(), Boolean) :: any
end

function Boolean:_matchesType(value : any) : boolean
	return typeOf(value) == "boolean"
end

function Boolean:_validate(value, dc, path, policy)
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
	
	if value ~= false and value ~= true then
		newDc:Add(policy, `Expected boolean, got '{typeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
end

function Boolean:Coerce(value : any) : boolean?
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
	
	if value ~= false and value ~= true then
		result = toType.Boolean(result)
	end
	
	if result == nil then
		return self.default
	end
	
	return result
end

function Boolean:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Boolean:IsValid(value : any)
	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then 
		return true
	end

	if oneOfSet and not oneOfSet[value] then
		return false
	end

	if value ~= false and value ~= true then
		return false
	end

	return true
end

return setmetatable({}, {
	__call = function()
		return Boolean.new()
	end
})