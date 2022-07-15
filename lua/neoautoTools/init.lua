
local M = {}

local vf = vim.fn
local utils = require("neoautoTools.utils")

local function setmapping()
    -- 符号包裹
    vim.api.nvim_set_keymap("v", "<C-l>",
            "<CMD>lua require('neoautoTools').package()<CR>",
            {noremap=true, silent=true})
    vim.api.nvim_set_keymap("n", "",
            "<CMD>lua require('neoautoTools').commentOnce()<CR>",
            {noremap=true, silent=true})
    vim.api.nvim_set_keymap("i", "",
            "<CMD>lua require('neoautoTools').commentOnce()<CR>",
            {noremap=true, silent=true})
    vim.api.nvim_set_keymap("v", "",
            "<CMD>lua require('neoautoTools').comment()<CR>",
            {noremap=true, silent=true})
    vim.api.nvim_set_keymap("v", "<TAB>",
            "><CR>gv",
            {noremap=true, silent=true})
    vim.api.nvim_set_keymap("v", "-<TAB>",
            "<<CR>gv",
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

M.bufs = {}

local function registerBuffer(buf)
    local fileLocation = vim.api.nvim_buf_get_name(buf)
    local gpos = utils.find_last_of(fileLocation, "/", true)
    local fileName = nil
    if gpos ~= nil then
        fileName = string.sub(fileLocation, gpos + 1)
    else
        fileName = fileLocation
    end
    local suffix
    gpos = utils.find_last_of(fileName, ".", true)
    if gpos ~= nil then
        suffix = string.sub(fileName, gpos + 1)
    else
        suffix = fileName
    end
    M.bufs[buf] = {
        fileLocation = fileLocation,
        fileName = fileName,
        suffix = suffix,
        commentCh = M.suffixsComment[suffix],
    }
end

M.suffixsComment = {}
M.suffixsComment["c"] = "//"
M.suffixsComment["h"] = "//"
M.suffixsComment["cpp"] = "//"
M.suffixsComment["hpp"] = "//"
M.suffixsComment["java"] = "//"
M.suffixsComment["sh"] = "#"
M.suffixsComment["vim"] = '"'
M.suffixsComment["lua"] = "--"

function M.commentOnce()
    -- 获取当前buffer number
    local buf = vf.bufnr("", false)
    if M.bufs[buf] == nil then
        registerBuffer(buf)
    end
    local len = vf.getline(".")
    -- 获取第一个非空字符的位置，indent传入的是行号
    local scnt = vf.indent(vf.line("."))
    local ch = M.bufs[buf].commentCh
    if ch == nil then
        return
    end
    -- 获取注释位置
    local zscnti, zscntj = string.find(len, ch, 1, true)
    if (zscnti == (scnt + 1)) then
        -- 如果注释了这行就解注释
        local s1 = string.sub(len, zscntj + 1)
        len = string.sub(len, 0, zscnti - 1)
        s1 = vim.fn.trim(s1, " ", 1)
        vf.setline(".", len .. s1)
    else
        local freeCh = ch .. M.appendCommentCh
        local s2 = string.sub(len, scnt + 1)
        vf.setline(".", string.sub(len, 0, scnt) .. freeCh .. s2)
        -- 如果是一个空行，将光标移动到行尾
        if string.len(s2) == 0 then
            local oPos = vf.getpos(".")
            oPos[3] = oPos[3] + string.len(freeCh)
            vf.setpos(".", oPos)
        end
    end
end

local function commentItme(lineNum, ch)
    local len = vf.getline(lineNum)
    local lenSize = string.len(len)
    if lenSize == 0 then
        return nil, 3
    end
    -- 获取第一个非空字符的位置，indent传入的是行号
    local scnt = vf.indent(lineNum)
    if scnt == lenSize then
        return nil, 3
    end
    -- 获取注释位置
    local zscnti, zscntj = string.find(len, ch, 1, true)
    if zscnti == (scnt + 1) then
        -- 如果注释了这行就解注释
        local s1 = string.sub(len, zscntj + 1)
        len = string.sub(len, 0, zscnti - 1)
        -- 去除前面的空格
        s1 = vim.fn.trim(s1, " ", 1)
        return len .. s1, 2
    else
        local s1 = string.sub(len, scnt + 1)
        return string.sub(len, 0, scnt) .. ch .. M.appendCommentCh .. s1, 1
    end
end

function M.comment()
    -- 获取当前buffer number
    local buf = vf.bufnr("", false)
    if M.bufs[buf] == nil then
        registerBuffer(buf)
    end
    local vl = vf.line("v")
    local tl = vf.line(".")
    if vl > tl then
        vl, tl = tl, vl
    end
    local anttLines = {}
    local sAnttLines = {}
    local anttLinesIndex = 1
    local sAnttLinesIndex = 1
    local anttFlag = false
    local commentCh = M.bufs[buf].commentCh
    for i = vl, tl, 1 do
        local len, flag = commentItme(i, commentCh)
        if flag == 1 then
            if len ~= nil then
                anttLines[anttLinesIndex] = {line = i, str = len}
                anttLinesIndex = anttLinesIndex + 1
            end
            anttFlag = true
        elseif not anttFlag then
            if len ~= nil then
                sAnttLines[sAnttLinesIndex] = {line = i, str = len}
                sAnttLinesIndex = sAnttLinesIndex + 1
            end
        end
    end
    -- 如果有需要注释的行，不管已经注释了的行
    if anttFlag then
        for _, v in ipairs(anttLines) do
            vf.setline(v.line, v.str)
        end
    -- 全部都是要解注释的行
    else
        for _, v in ipairs(sAnttLines) do
            vf.setline(v.line, v.str)
        end
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
    if attr.appendCommentCh == nil then
        M.appendCommentCh = ""
    else
        M.appendCommentCh = attr.appendCommentCh
    end
end

return M

