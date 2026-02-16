export type DebugContext = {
	messages: {any},
	
	new: () -> DebugContext,
	Add: (self: DebugContext, policy: ("Silent" | "Warn" | "Error"), message: string, path: string) -> (),
	Throw: (self: DebugContext) -> (),
}

local DebugContext = {}
DebugContext.__index = DebugContext

function DebugContext.new() : DebugContext
	local self = setmetatable({}, DebugContext) :: DebugContext

	self.messages = {}
	
	return self
end

function DebugContext:Add(policy : ("Silent" | "Warn" | "Error"), message : string, path : string?)
	table.insert(self.messages, {
		type = policy,
		message = message,
		path = path,
	})
end

function DebugContext:Throw()
	local errorMsg = ""
	local warnMsg = ""
	
	for i, msg in ipairs(self.messages) do
		local finalMsg = `[RoZod] {msg.type}: `

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