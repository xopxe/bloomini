-- Adapted by xxopxe@gmail.com
-- from http://lua-users.org/lists/lua-l/2005-02/msg00641.html


--
-- A "packbits" implementation of a bitset.
-- A bitset is any set of non-negative integers.
-- Does not support iteration over the set (yet).
--
-- author:  Wim Couwenberg
-- created: thu, Feb 24, 2005
--
-- Sample usage:
--
--		local set = bitset()
--		set[10] = true
--		set[15] = true
--		set[8] = false
--		if set[10] then print "10 is in the set" end
--

-- determine precision of Lua's number type and
-- setup a table of bitmasks.  (only tested on a
-- system where a number is an IEEE 754 double
-- though.)

local masks = {}

local function prepmasks(i, p)
  if p < 0 or p + 1 == p then
    return i
  else
    masks[i] = p
    return prepmasks(i + 1, 2*p)
  end
end

local stride = prepmasks(0, 1)
local maxmask = masks[stride - 1]

local function split(n)
  local r = math.fmod(n, stride)
  return n - r, masks[r]
end

local function test(n, m)
  if m == maxmask then
    return n >= m
  else
    return math.fmod(n, 2*m) >= m
  end
end

local bitset_meta = {}

function bitset_meta:__index(n)
  local index, mask = split(n)
  local s = self.set[index]
  return s ~= nil and test(s, mask)
end

function bitset_meta:__newindex(n, v)
  local index, mask = split(n)
  local s = self.set[index]
  if v then
    if not s then
      self.set[index] = mask
    elseif not test(s, mask) then
      self.set[index] = s + mask
    end
  elseif s == mask then
    self.set[index] = nil
  elseif s and test(s, mask) then
    self.set[index] = s - mask
  end
end


return function(set)
  local b = { set = set or {} }
  --[[
  b.dump = function()
    for k, v in pairs(b.set) do
      print ('s:',k,v)
    end
  end
  --]]
	return setmetatable(b, bitset_meta)
end

