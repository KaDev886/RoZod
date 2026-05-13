local DebugContext = require(script.Parent.DebugContext)

return function(dc : DebugContext.dc?) : DebugContext.dc
    if dc then
		return dc
	end
	return DebugContext.new()
end