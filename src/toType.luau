local typeOf = require(script.Parent.typeOf)

local toType = {}

function toType.Vector3(value : any) : Vector3?
    local to  = typeOf(value)

    if to == "Vector3" then
        return value
    end

    if to == "NaN" or to == "nil" then 
        return nil
    end

    if to == "string" then
        local coords = {}

        for s in string.gmatch(value, "([^,]+)") do
            table.insert(coords, tonumber(s) or 0)
        end

        return Vector3.new(coords[1] or 0, coords[2] or 0, coords[3] or 0)
    end

	return nil
end

function toType.DistTable(value : any)
	local to = typeOf(value)

	if to == "table" then
		return value
	end

    if to == "NaN" or to == "nil" then 
        return {}
    end
	
	if to == "string" then
		local str = value:gsub("^%s*{", ""):gsub("}%s*$", "")

        local result = {}

        for pair in string.gmatch(str, "([^,]+)") do
            pair = pair:match("^%s*(.-)%s*$")
        
            local key, val = pair:match("([^=]+)%s*=%s*(.+)")

            if key and val then
                key = key:match("^%s*(.-)%s*$")
                val = val:match("^%s*(.-)%s*$")
                result[key] = val
            else
                table.insert(result, pair)
            end
		end

		return result
	end

	return nil
end

function toType.Enum(value : any) : (Enum | EnumItem)?
    local to = typeOf(value)

	if to == "Enum" or to == "EnumItem" then
		return value
	end

    if to == "NaN" or to == "nil" then 
        return nil
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
    local to = typeOf(value)
	
	if to == "CFrame" then
		return value
	end

    if to == "NaN" or to == "nil" then 
        return nil
    end

	if to == "Vector3" then
		return CFrame.new(value)
	end

	if to == "string" then
		local vect3 = toType.Vector3(value)

		if typeOf(vect3) == "Vector3" then
			return toType.CFrame(vect3)
		end
	end

	return nil
end

function toType.Boolean(value : any) : boolean?
	local to = typeOf(value)

	if to == "boolean" then
		return value
	end

	if to == "NaN" or to == "nil" then
		return nil
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
	local to = typeOf(value)

	if to == "table" then
		return value
	end

	if to == "NaN" or to == "nil" then
		return nil
	end

	if to == "string" then
		local result = {}

		for s in string.gmatch(value, "([^,]+)") do
			table.insert(result, s:match("^%s*(.-)%s*$"))
		end

		return result
	end

	return nil
end

return toType