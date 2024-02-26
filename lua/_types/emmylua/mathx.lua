---@meta

---@class mathx : mathlib
mathx = {}

---Rounds half away from zeros
---@param n number
---@return number
function mathx.round(n) end

---Pick a random choice from a list of values
---@generic T
---@param possible_values T[] array of possible values
---@return T
function mathx.random_choice(possible_values) end
