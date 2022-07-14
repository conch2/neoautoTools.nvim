
local M = {}

local vf = vim.fn

local function setmapping()
    -- 符号包裹
    vim.api.nvim_set_keymap("v", "<C-l>",
            "<CMD>lua require('neoautoTools').package()<CR>",
            {noremap=true, silent=true})
end

M.chmap = {}
-- default setting
M.chmap['('] = ')'
M.chmap['['] = ']'
M.chmap['{'] = '}'
M.chmap['<'] = '>'
M.chmap['"'] = '"'
M.chmap["'"] = "'"

-- 使用()等将选中内容包裹起来
function M.package()
    local lch = vim.fn.nr2char(vim.fn.getchar())
    local rch = M.chmap[lch]
    if rch == nil then
        return
    end
    local vln = vim.fn.line("v")
    local tln = vim.fn.line(".")
    local isSingleLen = true
    -- 选择区域为多行
    if vln ~= tln then
        isSingleLen = false
        if vln > tln then
            vln, tln = ".", "v"
        else
            vln, tln = "v", "."
        end
        local c1 = vim.fn.col(vln)
        local c2 = vim.fn.col(tln)
        local len1 = vim.fn.getline(vln)
        local len2 = vim.fn.getline(tln)
        local s1 = string.sub(len1, 1, c1 - 1)
        local s2 = string.sub(len1, c1)
        len1 = s1 .. lch .. s2
        s1 = string.sub(len2, 1, c2)
        s2 = string.sub(len2, c2 + 1)
        len2 = s1 .. rch .. s2
        vim.fn.setline(vln, len1)
        vim.fn.setline(tln, len2)
    -- 选中区域为单行时
    else
        local l1 = vf.col("v")
        local l2 = vf.col(".")
        if l1 > l2 then
            l1, l2 = l2, l1
            vln, tln = ".", "v"
        else
            vln, tln = "v", "."
        end
        local line = vim.fn.getline(".")
        local s1 = string.sub(line, 1, l1 - 1)
        local s2 = string.sub(line, l1, l2)
        local s3 = string.sub(line, l2 + 1)
        line = s1 .. lch .. s2 .. rch .. s3
        vim.fn.setline(".", line)
    end
    -- 退出视图模式
    if M.packageEndEvent == 1 then
        vim.cmd(":normal v")
    -- 设置选中内容，使其将添加的包裹内容也选中
    elseif M.packageEndEvent == 2 then
        local addCharsNum = string.len(lch)
        if isSingleLen then
            addCharsNum = addCharsNum + string.len(rch)
        end
        local vpos = vf.getpos(vln)
        local tpos = vf.getpos(tln)
        vim.cmd(":normal v")
        tpos[3] = tpos[3] + addCharsNum
        if tln == "v" then
            vpos, tpos = tpos, vpos
        end
        vf.setpos(".", vpos)
        vim.cmd(":normal v")
        vf.setpos(".", tpos)
    else
        -- nothing
    end
end



-- @argment attr table
function M.setup(attr)
    if attr == nil then
        attr = {}
    end
    setmapping()
    if attr.chmap ~= nil then
        M.chmap = attr.chmap
    end
    if attr.addChmap ~= nil then
        for k, v in pairs(attr.addChmap) do
            M.chmap[k] = v
        end
    end
    M.packageEndEvent = attr.packageEndEvent
end

return M

