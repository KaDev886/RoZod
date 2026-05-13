--!native
--!optimize 2

return function(value : any) : string
    local valueType = typeof(value)

    if valueType == "table" then
        if value._schema == true then
            return "Schema" 
        end
    end
    
    return valueType
end