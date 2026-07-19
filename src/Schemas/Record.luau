--!strict
--!native
--!optimize 2

const getValidDc = require(script.Parent.Parent.getValidDc)
const typeOf = require(script.Parent.Parent.typeOf)
const Base = require(script.Parent.Parent.Base)
const Any = require(script.Parent.Any)
const tableUtils = require(script.Parent.Parent.tableUtils)
local toType = require(script.Parent.Parent.toType)

export type RecordSchema = Base.BaseSchema<RecordSchema, ({} | { any })?> & {
	MinLength: (self: RecordSchema, minLength: number) -> RecordSchema,
	MaxLength: (self: RecordSchema, maxLength: number) -> RecordSchema,
}

local Record = {}
Record.__index = Record

setmetatable(Record, Base)

const KIND_SET = { table = true }

function Record.new(keySchema : any, valueSchema : any) : RecordSchema
	local self = setmetatable(Base.new(), Record) :: any

	self.kindStr = "table"
	self.kindSet = KIND_SET

	self.keySchema = if typeOf(keySchema) == "Schema" then keySchema else Any()
	self.valueSchema = if typeOf(valueSchema) == "Schema" then valueSchema else Any()

    self.minLength = 0
    self.maxLength = math.huge

	return self
end

function Record:_matchesRules(value : ({} | { any })) : boolean
    const keySchema = self.keySchema
    const valueSchema = self.valueSchema
	
	for key, val in value do
        if not keySchema:IsValid(key) or not valueSchema:IsValid(val) then
            return false
        end
    end

    local size = tableUtils.count(value)
    if size < self.minLength or size > self.maxLength then
        return false
    end

    return true
end

function Record:_validate(value, dc, path, policy)
	if policy == "Silent" then return end

	if value == nil and self.optional then
		return
	end
	
	const newDc = getValidDc(dc)

    const keySchema = self.keySchema
    const valueSchema = self.valueSchema

    Base._validate(self, value, newDc, path, policy)

	if newDc:HasMessages() then
		if dc ~= newDc then
			newDc:Throw()
		end
		return
	end

    for key, val in value do
        local newPath = { parent = path, key = key, isIndex = false }

		local newPolicyKey = keySchema.manualPolicy and keySchema.policy or policy or keySchema.policy
        local newPolicyVal = valueSchema.manualPolicy and valueSchema.policy or policy or valueSchema.policy
        
        keySchema:_validate(key, newDc, newPath, newPolicyKey)
        valueSchema:_validate(val, newDc, newPath, newPolicyVal)
    end

    if newDc:HasMessages() then
		if dc ~= newDc then
			newDc:Throw()
		end
		return
	end

    local size = tableUtils.count(value)
	
    if size < self.minLength then
		newDc:Add(
			policy, 
			`Record is too small. Expected at least {self.minLength} elements, got {size}`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
		
		return
	end
	
	if size > self.maxLength then
		newDc:Add(
			policy, 
			`Record is too large. Expected at most {self.maxLength} elements, got {size}`, 
			path
		)
		
		if dc ~= newDc then
			newDc:Throw()
		end
	end
end

function Record:MinLength(minLength : number) : RecordSchema
	const newDc = getValidDc()

	if typeOf(minLength) ~= "number" then
		newDc:Add("Error", `Expected number for minLength, got '{typeOf(minLength)}'`)
		newDc:Throw()
	end

	if minLength < 0 then
		newDc:Add("Error", `minLength cannot be negative`)
		newDc:Throw()
	end

	if minLength > self.maxLength then
		newDc:Add(
			"Error", 
			`minLength cannot be greater than maxLength. Expected at most {self.maxLength}, got {minLength}`
		)
		newDc:Throw()
	end

	self.minLength = minLength
	self:_validateSchema()
	
	return self :: any
end

function Record:MaxLength(maxLength : number) : RecordSchema
	const newDc = getValidDc()

	if typeOf(maxLength) ~= "number" then
		newDc:Add("Error", `Expected number for maxLength, got '{typeOf(maxLength)}'`)
		newDc:Throw()
	end

	if maxLength < 0 then
		newDc:Add("Error", `maxLength cannot be negative`)
		newDc:Throw()
	end

	if maxLength < self.minLength then
		newDc:Add(
			"Error", 
			`maxLength cannot be less than minLength. Expected at least {self.minLength}, got {maxLength}`
		)
		newDc:Throw()
	end
	
	self.maxLength = maxLength
	self:_validateSchema()

	return self :: any
end

function Record:Coerce(value : any) : ({} | { any })?
    local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end

    if self:IsValid(result) then
		return result
	end

    if typeof(value) ~= "table" then
        result = toType.DictTable(value)
    else
        result = table.clone(result)
    end

    local coercedRecord = {}

    for key, val in result do
        local coercedKey = self.keySchema:Coerce(key)
        local coercedVal = self.valueSchema:Coerce(val)

        if coercedKey == nil or coercedVal == nil then
            return self.default
        end
            
        coercedRecord[coercedKey] = coercedVal
    end

    local size = tableUtils.count(coercedRecord)
	
    if size < self.minLength or size > self.maxLength then
		return nil
	end
    
    return coercedRecord
end

return Record.new