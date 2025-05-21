local table        = table
local rawget       = rawget
local type         = type
local ipairs       = ipairs
local setmetatable = setmetatable
local pairs        = pairs
local select       = select
local string       = string
local table_new, nkeys
if ngx then
  table_new = table.new
  nkeys     = require "table.nkeys"
else
  table_new = function(narray, nhash)
    return {}
  end
  nkeys = function(self)
    local n = 0
    for key, _ in pairs(self) do
      n = n + 1
    end
    return n
  end
end

local function object_call(t, ...)
  local self = t:new()
  self:init(...)
  return self
end

local object
object = setmetatable({
  __call = object_call,
  __name__ = 'object',
  __index = object,
  __bases__ = {},
  __mro__ = { object },
  __tostring = function(self)
    return string.format('<instance %s>', rawget(self.__mro__[1], '__name__') or '?')
  end,

  new = function(cls)
    return setmetatable({}, cls)
  end,

  init = function(self, ...)
    return object.assign(self, ...)
  end,

  assign = function(self, ...)
    for i = 1, select("#", ...) do
      for k, v in pairs(select(i, ...)) do
        self[k] = v
      end
    end
    return self
  end,

  entries = function(self)
    local res = setmetatable({}, object)
    for k, v in pairs(self) do
      res[#res + 1] = { k, v }
    end
    return res
  end,

  from_entries = function(arr)
    local res = setmetatable({}, object)
    for _, e in ipairs(arr) do
      res[e[1]] = e[2]
    end
    return res
  end,

  keys = function(self)
    local res = setmetatable(table_new(nkeys(self), 0), object)
    for k, _ in pairs(self) do
      res[#res + 1] = k
    end
    return res
  end,

  values = function(self)
    local res = setmetatable(table_new(nkeys(self), 0), object)
    for _, v in pairs(self) do
      res[#res + 1] = v
    end
    return res
  end,
}, {
  __call = object_call,
  __tostring = function(cls)
    return string.format('<class %s>', rawget(cls, '__name__') or '?')
  end
})


local function inspect(C)
  local res = {}
  for i, e in ipairs(C.__mro__) do
    table.insert(res, e.__name__)
  end
  print(table.concat(res, ' > '))
end

local function merge(in_lists)
  if #in_lists == 0 then
    return {}
  end
  for _, mro_list in ipairs(in_lists) do
    local head = mro_list[1]
    local has_head = false
    for _, cmp_list in ipairs(in_lists) do
      if cmp_list ~= mro_list then
        for k = 2, #cmp_list do
          if head == cmp_list[k] then
            has_head = true
            break
          end
        end
        if has_head then
          break
        end
      end
    end
    if not has_head then
      local next_list = {}
      for l, merge_item in ipairs(in_lists) do
        for m, value in ipairs(merge_item) do
          if head == value then
            table.remove(merge_item, m)
            break
          end
        end
        if #merge_item > 0 then
          table.insert(next_list, merge_item)
        end
      end
      return { head, unpack(merge(next_list)) }
    end
  end
  error("TypeError")
end

local function c3_mro(cls)
  if cls == object then
    return { object }
  end

  local merge_list = {}
  for _, base_cls in ipairs(cls.__bases__) do
    table.insert(merge_list, c3_mro(base_cls))
  end
  table.insert(merge_list, { unpack(cls.__bases__) })
  local mro = { cls, unpack(merge(merge_list)) }
  return mro
end

local function super(cls, self)
  local mro = getmetatable(self).__mro__
  -- find the index of cls in mro
  local index
  for i, e in ipairs(mro) do
    if e == cls then
      index = i
    end
  end
  return setmetatable({}, {
    __index = function(_, key)
      for i = index + 1, #mro do
        local func = rawget(mro[i], key)
        if func ~= nil then
          return function(_, ...)
            return func(self, ...)
          end
        end
      end
    end
  })
end


---@param bases table
---@param cls table
---@return table
local function class_extends(bases, cls)
  cls.__name__ = cls.__name__ or tostring(cls)
  cls.__bases__ = { unpack(bases) }
  cls.__mro__ = c3_mro(cls)
  cls.__index = cls
  cls.__tostring = object.__tostring
  cls.__call = object.__call
  cls.new = object.new -- ensure super's getmetatable work
  cls.init = cls.init or object.init

  local meta = {
    __call = object.__call,
    __tostring = getmetatable(object).__tostring,
    __index = function(t, key)
      for i = 2, #t.__mro__ do
        local e = t.__mro__[i]
        if rawget(e, key) ~= nil then
          return e[key]
        end
      end
    end
  }
  return setmetatable(cls, meta)
end

local function mro_class(a)
  if a == nil then
    -- local A = Class()
    return class_extends({ object }, {})
  end
  -- local A = Class 'A'
  if type(a) == 'string' then
    return class_extends({ object }, { __name__ = a })
  elseif type(a) == 'table' then
    if #a == 0 then
      -- local A = Class {
      --   foo = function(self) end
      -- }
      return class_extends({ object }, a)
    else
      -- local C = Class {A, B} {
      --   foo = function(self) end
      -- }
      return function(cls)
        return class_extends(a, cls)
      end
    end
  else
    error("invalid argument type for class: " .. type(a))
  end
end

local Class = setmetatable({
  object = object,
  super = super,
  inspect = inspect
}, {
  __call = function(t, ...)
    return mro_class(...)
  end
})

return Class
