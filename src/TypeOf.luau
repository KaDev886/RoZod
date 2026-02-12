return function(value : any) : string
    local valueType = typeof(value)

    if valueType == "number" then
        if value ~= value then
            return "NaN"
        end
    elseif valueType == "table" then
        if getmetatable(value) then
            if typeof(value.IsValid) == "function" and 
               typeof(value.Validate) == "function" and 
               typeof(value.Coerce) == "function" then
                
                return "Schema"
            end
        end
    end
    
    return valueType
end