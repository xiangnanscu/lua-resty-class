# lua-resty-class

Python multiple inheritance class (mro) implementation.

# Install

```sh
opm get xiangnanscu/lua-resty-class
```

# Api

## making a class

```lua
local A = Class {
  echoA = function(self)
    print("echoA")
  end
}
local B = Class {
  echoB = function(self)
    print("echoB")
  end
}
-- multiple inheritance like python
local C = Class {A, B} {
  echoC = function(self)
    print("echoC")
  end
}
local c = C()
c:echoA()
c:echoB()
c:echoC()
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
local Class = require("lib.resty.class")

local A = Class {
  __name__ = 'A',
  echo = function(self)
    print('call a.echo')
  end,
}

local B = Class { A } {
  __name__ = 'B',
}
function B:echo()
  Class.super(B, self):echo()
  print('call b.echo')
end

Class.inspect(B)

local C = Class { A } {
  __name__ = 'C',
}
function C:echo()
  Class.super(C, self):echo()
  print('call c.echo')
end

Class.inspect(C)

local D = Class { C, B } {
  __name__ = 'D',
}
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
