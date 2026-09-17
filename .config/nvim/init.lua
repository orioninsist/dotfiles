-- ============================================================
-- NEOVIM — SECOND BRAIN
-- ============================================================

vim.g.mapleader = ' '

-- ------------------------------------------------------------
-- Editor
-- ------------------------------------------------------------

vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.completeopt = {
    'menu',
    'menuone',
    'noselect',
}

require('note_links').setup()

-- ------------------------------------------------------------
-- Clipboard — OSC 52 / WezTerm / Zellij
-- ------------------------------------------------------------

vim.opt.clipboard = 'unnamedplus'

vim.g.clipboard = {
    name = 'OSC 52',

    copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },

    paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
}

vim.keymap.set(
    'n',
    '<C-S-Y>',
    ':%y+<CR>',
    { desc = 'Copy whole file to clipboard' }
)

-- ============================================================
-- Plugins
-- ============================================================

vim.pack.add({
    'https://github.com/nvim-treesitter/nvim-treesitter',

    -- Markdown renderer
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',

    -- Stable completion engine
    {
        src = 'https://github.com/Saghen/blink.cmp',
        version = 'v1',
    },
})

-- ============================================================
-- AUTOCOMPLETE
-- ============================================================

require('blink.cmp').setup({
    keymap = {
        preset = 'default',

        -- Enter = seçili öneriyi kabul et
        ['<CR>'] = { 'accept', 'fallback' },

        -- Tab / Shift-Tab = öneriler arasında gezin
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },

        -- Ctrl-Space = menüyü manuel aç
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },

        -- Esc = completion menüsünü kapat
        ['<Esc>'] = { 'hide', 'fallback' },
    },

    completion = {
        -- Yazarken otomatik öneri menüsü
        menu = {
            auto_show = true,

            border = 'rounded',

            draw = {
                columns = {
                    { 'kind_icon' },
                    { 'label', 'label_description', gap = 1 },
                    { 'source_name' },
                },
            },
        },

        -- Seçili öğenin dokümantasyonunu güzel pencerede göster
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 300,

            window = {
                border = 'rounded',
            },
        },

        -- Ghost text:
        -- önerinin devamını satır üzerinde soluk biçimde gösterir
        ghost_text = {
            enabled = true,
        },
    },

    -- Second Brain için ihtiyacımız olan kaynaklar
    sources = {
        default = {
            'lsp',
            'path',
            'snippets',
            'buffer',
        },
    },

    -- Hızlı fuzzy matching
    fuzzy = {
        implementation = 'prefer_rust_with_warning',
    },
})

-- ============================================================
-- MARKDOWN — PREMIUM SECOND BRAIN UI
-- ============================================================

require('render-markdown').setup({
    enabled = true,

    preset = 'obsidian',

    -- Normal mode = güzel render
    -- Insert mode = gerçek Markdown
    render_modes = {
        'n',
        'c',
        't',
    },

    file_types = {
        'markdown',
    },

    anti_conceal = {
        enabled = true,
    },

    -- --------------------------------------------------------
    -- Markdown autocomplete
    -- --------------------------------------------------------

    -- Checkbox + callout önerilerini blink.cmp'ye verir.
    completions = {
        lsp = {
            enabled = true,
        },
    },

    -- --------------------------------------------------------
    -- Headings
    -- --------------------------------------------------------

    heading = {
        enabled = true,
        sign = false,

        icons = {
            '󰎤 ',
            '󰎧 ',
            '󰎪 ',
            '󰎭 ',
            '󰎱 ',
            '󰎳 ',
        },

        position = 'inline',

        -- Büyük renkli arka plan yok.
        backgrounds = {},

        foregrounds = {
            'RenderMarkdownH1',
            'RenderMarkdownH2',
            'RenderMarkdownH3',
            'RenderMarkdownH4',
            'RenderMarkdownH5',
            'RenderMarkdownH6',
        },
    },

    -- --------------------------------------------------------
    -- Lists
    -- --------------------------------------------------------

    bullet = {
        enabled = true,

        icons = {
            '●',
            '○',
            '◆',
            '◇',
        },

        left_pad = 0,
        right_pad = 1,
    },

    -- --------------------------------------------------------
    -- Checkboxes
    -- --------------------------------------------------------

    checkbox = {
        enabled = true,

        unchecked = {
            icon = '󰄱 ',
        },

        checked = {
            icon = '󰱒 ',
        },
    },

    -- --------------------------------------------------------
    -- Quotes / Callouts
    -- --------------------------------------------------------

    quote = {
        enabled = true,
        icon = '▋',
        repeat_linebreak = false,
    },

    -- --------------------------------------------------------
    -- Code blocks
    -- --------------------------------------------------------

    code = {
        enabled = true,

        style = 'full',
        position = 'left',

        language_pad = 1,

        left_pad = 2,
        right_pad = 2,

        width = 'block',

        above = '▄',
        below = '▀',
    },

    -- --------------------------------------------------------
    -- Horizontal rule
    -- --------------------------------------------------------

    dash = {
        enabled = true,
        icon = '─',
        width = 'full',
    },

    -- --------------------------------------------------------
    -- Links
    -- --------------------------------------------------------

    link = {
        enabled = true,

        hyperlink = '',

        wiki = {
            icon = '󱗖 ',
        },
    },

    -- --------------------------------------------------------
    -- Tables
    -- --------------------------------------------------------

    pipe_table = {
        enabled = true,
        preset = 'round',
        style = 'full',
    },
})

-- ============================================================
-- Markdown shortcuts
-- ============================================================

-- Space + m
-- Premium render <-> raw Markdown
vim.keymap.set('n', '<leader>m', function()
    require('render-markdown').toggle()
end, {
    desc = 'Markdown görünümünü aç/kapat',
})