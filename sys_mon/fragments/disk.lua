function disc_usage()
   local handle = io.open("/sys/block/sda/stat", "r")
   local result = handle:read("*l")
   handle:close()
   local v={}
   local i=1
   for d in string.gmatch(result, "%d+") do
      v[tostring(i)] = d
      i=i+1
   end
   return v['1'], v['5']
end

function co_disc_usage()
   while true do
      local r,w=disc_usage()
      MTAB['discio_r'] = math.floor(r / 1000)
      MTAB['discio_w'] = math.floor(w / 1000)
      MTAB['discio'] = math.floor((r+w) / 1000)
      coroutine.yield()
   end
end
return {co=co_disc_usage, ri=2}
