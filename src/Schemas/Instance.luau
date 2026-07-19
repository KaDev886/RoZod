--!strict
--!native
--!optimize 2

const getValidDc = require(script.Parent.Parent.getValidDc)
const Base = require(script.Parent.Parent.Base)

export type InstanceSchema = Base.BaseSchema<InstanceSchema, Instance?>

local InstanceM = {}
InstanceM.__index = InstanceM

setmetatable(InstanceM, Base)

const KIND_SET = { Instance = true }

function InstanceM.new() : InstanceSchema
	local self = setmetatable(Base.new(), InstanceM) :: any

	self.kindStr = "Instance"
	self.kindSet = KIND_SET

    self.isa = nil

	return self
end

function InstanceM:_matchesRules(value : Instance) : boolean
    if self.isa and not value:IsA(self.isa) then
        return false
    end
    return true
end

function InstanceM:_validate(value, dc, path, policy)
	if policy == "Silent" then return end

	if value == nil and self.optional then
		return
	end

	const newDc = getValidDc(dc)

	Base._validate(self, value, newDc, path, policy)

	if newDc:HasMessages() then
		if dc ~= newDc then
			newDc:Throw()
		end
		return
	end

    if self.isa and not value:IsA(self.isa) then
        newDc:Add(policy, `Expected an instance of '{self.isa}', got '{value.ClassName}'`, path)

        if dc ~= newDc then
            newDc:Throw()
        end
		return
    end
end

function InstanceM:IsA(isa : string) : InstanceSchema
    self.isa = isa
    return self :: any
end

function InstanceM:Coerce(value : any) : string?
	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end

	if typeof(result) ~= "Instance" then
		return self.default
	end
	
	return result
end

return InstanceM.new