--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local Base = require(script.Parent.Parent.Base)

export type CFrameSchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	Silent: (self: CFrameSchema) -> CFrameSchema,
	Warn: (self: CFrameSchema) -> CFrameSchema,
	Error: (self: CFrameSchema) -> CFrameSchema,
	Default: (self: CFrameSchema, value: any) -> CFrameSchema,
	Expected: (self: CFrameSchema, expecteds: { any }) -> CFrameSchema,
	Optional: (self: CFrameSchema) -> CFrameSchema,
	
	Coerce: (self: CFrameSchema, value: any) -> CFrame,
	Validate: (self: CFrameSchema, value: any) -> (),
	IsValid: (self: CFrameSchema, value: any) -> boolean,
}

local CFrameM = {}
CFrameM.__index = CFrameM

setmetatable(CFrameM, { __index = Base })

function CFrameM:Coerce(value : any) : CFrame
	if self:IsValid(value) then
		return value
	end
	
	local result = self.default or value
	
	if typeof(result) ~= "CFrame" then
		result = CFrame.identity
	end
	
	return Base.Coerce(self, result)
end

function CFrameM:Validate(value : any, dc : DebugContext.DebugContext?)
	local newDc = self:_getValidDc(dc)
	
	if typeof(value) ~= "CFrame" then
		newDc:Add(self.policy, self.type, `Expected CFrame, got '{typeof(value)}'`)
		
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

function CFrameM:IsValid(value : any) : boolean
	if typeof(value) ~= "CFrame" then
		return false
	end
	
	return Base.IsValid(self, value)
end

return function() : CFrameSchema
	local self = setmetatable(Base.new(), CFrameM) :: CFrameSchema

	self.type = script.Name

	return self
end