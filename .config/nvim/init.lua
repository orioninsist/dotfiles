-- ============================================================
-- NEOVIM — SECOND BRAIN
-- ============================================================

vim.g.mapleader = ' '

-- ------------------------------------------------------------
-- Editor
-- ------------------------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = '↳ '
vim.opt.scrolloff = 6
vim.opt.sidescrolloff = 4
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.winborder = 'rounded'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.completeopt = {
    'menu',
    'menuone',
    'noselect',
}

-- ------------------------------------------------------------
-- Clipboard — OSC 52
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

vim.keymap.set('n', '<C-S-Y>', ':%y+<CR>', { desc = 'Copy whole file to clipboard' })

-- ------------------------------------------------------------
-- Plugins
-- ------------------------------------------------------------

vim.pack.add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
    {
        src = 'https://github.com/Saghen/blink.cmp',
        version = 'v1',
    },
})

-- ------------------------------------------------------------
-- Treesitter
-- ------------------------------------------------------------

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'markdown_inline' },
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- ------------------------------------------------------------
-- Autocomplete
-- ------------------------------------------------------------

require('blink.cmp').setup({
    keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
    },
    completion = {
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
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 220,
            window = { border = 'rounded' },
        },
        ghost_text = { enabled = true },
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = {
        implementation = 'prefer_rust_with_warning',
    },
})

-- ------------------------------------------------------------
-- Markdown writing mode
-- ------------------------------------------------------------

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function(args)
        local bo = vim.bo[args.buf]
        local wo = vim.wo

        bo.textwidth = 0
        bo.wrapmargin = 0
        wo.spell = true
        bo.spelllang = 'en_us'

        wo.wrap = true
        wo.linebreak = true
        wo.breakindent = true
        wo.conceallevel = 2
        wo.concealcursor = 'nc'

        vim.keymap.set('n', 'j', 'gj', { buffer = args.buf, silent = true, desc = 'Down by visual line' })
        vim.keymap.set('n', 'k', 'gk', { buffer = args.buf, silent = true, desc = 'Up by visual line' })

        vim.keymap.set('n', '<leader>tc', function()
            local line = vim.api.nvim_get_current_line()
            if line:find('%[ %]') then
                line = line:gsub('%[ %]', '[x]', 1)
            elseif line:find('%[x%]') or line:find('%[X%]') then
                line = line:gsub('%[[xX]%]', '[ ]', 1)
            end
            vim.api.nvim_set_current_line(line)
        end, { buffer = args.buf, desc = 'Toggle Markdown checkbox' })

        vim.keymap.set('n', '<leader>h1', 'I# <Esc>', { buffer = args.buf, desc = 'Heading 1' })
        vim.keymap.set('n', '<leader>h2', 'I## <Esc>', { buffer = args.buf, desc = 'Heading 2' })
        vim.keymap.set('n', '<leader>h3', 'I### <Esc>', { buffer = args.buf, desc = 'Heading 3' })
        vim.keymap.set('n', '<leader>li', 'I- <Esc>', { buffer = args.buf, desc = 'Bullet list item' })
        vim.keymap.set('n', '<leader>td', 'I- [ ] <Esc>', { buffer = args.buf, desc = 'Task item' })
        vim.keymap.set('n', '<leader>bq', 'I> <Esc>', { buffer = args.buf, desc = 'Blockquote' })
    end,
})

-- ------------------------------------------------------------
-- Render Markdown
-- ------------------------------------------------------------

require('render-markdown').setup({
    enabled = true,
    preset = 'obsidian',
    render_modes = { 'n', 'c', 't' },
    file_types = { 'markdown' },
    anti_conceal = { enabled = true },
    completions = {
        lsp = { enabled = true },
    },
    heading = {
        enabled = true,
        sign = false,
        icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
        position = 'inline',
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
    bullet = {
        enabled = true,
        icons = { '●', '○', '◆', '◇' },
        left_pad = 0,
        right_pad = 1,
    },
    checkbox = {
        enabled = true,
        unchecked = { icon = '󰄱 ' },
        checked = { icon = '󰱒 ' },
    },
    quote = {
        enabled = true,
        icon = '▋',
        repeat_linebreak = false,
    },
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
    dash = {
        enabled = true,
        icon = '─',
        width = 'full',
    },
    link = {
        enabled = true,
        hyperlink = '',
        wiki = { icon = '󱗖 ' },
    },
    pipe_table = {
        enabled = true,
        preset = 'round',
        style = 'full',
    },
})

-- ------------------------------------------------------------
-- Markdown shortcuts
-- ------------------------------------------------------------

vim.keymap.set('n', '<leader>m', function()
    require('render-markdown').toggle()
end, { desc = 'Toggle rendered Markdown' })

vim.keymap.set('n', '<leader>ss', function()
    vim.wo.spell = not vim.wo.spell
    vim.notify('Spell: ' .. (vim.wo.spell and 'on' or 'off'))
end, { desc = 'Toggle spell checking' })

vim.keymap.set('n', '<leader>nh', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Custom note-link completion
require('note_links').setup()
