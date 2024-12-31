U = {} -- This is a global variable that is used for all Utils
U.Cache = {}
U.Cache.Resource = GetCurrentResourceName()


---Prints info to console when Config.EnableDev is true
---@param ... any
function DevPrint(...)
	if not Config.EnableDev then return end
	print('^1[DEV] ^4', ...)
end