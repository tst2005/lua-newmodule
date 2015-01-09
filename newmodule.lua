--[[--------------------------------------------------------
	-- Framework - A Framework for Lua/LOVE --
	-- Copyright (c) 2014-2015 TsT worldmaster.fr --
--]]--------------------------------------------------------

local _M -- the module itself, nil at the beginning, overwriten at the end of load.

local function new(self, modname)
	local mod
	if _M == nil or self == _M or not self then
		mod = {} -- create a new module
	else
		assert(type(self)=="table")
		mod = self -- use this table
		assert(mod._NAME == nil and mod._PATH == nil)
	end
	if not modname then
		error("Missing module name. Usage: require('newmodule')(...) ; require('newmodule'):from({}, ...)", 2)
	end

	local name = (modname):gsub("%.init$","")
	local path = modname
--	if (modname):find(".", nil, true) then
--		path = (modname):gsub("%.init$","")
--	else -- modname: "" or "mod1"
--		path = name
--	end
--	local name = (modname):gsub("%.[^%.]+$","")


	-- FIXME: 
	-- pour le path il faudrait ajouter .init sil y est pas deja ? pour pouvoir virer les .init dans le cas d'un chargement au meme niveau
	-- ou juste un . final ??

	local function __add(_, target) -- to load a module in the same directory
		local submodname
		local path = path
		if (path):find(".", nil, true) then
			path = path:gsub("%.init$","")
			path = path:gsub("%.[^%.]+$","")
		else
			path = ""
		end

		if path and path ~= "" then
			submodname = path.."."..target
		else
			submodname = target
		end
		return require(submodname)
	end
	local function __div(_, target) -- to load a subdirectory module
		local submodname
		local path = path
		if (path):find(".", nil, true) then
			path = path:gsub("%.init$","")
		elseif path == "init" then
			path = ""
		end
		if path and path ~= "" then
			submodname = path.."."..target
		else
			submodname = target
		end
		return require(submodname)
	end

	mod._NAME = name
	mod._PATH = path
	--print("create module", mod, mod._NAME, mod._PATH)
	return setmetatable(mod, {
		__add = __add,
		__div = __div,
	})
end

_M = new(nil, ...) -- Use the feature of the module to generate the module object itself

-- Add the from method (only for the module 'newmodule', not for modules created with it
_M.from = function(self, M, ...) return new(M, ...) end

return setmetatable(_M, {__call = new,})
