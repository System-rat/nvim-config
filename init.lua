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
  {
    "dense-analysis/ale",
    config = function()
      local g = vim.g

      g.ale_linters = {
        rust = { "analyzer", "cargo" },
        haskell = "hls",
      }

      g.ale_fixers = {
        rust = { "rustfmt" },
        cpp = { "clang-format" }
      }
      g.ale_completon_enabled = 1
      g.ale_completion_autoimport = 1
      g.ale_fix_on_save = 1
      g.ale_rust_analyzer_config = {
        cargo = {
          allFeatures = true,
        },
        checkOnSave = {
          allTargets = true
        }
      }
    end
  },
  -- Needed for neorg
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
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
          ["core.concealer"] = {}
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
    "ggandor/leap.nvim",
    config = function()
      require('leap').create_default_mappings()
    end,
    dependencies = { "tpope/vim-repeat" }
  }
})

-- Source the vimrc.vim file for bindings and other vim stuff
local config_path = vim.fn.stdpath("config") .. "/vimrc.vim";
if vim.loop.fs_stat(config_path) then
	vim.cmd("source " .. config_path)
end
