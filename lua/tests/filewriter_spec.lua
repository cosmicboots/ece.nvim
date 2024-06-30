describe("filewriter", function()
    local fw = require("ece.filewriter")
    local content

    before_each(function()
        content = {
            "",
            "[*.lua]",
            "indent_style = space",
            "indent_size = 4",
            "end_of_line = lf",
            "",
            "[*.txt]",
            "indent_style = space",
        }
    end)

    it("set_option", function()
        fw._set_option(content, "*.lua", "charset", "utf-8")
        assert.are.same(content, {
            "",
            "[*.lua]",
            "indent_style = space",
            "indent_size = 4",
            "end_of_line = lf",
            "charset = utf-8",
            "",
            "[*.txt]",
            "indent_style = space",
        })
    end)

    it("set_option (root)", function()
        fw._set_option(content, nil, "root", true)
        assert.are.same(content, {
            "root = true",
            "",
            "[*.lua]",
            "indent_style = space",
            "indent_size = 4",
            "end_of_line = lf",
            "",
            "[*.txt]",
            "indent_style = space",
        }
        )
    end)
end)
