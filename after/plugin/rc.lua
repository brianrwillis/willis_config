-- TODO:
-- fix commenting empty line
-- deduce scroll overriding
-- figure out how to split up tags files for speed; use hierarchy in mucomplete?
-- put ctag jump new tab back in? Or find better way...
--    put in a case where if the file is already open in a new tab, just go to it
--    or watch a video on how better to navigate in vim
-- put C-L back in (or find better way...)
-- Figure out Session.vim

---------------- Settings ----------------
-- set <leader>
vim.g.mapleader = " "

-- Nonvolatile undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('config') .. '/undodir'

-- Delays on hotkeys
vim.opt.timeoutlen = 200
vim.opt.ttimeoutlen = 200

vim.opt.number = true                  -- Number lines
vim.opt.hidden = true                  -- Fix windowing
vim.opt.laststatus = 2                 -- Always display statusline
vim.opt.cmdheight = 2                  -- Less 'Press enter to continue' on cmd line
vim.opt.showtabline = 2                -- Always show tabs, even if only one file is open
vim.opt.mouse = "a"                    -- New-school
vim.opt.display = "lastline"           -- Show partial word-wrapped lines
vim.opt.backspace = "eol,indent,start" -- Fix backspacing after a newline

vim.opt.wildmode = "list:longest"      -- Shell-like tab complete

vim.opt.expandtab = true         -- Insert spaces, not a tab, when tabbing
vim.opt.autoindent = true        -- Indent... smart-ish
vim.opt.smarttab = false         -- Do not delete more than one space when backspacing
vim.opt.shiftround = true        -- Round to nearest multiple of shiftwidth
vim.opt.tabstop = 4              -- Size of tab
vim.opt.softtabstop = 0          -- Size of tab in editing operations
vim.opt.shiftwidth = 4           -- Number of spaces used for each autoindent
        
-- Do not autoindent after a ":", "else", or "endif"
vim.opt.indentkeys:remove("<:>") 
vim.opt.indentkeys:remove("=else") 
vim.opt.indentkeys:remove("=endif") 

-- Statusline
vim.opt.statusline = "%F %m%r"             -- <filepath> [+][RO]
vim.opt.statusline:append("%=")            -- start right-aligning
-- vim.opt.statusline:append("[%l, %c] %p%%") -- [line, col] file%
vim.opt.statusline:append("so: %{&scroll}  [%l, %c] %p%%") -- FIXME: scroll debugging

-- Swap files go in the dir where the OG files live
vim.opt.directory = "."

-- Omnifunc
vim.cmd("filetype on")
vim.cmd("filetype plugin on")
vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.completeopt:remove("preview")
------------------------------------------


---------------- Remaps ----------------
-- Set space as <leader>
vim.keymap.set({"n", "v"}, " ", "<Nop>")

-- Center on jumps
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "", "zz")
vim.keymap.set("n", "", "<c-i>zz") -- Remap from Ctrl-I
vim.keymap.set("n", "", "zz")
vim.keymap.set("n", "", "zz")
vim.keymap.set("n", "", "zz")
vim.keymap.set("n", "", "zz")

-- Don't jump on first match
vim.keymap.set("n", "#", ":keepjumps normal! mZ#`Z<cr>")
vim.keymap.set("n", "*", ":keepjumps normal! mZ*`Z<cr>")

-- Ctrl-J: escape, turn off highlights, clear cmd line
vim.keymap.set({"n", "v", "i", "c"}, "<c-j>", ":nohls<cr>:echo<cr>")

