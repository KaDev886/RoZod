local globalConfig = require(script.globalConfig)

local Schemas = script.Schemas

return {
    setGlobalConfig = globalConfig.setGlobalConfig,
    getGlobalConfig = globalConfig.getGlobalConfig,

    Any = require(Schemas.Any),
    Object = require(Schemas.Object),
    Array = require(Schemas.Array),
    Number = require(Schemas.Number),
    String = require(Schemas.String),
    Boolean = require(Schemas.Boolean),
    Enum = require(Schemas.Enum),
    Vector3 = require(Schemas.Vector3),
    CFrame = require(Schemas.CFrame),
}