local supported = { mermaid = true, d2 = true, typst = true }
local editing = {}

local function find_block(buf, row)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local first, lang
  for i = row, 1, -1 do
    local found = lines[i]:match('^%s*```%s*([%w_-]+)%s*$')
    if found and supported[found] then first, lang = i, found; break end
    if lines[i]:match('^%s*```%s*$') then break end
  end
  if not first then return nil end
  for i = first + 1, #lines do
    if lines[i]:match('^%s*```%s*$') then
      if row <= i then return { first = first, last = i, lang = lang } end
      break
    end
  end
end

local function begin_edit()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= 'markdown' then return false end
  local block = find_block(buf, vim.api.nvim_win_get_cursor(0)[1])
  if not block then return false end
  editing[buf] = block
  -- Existing custom images will be cleared by the renderer's public buffer event.
  vim.api.nvim_exec_autocmds('User', { pattern = 'KnowledgePreviewEditStart', data = { buf = buf } })
  local ok, image = pcall(require, 'snacks.image')
  if ok and image.doc then pcall(image.doc.detach, buf) end
  vim.api.nvim_win_set_cursor(0, { math.min(block.first + 1, block.last), 0 })
  vim.cmd('redraw!')
  vim.cmd('startinsert')
  return true
end

local function finish_edit()
  local buf = vim.api.nvim_get_current_buf()
  if not editing[buf] then return end
  editing[buf] = nil
  vim.api.nvim_exec_autocmds('User', { pattern = 'KnowledgePreviewEditEnd', data = { buf = buf } })
end

return {
  {
    'AstroNvim/astrocore',
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}
      opts.mappings.n['<CR>'] = { function() if not begin_edit() then vim.cmd('normal! j') end end, desc = 'Edit rendered block' }
      opts.autocmds = opts.autocmds or {}
      opts.autocmds.knowledge_render_edit = {
        { event = 'InsertLeave', pattern = '*.md', callback = finish_edit },
      }
    end,
  },
}
