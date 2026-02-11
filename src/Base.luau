--!strict

local DebugContext = require(script.Parent.DebugContext)

export type SchemaBase = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	Silent: (self: any) -> any,
	Warn: (self: any) -> any,
	Error: (self: any) -> any,
	Default: (self: any, value: any) -> any,
	Expected: (self: any, expecteds: { any }) -> any,
	Optional: (self: any) -> any,
	
	Coerce: (self: any, value: any) -> any,
	Validate: (self: any, value: any) -> (),
	IsValid: (self: any, value: any) -> boolean,
}

local Base = {}
Base.__index = Base

function Base.new() : SchemaBase
	local self = setmetatable({}, Base) :: SchemaBase
	
	self.type = "Base"
	self.expecteds = {}
	self.optional = false
	self.default = nil
	self.policy = "Error"
	
	return self
end

function Base:_getValidDc(dc : DebugContext.DebugContext?) : DebugContext.DebugContext
	if dc then
		if typeof(dc) == "table" and dc.messages and type(dc.Add) == "function" and type(dc.Throw) == "function" then
			return dc
		else
			return DebugContext.new()
		end
	else
		return DebugContext.new()
	end
end

function Base:Silent() : any
	self.policy = "Silent"
	return self
end

function Base:Warn() : any
	self.policy = "Warn"
	return self
end

function Base:Error() : any
	self.policy = "Error"
	return self
end

function Base:Default(value : any) : any
	self.default = value
	return self
end

function Base:Expected(expecteds : { any }) : any
	local newDc = self:_getValidDc()
	
	if typeof(expecteds) ~= "table" then
		newDc:Add(self.policy, self.type, `Expecteds must be a table, got '{typeof(expecteds)}'`)
		newDc:Throw()
		
		return self
	end
	
	self.expecteds = expecteds
	return self
end

function Base:Optional() : any
	self.optional = true
	return self
end

function Base:Coerce(value : any) : any
	if self:IsValid(value) then
		return value
	end
	
	local result = self.default or value
	
	if #self.expecteds ~= 0 and not table.find(self.expecteds, value) then
		result = self.expecteds[1]
	end
	
	return result
end

function Base:Validate(value : any, dc : DebugContext.DebugContext?)
	local newDc = self:_getValidDc(dc)
	
	if #self.expecteds ~= 0 and not table.find(self.expecteds, value) then
		local validExpecteds = {}
		
		for _, expected in ipairs(self.expecteds) do
			table.insert(validExpecteds, tostring(expected))
		end
		
		newDc:Add(self.policy, self.type, `Expected one of {table.concat(validExpecteds, " | ")} got '{tostring(value)}'`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
	end
end

function Base:IsValid(value : any) : boolean
	if #self.expecteds ~= 0 and not table.find(self.expecteds, value) then
		return false
	end
	
	return true
end

return Base