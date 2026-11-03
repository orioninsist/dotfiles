-- Custom Typst/D2 Markdown preview, managed independently of Snacks doc images.
local state = {}
local M = {}

local function get(buf)
  state[buf] = state[buf] or { images = {}, files = {}, timer = nil, editing = false, generation = 0 }
  return state[buf]
end

local function clear(buf)
  local s = state[buf]
  if not s then return end
  for _, img in ipairs(s.images) do pcall(function() img:close() end) end
  s.images = {}
  for _, path in ipairs(s.files) do pcall(vim.fn.delete, path) end
  s.files = {}
end

local function blocks(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local found, i = {}, 1
  while i <= #lines do
    local lang = lines[i]:match('^%s*```%s*([%w_-]+)%s*$')
    if lang == 'typst' or lang == 'd2' then
      local first, body = i, {}
      i = i + 1
      while i <= #lines and not lines[i]:match('^%s*```%s*$') do
        body[#body + 1] = lines[i]
        i = i + 1
      end
      if i <= #lines then
        found[#found + 1] = { lang = lang, first = first, last = i, source = table.concat(body, '\n') }
      end
    end
    i = i + 1
  end
  return found
end

local function compile(block, s)
  local base = vim.fn.tempname()
  local src = base .. (block.lang == 'typst' and '.typ' or '.d2')
  local png = base .. '.png'
  s.files[#s.files + 1] = src
  s.files[#s.files + 1] = png
  vim.fn.writefile(vim.split(block.source, '\n', { plain = true }), src)
  local cmd
  if block.lang == 'typst' then
    cmd = { 'typst', 'compile', src, png, '--ppi', '144' }
  else
    local svg = base .. '.svg'
    s.files[#s.files + 1] = svg
    local result = vim.system({ 'd2', src, svg }, { text = true }):wait()
    if result.code ~= 0 then
      vim.notify('D2 render error: ' .. (result.stderr or ''), vim.log.levels.ERROR)
      return nil
    end
    cmd = { 'inkscape', svg, '--export-filename=' .. png }
  end
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify(block.lang .. ' render error: ' .. (result.stderr or ''), vim.log.levels.ERROR)
    return nil
  end
  return png
end

function M.clear(buf)
  local s = get(buf)
  s.generation = s.generation + 1
  if s.timer then s.timer:stop(); s.timer:close(); s.timer = nil end
  clear(buf)
end

function M.edit(buf)
  local s = get(buf)
  s.editing = true
  M.clear(buf)
end

function M.resume(buf)
  local s = get(buf)
  s.editing = false
  M.schedule(buf)
end

local function render(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= 'markdown' then return end
  local s = get(buf)
  if s.editing then return end
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  if s.last_tick == tick and #s.images > 0 then return end
  clear(buf)
  s.last_tick = tick
  local ok, snacks = pcall(require, 'snacks')
  if not ok or not snacks.image or not snacks.image.placement then return end
  for _, block in ipairs(blocks(buf)) do
    local png = compile(block, s)
    if png and vim.fn.filereadable(png) == 1 then
      local placed, img = pcall(snacks.image.placement.new, buf, png, {
        pos = { block.first, 0 },
        range = { block.first - 1, 0, block.last, 0 },
        inline = true, conceal = true, type = 'chart',
        max_width = 80, max_height = 30,
      })
      if placed and img then s.images[#s.images + 1] = img end
    end
  end
  vim.cmd('redraw!')
end

function M.schedule(buf)
  local s = get(buf)
  if s.editing then return end
  if s.timer then s.timer:stop(); s.timer:close() end
  s.timer = vim.uv.new_timer()
  local timer = s.timer
  timer:start(350, 0, vim.schedule_wrap(function()
    if s.timer == timer then s.timer = nil end
    if not timer:is_closing() then timer:close() end
    render(buf)
  end))
end

return {
  {
    'AstroNvim/astrocore',
    opts = function(_, opts)
      opts.autocmds = opts.autocmds or {}
      opts.autocmds.knowledge_inline_render = {
        { event = { 'BufEnter', 'BufWinEnter', 'InsertLeave', 'BufWritePost' }, pattern = '*.md', callback = function(args) M.schedule(args.buf) end },
        { event = 'User', pattern = 'KnowledgePreviewEditStart', callback = function(args) if args.data and args.data.buf then M.edit(args.data.buf) end end },
        { event = 'User', pattern = 'KnowledgePreviewEditEnd', callback = function(args) if args.data and args.data.buf then M.resume(args.data.buf) end end },
        { event = { 'BufDelete', 'BufWipeout' }, pattern = '*.md', callback = function(args) M.clear(args.buf); state[args.buf] = nil end },
      }
    end,
  },
}
