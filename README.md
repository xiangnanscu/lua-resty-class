# lua-resty-class
Python multiple inheritance class (mro) implementation.
# install
```sh
opm get xiangnanscu/lua-resty-class
```
# Synopsis
```lua
local class = require("resty.class")
local object = require("resty.object")

local function pmro(C)
  local res = {}
  for i, e in ipairs(C.__mro__) do
    table.insert(res, e.__name__)
  end
  print(table.concat(res, ' > '))
end

local A = class 'A' ()
function A.init(self, n)
  self.n = n
end

function A.echo(self)
  print("echo A", self.n)
end

local B = class { A } ()
B.__name__ = 'B'
function B.init(self, n)
  self.n = n
end

function B.echo(self)
  self:super(B):echo()
  print("echo B", self.n)
end

local C = class 'C' { B, A } ()
function C.init(self, n)
  self.n = n
end

function C.echo(self)
  self:super(C):echo()
  print("echo C", self.n)
end

local o = object()
local a = A(1)
local b = B(10)
local c = C(100)
print(tostring(o), tostring(object))
print(tostring(a), tostring(A))
print(tostring(b), tostring(B))
print(tostring(c), tostring(C))
c:echo()
pmro(C)

local A = class()
local B = class 'B' {}
local C = class 'C' {}
local D = class 'D' {}
local E = class 'E' {}
local K1 = class 'K1' { A, B, C } {}
local K2 = class 'K2' { D, B, E } {}
local K3 = class 'K3' { D, A } {}
local Z = class 'Z' { K1, K2, K3 } {}

pmro(Z)

```
output:
```
<instance object><class object>
<instance A><class A>
<instance B><class B>
<instance C><class C>
echo A100
echo B100
echo C100
C > B > A > object
Z > K1 > K2 > K3 > D > object > B > C > E > object
```