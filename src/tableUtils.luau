local typeOf = require(script.Parent.typeOf)

local Utils = {}

function Utils.copyTable(t)
	local copy = {}
	
	for key, value in t do
		if typeof(value) == "table" then
			copy[key] = Utils.copyTable(value)
		else
			copy[key] = value
		end
	end
	
	return copy
end

function Utils.fillTable(t, value : number, fillWith : any)
	local result = Utils.copyTable(t)
	
	for i = 1, value - #t do
		table.insert(result, fillWith)
	end
	
	return result
end

function Utils.sliceTable(t, i : number, j : number)
	local result = {}
	local counter = 0
	
	for key, value in t do
		if counter >= i and counter <= j then
			table.insert(result, value)
		end
		
		counter += 1
	end
	
	return result
end

function Utils.isArray(t)
	if typeOf(t) ~= "table" then
		return false
	end

	local count = 0

	for key in t do
		if typeOf(key) ~= "number" then
			return false
		end
		
		count += 1
	end

	return count == #t
end

function Utils.isDictionary(t)
	if typeOf(t) ~= "table" then
		return false
	end

	if #t == 0 then
		return true
	end

	return not Utils.isArray(t)
end

return Utils