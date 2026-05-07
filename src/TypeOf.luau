return function(value : any) : string
    local valueType = typeof(value)

    if valueType == "table" then
        if getmetatable(value) then
            if typeof(value.IsValid) == "function" and 
               typeof(value.Validate) == "function" and 
               typeof(value.Coerce) == "function" then
                
                return "Schema"
            elseif typeof(value.Add) == "function" and 
                   typeof(value.Throw) == "function" then
                    
                return "DebugContext"
            end
        end
    end
    
    return valueType
end