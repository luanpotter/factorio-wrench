local array = {};

function Array(t)
    return setmetatable(t, {__index = array})
end

Array_from_values = function (table)
  local new_array = {}
  local j = 1
  for k,v in pairs(table) do
    new_array[j] = v
    j = j + 1
  end
  return Array(new_array)
end

function array.map(a, func)
  local new_array = {}
  for i,v in ipairs(a) do
    new_array[i] = func(v)
  end
  return Array(new_array)
end

function array.for_each(a, func)
  for _,v in ipairs(a) do
    local ret = func(v)
    if ret then
      break
    end
  end
end

function array.filter(a, func)
  local new_array = {}
  local j = 1
  for _,v in ipairs(a) do
    if (func(v)) then
      new_array[j] = v
      j = j + 1
    end
  end
  return Array(new_array)
end

function array.size(a)
  return #a
end

function array.find(a, func)
  local f = a:filter(func)
  if (f:size() > 0) then
    return f[1]
  end
  return nil
end

function array.contains(a, el)
  return a:filter(function (e)
    return e == el
  end):size() > 0
end

function array.to_string(a)
  local str = "[ "
  a:for_each(function(v)
    if type(v) == "array" then
      str = str .. v:tostring()
    elseif type(v) == "table" then
      str = str .. Array(v):tostring()
    else
      str = str .. v
    end
    str = str .. ", "
  end)
  str = str .. " ]"
  return str
end