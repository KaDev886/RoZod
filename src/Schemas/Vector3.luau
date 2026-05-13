--!strict

local getValidDc = require(script.Parent.Parent.getValidDc)
local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local Base = require(script.Parent.Parent.Base)

export type Vector3Schema = Base.BaseSchema<Vector3Schema, Vector3?>

local Vector3M = {}
Vector3M.__index = Vector3M

setmetatable(Vector3M, Base)

function Vector3M.new() : Vector3Schema
	return setmetatable(Base.new(), Vector3M) :: any
end

function Vector3M:_matchesType(value : any) : boolean
	return typeOf(value) == "Vector3"
end

function Vector3M:_matchesRules(value : any) : boolean
	if value ~= value then
		return false
	end
	return true
end

function Vector3M:_validate(value, dc, path, policy)
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
	
	if to ~= "Vector3" then
		newDc:Add(policy, `Expected Vector3, got '{to}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end

	if value ~= value then
		newDc:Add(policy, "Expected valid Vector3, got NaN", path)

		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
end

function Vector3M:Coerce(value : any) : Vector3?
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

	if typeOf(result) ~= "Vector3" then
		result = toType.Vector3(result)
	end
	
	if result == nil or result ~= result then
		return self.default
	end
	
	return result
end

function Vector3M:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Vector3M:IsValid(value : any)
	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then 
		return true
	end

	if oneOfSet and not oneOfSet[value] then
		return false
	end

	if typeOf(value) ~= "Vector3" then
		return false
	end
	
	if value ~= value then
		return false
	end

	return true
end

return setmetatable({}, {
	__call = function()
		return Vector3M.new()
	end,
})