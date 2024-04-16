-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  {
    "rcarriga/nvim-notify",
    config = function()
      -- override default notification provider
      vim.notify = require("notify")
      vim.notify.setup({
        stages = "static",
        renderer = "wrapped-compact"
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    priority = 1001,
      config = function()
         -- Configure tree-sitter for it to work
         require('nvim-treesitter.configs').setup {
          auto_install = true,
           highlight = {
             enable = true,
             additional_vim_regex_highlighting = false,
           },
         }
      end
  },
  -- {
  --   "dense-analysis/ale",
  --   config = function()
  --     local g = vim.g
  --
  --     g.ale_linters = {
  --       rust = { "analyzer", "cargo" },
  --       haskell = "hls",
  --     }
  --
  --     g.ale_fixers = {
  --       rust = { "rustfmt" },
  --       cpp = { "clang-format" }
  --     }
  --     g.ale_completon_enabled = 1
  --     g.ale_completion_autoimport = 1
  --     g.ale_fix_on_save = 1
  --     g.ale_rust_analyzer_config = {
  --       cargo = {
  --         allFeatures = true,
  --       },
  --       checkOnSave = {
  --         allTargets = true
  --       }
  --     }
  --   end
  -- },
  -- Needed for neorg
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp"
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")

      local servers = {
        "clangd",
        "rust_analyzer"
      }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          capabilities = capabilities,
        }
      end
    end
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup {
        mapping = cmp.mapping.preset.insert({
          ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
          ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
          -- C-b (back) C-f (forward) for snippet placeholder navigation.
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        window = {
          documentation = cmp.config.window.bordered({ zindex = 10 }),
          completion = cmp.config.window.bordered({ zindex = 5 })
        },
        sources = {
           { name = "nvim_lsp" },
        },
      }
    end
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      "luarocks.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require('neorg').setup {
        load = {
          ["core.defaults"] = {},
          ["core.dirman"] = {
            config = {
              workspaces = {
                work = "~/Notes/Work",
                home = "~/Notes/Home",
              }
            }
          },
          ["core.keybinds"] = {
            config = {
              default_keybinds = true,
              neorg_leader = ','
            }
          },
          ["core.concealer"] = {},
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp"
            }
          }
        }
      }
    end
  },
  {
    "rbgrouleff/bclose.vim"
  },
  {
    "francoiscabrol/ranger.vim",
    config = function()
      local g = vim.g
      g.ranger_replace_netrw = 1
      g.ranger_map_keys = 0
    end
  },
  {
    "EdenEast/nightfox.nvim"
  },
  {
    "catppuccin/nvim",
    config = function()
      require('catppuccin').setup({
        custom_highlights = function(colors)
          return {
            Whitespace = { fg = colors.overlay1 }
          }
        end
      })
    end
  },
  {
    "ggandor/leap.nvim",
    config = function()
      require('leap').create_default_mappings()
    end,
    dependencies = { "tpope/vim-repeat" }
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "numToStr/Comment.nvim",
    opts = {}
  },
})

-- Source the vimrc.vim file for bindings and other vim stuff
local config_path = vim.fn.stdpath("config") .. "/vimrc.vim";
if vim.loop.fs_stat(config_path) then
  vim.cmd("source " .. config_path)
end
