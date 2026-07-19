local globalConfig = {}

local defaultConfig = {
    debugName = "RoZod",
    defaultPolicy = "Error"
}

type globalConfig = {
    debugName: string,
    defaultPolicy: string
}

local currentConfig = defaultConfig

local function coerce(before : {}, new : {})
    local cleanConfig = {}

    for key, value in before do
        local newValue = new[key]

        if newValue == nil then
            cleanConfig[key] = value
        else
            if typeof(newValue) == "table" then
                cleanConfig[key] = coerce(value, newValue)
            else
                cleanConfig[key] = newValue
            end
        end
    end

    return cleanConfig
end

function globalConfig.setGlobalConfig(newConfig : globalConfig)
    if typeof(newConfig) ~= "table" then return end

    currentConfig = coerce(defaultConfig, newConfig)
end

function globalConfig.getGlobalConfig()
    return currentConfig
end

globalConfig.setGlobalConfig(defaultConfig)

return globalConfig