return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<Leader>ml"] = {
          function()
            local root = vim.fn.expand("~/Library/Documents/Notes")
            local source = vim.api.nvim_buf_get_name(0)

            if vim.bo.filetype ~= "markdown" or source == "" then
              vim.notify("Önce bir Markdown dosyası açın", vim.log.levels.WARN)
              return
            end

            Snacks.picker.files({
              cwd = root,
              ignored = true,
              hidden = false,

              actions = {
                confirm = function(picker, item)
                  item = item or picker:current()
                  if not item then return end

                  local target = item.file
                  if not target then return end

                  if not vim.startswith(target, "/") then
                    target = root .. "/" .. target
                  end

                  if not target:match("%.md$") then
                    vim.notify("Yalnızca Markdown dosyası seçin", vim.log.levels.WARN)
                    return
                  end

                  local relative = vim.fs.relpath(
                    vim.fs.dirname(source),
                    target
                  )

                  if not relative then
                    vim.notify("Bağlantı oluşturulamadı", vim.log.levels.ERROR)
                    return
                  end

                  local title = vim.fn.fnamemodify(target, ":t:r")
                  local link = "[" .. title .. "](" .. relative .. ")"

                  picker:close()

                  vim.schedule(function()
                    vim.api.nvim_put({ link }, "c", true, true)
                  end)
                end,
              },
            })
          end,
          desc = "Markdown bağlantısı ekle",
        },
      },
    },
  },
}
