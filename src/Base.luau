--!strict

local getValidDc = require(script.Parent.getValidDc)
local typeOf = require(script.Parent.typeOf)

export type BaseSchema<Self, Coerced> = {
	oneOf: ({ any })?,
	optional: boolean,
	default: any,
	manualPolicy: boolean,
	policy: ("Silent" | "Warn" | "Error"),
	
	Silent: (self: Self) -> Self,
	Warn: (self: Self) -> Self,
	Error: (self: Self) -> Self,
	Default: (self: Self, value: any) -> Self,
	OneOf: (self: Self, values: { any }) -> Self,
	Optional: (self: Self) -> Self,
	
	Coerce: (self: Self, value: any) -> Coerced,
	Validate: (self: Self, value: any) -> (),
	IsValid: (self: Self, value: any) -> boolean,
}

local Base = {}
Base.__index = Base

function Base.new<Self, Coerced>() : BaseSchema<Self, Coerced>
	local self = setmetatable({}, Base) :: any
	
	self.oneOf = nil
	self.oneOfSet = nil
	
	self.optional = false
	self.default = nil
	
	self.manualPolicy = false
	self.policy = "Error"
	
	self._schema = true

	return self
end

function Base:_matchesOneOf(value : any) : boolean
	local oneOfSet = self.oneOfSet

	if oneOfSet and not oneOfSet[value] then
		return false
	end
	
	return true
end

function Base:_matchesType(value : any) : boolean
	return true
end

function Base:_matchesRules(value : any) : boolean
	return true
end

function Base:_validateSchema()
	local dc = getValidDc()
	
	local default = self.default
	local oneOf = self.oneOf

	if default ~= nil then
		if not self:_matchesOneOf(default) then
			dc:Add(
				"Error",
				`Default value does not exist in OneOf set, got '{default}'`
			)
		end

		if not self:_matchesType(default) then
			dc:Add(
				"Error",
				`Default value does not match schema type, got '{default}'`
			)
		end

		if not self:_matchesRules(default) then
			dc:Add(
				"Error",
				`Default value violates schema rules, got '{default}'`
			)
		end
	end

	if oneOf then
		for _, value in oneOf do
			if not self:_matchesType(value) then
				dc:Add(
					"Error",
					`OneOf contains value with invalid type, got '{value}'`
				)
			end

			if not self:_matchesRules(value) then
				dc:Add(
					"Error",
					`OneOf contains value that violates schema rules, got '{value}'`
				)
			end
		end
	end

	dc:Throw()
end

function Base:_validate(value, dc, path, policy)
	return nil
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
	self:_validateSchema()
	return self
end

function Base:OneOf(values : { any })
	local newDc = getValidDc()
	
	if typeOf(values) ~= "table" then
		newDc:Add("Error", `OneOf must be a table, got '{typeOf(values)}'`)
		newDc:Throw()
		
		return
	end

	local lookup = {}

	for _, value in values do
		lookup[value] = true
	end

	self.oneOf = values
	self.oneOfSet = lookup

	self:_validateSchema()
	
	return self
end

function Base:Optional()
	self.optional = true
	return self
end

function Base:Coerce(value : any) : any
	return value
end

function Base:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Base:IsValid(value : any)
	return true
end

return Base