local bitset=require 'bitset'
local crc32 = require 'crc32'

local function parse(s)
  local bits, hashes, set_s = s:match('^bits=(%d+);hashes=(%d+);set={(.*),}$')
  local set = {}
  for k, v in set_s:gmatch("%[(%d+)%]=(%d+)") do
    set[tonumber(k)] = tonumber(v)
  end
  return {
    bits=bits,
    hashes=hashes,
    set=set,
  }
end

return function (bits, hashes)
  
  local set 
  
  if type(bits)=='string' then
	  -- serialized filter pased as parameter, regenerate
    local from = parse(bits)
    set = bitset(from.set)
    hashes = from.hashes
    bits = from.bits
  else
    set = bitset()
  end
  
  
  local filter = {
    add = function(v)
      for i = 1, hashes do
        local h = crc32(tostring(i)..v)
        set[h%bits] = true
      end
    end,
    test = function(v)
      for i = 1, hashes do
        local h = crc32(tostring(i)..v)
        if set[h%bits] == false then return false end
      end
      return true
    end,
    serialize = function()
      local s=''
      s=s..'bits='..tostring(bits)..';hashes='..tostring(hashes)..';set={'
      for k, v in pairs(set.set) do
        s=s..'['..string.format('%d',k)..']='..string.format('%d',v)..','--print ('s:',k,v)
      end
      s=s..'}'
      return s
    end,
      
  }
  return filter
end
