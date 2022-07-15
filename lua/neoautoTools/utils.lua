
local M = {}

function M.find_last_of(s, fc, plain)
    local fcLen = string.len(fc)
    local num = -1
    local sLen = -string.len(s)
    while num >= sLen do
        local pos = string.find(s, fc, num, plain)
        if pos ~= nil then
            return pos
        end
        num = num - fcLen
    end
    return nil
end

return M

