--!strict

local getValidDc = require(script.Parent.Parent.getValidDc)
local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local Base = require(script.Parent.Parent.Base)

export type EnumSchema = Base.BaseSchema<EnumSchema, (Enum | EnumItem)?>

local EnumM = {}
EnumM.__index = EnumM

setmetatable(EnumM, Base)

function EnumM.new() : EnumSchema
	return setmetatable(Base.new(), EnumM) :: any
end

function EnumM:_matchesType(value : any) : boolean
	local to = typeOf(value)
	return to == "Enum" or to == "EnumItem"
end

function EnumM:_validate(value, dc, path, policy)
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

	if to ~= "Enum" and to ~= "EnumItem" then
		newDc:Add(policy, `Expected Enum or EnumItem, got '{to}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
end

function EnumM:Coerce(value : any) : (Enum | EnumItem)?
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
	
	local to = typeOf(value)

	if to ~= "Enum" and to ~= "EnumItem" then
		result = toType.Enum(result)
	end

	if result == nil then
		return self.default
	end
	
	return result
end

function EnumM:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function EnumM:IsValid(value : any)
	local oneOfSet = self.oneOfSet

	if value == nil and self.optional then 
		return true
	end
	
	if oneOfSet and not oneOfSet[value] then
		return false
	end

	local to = typeOf(value)

	if to ~= "Enum" and to ~= "EnumItem" then
		return false
	end
	
	return true
end

return setmetatable({}, {
	__call = function()
		return EnumM.new()
	end
})