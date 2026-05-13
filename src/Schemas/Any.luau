--!strict

local getValidDc = require(script.Parent.Parent.getValidDc)
local Base = require(script.Parent.Parent.Base)

local Any = {}
Any.__index = Any

setmetatable(Any, Base)

export type AnySchema = Base.BaseSchema<AnySchema, any?>

function Any.new() : AnySchema
	return setmetatable(Base.new(), Any) :: any
end

function Any:_matchesRules(value : any) : boolean
	if value == nil then
		return false
	end

	if value ~= value then
		return false
	end

	return true
end

function Any:_validate(value, dc, path, policy)
	if policy == "Silent" then return end

	local newDc = getValidDc(dc)

	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then
		return
	end
	
	if oneOfSet and not oneOfSet[value] then
		newDc:Add(
			policy, 
			`Expected one of: {table.concat(oneOfSet, " | ")} got '{tostring(value)}'`,
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end

		return
	end

	if value == nil then
		newDc:Add(policy, "Expected valid value, got nil", path)

		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if value ~= value then
		newDc:Add(policy, "Expected valid value, got NaN", path)

		if dc ~= newDc then
			newDc:Throw()
		end
	end
end

function Any:Coerce(value: any) : any
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

	if result ~= result then
		return self.default
	end

	return result
end

function Any:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Any:IsValid(value : any)
	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then 
		return true
	end

	if oneOfSet and not oneOfSet [value] then
		return false
	end

	if value == nil then
		return false
	end

	if value ~= value then
		return false
	end
	
	return true
end

return setmetatable({}, {
	__call = function()
		return Any.new()
	end
})