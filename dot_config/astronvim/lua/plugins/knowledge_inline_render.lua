local images = {}

local function close_images(buf)
  if not images[buf] then
    return
  end

  for _, img in ipairs(images[buf]) do
    pcall(function()
      img:close()
    end)
  end

  images[buf] = nil
end


local function find_blocks(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local blocks = {}

  local i = 1

  while i <= #lines do
    local lang = lines[i]:match("^%s*```%s*([%w_-]+)%s*$")

    if lang == "d2" or lang == "typst" then
      local first = i
      local body = {}

      i = i + 1

      while i <= #lines
        and not lines[i]:match("^%s*```%s*$")
      do
        table.insert(body, lines[i])
        i = i + 1
      end

      if i <= #lines then
        table.insert(blocks, {
          lang = lang,
          first = first,
          last = i,
          source = table.concat(body, "\n"),
        })
      end
    end

    i = i + 1
  end

  return blocks
end


local function compile(block)
  local base = vim.fn.tempname()

  if block.lang == "d2" then
    local src = base .. ".d2"
    local svg = base .. ".svg"
    local png = base .. ".png"

    vim.fn.writefile(
      vim.split(block.source, "\n", { plain = true }),
      src
    )

    local d2_result = vim.system({
      "d2",
      src,
      svg,
    }, {
      text = true,
    }):wait()

    if d2_result.code ~= 0 then
      vim.notify(
        "D2 render hatasi:\n" ..
        (d2_result.stderr or ""),
        vim.log.levels.ERROR
      )

      return nil
    end

    local inkscape_result = vim.system({
      "inkscape",
      svg,
      "--export-filename=" .. png,
    }, {
      text = true,
    }):wait()

    if inkscape_result.code ~= 0 then
      vim.notify(
        "D2 SVG -> PNG hatasi:\n" ..
        (inkscape_result.stderr or ""),
        vim.log.levels.ERROR
      )

      return nil
    end

    return png
  end


  if block.lang == "typst" then
    local src = base .. ".typ"
    local png = base .. ".png"

    vim.fn.writefile(
      vim.split(block.source, "\n", { plain = true }),
      src
    )

    local result = vim.system({
      "typst",
      "compile",
      src,
      png,
      "--ppi",
      "144",
    }, {
      text = true,
    }):wait()

    if result.code ~= 0 then
      vim.notify(
        "Typst render hatasi:\n" ..
        (result.stderr or ""),
        vim.log.levels.ERROR
      )

      return nil
    end

    return png
  end
end


local function render(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if vim.bo[buf].filetype ~= "markdown" then
    return
  end

  close_images(buf)

  local blocks = find_blocks(buf)

  if #blocks == 0 then
    return
  end

  images[buf] = {}

  for _, block in ipairs(blocks) do
    local png = compile(block)

    if png and vim.fn.filereadable(png) == 1 then
      local img = Snacks.image.placement.new(
        buf,
        png,
        {
          pos = {
            block.first,
            0,
          },

          range = {
            block.first - 1,
            0,
            block.last,
            0,
          },

          inline = true,
          conceal = true,

          type = "chart",

          max_width = 80,
          max_height = 30,
        }
      )

      table.insert(images[buf], img)
    end
  end

  vim.cmd("redraw!")
end


local timers = {}

local function schedule(buf)
  if timers[buf] then
    timers[buf]:stop()
    timers[buf]:close()
  end

  local timer = vim.uv.new_timer()
  timers[buf] = timer

  timer:start(
    300,
    0,
    vim.schedule_wrap(function()
      if timers[buf] == timer then
        timers[buf] = nil
      end

      timer:close()

      if vim.api.nvim_buf_is_valid(buf) then
        render(buf)
      end
    end)
  )
end


return {
  {
    "AstroNvim/astrocore",

    opts = function(_, opts)
      opts.autocmds = opts.autocmds or {}

      opts.autocmds.knowledge_inline_render = {
        {
          event = {
            "BufEnter",
            "BufWinEnter",
          },

          pattern = "*.md",

          callback = function(args)
            schedule(args.buf)
          end,
        },

        {
          event = {
            "InsertLeave",
            "BufWritePost",
          },

          pattern = "*.md",

          callback = function(args)
            schedule(args.buf)
          end,
        },

        {
          event = {
            "BufDelete",
            "BufWipeout",
          },

          pattern = "*.md",

          callback = function(args)
            close_images(args.buf)
          end,
        },
      }
    end,
  },
}
