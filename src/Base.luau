--!strict

local DebugContext = require(script.Parent.DebugContext)
local typeOf = require(script.Parent.typeOf)

export type BaseSchema<Self, Coerced> = {
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	manualPolicy: boolean,
	policy: ("Silent" | "Warn" | "Error"),
	
	Silent: (self: Self) -> Self,
	Warn: (self: Self) -> Self,
	Error: (self: Self) -> Self,
	Default: (self: Self, value: any) -> Self,
	Expected: (self: Self, expecteds: { any }) -> Self,
	Optional: (self: Self) -> Self,
	
	Coerce: (self: Self, value: any) -> Coerced,
	Validate: (self: Self, value: any) -> (),
	IsValid: (self: Self, value: any) -> boolean,
}

local Base = {}
Base.__index = Base

function Base.new<Self, Coerced>() : BaseSchema<Self, Coerced>
	local self = setmetatable({}, Base) :: any
	
	self.expecteds = {}
	self.optional = false
	self.default = nil
	
	self.manualPolicy = false
	self.policy = "Error"

	return self
end

function Base:_getValidDc(dc : DebugContext.dc?) : DebugContext.dc
	if dc then
		if typeOf(dc) == "DebugContext" then
			return dc
		else
			return DebugContext.new()
		end
	else
		return DebugContext.new()
	end
end

function Base:_validateDefault()
	if self.default ~= nil and not self:IsValid(self.default) then
		local newDc = self:_getValidDc()
		
		newDc:Add(
			"Error", 
			`Invalid default value. Expected a value that matches the schema, got '{tostring(self.default)}'`
		)
		
		newDc:Throw()
	end
end

function Base:_validate(value, dc, path, policy)
	if value == nil and self.optional then 
		return
	end
	
	local newDc = self:_getValidDc(dc)
	
	if #self.expecteds ~= 0 and not table.find(self.expecteds, value) then
		local validExpecteds = {}
		
		for _, expected in self.expecteds do
			if typeof(expected) == "Vector3" then
				table.insert(validExpecteds, `({tostring(expected)})`)
			else
				table.insert(validExpecteds, tostring(expected))
			end
		end
		
		newDc:Add(
			policy, 
			`Expected one of: {table.concat(validExpecteds, " | ")} got '{tostring(value)}'`,
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
	end
end

function Base:Silent()
	self.manualPolicy = true
	self.policy = "Silent"
	return self
end

function Base:Warn()
	self.manualPolicy = true
	self.policy = "Warn"
	return self
end

function Base:Error()
	self.manualPolicy = true
	self.policy = "Error"
	return self
end

function Base:Default(value : any)
	self.default = value
	self:_validateDefault()

	return self
end

function Base:Expected(expecteds : { any })
	local newDc = self:_getValidDc()
	
	if typeOf(expecteds) ~= "table" then
		newDc:Add("Error", `Expecteds must be a table, got '{typeOf(expecteds)}'`)
		newDc:Throw()
		
		return self
	end

	local result = false

	for _, expected in expecteds do
		if not self:IsValid(expected) then
			newDc:Add("Error", `Invalid expected value: '{tostring(expected)}'`)
			result = true
		end
	end
	
	if result then
		newDc:Throw()
	end
	
	self.expecteds = expecteds
	self:_validateDefault()
	
	return self
end

function Base:Optional()
	self.optional = true
	return self
end

function Base:Coerce(value : any)
	if #self.expecteds ~= 0 and not table.find(self.expecteds, value) then
		return self.default
	end
	
	return value
end

function Base:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Base:IsValid(value : any)
	if value == nil and self.optional then 
		return true
	end

	if #self.expecteds ~= 0 and not table.find(self.expecteds, value) then
		return false
	end
	
	return true
end

return Base