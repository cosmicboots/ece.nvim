local fw = require("ece.filewriter")

local M = {}

---@class CmdCallbackArgs
---@field name string Command name
---@field args string The args passed to the command, if any <args>
---@field fargs table The args split by unescaped whitespace (when more than one argument is allowed), if any <f-args>
---@field nargs string Number of arguments |:command-nargs|
---@field bang boolean "true" if the command was executed with a ! modifier <bang>
---@field line1 number The starting line of the command range <line1>
---@field line2 number The final line of the command range <line2>
---@field range number The number of items in the command range: 0, 1, or 2 <range>
---@field count number Any count supplied <count>
---@field reg string The optional register, if specified <reg>
---@field mods string Command modifiers, if any <mods>
---@field smods table Command modifiers in a structured format. Has the same structure as the "mods" key of |nvim_parse_cmd()|.

---Setup function
M.setup = function()
    vim.api.nvim_create_user_command("ECCreate",
        ---@param opts CmdCallbackArgs
        function(opts)
            local filepath = ".editorconfig"
            if opts.args[1] then
                filepath = opts.args[1]
            end

            fw.dump_config(filepath, "*.txt")
        end, {})

    vim.api.nvim_create_user_command("ECSaveExt",
        ---@param opts CmdCallbackArgs
        function(opts)
            local filepath = ".editorconfig"
            if opts.args[1] then
                filepath = opts.args[1]
            end

            local buf_name = vim.api.nvim_buf_get_name(0)

            local ext = buf_name:match(".*(%..*)$")
            print("ext", ext)

            fw.dump_config(filepath, "*" .. ext)
        end, {})
end

return M
