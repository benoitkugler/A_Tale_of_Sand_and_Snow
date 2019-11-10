---@class mapClass
---@field get_direction fun(from:integer, dir:integer, count:integer):integer, integer
---@field get_relative_dir fun(from:integer, to:integer)
---@field rotate_right_around_center fun()
---@field get_adjacent_tiles fun()
---@field tiles_adjacent fun()
---@field distance_between fun(loc1:table, loc2:table):integer
local __

---@class wesnothClass
---@field map mapClass
---@field find_vacant_tile fun(x:integer, y:integer):integer, integer
---@field fire fun(event:string, data:table):void
---@field get_unit fun(id:string):Unit
---@field get_units fun(filter:table):Unit[]
local _

---@type wesnothClass
wesnoth = wesnoth
