# neoautoTools.nvim
# 安装
plugin
```lua
local packer = require("packer")
packer.startup({
    function()
        use {
            "conch2/neoautoTools.nvim",
        }
    end
})
```
# 配置
注意本插件的全部快捷键没有默认值都需要自己设置，具体设置如下：

请在neovim的配置文件init.lua或者其它lua文件内设置，或者直接在plugin里配置。
```lua
        use {
            "conch2/neoautoTools.nvim",
            config = function()
                require("neoautoTools").setup({})
            end
        }
```

## 快速注释：（例）
```lua
require("neoautoTools").setup({
    append_comment_char = ' ',
    add_suffixs_comment = {
        c = "//",
        cpp = "//"
        py = "#",
        s = "//",
     },
    mapping = {
        comment = "<C-/>",
    },
})
```
`append_comment_char` 自定义在注释符与代码直接添加的字符，如：append_comment_char='A' 快速注释行`print('hello')` 注释后：`#Aprint('hello')`

`mapping.comment` 自定义快捷键

## 增加、减少缩进：（例）
```lua
require("neoautoTools").setup({
    mapping = {
        neo_tab = "<TAB>",
        neo_sub_tab = "<S><TAB>",
    },
})
```
`mapping.neo_tab` 增加缩进快捷键设置  
`mapping.neo_sub_tab` 增加缩进快捷键设置

## 可视模式范围使用符号包裹：（例）
```lua
require("neoautoTools").setup({
    package_end_event = 2,
    mapping = {
        range_package = "<C-l>",
    },
})
```
`package_end_event` 是在完成包裹后的行为，具体可取值与说明如下：
- 1 退出可视模式
- 2 将包裹的符号也选中
- nil或其它 不对后续进行处理

`mapping.range_package` 快捷键