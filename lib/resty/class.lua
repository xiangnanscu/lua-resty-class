local object       = require("resty.object")
local table        = table
local rawget       = rawget
local type         = type
local ipairs       = ipairs
local setmetatable = setmetatable


local function merge(in_lists)
  if #in_lists == 0 then
    return {}
  end
  for _, mro_list in ipairs(in_lists) do
    local head = mro_list[1]
    local has_head = false
    for j, cmp_list in ipairs(in_lists) do
      if cmp_list == mro_list then
        goto continue
      end
      for k = 2, #cmp_list do
        if head == cmp_list[k] then
          has_head = true
          break
        end
      end
      if has_head then
        break
      end
      ::continue::
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
  return setmetatable({}, {
    __index = function(_, key)
      for i = 2, #cls.__mro__ do
        local func = rawget(cls.__mro__[i], key)
        if func ~= nil then
          return function(_, ...)
            return func(self, ...)
          end
        end
      end
    end
  })
end

local function class_extends(cls, bases)
  cls.__bases__ = { unpack(bases) }
  cls.__mro__ = c3_mro(cls)
  cls.__index = cls
  cls.__tostring = object.__tostring
  cls.__call = object.__call
  cls.new = object.new
  cls.init = object.init
  function cls.super(self, cls)
    return super(cls, self)
  end

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
  return setmetatable(cls, meta), meta
end

local function class(bases)
  if bases == nil then
    return class_extends({}, { object })
  elseif type(bases) == 'string' then
    return function(a)
      if a == nil then
        return class_extends({ __name__ = bases }, { object })
      elseif type(a) ~= 'table' then
        error("invalid type for class continuation: " .. type(a))
      elseif #a == 0 then
        a.__name__ = bases
        return class_extends(a, { object })
      else
        return function(b)
          b = b or {}
          b.__name__ = bases
          return class_extends(b, a)
        end
      end
    end
  elseif type(bases) ~= 'table' then
    error("invalid type for class: " .. type(bases))
  elseif #bases == 0 then
    return class_extends(bases, { object })
  else
    return function(cls)
      return class_extends(cls or {}, bases)
    end
  end
end

return class
