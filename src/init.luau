local globalConfig = require(script.globalConfig)

local Schemas = script.Schemas

return {
    setGlobalConfig = globalConfig.setGlobalConfig,
    getGlobalConfig = globalConfig.getGlobalConfig,

    Any = require(Schemas.Any),
    Object = require(Schemas.Object),
    Array = require(Schemas.Array),
    Record = require(Schemas.Record),
    Instance = require(Schemas.Instance),
    Number = require(Schemas.Number),
    String = require(Schemas.String),
    Boolean = require(Schemas.Boolean),
    Enum = require(Schemas.Enum),
    Color3 = require(Schemas.Color3),
    Vector3 = require(Schemas.Vector3),
    CFrame = require(Schemas.CFrame),
}