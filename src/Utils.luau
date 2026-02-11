local Utils = {}

function Utils.copyTable(t)
	if typeof(t) ~= "table" then
		return {}
	end
	
	local copy = {}
	
	for key, value in t do
		if typeof(value) ~= "table" then
			copy[key] = value
		else
			copy[key] = Utils.copyTable(value)
		end
	end
	
	return copy
end

function Utils.fillTable(t, value : number, fillWith : any)
	if typeof(t) ~= "table" then
		return {}
	end
	
	local result = Utils.copyTable(t)
	
	for i = 1, value - #t do
		table.insert(result, fillWith)
	end
	
	return result
end

function Utils.sliceTable(t, i : number, j : number)
	if typeof(t) ~= "table" then
		return {}
	end
	
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

return Utils