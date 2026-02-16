--!strict

local DebugContext = require(script.Parent.DebugContext)
local TypeOf = require(script.Parent.TypeOf)

export type BaseSchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	Silent: (self: BaseSchema) -> BaseSchema,
	Warn: (self: BaseSchema) -> BaseSchema,
	Error: (self: BaseSchema) -> BaseSchema,
	Default: (self: BaseSchema, value: any) -> BaseSchema,
	Expected: (self: BaseSchema, expecteds: { any }) -> BaseSchema,
	Optional: (self: BaseSchema) -> BaseSchema,
	
	Coerce: (self: BaseSchema, value: any) -> any,
	Validate: (self: BaseSchema, value: any) -> (),
	IsValid: (self: BaseSchema, value: any) -> boolean,
}

local Base = {}
Base.__index = Base

function Base.new() : BaseSchema
	local self = setmetatable({}, Base) :: BaseSchema
	
	self.type = "Base"
	self.expecteds = {}
	self.optional = false
	self.default = nil
	self.policy = "Error"
	
	return self
end

function Base:_getValidDc(dc : DebugContext.DebugContext?) : DebugContext.DebugContext
	if dc then
		if TypeOf(dc) == "DebugContext" then
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

function Base:Silent() : BaseSchema
	self.policy = "Silent"
	return self
end

function Base:Warn() : BaseSchema
	self.policy = "Warn"
	return self
end

function Base:Error() : BaseSchema
	self.policy = "Error"
	return self
end

function Base:Default(value : any) : BaseSchema
	self.default = value
	self:_validateDefault()

	return self
end

function Base:Expected(expecteds : { any }) : BaseSchema
	local newDc = self:_getValidDc()
	
	if TypeOf(expecteds) ~= "table" then
		newDc:Add("Error", `Expecteds must be a table, got '{TypeOf(expecteds)}'`)
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

function Base:Optional() : BaseSchema
	self.optional = true
	return self
end

function Base:Coerce(value : any) : any
	if self:IsValid(value) then
		return value
	end
	
	local result = if self.default ~= nil then self.default else value
	
	if #self.expecteds ~= 0 and not table.find(self.expecteds, result) then
		result = self.expecteds[1]
	end
	
	return result
end

--function Base:ForceCoerce(value : any) : any
-- ...
--end

function Base:Validate(value : any, dc : DebugContext.DebugContext?, path : string?)
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then 
		return 
	end
	
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
			self.policy, 
			`Expected one of {table.concat(validExpecteds, " | ")} got '{tostring(value)}'`,
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
	end
end

function Base:IsValid(value : any) : boolean
	if value == nil and self.optional then 
		return true
	end

	if #self.expecteds ~= 0 and not table.find(self.expecteds, value) then
		return false
	end
	
	return true
end

return Base