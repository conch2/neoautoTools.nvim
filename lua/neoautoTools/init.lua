
local M = {}

local vf = vim.fn

local function setmapping()
    vim.api.nvim_set_keymap("v", "<C-l>",
            "<CMD>lua require('neoautoTools').package()<CR>",
            {noremap=true, silent=true})
end

require()

function M.package()
    vim.cmd("normal <ESC>")
end

-- @argment attr table
function M.setup(attr)
    if attr == nil then
        attr = {}
    end
    setmapping()
end

return M

