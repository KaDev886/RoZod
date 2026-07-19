--!strict
--!native
--!optimize 2

const toType = require(script.Parent.Parent.toType)
const Base = require(script.Parent.Parent.Base)

export type Color3Schema = Base.BaseSchema<Color3Schema, Color3?>

local Color3M = {}
Color3M.__index = Color3M

setmetatable(Color3M, Base)

const KIND_SET = { Color3 = true }

function Color3M.new() : Color3Schema
	local self = setmetatable(Base.new(), Color3M) :: any

	self.kindStr = "Color3"
	self.kindSet = KIND_SET

	return self
end

function Color3M:Coerce(value : any) : Color3?
	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end
	
	if typeof(result) ~= "Color3" then
		result = toType.Color3(result)
	end
	
	if result == nil then
		return self.default
	end
	
	return result
end

return Color3M.new