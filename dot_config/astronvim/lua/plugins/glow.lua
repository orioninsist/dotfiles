return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}

      opts.mappings.n["<Leader>gg"] = {
        function()
          local file = vim.api.nvim_buf_get_name(0)

          if file == "" then
            vim.notify("Dosya kaydedilmemiş", vim.log.levels.WARN)
            return
          end

          vim.cmd("silent write")
          vim.cmd("botright new")
          vim.cmd("terminal glow -p " .. vim.fn.shellescape(file))
          vim.cmd("startinsert")
        end,
        desc = "Glow current file",
      }
    end,
  },
}
