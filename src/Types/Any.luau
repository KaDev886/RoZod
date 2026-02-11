--!strict

local Base = require(script.Parent.Parent.Base)

local Any = {}
Any.__index = Any

setmetatable(Any, { __index = Base })

export type AnySchema = Base.SchemaBase

return function() : AnySchema
	local self = setmetatable(Base.new(), Any) :: AnySchema
	
	self.type = script.Name
	
	return self
end