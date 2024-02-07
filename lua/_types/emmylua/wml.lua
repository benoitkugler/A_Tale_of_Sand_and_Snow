---@meta

---@alias WMLValue number | boolean | string | tstring

---A WML table is a table consisting of an array part and string keys.
---
---String key values can be any of number | boolean | string | (string|boolean|number)[]
---
---Array values are of type WMLTag
---@class WMLTable : { [string]: WMLValue | WMLValue[], [integer]: WMLTag }
---A read-only WML table that auto-substitutes WML variables when read.
---@class vconfig
---@field __literal WMLTable
---@field __parsed WMLTable
---@field __shallow_literal WMLTable
---@field __shallow_parsed WMLTable
---@alias WML WMLTable|vconfig

---A WML tag is a two-element array.
---The first element is a string and the second element is a WML
---@alias WMLTag  { [1]: string, [2]: WML}

-- -@class WMLTag
-- -@field tag string
-- -@field contents WML


---@class wml
---@field all_variables WMLTable
---@field tag { [string]: fun(cfg: WMLTable): WMLTag}
---@field variables table<string, WML>
---@field variables_proxy table<string, WMLVariableProxy>
---@field array_access table
wml = {}

---Loads a WML file into memory as a WML table
---@param path string Path to the file (a WML path)
---@param preproc? string[]|boolean Whether to preprocess and/or which defines to set
---@param schema? string Path to a schema file (a WML path) if you want the file validated
---@return WML #The parsed WML table
function wml.load(path, preproc, schema) end

---Parse a WML string into a WML table
---@param str string A string containing WML text; preprocessor directives and macros are not supported
---@param schema? string Path to a schema file (a WML path) if you want the file validated
---@return WML #The parsed WML table
function wml.parse(str, schema) end

---Returns a clone (deep copy) of a WML table
---@param cfg WML
---@return WML
function wml.clone(cfg) end

---Merges two WML tables together
---@alias WMLMergeMode
---| "'append'" # Tags from the new table are appended to the end of the base table
---| "'replace'" # Tags from the new table replace any other tags of the same name in the base table
---| "'merge'" # Tags from the new table are recursively merged with the respective tag of the saem name in the base table
---@param base WML WML table to use as a base for the merge
---@param merge WML The WML table to merge into the base
---@param mode WMLMergeMode Merge mode to use for child tags
---@return WML #The merged WML table; this is a copy, input tables are unchanged
function wml.merge(base, merge, mode) end

---Computes the difference between two WML tables
---@param left WML
---@param right WML
---@return WML #A WML table representing the differences
function wml.diff(left, right) end

---Applies a diff to a WML table
---@param base WML The base WML table to patch
---@param diff WML A WML table containing a diff
---@return WML #The new WML table with the diff applied
function wml.patch(base, diff) end

---Test if two WML tables are equal
---WML tables are equal if they have all the same keys with the same values and their child tags are recursively equal
---@param a WML
---@param b WML
---@return boolean
function wml.equal(a, b) end

---Test if a table is a valid WML table
---@return boolean
function wml.valid(value) end

---Test if a WML table matches a filters
---@param cfg WML WML table to test
---@param filter WML A WML filter
---@return boolean #Whether cfg matches the filter
function wml.matches_filter(cfg, filter) end

---Serializes a WML table to a string
---@param cfg WML The WML table to serialize
---@return string #WML data as text, representing the input table
function wml.tostring(cfg) end

---Interpolates variables into a WML table, including expansion of `[insert_tag]`
---@param vcfg WML WML table to interpolate into
---@param vars WML WML table containing variables
---@return WML #Parsed WML table with all variables interpolated and all `[insert_tag]`s expanded
function wml.interpolate(vcfg, vars) end

---Turns a WML table into a read-only vconfig that automatically interpolates WML variables
---@param cfg WML
---@return vconfig
function wml.tovconfig(cfg) end

---Evaluates a table of ConditionalWML
---@param cfg WML
---@return boolean
function wml.eval_conditional(cfg) end

---@deprecated
---@return WMLTable
function wml.get_all_vars() end

---@deprecated
---@param var string
---@return WMLTable
function wml.get_variable(var) end

---@deprecated
---@param var string
---@param value WMLTable
function wml.set_variable(var, value) end

---copied from data/lua/core/wml.lua

---Returns the first subtag of cfg with the given name.
---If a id is not nil, the "id" attribute of the subtag has to match too.
---The function also returns the index of the subtag in the array.
---Returns nil if no matching subtag is found
---@param cfg WML
---@param name string
---@param id? string
---@return WML?
function wml.get_child(cfg, name, id) end

---Returns the nth subtag of cfg with the given name.
---(Indices start at 1, as always with Lua.)
---The function also returns the index of the subtag in the array.
---Returns nil if no matching subtag is found
---@param cfg WML
---@param name string
---@param n integer
---@return WML?, integer?
function wml.get_nth_child(cfg, name, n) end

---Returns the first subtag of cfg with the given name that matches the filter.
---If name is omitted, any subtag can match regardless of its name.
---The function also returns the index of the subtag in the array.
---Returns nil if no matching subtag is found
function wml.find_child(cfg, name, filter) end

---Returns the number of attributes of the config
function wml.attribute_count(cfg) end

---Returns the number of subtags of with the given name.
function wml.child_count(cfg, name) end

---Returns an iterator over all the subtags of cfg with the given name.
---@param cfg WML
---@param tag string
---@return fun(): WMLTable?
function wml.child_range(cfg, tag) end

---Returns an array from the subtags of cfg with the given name
function wml.child_array(cfg, tag) end

---Removes the first matching child tag from cfg
function wml.remove_child(cfg, tag) end

---Removes all matching child tags from cfg
function wml.remove_children(cfg, ...) end

---Fire a WML action tag. Note: WML variables are substituted into the parameters table.
---@param name string
---@param cfg? WML The WML table to serialize
function wml.fire(name, cfg) end

---Fetches all the WML container variables with name var,
---returns a table containing all the variables (starting at index 1).
---@param var string
---@param context any?
---@return WML[] #A table containing all the variables (starting at index 1).
function wml.array_access.get(var, context) end

---Puts all the elements of table t inside a WML container with name var.
---@param var string
---@param t (WML|WMLValue)[] An array of WML tables
---@param context any?
function wml.array_access.set(var, t, context) end

-- Creates proxies for all the WML container variables with name var.
-- This is similar to wml.array_access.get, except that the elements
-- can be used for writing too.
---@param var string Name of the variable to fetch
---@return WMLVariableProxy[] #A table containing all the variable proxies (starting at index 1).
function wml.array_access.get_proxy(var) end

---@alias WMLVariableProxy table<string, string|number|boolean|WMLTable>