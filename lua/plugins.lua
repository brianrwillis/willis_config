-- Ensure PackerSync is installed
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
                   install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()


-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]


-- Plugin configuration
return require('packer').startup(function(use)
    -- Packer can manage itself
    use "wbthomason/packer.nvim"

    -- Color scheme
    use {
        "sainnhe/gruvbox-material",
        config = function()
            vim.cmd([[
                let g:gruvbox_material_background = "hard"
                let g:gruvbox_material_better_performance = 1
                set background=dark
                colorscheme gruvbox-material
            ]])
        end
    }

    -- Treesitter coloring
    use {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require('nvim-treesitter.configs').setup {
                -- A list of parser names, or "all" (the five listed parsers should always be installed)
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query",
                                     "python", "gitignore", "make", "cpp", "diff", "json", 
                                     "markdown", "matlab", "dockerfile" },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,

                highlight = {
                    enable = true,

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },
            }
        end,
        run = ':TSUpdate',
    }

    -- Autocomplete
    use {
        "lifepillar/vim-mucomplete",
        config = function()
            vim.cmd([[
                set completeopt+=menuone
                set completeopt+=noselect
                set shortmess+=c " Shut off completion messages
            ]])
        end
    }

    -- Comments
    use {
        "terrortylor/nvim-comment",
        config = function()
            require('nvim_comment').setup {
                create_mappings = false
            }
        end
    }

    -- Surround
    use {
        "echasnovski/mini.surround",
        config = function()
            require('mini.surround').setup {
                -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
                highlight_duration = 500,

                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    add = 'sa',            -- Add surrounding in Normal and Visual modes
                    delete = 'sd',         -- Delete surrounding
                    find = 'sf',           -- Find surrounding (to the right)
                    find_left = 'sF',      -- Find surrounding (to the left)
                    highlight = 'sh',      -- Highlight surrounding
                    replace = 'sr',        -- Replace surrounding
                    update_n_lines = 'sn', -- Update `n_lines`

                    suffix_last = 'l', -- Suffix to search with "prev" method
                    suffix_next = 'n', -- Suffix to search with "next" method
            },

            -- Whether to respect selection type:
            -- - Place surroundings on separate lines in linewise mode.
            -- - Place surroundings on each line in blockwise mode.
            respect_selection_type = true,

            -- Number of lines within which surrounding is searched
            n_lines = 40
        }

        -- Remove normal mode mappings
        vim.keymap.del('n', 'sa')
        vim.keymap.del('n', 'sd')
        vim.keymap.del('n', 'sf')
        vim.keymap.del('n', 'sF')
        vim.keymap.del('n', 'sh')
        vim.keymap.del('n', 'sr')
        vim.keymap.del('n', 'sn')
        vim.keymap.del('n', 'shn')
        vim.keymap.del('n', 'sFn')
        vim.keymap.del('n', 'sfn')
        vim.keymap.del('n', 'srn')
        vim.keymap.del('n', 'sdn')
        vim.keymap.del('n', 'shl')
        vim.keymap.del('n', 'sFl')
        vim.keymap.del('n', 'sfl')
        vim.keymap.del('n', 'srl')
        vim.keymap.del('n', 'sdl')

        end
    }

    -- Create sessions files for reloading vim environs
    use "tpope/vim-obsession"

    -- Auto ctag gen
    use "ludovicchabant/vim-gutentags"
end)
