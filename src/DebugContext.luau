--!strict
local globalConfig = require(script.Parent.globalConfig)

export type dc = {
	messages: {any},
	
	new: () -> dc,
	Add: (self: dc, policy: ("Silent" | "Warn" | "Error"), message: string, path: string?) -> (),
	Throw: (self: dc) -> (),
}

local DebugContext = {}
DebugContext.__index = DebugContext

function DebugContext.new() : dc
	local self = setmetatable({}, DebugContext) :: any

	self.messages = {}

	return self
end

function DebugContext:Add(policy : ("Silent" | "Warn" | "Error"), message : string, path : string?)
	if policy == "Silent" then return end

	table.insert(self.messages, {
		type = policy,
		message = message,
		path = path,
	})
end

function DebugContext:Throw()
	local config = globalConfig.getGlobalConfig()

	local errorMsg = ""
	local warnMsg = ""

	for i, msg in ipairs(self.messages) do
		local finalMsg = `[{config.debugName}] {msg.type}: `
		
		if not msg.path then
			finalMsg = finalMsg .. msg.message
		else
			finalMsg = finalMsg .. `{msg.path} | {msg.message}`
		end
		
		if msg.type == "Error" then
			errorMsg = errorMsg .. "\n" .. finalMsg
		elseif msg.type == "Warn" then
			warnMsg = warnMsg .. "\n" .. finalMsg
		end
	end
	
	if warnMsg ~= "" then
		warn(warnMsg)
	end
	
	if errorMsg ~= "" then
		error(errorMsg, 0)
	end
end

return DebugContext