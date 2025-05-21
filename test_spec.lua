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
