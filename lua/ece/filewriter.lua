local M = {}

---Read a file into table of lines
---@param filename string
---@return table<string>? content nil if file doesn't exist
local function read_file(filename)
    local f = io.open(filename, "r")
    if f == nil then
        return nil
    end

    local content = {}
    if f then
        for line in f:lines() do
            table.insert(content, line)
        end
        f:close()
    end
    return content
end

---Write table of lines to file
---@param filename string
---@param content table<string>
local function write_file(filename, content)
    local f = io.open(filename, "w")

    if f then
        for _, line in ipairs(content) do
            f:write(line, "\n")
        end
        f:flush()
        f:close()
    end
end

-- This function is from the neovim source
--- Parse a single line in an EditorConfig file
--- @param line string Line
--- @return string? glob pattern if the line contains a pattern
--- @return string? key if the line contains a key-value pair
--- @return string? value if the line contains a key-value pair
local function parse_line(line)
    if not line:find('^%s*[^ #;]') then
        return
    end

    --- @type string?
    local glob = (line:match('%b[]') or ''):match('^%s*%[(.*)%]%s*$')
    if glob then
        return glob
    end

    local key, val = line:match('^%s*([^:= ][^:=]-)%s*[:=]%s*(.-)%s*$')
    if key ~= nil and val ~= nil then
        return nil, key:lower(), val:lower()
    end
end

---Set specified editorconfig option
---@param content table<string> content of the editorconfig
---@param section string? editorconfig config section. nil will set option at the root
---@param option options
---@param value string|number|boolean
---@return table<string> content updated editorconfig
local function set_option(content, section, option, value)
    local in_section = false

    -- HACK: there's probably a better way to guarantee the loop to run once
    local file_empty = false
    if #content == 0 then
        table.insert(content, "")
        file_empty = true
    end

    for i, line in ipairs(content) do
        local glob, k, _ = parse_line(line)

        if glob == section then
            in_section = true
        elseif k == option and in_section then
            content[i] = option .. " = " .. value
            break
        elseif in_section and glob then
            for j = i - 1, 1, -1 do
                if content[j] ~= "" then
                    table.insert(content, j + 1, option .. " = " .. tostring(value))
                    break
                elseif j == 1 then
                    table.insert(content, j, option .. " = " .. tostring(value))
                    break
                end
            end
            break
        end

        if i == #content then
            if in_section then
                table.insert(content, option .. " = " .. tostring(value))
            else
                table.insert(content, "")
                if section then
                    table.insert(content, "[" .. section .. "]")
                end
                table.insert(content, option .. " = " .. value)
                if section == nil then
                    table.insert(content, "")
                end
            end
            break
        end
    end

    if file_empty then
        table.remove(content, 1)
    end

    return content
end

M._set_option = set_option

M.dump_config = function(filepath, glob)
    local config = read_file(filepath)
    if config == nil then
        config = {}
    end

    -- indent style
    if vim.bo.expandtab then
        set_option(config, glob, "indent_style", "space")
    else
        set_option(config, glob, "indent_style", "tab")
    end

    -- indent size
    set_option(config, glob, "indent_size", vim.bo.shiftwidth)

    -- tab width
    set_option(config, glob, "tab_width", vim.bo.tabstop)

    -- end of line
    set_option(config, glob, "end_of_line", ({
        dos = "crlf",
        unix = "lf",
        mac = "cr",
    })[vim.bo.fileformat])

    -- charset
    local enc = vim.bo.fileencoding
    if enc == "utf-8" then
        if vim.bo.bomb then
            set_option(config, glob, "charset", "utf-8-bom")
        else
            set_option(config, glob, "charset", "utf-8")
        end
    elseif enc == "utf-16" then
        set_option(config, glob, "charset", "utf-16be")
    elseif enc ~= "" then
        set_option(config, glob, "charset", enc)
    end

    -- max line length
    local tw = vim.bo.textwidth
    if tw == 0 then
        set_option(config, glob, "max_line_length", "off")
    else
        set_option(config, glob, "max_line_length", tw)
    end

    write_file(filepath, config)
end

---Set root option
---@param filepath string path to editorconfig
M.create_root = function(filepath)
    local config = read_file(filepath)
    if config == nil then
        config = {}
    end

    set_option(config, nil, "root", true)

    write_file(filepath, config)
end

return M
