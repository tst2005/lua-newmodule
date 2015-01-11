If you play with Lua module, You probably know that becomes complicate with lot of modules, directories, path, etc.

Now I use newmodule everywhere.


# What is the problem ?

* The Lua 5.0 introduce the module() function. This way to define module was critiqued.

   See http://lua-users.org/wiki/LuaModuleFunctionCritiqued.

* A better and simple way to define module (without the module() function !) was proposed.

   See : http://lua-users.org/wiki/ModulesTutorial.

* In Lua 5.2 the module() function was removed.

   See http://www.lua.org/manual/5.2/manual.html#8.2


# More about Lua modules ?

You should read the following article :

   kikito wrote:
 ```
     I wrote about modules, packages and multiple files here:
     http://kiki.to/blog/2014/04/12/rule-5-beware-of-multiple-files/
 ```

You should also read : https://love2d.org/forums/viewtopic.php?p=178568#p178568


# Download

On github : https://github.com/tst2005/lua-newmodule.git


# Installation

You can copy it on the main directory.
Or change the package path.


I choose to create my own framework to keep my newmodule in subdirectories (and lot of other stuff)
The framework will be release soon at https://github.com/tst2005/dragoon-framework.git )


# Documentation

## require("newmodule")

Use the newmodule to create a new table.
Detect the name of the module (_M._NAME usefull for debug message)
Detect the module name, usefull to require sub module
Detect the module parent name, usefull to require module in the same directory
The table returns follow the format :


```
loccal _M = require("newmodule")(...)
```

equal to :

```
local _M = {
  _NAME = "lua-foo.foo",
  _PATH = "lua-foo.foo",
  _PPATH = "lua-foo",
}
```
In this case _NAME will always equal to _PATH.


Load a sub module :
```
local child = require(_M.PATH .. ".childmodule")
or
local child = child_require("childmodule")
```

Load another module in the same directory :
```
local bro = require(_M.PPATH .. ".brothermodule")
or
local bro = brother_require("brothermodule")
```


## require("newmodule"):from(a_table, ...)

Returns : the modified table passed as argument a_table
Like the `require("newmodule")(...)` except you are able a provide the table.
`require("newmodule")(...)` equals `require("newmodule"):from({}, ...)`

```
local _M = { _VERSION = "0.1" }
require("newmodule"):from(_M, ...)
return _M
```


## require("newmodule"):initload("modulename", ...)

A special stuff for the init.lua file that is only use to redirect the loader to the real module.
```
return require("newmodule"):initload("realmodule", ...)
```

# Details about the module fields

The _NAME field will be kept if already exists.

The _PATH, _PPATH and _CALLEDWITH field will be overwritten if exists.

If not exists all fields will be created.

## _NAME

In some cases it's interesting to include in error message the name of the module.
I think the _NAME should contains module name readable by human text, like "bar, the sub-module of foo" instead of "foo.bar"


Other implementation of module seems use this field.
I can not use it to manage module path for automatic loading...

## _PATH

It's the module path (without ".init" suffix if present)

## _PPATH

It's the _PATH without one level.
if _PATH = lib.foo.foo then _PPATH will be lib.foo.

## _CALLEDWITH

CALLEDWITH is most for debug purpose.
It's a copy of the 1st argument passed (like the _PATH but the ".init" suffix is never removed)

# Localised Loaders

What is the difference between child and brother module

```
parent/
     mod.lua
     bro.lua
     mod/child.lua
```

In mod.lua the bro.lua is in the same parent directory, it's a brother module, should be loaded with brother_require("bro")
In mod.lua the child.lua is in a subdirectory with the name of mod.lua (mod.child) it's a child of mod and should be loaded with child_require("child").
It equals to brother_require("mod.child").

## Where is the child_require
and brother_require ?

Both are generated during the require("newmodule")(...) call.

mod.lua
```
local _M, child_require, brother_require = require("newmodule")(...)
local bro = brother_require("bro")
local child = child_require("child")
```

## child_require(childname)

The child_require will internally use the _M.
_PATH.

mod.lua :
```
local _M, child_require = require("newmodule")(...)
local child = child_require("child")
```

## brother_require(brothername)

The child_require will internally use the _M.
_PPATH.

```
local _M, child_require, brother_require = require("newmodule")(...)
local bro = brother_require("bro")
```


# Sample of use

```
test.foo.sh
foo/
     init.lua
     foo.lua
     x.lua
```

init.lua :
```
return require("newmodule"):initload("foo", ...)
```


foo.lua :
```
local _M, creq, breq = require("newmodule")(...)
print("foo: _NAME=", _M._NAME)
print("foo: _PATH=", _M._PATH)
print("foo: _PPATH=", _M._PPATH)

local x = (breq "x") -- require("foo.x")
return _M
```

x.lua :
```
local _M = {
    __OK = "ok",
}
require'newmodule':from(_M, ...)
print("x ok?", _M.__OK)
return _M
```

test with :
```
lua -l newmodule -e 'require"foo"'
lua -l newmodule -e 'require"foo.init"'
lua -l newmodule -e 'require"foo.foo"'
cd foo ; lua -l newmodule -e 'require"foo"'
```

