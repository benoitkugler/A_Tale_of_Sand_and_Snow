---@meta



---@class location_set
local location_set = {}

---@class loc_set : methods

---@class methods
local methods = {}


---@return boolean
function methods:empty() end

---@return integer
function methods:size() end

function methods:clear() end

---@param x integer
---@param y integer
---@return any
function methods:get(x, y) end

---@param x integer
---@param y integer
---@param value any?
function methods:insert(x, y, value) end

-- function methods:remove(...)
--     local loc = wesnoth.map.read_location(...)
--     if loc ~= nil then
--         self.values[index(loc.x, loc.y)] = nil
--     end
-- end

---@return loc_set
function methods:clone() end

---@param s loc_set
function methods:union(s) end

---@param s loc_set
---@param f fun(x:integer, y:integer, l1:location,l2: location):location
function methods:union_merge(s, f) end

---@param s loc_set
function methods:inter(s) end

---@param s loc_set
---@param f fun(x:integer, y:integer, l1:location,l2: location):location
function methods:inter_merge(s, f) end

---@param s loc_set
function methods:diff(s) end

---@param s loc_set
function methods:symm(s) end

---@param f fun(x:integer, y:integer, v:location): boolean
---@return loc_set
function methods:filter(f) end

-- function methods:iter(f)
--     if f == nil then
--         local locs = self
--         return coroutine.wrap(function()
--             locs:iter(coroutine.yield)
--         end)
--     end
--     for p, v in pairs(self.values) do
--         local x, y = revindex(p)
--         f(x, y, v)
--     end
-- end

-- function methods:stable_iter(f)
--     if f == nil then
--         local locs = self
--         return coroutine.wrap(function()
--             locs:stable_iter(coroutine.yield)
--         end)
--     end
--     local indices = {}
--     for p, v in pairs(self.values) do
--         table.insert(indices, p)
--     end
--     table.sort(indices)
--     for i, p in ipairs(indices) do
--         local x, y = revindex(p)
--         f(x, y, self.values[p])
--     end
-- end

---@param t location[]
function methods:of_pairs(t) end

-- function methods:of_wml_var(name)
--     local values = self.values
--     for i = 0, wml.variables[name .. ".length"] - 1 do
--         local t = wml.variables[string.format("%s[%d]", name, i)]
--         local x, y = t.x, t.y
--         t.x, t.y = nil, nil
--         values[index(x, y)] = next(t) and t or true
--     end
-- end

---@param t location_triple[]
function methods:of_triples(t) end

-- function methods:of_shroud_data(data)
--     self:of_pairs(wesnoth.map.parse_bitmap(data))
-- end

---@return location[]
function methods:to_pairs() end

---@return location[]
function methods:to_stable_pairs() end

-- function methods:to_wml_var(name)
--     local i = 0
--     wml.variables[name] = nil
--     self:stable_iter(function(x, y, v)
--         if type(v) == 'table' then
--             wml.variables[string.format("%s[%d]", name, i)] = v
--         end
--         wml.variables[string.format("%s[%d].x", name, i)] = x
--         wml.variables[string.format("%s[%d].y", name, i)] = y
--         i = i + 1
--     end)
-- end

---@return location_triple[]
function methods:to_triples() end

-- function methods:to_shroud_data()
--     return wesnoth.map.make_bitmap(self:to_pairs())
-- end

---@return integer
---@return integer
function methods:random() end

---@return loc_set
function location_set.create() end

---comment
---@param t location[]
---@return loc_set
function location_set.of_pairs(t) end

-- function location_set.of_wml_var(name)
--     local s = location_set.create()
--     s:of_wml_var(name)
--     return s
-- end

---@param t location_triple[]
---@return loc_set
function location_set.of_triples(t) end

-- function location_set.of_shroud_data(data)
--     local s = location_set.create()
--     s:of_shroud_data(data)
--     return s
-- end

return location_set
