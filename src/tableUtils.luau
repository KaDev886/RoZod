--!strict
--!native
--!optimize 2

local Utils = {}

function Utils.count(t : {any}) : number
	local c = 0
	for _ in t do
		c += 1
	end
	return c
end

function Utils.isArray(t)
	if typeof(t) ~= "table" then
		return false
	end

	local maxIndex = 0
	local count = 0

	for k in t do
		count += 1

		if typeof(k) ~= "number" then
			return false
		end

		if k < 1 then
			return false
		end

		if k > maxIndex then
			maxIndex = k
		end
	end

	return maxIndex == count
end

function Utils.isDictionary(t)
	if typeof(t) ~= "table" then
		return false
	end

	if #t == 0 then
		return true
	end

	return not Utils.isArray(t)
end

return Utils