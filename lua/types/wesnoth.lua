---@class mapClass
---@field get_direction fun(from:integer, dir:integer, count:integer):integer, integer
---@field get_relative_dir fun(from:integer, to:integer)
---@field rotate_right_around_center fun()
---@field get_adjacent_tiles fun()
---@field tiles_adjacent fun()
---@field distance_between fun(loc1:table, loc2:table):integer
local __

---@class wesnoth
---@field interface w_interface
---@field map mapClass
---@field find_vacant_tile fun(x:integer, y:integer):integer, integer
---@field get_unit fun(id:string):Unit
---@field get_units fun(filter:table):Unit[]
---@field is_enemy fun(side1:integer, side2:integer):boolean
local _

-- wesnoth = wesnoth -- to avoid undef errors
-- wml = wml

---@class LocationSet
---@field to_pairs fun():integer[][]

---@class w_interface
---@field delay fun(ms:integer)
---@field scroll_to_hex fun(x:integer, y:integer, ...)
---@field add_item_image fun(x:integer, y:integer, filename: string)
---@field add_item_halo fun(x:integer, y:integer, filename: string)
---@field remove_item fun(x:integer, y:integer, ...)
---@field float_label fun(x:integer, y:integer, text:string)
---@field add_hex_overlay fun(x:integer, y:integer, item: table)
---@field remove_hex_overlay fun(x:integer, y:integer, ...)

---@class wml
---@field fire fun(tag:string,...)
