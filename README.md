# lua-resty-class

Python multiple inheritance class (mro) implementation.

# Install

```sh
opm get xiangnanscu/lua-resty-class
```

# Api

## making a class

```lua
local A = Class() -- same as:
local A = Class {}
local A = Class 'A' -- same as:
local A = Class { __name__ = 'A' }
local C = Class {A, B} -- multiple inheritance like python
```

## Class.super(cls, self)

Call the super method of C

```lua
Class.super(C, self)
```

## Class.inspect(cls)

Print the mro chain of `cls`

# Synopsis

```lua
local Class = require("resty.class")

local A = Class {
  __name__ = 'A',
  echo = function(self)
    print('call a.echo')
  end,
}

local B = Class { A }
B.__name__ = 'B'
function B:echo()
  Class.super(B, self):echo()
  print('call b.echo')
end

Class.inspect(B)

local C = Class { A }
C.__name__ = 'C'
function C:echo()
  Class.super(C, self):echo()
  print('call c.echo')
end

Class.inspect(C)

local D = Class { C, B }
D.__name__ = 'D'
function D:echo()
  Class.super(D, self):echo()
  print('call d.echo')
end

Class.inspect(D)

local c = C()
c:echo()
print('------------')
local d = D()
d:echo()

```

output:

```
B > A > object
C > A > object
D > C > B > A > object
call a.echo
call c.echo
------------
call a.echo
call b.echo
call c.echo
call d.echo
```
