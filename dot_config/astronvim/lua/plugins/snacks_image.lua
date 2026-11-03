return {
  "folke/snacks.nvim",
  opts = {
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        float = true,
        max_width = 80,
        max_height = 30,
        conceal = function(lang, kind)
          return kind == "chart" or kind == "math"
        end,
      },
      math = { enabled = true },
    },
  },
}
