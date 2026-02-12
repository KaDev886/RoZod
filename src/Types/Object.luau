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
	
	local result = self.default or value
	
	if TypeOf(result) ~= "table" then
		result = {}
	else
		result = Utils.copyTable(value)
	end
	
	local shape = self.shape :: {[any] : any}
	
	for key, rule in pairs(shape) do
		result[key] = rule:Coerce(result[key])
		
		if result[key] == nil and (rule :: any).optional then
			result[key] = nil
		end
	end
	
	if not self.extra then
		for key, _ in result do
			local rule : any = shape[key]
			
			if rule and rule.optional then
				continue
			end
			
			if shape[key] then
				continue
			end
			
			result[key] = nil
		end
	end
	
	return result
end

function Object:Validate(value : ({} | {[any] : any}), dc : DebugContext.DebugContext?)
	local newDc = self:_getValidDc(dc)

	if TypeOf(value) ~= "table" then
		newDc:Add(self.policy, self.type, `Expected a table, got '{TypeOf(value)}'`)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	local result = true
	
	for key, rule in pairs(self.shape) do
		if value[key] == nil and (rule :: any).optional then
			continue
		end
		
		if value[key] == nil then
			newDc:Add((rule :: any).policy, self.type, `Missing required key '{tostring(key)}'`)
			
			result = false
		end
		
		if value[key] ~= nil and not (rule :: any):IsValid(value[key]) then
			newDc:Add((rule :: any).policy, self.type, `Invalid value for key '{tostring(key)}'`)
			
			result = false
			
			(rule :: any):Validate(value[key], newDc)
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
			local rule = self.shape[key]
			
			if rule and (rule :: any).optional then
				continue
			end
			
			if not rule then
				newDc:Add(self.policy, self.type, `Unexpected extra key '{tostring(key)}'`)
				
				result = false
			end
		end
		
		if not result then
			if dc ~= newDc then
				newDc:Throw()
			end
		end
	end
end

function Object:IsValid(value : any) : boolean
	if TypeOf(value) ~= "table" then
		return false
	end
	
	for key, rule in pairs(self.shape) do
		if value[key] == nil and (rule :: any).optional then
			continue
		end
		
		if value[key] == nil then
			return false
		end
		
		if value[key] ~= nil and not (rule :: any):IsValid(value[key]) then
			return false
		end
	end
	
	if not self.extra then
		local result = true

		for key, _ in value do
			local rule = self.shape[key]

			if rule and (rule :: any).optional then
				continue
			end

			if not rule then
				return false
			end
		end
	end
	
	return true
end

return function(shape : {[any] : any}) : ObjectSchema
	local self = setmetatable(Base.new(), Object) :: ObjectSchema
	
	self.type = script.Name
	
	self.shape = shape or {}
	self.extra = false
	
	return self
end