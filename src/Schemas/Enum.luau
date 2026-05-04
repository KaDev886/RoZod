--!strict

local typeOf = require(script.Parent.Parent.typeOf)
local toType = require(script.Parent.Parent.toType)
local Base = require(script.Parent.Parent.Base)

export type EnumSchema = Base.BaseSchema<EnumSchema, (Enum | EnumItem)?>

local EnumM = {}
EnumM.__index = EnumM

setmetatable(EnumM, Base)

local function isValidType(value : any) : boolean
	local to = typeOf(value)
	return to == "Enum" or to == "EnumItem"
end

function EnumM.new() : EnumSchema
	return setmetatable(Base.new(), EnumM) :: any
end

function EnumM:_validate(value, dc, path, policy)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end

	if not isValidType(value) then
		newDc:Add(policy, `Expected Enum or EnumItem, got '{typeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	Base._validate(self, value, newDc, path, policy)
	
	if dc ~= newDc then
		newDc:Throw()
	end
end

function EnumM:Coerce(value : any) : (Enum | EnumItem)
	if self:IsValid(value) then
		return value
	end

	if self.default ~= nil then
		return self.default
	end

	local result = value
	
	if not isValidType(result) then
		result = toType.Enum(result)

		if result == nil then
			return nil
		end
	end
	
	return Base.Coerce(self, result)
end

function EnumM:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function EnumM:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end
	
	if not isValidType(value) then
		return false
	end
	
	return Base.IsValid(self, value)
end

return setmetatable({}, {
	__call = function()
		return EnumM.new()
	end
})