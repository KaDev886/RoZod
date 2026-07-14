--!strict
--!native
--!optimize 2

const Base = require(script.Parent.Parent.Base)

local Any = {}
Any.__index = Any

setmetatable(Any, Base)

export type AnySchema = Base.BaseSchema<AnySchema, any?>

function Any.new() : AnySchema
	return setmetatable(Base.new(), Any) :: any
end

return Any.new