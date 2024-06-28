# ece.nvim -- The EditorConfig Editor

ece.nvim is a Neovim plugin that provides a way to edit and manage
`.editorconfig` files using the current Neovim settings.

## Installation

Use your favorite plugin manager to install ece.nvim.

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "cosmicboots/ece.nvim" }
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
    "cosmicboots/ece.nvim",
}
```

## Usage

The main goal of this plugin is to automatically create/update the
`.editorconfig` settings by using the current Neovim buffer settings.

For example, if you're editing a Lua file and you run `:ECSaveExt`, you will
get the following chunk added (or updated) in your projects `.editorconfig`:

```ini
[*.lua]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
```

The values set for the above options come from the current buffers settings.
For example, the `indent_size` option is set using Neovim's `shiftwidth` buffer
option.


