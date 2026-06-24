local module = {}

local function find(a, tbl)
	for _, a_ in pairs(tbl) do 
		if a_==a then return true end 
	end
end

function module.difference(a, b)
	local ret = {}
	for i, v in pairs(a) do
		if not find(v,b) then table.insert(ret, v) end
	end
	
	return ret
end


return module

