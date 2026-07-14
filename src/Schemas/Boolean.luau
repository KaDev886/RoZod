--!strict
--!native
--!optimize 2

const toType = require(script.Parent.Parent.toType)
const Base = require(script.Parent.Parent.Base)

export type BooleanSchema = Base.BaseSchema<BooleanSchema, boolean?>

local Boolean = {}
Boolean.__index = Boolean

setmetatable(Boolean, Base)

local KIND_SET = { boolean = true }

function Boolean.new() : BooleanSchema
	local self = setmetatable(Base.new(), Boolean) :: any

	self.kindStr = "boolean"
	self.kindSet = KIND_SET

	return self
end

function Boolean:Coerce(value : any) : boolean?
	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end
	
	if value ~= false and value ~= true then
		result = toType.Boolean(result)
	end
	
	if result == nil then
		return self.default
	end
	
	return result
end

return Boolean.new