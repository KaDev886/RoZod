--!strict
--!native
--!optimize 2

const toType = require(script.Parent.Parent.toType)
const Base = require(script.Parent.Parent.Base)

export type Vector3Schema = Base.BaseSchema<Vector3Schema, Vector3?>

local Vector3M = {}
Vector3M.__index = Vector3M

setmetatable(Vector3M, Base)

const KIND_SET = { Vector3 = true }

function Vector3M.new() : Vector3Schema
	local self = setmetatable(Base.new(), Vector3M) :: any

	self.kindStr = "Vector3"
	self.kindSet = KIND_SET
	
	return self
end

function Vector3M:Coerce(value : any) : Vector3?
	local result = Base.Coerce(self, value)
	
	if result == nil then
		return nil
	end

	if typeof(result) ~= "Vector3" then
		result = toType.Vector3(result)
	end
	
	if result == nil then
		return self.default
	end
	
	return result
end

return Vector3M.new