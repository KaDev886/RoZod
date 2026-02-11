--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local Base = require(script.Parent.Parent.Base)

export type Vector3Schema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	Silent: (self: Vector3Schema) -> Vector3Schema,
	Warn: (self: Vector3Schema) -> Vector3Schema,
	Error: (self: Vector3Schema) -> Vector3Schema,
	Default: (self: Vector3Schema, value: any) -> Vector3Schema,
	Expected: (self: Vector3Schema, expecteds: { any }) -> Vector3Schema,
	Optional: (self: Vector3Schema) -> Vector3Schema,
	
	Coerce: (self: Vector3Schema, value: any) -> Vector3,
	Validate: (self: Vector3Schema, value: any) -> (),
	IsValid: (self: Vector3Schema, value: any) -> boolean,
}

local Vector3M = {}
Vector3M.__index = Vector3M

setmetatable(Vector3M, { __index = Base })

function Vector3M:Coerce(value : any) : Vector3
	if self:IsValid(value) then
		return value
	end
	
	local result = self.default or value
	
	if typeof(result) ~= "Vector3" then
		result = Vector3.zero
	end
	
	return Base.Coerce(self, result)
end

function Vector3M:Validate(value : any, dc : DebugContext.DebugContext?)
	local newDc = self:_getValidDc(dc)
	
	if typeof(value) ~= "Vector3" then
		newDc:Add(self.policy, self.type, `Expected Vector3, got '{typeof(value)}'`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if not Base.IsValid(self, value) then
		Base.Validate(self, value, newDc)
		
		if dc ~= newDc then
			newDc:Throw()
		end
	end
end

function Vector3M:IsValid(value : any) : boolean
	if typeof(value) ~= "Vector3" then
		return false
	end
	
	return Base.IsValid(self, value)
end

return function() : Vector3Schema
	local self = setmetatable(Base.new(), Vector3M) :: Vector3Schema
	
	self.type = script.Name
	
	return self
end