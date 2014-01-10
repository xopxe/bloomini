--[[
local set = require'bitset'()
set[10] = true
set[10000] = true
set[15] = true
set[8] = false

--set.dump()

if set[10] then print "10 is in the set" end
if not set[10000] then print "10000 is not in the set" end
--]]

local bloom = require'bloom'
local filter = bloom(5000, 40)

local strings = {
    'xxxxxxx', 
    'yxccsdvsdvfvfvyy',
    'yxccsddasfsdafasfvsdvfvfvyy',
    'yxccsddasfsdafasfvsdvfvfvyy1',
    'yxccsddasfsdafasfvsdvfvfvyy2',
    'yxccsddasfsdafasfvsdvfvfvyy3',
}

for _, s in ipairs(strings) do
  filter.add(s)
end

for i=1, 100 do
  filter.add(string.rep('?', i))
end


local serialized = filter.serialize()
print('serialized', serialized)
local filter2 = bloom(filter.serialize())

for _, s in ipairs(strings) do
  print ('test1:', assert(filter.test(s)==true))
  print ('test2:', assert(filter2.test(s)==true))
end

print ('?', filter2.test('xxxxxx '))
print ('?', filter2.test(' xxxxxx'))
print ('?', filter2.test('xxx xxx'))
print ('?', filter2.test(''))