-- Hooks for system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set({"n", "v"}, "<leader>d", [["+d]])
vim.keymap.set("n",        "<leader>p", [["+p]])
vim.keymap.set("n",        "<leader>P", [["+P]])

-- Don't overwrite clipboard text on paste over
vim.keymap.set("v", "p",         [[pgvy]])
vim.keymap.set("v", "<leader>p", [["_c"+p]])
vim.keymap.set("v", "<leader>P", [["_c"+P]])

-- Black hole deletes
vim.keymap.set({"n", "v"}, "D",  [["_d]])
vim.keymap.set("n",        "DD", [["_dd]])
vim.keymap.set({"n", "v"}, "C",  [["_c]])
vim.keymap.set("n",        "CC", [["_cc]])

-- Fucksake
vim.keymap.set("n", "tg", "gt")
vim.keymap.set("n", "Tg", "gT")

-- Ctrl-H -> open new tab with file list of current dir
-- Ctrl-G -> open current tab with file list of current dir
vim.keymap.set("n", "", ":tabe %:h/")
vim.keymap.set("n", "", ":e %:h/")

-- Tab for completion
-- (Now accomplished by mucomplete)
-- vim.keymap.set("i", "<Tab>", "<C-P>")
-- vim.keymap.set("i", "<S-Tab>", "<C-N>")

-- Tab
vim.keymap.set("n", "<Tab>", ">>")
vim.keymap.set("n", "<S-Tab>", "<<")
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")

-- No motion on "=" in normal mode
vim.keymap.set("n", "=", "==")

-- Unmap help hotkey
vim.keymap.set({"n", "v", "i", "c"}, "<F1>", "<Nop>")

-- When a popupmenu is visible, make <cr> not create a newline
vim.api.nvim_set_keymap('i', '<cr>', 'pumvisible() ? "<c-y>" : "<cr>"', {expr = true})

-- Comment plugin hotkeys
vim.keymap.set("n", "", ":CommentToggle<cr>")
vim.keymap.set("i", "", ":CommentToggle<cr>A")
vim.keymap.set("v", "", ":'<,'>CommentToggle<cr>")
----------------------------------------


---------------- Commands ----------------
-- Re-source
vim.api.nvim_create_user_command("S",
    [[
        source ~/.config/nvim/init.lua
        source ~/.config/nvim/after/plugin/rc.lua
        source ~/.config/nvim/after/plugin/funs.vim
    ]],
    {}
)
------------------------------------------


---------------- Autocommands ----------------
-- Set tab size for different filetypes and directories
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.yaml", "*/augmental/**"},
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
    end
})

-- When in a vim or lua file, <c-k> auto opens help for cword
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.vim", "*.lua"},
    callback = function()
        vim.opt_local.keywordprg = ":help"    
    end
})

-- Generic buffer enter autocommands for all files
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = "*",
    callback = function()
        -- Don't get smart with comments (must be done after runtime configs load)
        vim.opt.formatoptions:remove{"r"}
        vim.opt.formatoptions:remove{"o"}

        -- Force the cursor to cmd mode
        vim.cmd("norm! ")
    end
})

-- Change comment string to "//" for C files
vim.api.nvim_create_autocmd({"BufEnter", "BufFilePost"}, {
    pattern = {"*.c", "*.cpp", "*.h", "*.hpp"},
    callback = function()
      vim.api.nvim_buf_set_option(0, "commentstring", "// %s")
    end
})

-- Open to last position (only on opening vim itself for the first time
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        vim.cmd([[if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]])
    end
})

-- Set Ctrl-U/D to 1/3rd of screen with a max of 15 rows (must be done after runtime configs load)
-- FIXME: still intermittent
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "VimResized"}, {
    pattern = "*",
    callback = function()
        vim.opt.scroll = math.floor(math.min(15, vim.api.nvim_win_get_height(0) / 3))
    end
})

-- Preserve clipboard on exit, requires xclip on system
vim.api.nvim_create_autocmd("VimLeave", {
    pattern = "*",
    command = [[call system("xclip -selection clipboard -i", getreg('+'))]]
})

-- Create parent dirs if nonexistent on file save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = [[call system("mkdir -p " . shellescape(expand('%:h')))]]
})
----------------------------------------------


---------------- Disable command history unless Ctrl-F was used ----------------
local function escape(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

vim.keymap.set("c", "<C-f>", function()
  vim.g.requested_cmdwin = true
  vim.api.nvim_feedkeys(escape "<C-f>", "n", false)
end)

vim.api.nvim_create_autocmd("CmdWinEnter", {
  group = vim.api.nvim_create_augroup("CWE", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.g.requested_cmdwin then
      vim.g.requested_cmdwin = nil
    else
      vim.api.nvim_feedkeys(escape ":q<CR>:", "m", false)
    end
  end,
})
--------------------------------------------------------------------------------
