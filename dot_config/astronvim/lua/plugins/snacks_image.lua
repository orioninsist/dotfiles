return {
  {
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

          -- Render edilen kaynak alanını gizle.
          conceal = function(lang, type)
            return type == "chart" or type == "math"
          end,
        },

        math = {
          enabled = true,
        },
      },
    },
  },
}
