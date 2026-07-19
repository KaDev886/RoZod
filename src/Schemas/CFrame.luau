--!strict
--!native
--!optimize 2

const toType = require(script.Parent.Parent.toType)
const Base = require(script.Parent.Parent.Base)

export type CFrameSchema = Base.BaseSchema<CFrameSchema, CFrame?>

local CFrameM = {}
CFrameM.__index = CFrameM

setmetatable(CFrameM, Base)

const KIND_SET = { CFrame = true }

function CFrameM.new() : CFrameSchema
	local self = setmetatable(Base.new(), CFrameM) :: any

	self.kindStr = "CFrame"
	self.kindSet = KIND_SET

	return self
end

function CFrameM:Coerce(value : any) : CFrame?
	local result = Base.Coerce(self, value)

	if result == nil then
		return nil
	end
	
	if typeof(result) ~= "CFrame" then
		result = toType.CFrame(result)
	end
	
	if result == nil then
		return self.default
	end
	
	return result
end

return CFrameM.new