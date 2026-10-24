local supported = {
  mermaid = true,
  d2 = true,
  typst = true,
}

local editing = {}


local function find_block(buf, row)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local start_line
  local lang

  for i = row, 1, -1 do
    local found = lines[i]:match("^%s*```%s*([%w_-]+)%s*$")

    if found and supported[found] then
      start_line = i
      lang = found
      break
    end

    if lines[i]:match("^%s*```%s*$") then
      break
    end
  end

  if not start_line then
    -- Cursor render'in hemen yanındaki/açılış fence satırındaysa.
    local found = lines[row]
      and lines[row]:match("^%s*```%s*([%w_-]+)%s*$")

    if found and supported[found] then
      start_line = row
      lang = found
    else
      return nil
    end
  end

  local last

  for i = start_line + 1, #lines do
    if lines[i]:match("^%s*```%s*$") then
      last = i
      break
    end
  end

  if not last then
    return nil
  end

  if row < start_line or row > last then
    return nil
  end

  return {
    lang = lang,
    first = start_line,
    last = last,
  }
end


local function force_source_visible(buf)
  -- Snacks document image'larini gecici olarak buffer'dan ayir.
  local ok, image = pcall(require, "snacks.image")

  if ok and image.doc then
    pcall(function()
      image.doc.detach(buf)
    end)
  end

  -- Custom D2/Typst placement'lari da BufEnter/InsertLeave
  -- sonrasinda yeniden olusacak. Ekrani temizlemek icin edit reload
  -- YAPMIYORUZ; buffer icerigine dokunmuyoruz.
  vim.cmd("redraw!")
end


local function begin_edit()
  local buf = vim.api.nvim_get_current_buf()

  if vim.bo[buf].filetype ~= "markdown" then
    return false
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local block = find_block(buf, row)

  if not block then
    return false
  end

  editing[buf] = block

  force_source_visible(buf)

  -- Cursor'u fence yerine ilk kaynak satirina koy.
  local target = math.min(block.first + 1, block.last)

  vim.api.nvim_win_set_cursor(0, {
    target,
    0,
  })

  vim.cmd("startinsert")

  return true
end


local function finish_edit()
  local buf = vim.api.nvim_get_current_buf()

  if not editing[buf] then
    return
  end

  editing[buf] = nil

  -- Mevcut renderer'in InsertLeave/BufWritePost autocmd'lari
  -- render'i yeniden uretecek.
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.cmd("redraw!")
    end
  end, 400)
end


return {
  {
    "AstroNvim/astrocore",

    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}

      -- Render block fence'indeyken Enter = edit.
      -- Normal Markdown satirlarinda Enter'in davranisini bozmuyoruz.
      opts.mappings.n["<CR>"] = {
        function()
          if not begin_edit() then
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes(
                "<CR>",
                true,
                false,
                true
              ),
              "n",
              false
            )
          end
        end,

        desc = "Edit rendered block",
      }

      opts.autocmds = opts.autocmds or {}

      opts.autocmds.knowledge_render_edit = {
        {
          event = "InsertLeave",
          pattern = "*.md",

          callback = function()
            finish_edit()
          end,
        },
      }
    end,
  },
}
