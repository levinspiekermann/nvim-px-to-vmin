# nvim-px-to-vmin

> Easily work with vmin in your css files

A Neovim plugin written in lua to convert px to vmin as you type. It also provides commands to convert px to vmin and a virtual text to visualize your vmin values.

## ⚡️ Features

- Easily convert px to vmin as you type (requires [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) or [blink.cmp](https://github.com/Saghen/blink.cmp))
- Convert px to vmin on a single value or a whole line
- Visualize your vmin values in a virtual text

## 📋 Installation

- With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'levinspiekermann/nvim-px-to-vmin',
    config = function()
        require('nvim-px-to-vmin').setup()
    end
}
```

- With [vim-plug](https://github.com/junegunn/vim-plug)

```lua
Plug 'levinspiekermann/nvim-px-to-vmin'

" Somewhere after plug#end()
lua require('nvim-px-to-vmin').setup()
```

- With [folke/lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'levinspiekermann/nvim-px-to-vmin',
    config = true,
    --If you need to set some options replace the line above with:
    -- config = function()
    --     require('nvim-px-to-vmin').setup()
    -- end,
}
```

## ⚙ Configuration

```lua
-- Those are the default values and can be omitted
require("nvim-px-to-vmin").setup({
    viewport_width = 1920,
    decimal_count = 4,
    show_virtual_text = true,
    add_cmp_source = false,
    filetypes = {
        "css",
        "scss",
        "sass",
    },
})
```

| Option              | Description                                                                                                                                      | Default value |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| `viewport_width`    | The viewport width used to convert px to vmin                                                                                                    | `1920`        |
| `decimal_count`     | The number of decimals to keep when converting px to vmin                                                                                        | `4`           |
| `show_virtual_text` | Show the vmin value converted in px in a virtual text                                                                                            | `true`        |
| `add_cmp_source`    | Add a nvim-cmp source to convert px to vmin as you type (requires [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)), disable if you use blink.cmp | `false`       |

### nvim-cmp integration

<details>
<summary>Show configuration for nvim-cmp</summary>

[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) to convert px to vmin as you type.

```lua
require("cmp").setup({
    -- other config
    sources = cmp.config.sources({
        { name = "nvim_px_to_vmin" },
        -- other sources
    }),
})
```

> [!IMPORTANT]
> Do not forget to set `add_cmp_source` to `true` in the setup function

</details>

## 🧰 Commands

| Command           | Description                                            |
| ----------------- | ------------------------------------------------------ |
| `:PxToVminCursor` | Convert px to vmin under cursor                        |
| `:PxToVminLine`   | Convert px to vmin on the whole line, can take a range |

## 📚 Keymaps

This plugin does not set any keymaps by default.
You can set keymaps like so:

```lua
-- Convert px to vmin under cursor
vim.api.nvim_set_keymap("n", "<leader>pxx", ":PxToVminCursor<CR>", { noremap = true })
-- Convert px to vmin on the whole line
vim.api.nvim_set_keymap("n", "<leader>pxl", ":PxToVminLine<CR>", { noremap = true })
-- Convert px to vmin on all the selected lines
vim.api.nvim_set_keymap("v", "<leader>px", ":PxToVminLine<CR>", { noremap = true })
```

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 🎭 Motivations

Based on [nvim-px-to-rem](https://github.com/jsongerber/nvim-px-to-rem) by jsongerber. Modified to work with vmin units instead of rem units.

## 📝 TODO

- [ ] Use Treesitter
- [ ] Write tests
- [ ] Write documentation

## 📜 License

MIT © [levinspiekermann](https://github.com/levinspiekermann/nvim-px-to-vmin/blob/master/LICENSE)
