local M = {}

local note_completion_active = false

function M.complete()
    local file = "/mnt/local/areas/note/storage/note-index.txt"
    local items = {}

    for line in io.lines(file) do
        table.insert(items, line)
    end

    return items
end

function M.open_completion()
    local items = {}
    local all = M.complete()

    local line = vim.api.nvim_get_current_line()
    local current = line:sub(1, vim.fn.col(".") - 1)

    local base = current:match("%((.*)$") or ""

    for _, item in ipairs(all) do
        if item:find(base, 1, true) then
            table.insert(items, item)
        end
    end

    if #items > 0 then
        note_completion_active = true

        vim.fn.complete(
            vim.fn.col(".") - 1,
            items
        )
    end
end

function M.setup()
    vim.api.nvim_create_user_command("NoteLinks", function()
        print("Note links loaded: " .. #M.complete())
    end, {})

    vim.api.nvim_create_autocmd("TextChangedI", {
        pattern = "*.md",
        callback = function()
            local line = vim.api.nvim_get_current_line()

            if line:match("%[[^%]]*%]%([^)]*$") then
                vim.schedule(function()
                    M.open_completion()
                end)
            end
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
            vim.keymap.set("i", "<Tab>", function()
                if vim.fn.pumvisible() == 1 then
                    vim.api.nvim_feedkeys(
                        vim.api.nvim_replace_termcodes("<C-y>", true, false, true),
                        "n",
                        false
                    )

                    vim.schedule(function()
                        vim.api.nvim_feedkeys(")", "i", false)
                    end)

                    return
                end

                return "<Tab>"
            end, { buffer = true, expr = true })
        end,
    })
end

return M
