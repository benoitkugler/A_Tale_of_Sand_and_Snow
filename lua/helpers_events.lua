---@param id_speaker string
---@param message string
function Message(id_speaker, message)
    wml.fire("message", { speaker = id_speaker, message = message })
end

---@param id_unit string
---@param x integer
---@param y integer
function MoveTo(id_unit, x, y)
    wml.fire("move_unit", { id = id_unit, to_x = x, to_y = y })
end

---End the scenario with a victory for the side 1.
function Victory() wml.fire("endlevel", { result = "victory", side = 1 }) end
