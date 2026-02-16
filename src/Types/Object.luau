--!strict

local DebugContext = require(script.Parent.Parent.DebugContext)
local TypeOf = require(script.Parent.Parent.TypeOf)
local Utils = require(script.Parent.Parent.Utils)
local Base = require(script.Parent.Parent.Base)

export type ObjectSchema = {
	type: string,
	expecteds: ({} | { any }),
	optional: boolean,
	default: any,
	policy: "Silent" | "Warn" | "Error",
	
	shape: {[any] : any},
	extra: boolean,
	
	Silent: (self: ObjectSchema) -> ObjectSchema,
	Warn: (self: ObjectSchema) -> ObjectSchema,
	Error: (self: ObjectSchema) -> ObjectSchema,
	Default: (self: ObjectSchema, value: any) -> ObjectSchema,
	Expected: (self: ObjectSchema, expecteds: { any }) -> ObjectSchema,
	Optional: (self: ObjectSchema) -> ObjectSchema,
	
	Extra: (self: ObjectSchema) -> ObjectSchema,
	
	Coerce: (self: ObjectSchema, value: any) -> ({} | {[any] : any}),
	Validate: (self: ObjectSchema, value: ({} | {[any] : any})) -> (),
	IsValid: (self: ObjectSchema, value: ({} | {[any] : any})) -> boolean,
}

local Object = {}
Object.__index = Object

setmetatable(Object, { __index = Base })

function Object:Extra() : ObjectSchema
	self.extra = true
	return self
end

function Object:Coerce(value : any) : ({} | {[any] : any})
	if self:IsValid(value) then
		return value
	end
	
	local result = if self.default ~= nil then self.default else value
	
	if TypeOf(result) ~= "table" then
		result = {}
	else
		result = Utils.copyTable(value)
	end
	
	local shape = self.shape :: {[any] : any}
	
	for key, rule in shape do
		result[key] = rule:Coerce(result[key])
	end
	
	if not self.extra then
		for key, _ in result do
			if shape[key] then
				continue
			end
			
			result[key] = nil
		end
	end
	
	return Base.Coerce(self, result)
end

function Object:Validate(value : ({} | {[any] : any}), dc : DebugContext.DebugContext?, path : string?) : ()
	local newDc = self:_getValidDc(dc)

	if value == nil and self.optional then
		return
	end

	if TypeOf(value) ~= "table" then
		newDc:Add(self.policy, `Expected a table, got '{TypeOf(value)}'`, path)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	local result = true
	
	for key, rule in self.shape do
		if not (rule :: any):IsValid(value[key]) then
			if value[key] == nil then
				newDc:Add(self.policy, `Missing required key '{tostring(key)}'`, path)
			else
				newDc:Add(self.policy, `Invalid value for key '{tostring(key)}'`, path)
			end
			
			local newPath = path and `{path}.{tostring(key)}` or `{tostring(key)}`

			(rule :: any):Validate(value[key], newDc, newPath)

			result = false
		end
	end
	
	if not result then
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if not self.extra then
		local result = true
		
		for key, _ in value do
			if not self.shape[key] then
				newDc:Add(self.policy, `Unexpected extra key '{tostring(key)}'`, path)
				
				result = false
			end
		end
		
		if not result then
			if dc ~= newDc then
				newDc:Throw()
			end
		end
	end

	Base.Validate(self, value, newDc, path)

	if dc ~= newDc then
		newDc:Throw()
	end
end

function Object:IsValid(value : any) : boolean
	if value == nil and self.optional then
		return true
	end

	if TypeOf(value) ~= "table" then
		return false
	end
	
	for key, rule in self.shape do
		if not (rule :: any):IsValid(value[key]) then
			return false
		end
	end
	
	if not self.extra then
		for key, _ in value do
			if not self.shape[key] then
				return false
			end
		end
	end
	
	return Base.IsValid(self, value)
end

return function(shape : {[any] : any}) : ObjectSchema
	local self = setmetatable(Base.new(), Object) :: ObjectSchema
	
	self.type = script.Name
	
	self.shape = shape or {}
	self.extra = false
	
	return self
end