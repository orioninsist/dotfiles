local M = {}

local index_file = '/mnt/local/areas/note/storage/note-index.txt'

local function read_index()
    local items = {}
    local handle = io.open(index_file, 'r')
    if not handle then
        return items
    end

    for line in handle:lines() do
        if line ~= '' then
            table.insert(items, line)
        end
    end

    handle:close()
    return items
end

function M.complete()
    return read_index()
end

function M.open_completion()
    local items = {}
    local all = read_index()
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col('.')
    local before_cursor = line:sub(1, col - 1)
    local base = before_cursor:match('%[[^%]]*%]%(([^)]*)$') or ''

    for _, item in ipairs(all) do
        if item:find(base, 1, true) then
            table.insert(items, item)
        end
    end

    if #items == 0 then
        return
    end

    local start_col = col - #base
    vim.fn.complete(start_col, items)
end

function M.setup()
    vim.api.nvim_create_user_command('NoteLinks', function()
        print('Note links loaded: ' .. #read_index())
    end, {})

    vim.api.nvim_create_autocmd('TextChangedI', {
        pattern = '*.md',
        callback = function()
            local line = vim.api.nvim_get_current_line()
            local col = vim.fn.col('.')
            local before_cursor = line:sub(1, col - 1)

            if before_cursor:match('%[[^%]]*%]%([^)]*$') then
                vim.schedule(M.open_completion)
            end
        end,
    })
end

return M
