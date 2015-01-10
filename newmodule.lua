--[[--------------------------------------------------------
	-- Dragoon Framework - A Framework for Lua/LOVE --
	-- Copyright (c) 2014-2015 TsT worldmaster.fr --
--]]--------------------------------------------------------

local _M -- the module itself, nil at the beginning, overwriten at the end of load.

local function _subrequire(modname, parentmodname)
	if parentmodname and parentmodname ~= "" then
		return require(parentmodname .. "." .. modname)
	else
		return require(modname)
	end
end

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

	local path = (modname):gsub("%.init$","")
	local ppath
	if (path):find(".", nil, true) then
		ppath = path:gsub("%.[^%.]+$","") -- remove one level to stay at in the same parent directory
	else
		ppath = ""
	end
	local name = path

	if not mod._NAME then mod._NAME = name end
	mod._PATH       = path -- (without .init)
	mod._PPATH      = ppath
	mod._CALLEDWITH = modname -- with .init

	local function child_require(modname)
		return _subrequire(modname, path)
	end
	local function brother_require(modname)
		return _subrequire(modname, ppath)
	end

	--print("create module:", mod._NAME, mod._PATH, mod._PPATH, mod._CALLEDWITH)
	return mod, child_require, brother_require
end

_M = new(nil, ...) -- Use the feature of the module to generate the module object itself

----------
-- Small Hack to support call of :
--  newmodule.from() or
--  newmodule:from()
--  newmodule.initload() or
--  newmodule:initload()
--
local function dropself(self, ...)
	if self == _M then
		return ...
	end
	return self, ...
end

----------
-- Usefull for create a module with an existing table
local function from(M, ...) return new(M, ...) end

----------
-- Usefull for init.lua to forward the load to another file.lua
-- Sample of use :
--      return require("newmodule").initload("anothermodule", ...)
-- or   return require("newmodule"):initload("anothermodule", ...)
--
local function initload(modname, ...)
	local m, creq = new(nil, ...)
	-- if used from a init.lua file
	-- we must load as child, because ".init" are remove, the M._PATH becomes like a parent path
	return creq(dropself(modname))
end
_M.initload = function(...) return initload( dropself(...) ) end
_M.from = function(...) return from( dropself(...) ) end

return setmetatable(_M, {__call = new,})
