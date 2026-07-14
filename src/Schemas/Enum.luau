--!strict
--!native
--!optimize 2

const toType = require(script.Parent.Parent.toType)
const Base = require(script.Parent.Parent.Base)

export type EnumSchema = Base.BaseSchema<EnumSchema, EnumItem?>

local EnumM = {}
EnumM.__index = EnumM

setmetatable(EnumM, Base)

local KIND_SET = { Enum = true, EnumItem = true }

function EnumM.new() : EnumSchema
	local self = setmetatable(Base.new(), EnumM) :: any

	self.kindStr = "Enum | EnumItem"
	self.kindSet = KIND_SET

	return self
end

function EnumM:Coerce(value : any) : (Enum | EnumItem)?
	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end

	local to = typeof(value)

	if to ~= "Enum" and to ~= "EnumItem" then
		result = toType.Enum(result)
	end
	
	if result == nil then
		return self.default
	end
	
	return result
end

return EnumM.new