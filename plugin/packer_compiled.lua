-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/bwillis/.cache/nvim/packer_hererocks/2.1.1692716794/share/lua/5.1/?.lua;/home/bwillis/.cache/nvim/packer_hererocks/2.1.1692716794/share/lua/5.1/?/init.lua;/home/bwillis/.cache/nvim/packer_hererocks/2.1.1692716794/lib/luarocks/rocks-5.1/?.lua;/home/bwillis/.cache/nvim/packer_hererocks/2.1.1692716794/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/bwillis/.cache/nvim/packer_hererocks/2.1.1692716794/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["gruvbox-material"] = {
    config = { "\27LJ\2\nû\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0Û\1                let g:gruvbox_material_background = \"hard\"\n                let g:gruvbox_material_better_performance = 1\n                set background=dark\n                colorscheme gruvbox-material\n            \bcmd\bvim\0" },
    loaded = true,
    path = "/home/bwillis/.local/share/nvim/site/pack/packer/start/gruvbox-material",
    url = "https://github.com/sainnhe/gruvbox-material"
  },
  ["mini.surround"] = {
    config = { "\27LJ\2\nà\5\0\0\4\0\27\0o6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\n\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\v\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\f\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\r\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\14\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\15\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\16\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\17\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\18\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\19\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\20\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\21\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\22\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\23\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\24\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\25\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\26\0B\0\3\1K\0\1\0\bsdl\bsrl\bsfl\bsFl\bshl\bsdn\bsrn\bsfn\bsFn\bshn\asn\asr\ash\asF\asf\asd\asa\6n\bdel\vkeymap\bvim\rmappings\1\0\t\14highlight\ash\vdelete\asd\badd\asa\16suffix_next\6n\16suffix_last\6l\19update_n_lines\asn\freplace\asr\14find_left\asF\tfind\asf\1\0\3\23highlight_duration\3ô\3\27respect_selection_type\2\fn_lines\3(\nsetup\18mini.surround\frequire\0" },
    loaded = true,
    path = "/home/bwillis/.local/share/nvim/site/pack/packer/start/mini.surround",
    url = "https://github.com/echasnovski/mini.surround"
  },
  ["nvim-comment"] = {
    config = { "\27LJ\2\nR\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\20create_mappings\1\nsetup\17nvim_comment\frequire\0" },
    loaded = true,
    path = "/home/bwillis/.local/share/nvim/site/pack/packer/start/nvim-comment",
    url = "https://github.com/terrortylor/nvim-comment"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n›\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\1\venable\2\21ensure_installed\1\0\2\17auto_install\2\17sync_install\1\1\15\0\0\6c\blua\bvim\vvimdoc\nquery\vpython\14gitignore\tmake\bcpp\tdiff\tjson\rmarkdown\vmatlab\15dockerfile\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/home/bwillis/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/bwillis/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["vim-mucomplete"] = {
    config = { "\27LJ\2\nÄ\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0¤\1                set completeopt+=menuone\n                set completeopt+=noselect\n                set shortmess+=c \" Shut off completion messages\n            \bcmd\bvim\0" },
    loaded = true,
    path = "/home/bwillis/.local/share/nvim/site/pack/packer/start/vim-mucomplete",
    url = "https://github.com/lifepillar/vim-mucomplete"
  },
  ["vim-obsession"] = {
    loaded = true,
    path = "/home/bwillis/.local/share/nvim/site/pack/packer/start/vim-obsession",
    url = "https://github.com/tpope/vim-obsession"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n›\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\14highlight\1\0\2&additional_vim_regex_highlighting\1\venable\2\21ensure_installed\1\0\2\17auto_install\2\17sync_install\1\1\15\0\0\6c\blua\bvim\vvimdoc\nquery\vpython\14gitignore\tmake\bcpp\tdiff\tjson\rmarkdown\vmatlab\15dockerfile\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: mini.surround
time([[Config for mini.surround]], true)
try_loadstring("\27LJ\2\nà\5\0\0\4\0\27\0o6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\n\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\v\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\f\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\r\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\14\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\15\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\16\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\17\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\18\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\19\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\20\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\21\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\22\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\23\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\24\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\25\0B\0\3\0016\0\6\0009\0\a\0009\0\b\0'\2\t\0'\3\26\0B\0\3\1K\0\1\0\bsdl\bsrl\bsfl\bsFl\bshl\bsdn\bsrn\bsfn\bsFn\bshn\asn\asr\ash\asF\asf\asd\asa\6n\bdel\vkeymap\bvim\rmappings\1\0\t\14highlight\ash\vdelete\asd\badd\asa\16suffix_next\6n\16suffix_last\6l\19update_n_lines\asn\freplace\asr\14find_left\asF\tfind\asf\1\0\3\23highlight_duration\3ô\3\27respect_selection_type\2\fn_lines\3(\nsetup\18mini.surround\frequire\0", "config", "mini.surround")
time([[Config for mini.surround]], false)
-- Config for: nvim-comment
time([[Config for nvim-comment]], true)
try_loadstring("\27LJ\2\nR\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\20create_mappings\1\nsetup\17nvim_comment\frequire\0", "config", "nvim-comment")
time([[Config for nvim-comment]], false)
-- Config for: gruvbox-material
time([[Config for gruvbox-material]], true)
try_loadstring("\27LJ\2\nû\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0Û\1                let g:gruvbox_material_background = \"hard\"\n                let g:gruvbox_material_better_performance = 1\n                set background=dark\n                colorscheme gruvbox-material\n            \bcmd\bvim\0", "config", "gruvbox-material")
time([[Config for gruvbox-material]], false)
-- Config for: vim-mucomplete
time([[Config for vim-mucomplete]], true)
try_loadstring("\27LJ\2\nÄ\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0¤\1                set completeopt+=menuone\n                set completeopt+=noselect\n                set shortmess+=c \" Shut off completion messages\n            \bcmd\bvim\0", "config", "vim-mucomplete")
time([[Config for vim-mucomplete]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
