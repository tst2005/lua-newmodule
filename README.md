Now I use newmodule everywhere.
But newmodule.lua must be available soon.

You can copy it on the main directory.
I choose to create my own framework to keep my newmodule in subdirectories with lot of other stuff ... but it's another story!

# Documentation

## require("newmodule")

Load the newmodule.
Return: a table
Sample :
```
local newmodule = require("newmodule")
```

## require("newmodule")(...)

Use the newmodule to create a new table.
Detect the name of the module (_M._NAME usefull for debug message)
Detect the module name, usefull to require sub module
Detect the module parent name, usefull to require module in the same directory
The table returns follow the format :
```local _M = require("newmodule")(...)```

equal to :

```
 local _M = {
  _NAME = "lua-foo.foo",
  _PATH = "lua-foo.foo",
  _PPATH = "lua-foo",
 }
```

Load a sub module :

```
local child = require(_M.PATH .. ".childmodule")
```

Load another module in the same directory :

```
local bro = require(_M.PPATH .. ".brothermodule")
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

TODO: speak about generated child_require() and brother_require()


# Download

on github : https://github.com/tst2005/lua-newmodule.git




# How to use newmodule.lua :


Sample :

 * test.foo.sh
 * foo/
 * - init.lua
 * - foo.lua
 * - x.lua


init.lua :
```
return require("newmodule"):initload("foo", ...)
```


foo.lua :
```
local _M, creq, breq = require("newmodule")(...)
print("cpp: _NAME=", _M._NAME)
print("cpp: _PATH=", _M._PATH)
print("cpp: _PPATH=", _M._PPATH)

local x = (breq "x") -- require("cpp.x")
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

```
$ sh test.foo.sh
cpp: _NAME=	foo.foo
cpp: _PATH=	foo.foo
cpp: _PPATH=	foo
x ok?	ok

cpp: _NAME=	foo.foo
cpp: _PATH=	foo.foo
cpp: _PPATH=	foo
x ok?	ok

cpp: _NAME=	foo.foo
cpp: _PATH=	foo.foo
cpp: _PPATH=	foo
x ok?	ok

cpp: _NAME=	foo
cpp: _PATH=	foo
cpp: _PPATH=	
x ok?	ok
```
