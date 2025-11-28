-- Options

vim.cmd.filetype("plugin indent on")
vim.o.spell = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.hidden = true
vim.o.mouse = "a"
vim.o.completeopt = "menu,menuone,noinsert"
vim.opt.sessionoptions:remove { "buffers" }
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.list = true
vim.o.listchars = "tab:› ,space:·,trail:·"
vim.o.sbr = ">>>"
vim.o.tabstop = 2
vim.o.softtabstop = 0
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.wrap = true
vim.o.linebreak = true
vim.o.relativenumber = true
vim.o.timeoutlen = 500
vim.o.background = "dark"
vim.o.termguicolors = true
vim.o.spelllang = "en_us"
vim.o.updatetime = 500
vim.o.cc = "120"
vim.o.title = true
vim.o.titlestring = "nvim%y %f[%L]%r%m"

vim.w.TrailWSMatch = nil
vim.cmd.highlight("TrailWS ctermbg=red guibg=red")

function To_camel_case()
  local to_remove = {
    "%.",
    ",",
    "@",
    "%|",
    "%/",
    "%\\",
    "%(",
    "%)",
    "%[",
    "%]",
    "%{",
    "%}",
    "%<",
    "%>"
  }
  local str = vim.fn.getreg("0")
  local words = {}

  for _, c in pairs(to_remove) do
    str = string.gsub(str, c, "")
  end

  for w in string.gmatch(str, "%a+") do
    table.insert(words, w)
  end

  words[1] = string.lower(words[1])

  for i, w in ipairs(words) do
    if i ~= 1 then
      words[i] = string.gsub(w, "^%l", string.upper)
    end
  end

  return table.concat(words, "")
end

local function setup_highlight()
  local twgrp = "TrailWS"
  local twpat = "\\s\\+$"
  local twpri = -1

  if vim.w.TrailWSMatch ~= nil then
    vim.fn.matchdelete(vim.w.TrailWSMatch)
    vim.fn.matchadd(twgrp, twpat, twpri, vim.w.TrailWSMatch)
  else
    vim.w.TrailWSMatch = vim.fn.matchadd(twgrp, twpat, twpri)
  end
end

local function remove_highlight()
  if vim.w.TrailWSMatch ~= nil then
    vim.fn.matchdelete(vim.w.TrailWSMatch)
    vim.w.TrailWSMatch = nil
  end
end

local shgroup = vim.api.nvim_create_augroup("SetupHighlight", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew", "BufNew", "BufModifiedSet" }, {
  group = shgroup,
  callback = function()
    remove_highlight()
    if vim.o.modifiable == true then
      setup_highlight()
    end
  end
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
  group = shgroup,
  callback = function()
    remove_highlight()
    vim.wo.spell = false
  end
})

local ft_groups = vim.api.nvim_create_augroup("FileTypes", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = ft_groups,
  pattern = "*.scons",
  callback = function()
    vim.o.ft = "python"
  end
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = ft_groups,
  pattern = "*.cs",
  callback = function ()
    vim.bo.sw = 4
  end
})

-- Base keybindings

vim.g.mapleader = ","
vim.keymap.set("", "<Leader>w", ":wa<Cr>")
vim.keymap.set({ "i", "c" }, "<Leader>w", "<C-c>:wa<Cr>")
vim.keymap.set("i", "<C-BS>", "<C-w>")

-- Tab switching
for i = 1, 9 do
  vim.keymap.set("", "<A-" .. i .. ">", i .. "gt")
end
vim.keymap.set("", "<A-0>", "10gt") -- Special case

vim.keymap.set("", "<Leader>.", "<Esc>")
vim.keymap.set({ "i", "c", "v", "o" }, "<Leader>.", "<C-c>")
vim.keymap.set("t", "<Leader>.", "<C-\\><C-n>")

