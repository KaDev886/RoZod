--!strict

local globalConfig = require(script.Parent.globalConfig)

export type dc = {
	messages: {any},
	
	new: () -> dc,
	Add: (self: dc, policy: ("Warn" | "Error"), message: string, path: any?) -> (),
	Throw: (self: dc) -> (),
	HasMessages: (self: dc) -> boolean
}

local function resolvePath(path : any) : string?
	if path == nil then
		return nil
	end

	if typeof(path) == "string" then
		return path
	end

	local parentStr = resolvePath(path.parent)

	if path.isIndex then
		local segment = "[" .. tostring(path.key) .. "]"
		return if parentStr then parentStr .. segment else segment
	end

	local segment = tostring(path.key)
	return if parentStr then parentStr .. "." .. segment else segment
end

local DebugContext = {}
DebugContext.__index = DebugContext

function DebugContext.new() : dc
	local self = setmetatable({}, DebugContext) :: any

	self.messages = {}

	return self
end

function DebugContext:Add(policy : ("Warn" | "Error"), message : string, path : any?)
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

	for _, msg in ipairs(self.messages) do
		local resolvedPath = resolvePath(msg.path)
		local message = resolvedPath and `{resolvedPath} | {msg.message}` or msg.message
		local finalMsg = `[{config.debugName}] {msg.type}: {message}`
		
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

function DebugContext:HasMessages()
	return #self.messages > 0
end

return DebugContext