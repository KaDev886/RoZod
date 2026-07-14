--!strict
--!native
--!optimize 2

const getValidDc = require(script.Parent.getValidDc)
const typeOf = require(script.Parent.typeOf)

export type BaseSchema<Self, Coerced> = {
	kindStr: string?,
	kindSet: { [string]: true }?,
	oneOfStr: string?,
	oneOfSet: { [string]: true },
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
	
	self.kindStr = nil
	self.kindSet = nil

	self.oneOfStr = nil
	self.oneOfSet = nil
	
	self.optional = false
	self.default = nil
		
	self.manualPolicy = false
	self.policy = "Error"
	
	self._schema = true

	return self
end

function Base:_matchesOneOf(value : any) : boolean
	const oneOfSet = self.oneOfSet

	if oneOfSet and not oneOfSet[value] then
		return false
	end
	
	return true
end

function Base:_matchesRules(value : any) : boolean
	return true
end

function Base:_validateSchema()
	const dc = getValidDc()

	const default = self.default
	const oneOfSet = self.oneOfSet
	const kindSet = self.kindSet

	if default ~= nil then
		if default ~= default then
			dc:Add("Error", "Default value is NaN")
		end

		if oneOfSet and not self:_matchesOneOf(default) then
			dc:Add(
				"Error",
				`Default value does not exist in OneOf set, got '{default}'`
			)
		end

		if kindSet and not kindSet[typeof(default)] then
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

	if oneOfSet then
		for value in oneOfSet do
			if value ~= value then
				dc:Add("Error", "OneOf contains NaN value")
			end

			if kindSet and not kindSet[typeof(value)] then
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
	if policy == "Silent" then return end

	const newDc = getValidDc(dc)
	
	const oneOfSet = self.oneOfSet
	const kindSet = self.kindSet
	
	if value == nil then
		if self.optional then
			return
		end

		newDc:Add(policy, "Expected a valid value, got 'nil'", path)

		if dc ~= newDc then
			newDc:Throw()
		end

		return
	end

	if value ~= value then
		newDc:Add(policy, "Expected valid value, got 'NaN'", path)

		if dc ~= newDc then
			newDc:Throw()
		end

		return
	end

	if oneOfSet and not oneOfSet[value] then
		newDc:Add(
			policy, 
			`Expected one of: ({self.oneOfStr}) got '{value}'`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if kindSet and not kindSet[typeof(value)] then
		newDc:Add(policy, `Expected ({self.kindStr}) got '{typeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
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
	self:_validateSchema()
	return self
end

function Base:OneOf(values : { any })
	const newDc = getValidDc()
	
	if typeOf(values) ~= "table" then
		newDc:Add("Error", `OneOf must be a table, got '{typeOf(values)}'`)
		newDc:Throw()
		
		return
	end

	local lookup = {}

	for _, value in values do
		lookup[value] = true
	end

	local parts = {}
	for _, v in values do
		parts[#parts + 1] = tostring(v)
	end

	self.oneOfStr = table.concat(parts, " | ")
	self.oneOfSet = lookup
	
	self:_validateSchema()
	
	return self
end

function Base:Optional()
	self.optional = true
	return self
end

function Base:Coerce(value : any) : any
	if value == nil then
		if self.optional then
			return nil
		end
		return self.default
	end

	if value ~= value then
		return self.default
	end
	
	const oneOfSet = self.oneOfSet
	
	if oneOfSet and not oneOfSet[value] then
		return self.default
	end

	return value
end

function Base:Validate(value : any)
	self:_validate(value, nil, nil, self.policy)
end

function Base:IsValid(value : any)
	if value == nil then
		return self.optional
	end

	if value ~= value then
		return false
	end

	const oneOfSet = self.oneOfSet

	if oneOfSet and not oneOfSet[value] then
		return false
	end
	
	const kindSet = self.kindSet
	
	if kindSet and not kindSet[typeof(value)] then
		return false
	end
	
	if not self:_matchesRules(value) then
		return false
	end
	
	return true
end

return Base