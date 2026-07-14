--!native
--!optimize 2

local tableUtils = require(script.Parent.tableUtils)

local toType = {}

function toType.Vector3(value : any) : Vector3?
    local to  = typeof(value)

    if to == "Vector3" then
        return value
    end
    
    if to == "string" then
        local coords = {}
        local count = 0

        for s in string.gmatch(value, "([^,]+)") do
            count += 1
            coords[count] = tonumber(s)
        end

		if #coords == 0 then
			return nil
		end

        return Vector3.new(coords[1] or 0, coords[2] or 0, coords[3] or 0)
    end

	return nil
end

local function processPair(result, token, arrayCount)
    local trimmed = token:match("^%s*(.-)%s*$")
    if trimmed == "" then return arrayCount end

    local key, val = trimmed:match("([^=]+)%s*=%s*(.+)")
    
    if key and val then
        result[key:match("^%s*(.-)%s*$")] = val:match("^%s*(.-)%s*$")
        return arrayCount
    else
        arrayCount += 1
        result[arrayCount] = trimmed
        return arrayCount
    end
end

function toType.DictTable(value: any): { [any]: any }?
    local to = typeof(value)

    if tableUtils.isDictionary(value) then
        return value
    end

    if to == "string" then
        local str = value:match("^%s*(.-)%s*$")

        if not (str:sub(1,1) == "{" and str:sub(-1,-1) == "}") then
            return nil
        end
        
        local content = str:sub(2, -2)
        local result = {}
        local depth = 0
        local tokenStart = 1
        local arrayCount = 0
        
        for i = 1, #content do
            local char = content:sub(i, i)
            
            if char == "{" then
                depth += 1
            elseif char == "}" then
                depth -= 1
            elseif char == "," and depth == 0 then
                arrayCount = processPair(result, content:sub(tokenStart, i - 1), arrayCount)
                tokenStart = i + 1
            end
        end
        
        processPair(result, content:sub(tokenStart, #content), arrayCount)
        return result
    end

    return nil
end

function toType.Enum(value : any) : (Enum | EnumItem)?
    local to = typeof(value)

	if to == "Enum" or to == "EnumItem" then
		return value
	end

	if to == "string" then
		local segments = string.split(value, ".")

		if segments[1] ~= "Enum" then
			return nil
		end

		table.remove(segments, 1)

		local result = Enum

		local ok = pcall(function()
			for _, name in ipairs(segments) do
				result = result[name]
			end
		end)
		
		if not ok then
			return nil
		end

		return result
	end

	return nil
end

function toType.CFrame(value : any) : CFrame?
    local to = typeof(value)
	
	if to == "CFrame" then
		return value
	end

	if to == "Vector3" then
		return CFrame.new(value)
	end

	if to == "string" then
		local vect3 = toType.Vector3(value)

		if typeof(vect3) == "Vector3" then
			return toType.CFrame(vect3)
		end
	end

	return nil
end

function toType.Boolean(value : any) : boolean?
	local to = typeof(value)

	if to == "boolean" then
		return value
	end

	if to == "string" then
		if value == "true" then
			return true
		elseif value == "false" then
			return false
		end
	end

	return nil
end

function toType.Array(value : any) : {any}?
	local to = typeof(value)

	if tableUtils.isArray(value) then
		return value
	end

	if to == "string" then
		local str = value:match("^%s*(.-)%s*$")

        if not (str:sub(1,1) == "{" and str:sub(-1,-1) == "}") then
            return nil
        end

		local content = str:sub(2, -2)

		local result = {}
		local resultCount = 0

		local depth = 0
        local tokenStart = 1

		for i = 1, #content do
            local char = content:sub(i, i)
            
            if char == "{" then
                depth += 1
            elseif char == "}" then
                depth -= 1
            elseif char == "," and depth == 0 then
                local trimmed = content:sub(tokenStart, i - 1):match("^%s*(.-)%s*$")
                if trimmed ~= "" then
                    resultCount += 1
                    result[resultCount] = trimmed
                end
                tokenStart = i + 1
            end
        end

		local lastTrimmed = content:sub(tokenStart, #content):match("^%s*(.-)%s*$")
        if lastTrimmed ~= "" then
            resultCount += 1
            result[resultCount] = lastTrimmed
        end

		if resultCount == 0 then
			return nil
		end
		
		return result
	end

	return nil
end

return toType