vim.keymap.set("", "<F1>", ":help<Space>")

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
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup {
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        ensure_installed = {
          "c",
          "cpp",
          "rust",
          "vim",
          "lua",
          "vimdoc",
          "norg",
          "markdown",
          "scss",
          "css",
          "html",
          "javascript",
          "typescript",
          "cmake",
          "make",
          "c_sharp",
          "csv",
          "haskell",
          "ruby",
          "java",
          "json",
          "json5",
          "julia",
          "python",
          "kconfig",
          "tmux",
          "yaml",
          "toml",
          "ini",
          "rst",
          "ssh_config",
          "sql",
          "proto",
          "nix",
          "latex",
          "dockerfile",
          "asm",
        },
      }

      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "nvim_treesitter#foldexpr()"
      vim.o.foldenable = true
      vim.o.foldlevel = 999;
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp"
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        "clangd",
        "rust_analyzer",
        "nixd",
        "pylyzer",
        "ruby_lsp",
      }
      for _, lsp in ipairs(servers) do
        vim.lsp.config(lsp, {
          capabilities = capabilities,
          on_attach = function() vim.lsp.inlay_hint.enable(true) end
        })
      end

      vim.lsp.config("jdtls", {
        cmd = { "jdt-language-server", "-configuration", vim.env.HOME .. "/.cache/jdtls/config", "-data",
          vim.env.HOME .. "/.cache/jdtls/workspace" },
        capabilities = capabilities,
        on_attach = function() vim.lsp.inlay_hint.enable(true) end
      })

      vim.lsp.config("omnisharp", {
        cmd = { "dotnet", vim.env.HOME .. "/.local/share/omnisharp/OmniSharp.dll" },
        on_attach = function() vim.lsp.inlay_hint.enable(true) end
      })

      -- Configure Lua for Neovim
      vim.lsp.config("lua_ls", {
        on_attach = function() vim.lsp.inlay_hint.enable(true) end,
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            return
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT"
            },
            workspace = {
              checkThirdParty = false,
              -- library = {
              --   vim.env.VIMRUNTIME
              -- }
              library = vim.api.nvim_get_runtime_file("", true)
            }
          })
        end,
        settings = {
          Lua = {}
        }
      })

      vim.keymap.set("", "<Leader>h", vim.lsp.buf.hover)
      vim.keymap.set("", "<F2>", vim.lsp.buf.rename)
      vim.keymap.set("", "<Leader>f", vim.lsp.buf.format)
      vim.keymap.set("", "<Leader>a", vim.lsp.buf.code_action)
      vim.keymap.set({ "n", "i" }, "<Leader>g", function()
        vim.diagnostic.open_float(nil, { focus = false })
      end)
    end
  },
  {
    "Julian/lean.nvim",
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim"
    },
    otps = {
      lsp = {},
      abbreviations = { enable = true }
    },
    config = function()
      local lean = require("lean")
      lean.setup {}
    end
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "neovim/nvim-lspconfig",
      "L3MON4D3/LuaSnip",
      "honza/vim-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_snipmate").lazy_load()

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
          ['<C-d>'] = cmp.mapping.scroll_docs(4),  -- Down
          -- C-b (back) C-f (forward) for snippet placeholder navigation.
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        window = {
          documentation = cmp.config.window.bordered({ zindex = 10 }),
          completion = cmp.config.window.bordered({ zindex = 5 })
        },
        formatting = {
          format = function(_, vim_item)
            -- Prevent the giant-ass menu from appearing
            vim_item.menu = nil
            return vim_item
          end
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "neorg" },
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
          },
          -- ["core.ui.calendar"] = {},
        }
      }
    end
  },
  {
    "rbgrouleff/bclose.vim"
  },
  {
    "francoiscabrol/ranger.vim",
    init = function()
      local g = vim.g
      g.ranger_replace_netrw = 1
      g.ranger_map_keys = 0
    end,
    config = function()
      vim.keymap.set("", "<Leader>r", ":RangerCurrentFile<Cr>")
      vim.keymap.set("", "<Leader>R", ":RangerCurrentFileNewTab<Cr>")
    end
  },
  {
    "EdenEast/nightfox.nvim",
    config = function()
      local nf = require("nightfox")
      nf.setup({
        groups = {
          all = {
            Whitespace = { fg = "palette.fg1" }
          }
        }
      })
    end
  },
  {
    "catppuccin/nvim",
    config = function()
      require('catppuccin').setup({
        custom_highlights = function(colors)
          return {
            Whitespace = { fg = colors.overlay1 },
            LeapBackdrop = { fg = colors.overlay0 },
          }
        end,
      })
    end
  },
  {
    "ggandor/leap.nvim",
    config = function()
      vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
      vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')
      vim.keymap.set('n',             'gs', '<Plug>(leap-from-window)')
    end,
    dependencies = { "tpope/vim-repeat" }
  },
  {
    "tpope/vim-fugitive"
  },
  {
    "numToStr/Comment.nvim",
    opts = {}
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make"
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    config = function()
      local tele = require("telescope")

      tele.setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case"
          }
        },
        defaults = {
          layout_strategy = 'vertical'
        }
      })

      tele.load_extension("fzf")

      local builtins = require('telescope.builtin')

      -- Replace with the better telescope search
      vim.keymap.del("", "<F1>")
      vim.keymap.set("", "<F1>", builtins.help_tags)

      vim.keymap.set("", "<Leader>d", function()
        builtins.lsp_definitions()
      end)

      vim.keymap.set("", "<Leader>dd", function()
        builtins.lsp_definitions({ jump_type = "tab" })
      end)

      vim.keymap.set("", "<Leader>dt", function()
        builtins.lsp_type_definitions()
      end)

      vim.keymap.set("", "<Leader>dtt", function()
        builtins.lsp_type_definitions({ jump_type = "tab" })
      end)

      vim.keymap.set("", "<Leader>di", function()
        builtins.lsp_implementations()
      end)

      vim.keymap.set("", "<Leader>dii", function()
        builtins.lsp_implementations({ jump_type = "tab" })
      end)

      vim.keymap.set("", "<Leader>da", function()
        builtins.lsp_references()
      end)

      vim.keymap.set("", "<Leader>daa", function()
        builtins.lsp_references({ jump_type = "tab" })
      end)

      vim.keymap.set("", "<Leader>/", builtins.live_grep)
    end
  }
})

-- Lazy doesn't trigger buffer events
-- and it doesn't toggle so just add the
-- functionality to do it here.
local lv = require("lazy.view")
vim.keymap.set("", "<F10>", function()
  if lv.visible() then
    lv.view:close()
  else
    lv.show("home")
    remove_highlight()
  end
end)

-- Options to load after plugins

vim.cmd.colorscheme("catppuccin")
vim.cmd.helptags { "ALL", mods = { silent = true } }
