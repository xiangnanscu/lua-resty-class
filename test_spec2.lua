local Class = require("lib.resty.class")

local function pmro(C)
  local res = {}
  for i, e in ipairs(C.__mro__) do
    table.insert(res, e.__name__)
  end
  print(table.concat(res, ' > '))
end

-- create a class by passing none or an empty table
local A = Class()
local B = Class {
  __name__ = 'B',
  echo = function(self)
    print('call b.echo, ', self.name)
  end,
}
local C = Class { B } {
  __name__ = 'C',
  init = function(self)
    self.name = 'C'
  end,
  echo = function(self)
    self:super():echo()
    print('call c.echo, ', self.name)
  end,
  c_method = function(self)
    print('this is c_method')
  end,
}

local D = Class 'D'
local D = Class { __name__ = 'D' }
local E = Class {
  __name__ = 'E',
  init = function(self)
    self.name = 'E'
  end,
  echo = function(self)
    print('call e.echo, ', self.name)
  end,
  e_method = function(self)
    print('this is e_method')
  end,
}

local F = Class { C, E } {
  __name__ = 'F'
}
local G = Class { C, E } {
  __name__ = 'G',
  init = function(self)
    self.name = 'G'
  end,
  echo = function(self)
    self:super():echo()
    print('call g.echo, ', self.name)
  end,
  g_method = function(self)
    print('this is g_method')
  end,
}

pmro(F)
pmro(G)


local f = F()
f:echo()
f.e_method()
f.c_method()

local g = G()
g:echo()
