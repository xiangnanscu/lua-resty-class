local object       = require("resty.object")
local table        = table
local rawget       = rawget
local type         = type
local ipairs       = ipairs
local setmetatable = setmetatable

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
      -- local A = Class {foo = function(self) end}
      return class_extends({ object }, a)
    else
      -- local C = Class {A, B}
      return class_extends(a, {})
    end
  else
    error("invalid argument type for class: " .. type(a))
  end
end

local Class = setmetatable({
  super = super,
  inspect = inspect
}, {
  __call = function(t, ...)
    return mro_class(...)
  end
})

return Class
