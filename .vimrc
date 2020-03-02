"NOTE: requires vim-gtk, ctags, and xclip to be installed!

"TODO: something updates after an source

" this mess tells us if the current tmux pane is running vim. invoke with:
" let is_vim = system(g:is_vim)[0]
let g:is_vim = "tmux if-shell \"ps -o state= -o comm= -t #{pane_tty} | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'\" \"run \\\"echo 1\\\"\" \"run \\\"echo 0\\\"\""

set laststatus=2
set tabstop=4
set expandtab
set shiftwidth=4
set wildmode=list:longest
set smartindent
set guifont=Monospace\ 9
set number
set mouse=a
set clipboard=unnamedplus
set hidden
set timeoutlen=250
set ttimeoutlen=250
set undofile
set undodir=~/.vim/undodir
set cmdheight=2
set backspace=indent,eol,start
let ch_syntax_for_h = 1 

" colors
set background=dark
let g:gruvbox_contrast_dark='hard'
colorscheme gruvbox

" blinky cursor in insert mode
let &t_SI = "\<esc>[5 q"
let &t_SR = "\<esc>[5 q"
let &t_EI = "\<esc>[2 q"

function! StatuslineGit()
  let l:branchname = system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

"TODO: breaks tmux
" set statusline=
" set statusline+=%#PmenuSel#
" set statusline+=%{StatuslineGit()}
" set statusline+=%#LineNr#
" set statusline+=\ %f
" set statusline+=%m
" set statusline+=%=
" set statusline+=%#CursorColumn#
" set statusline+=\ %y
" set statusline+=\ %p%%
" set statusline+=\ %l:%c
" set statusline+=

" highlighting searches
set hlsearch
set incsearch

" don't highlight shit on source vimrc wtf
:nohls

" preserve clipboard on exit, requires xclip on system
autocmd VimLeave * call system("xclip -selection clipboard -i", getreg('+'))

" ctrl-j = ESC and exit highlighted search
nnoremap <C-j> :silent! nohls<cr>:echo ""<cr>
vnoremap <C-j> :silent! nohls<cr>:echo ""<cr>
inoremap <C-j> :silent! nohls<cr>:echo ""<cr>
cnoremap <C-j> :silent! nohls<cr>:echo ""<cr>

" don't force '#' to the first column
inoremap # X#

" always allow 10 line spacing around 'n' and 'N' searches
"TODO: when no more matches, doesn't set so=0
nnoremap n :set so=10<cr>n:set so=0<cr>
nnoremap N :set so=10<cr>N:set so=0<cr>

" on ctag find, center screen
nnoremap  zz

" don't select whitespace preceding a word when selecting around it
"TODO

" surround a highlighted section with a char
function! SurroundWithChar()
    " get char
    let c = nr2char(getchar())

    " set surrounding chars
    if(c == '(' || c == ')')
        let firstc = '('
        let lastc = ')'
    elseif(c == '{' || c == '}')
        let firstc = '{'
        let lastc = '}'
    elseif(c == '[' || c == ']')
        let firstc = '['
        let lastc = ']'
    else
        let firstc = c
        let lastc = c
    endif

    " insert
    exe "norm gv\"zc" . firstc . "\"zpa" . lastc
endfunction!
vnoremap A :call SurroundWithChar()<cr>

" Don't overwrite clipboard text on paste over
xmap p pgvy

" When sourcing vimrc, first remove all settings
command! So mapc | set all& | so ~/.vimrc | :filetype detect
command! SO mapc | set all& | so ~/.vimrc | :filetype detect


" On file save, make sure the last revision actually says today. 
" Assumes text 'Last Rev' is in first 20 lines.
" Doesn't change the date if it's already correct so undo doesn't get messed up.
function! OnSave()
    let l:winview = winsaveview()
    silent! norm mz

    if(&modified)
        let current_date=strftime('%b %d, %Y')
        silent! 0,20g/Last Rev/exe "norm /RevWv$h\"zy"
        if(current_date!=getreg('z'))
            silent! 0,20g/Last Rev/exe "norm /RevW\"_d$a" . current_date
        endif
    endif

    " restore position
    silent! norm `z
    call winrestview(l:winview)
endfunction!
autocmd BufWritePre,FileWritePre * :call OnSave()


" Create parent dirs if not exist on file save
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) |
            \ execute "silent! !mkdir -p ".shellescape(expand('%:h'), 1) | redraw! | endif
augroup END


" Generate a tags file at the current directory. If a c program, includes the msp430 PAL
function! TagGen()
    :filetype detect
    silent! :call system("rm tags")
    if (&ft=='python')
        silent! !ctags -R . &
    else
        silent! !ctags -R . /opt/capella-msp430/msp430-elf/include/msp430fr5964.h &
    endif

    " clear the screen
    norm 
endfunction!
noremap <F4> :call TagGen()<cr>


" if there's no uncommented lines, uncomment everything
" else, comment everything
"TODO: single line comment after a return and auto indent puts cursor back (visual too)
function! CommentHotkey(with_range) range
    let l:winview = winsaveview()
    silent! norm mz
    :filetype detect

    " get comment symbol per filetype
    if(&ft=='vim')
        let symbol = "\""
    elseif((&ft == 'c') || (&ft == 'cpp') || (&ft == 'ch'))
        let symbol = "\/\/"
    else
        let symbol = "#"
    endif

    " get number of symbols in selection
    redir => symbol_cnt
        silent! exe a:firstline . "," . a:lastline . "s:\\(^\\s*" . symbol .
                \ "\\)\\|\\(^" . symbol . "\\)::n"
    redir END

    if(symbol_cnt[1] == 'E')
        let symbol_cnt = 0
    else
        let symbol_cnt = symbol_cnt[1]
    endif

    if(a:with_range == 1)
        " get number of total lines in selection
        redir => line_cnt
            silent! exe a:firstline . "," . a:lastline . "s/.//n"
        redir END
        let line_cnt = line_cnt[1]

        " add/remove comment symbols
        if(symbol_cnt != line_cnt)
            " insert comment
            exe a:firstline . "," . a:lastline . "norm I" . symbol . " "
         else
            " remove comments
            silent! exe a:firstline . "," . a:lastline . "s:" . symbol . " ::"
            silent! exe a:firstline . "," . a:lastline . "s:^" . symbol . "::"
        endif
    else
        " add/remove comment symbol
        if(symbol_cnt == 0)
            " insert comment
            exe a:firstline . "," . a:lastline . "norm I" . symbol . " "
        else
            " remove comments
            silent! exe a:firstline . "," . a:lastline . "s:" . symbol . " ::"
            silent! exe a:firstline . "," . a:lastline . "s:^" . symbol . "::"
        endif
     endif

    " restore position
    silent! norm `z
    call winrestview(l:winview)
    norm ll

    " move one more char back for //
    if((&ft == 'c') || (&ft == 'cpp') || (&ft == 'ch'))
        norm l
    endif
endfunction!
nnoremap  :call CommentHotkey(0)<cr>
inoremap  :call CommentHotkey(0)<cr>a
vnoremap  :call CommentHotkey(1)<cr>


" tab
" for range, does not fix indentation of individual lines.
" assumes indents are already divisible by 4
function! TabHotkey(with_range) range
    silent! norm mz

    " get number of spaces until a clean multiple of 4
    let tab_amount = 4 - indent('.') % 4

    " if already aligned, tab over 4
    if(tab_amount == 0)
        let tab_amount = 4
    endif

    " tab
    if(a:with_range==0)
        silent! exe "norm ^" . tab_amount . "i "
    else
        silent! exe "'<,'>norm ^" . tab_amount . "i "
    endif

    " move cursor to original location
    exe "silent! norm `z" . tab_amount . "l"
endfunction!
nnoremap <Tab> :call TabHotkey(0)<cr>:echo ""<cr>
" warning; stupid. If before tabbing we are on column 1,
" want to return to insert mode via 'i'. Otherwise, want 'a'
" but we ALSO want to use an 'a' if the line is only whitespaces. For some reason.
inoremap <expr> <Tab> ((col('.') == 1) && !(getline('.') !~ '\S')) ?
        \'<space><backspace>:call TabHotkey(0)<cr>:echo ""<cr>i':
        \'<space><backspace>:call TabHotkey(0)<cr>:echo ""<cr>a'
vnoremap <Tab> :call TabHotkey(1)<cr>:echo ""<cr>gv


" untab
" for range, does not fix indentation of individual lines.
" assumes indents are already divisible by 4
function! UnTabHotkey(with_range) range
    silent! norm mz

    " if no indentation, just exit
    if(indent('.') == 0)
        return 0
    endif

    " get number of spaces past a clean multiple of 4
    let untab_amount = indent('.') % 4
    if(untab_amount == 0)
        let untab_amount = 4
    endif

    " figure out how much to move the cursor
    let line_length = strwidth(getline('.'))
    let cursor_pos = col('.')
    if(cursor_pos >= (line_length - untab_amount))
    let cursor_move_amount = line_length - cursor_pos
    else
        let cursor_move_amount = untab_amount
    endif

    " get current cursor position to know how far to move the cursor
    " remove 'untab_amount' spaces
    if(a:with_range==0)
        silent! exe "s:^ \\{" . untab_amount . "\\}::"
    else
        silent! exe "'<,'>s:^ \\{" . untab_amount . "\\}::"
    endif

    " move cursor to original location
    if cursor_move_amount > 0
        exe "norm `z" . cursor_move_amount . "h"
    else
        norm `z
    endif
endfunction!
nnoremap [Z :call UnTabHotkey(0)<cr>:echo ""<cr>
" warning; stupid. If after untabbing we would be on column 1,
" want to return to insert mode via 'i'. Otherwise, want 'a'
inoremap <expr> [Z (col('.') <= 5) ?
    \'<space><backspace>:call UnTabHotkey(0)<cr>:echo ""<cr>i':
    \'<space><backspace>:call UnTabHotkey(0)<cr>:echo ""<cr>a'
vnoremap [Z :call UnTabHotkey(1)<cr>:echo ""<cr>gv


" save all vim windows in tmux window. Compiles/Uploads on 'omake pane' if specified
" warning: clears scrollback buffer on the terminal pane
function! SaveAllVim(action)
    let starting_pane = system("tmux list-panes | grep active")[0]
    let pane_cnt = system("tmux list-panes | wc -l")[0]

    " set terminal pane where omake or omake copy will run
    if(a:action != 0)
        " TODO: improve this
        " assumes pane 1 is the terminal pane unless 5 panes are open
        if(pane_cnt == 5)
            let terminal_pane = 2
        else
            let terminal_pane = 1
        endif
    endif

    " cycle through panes and save all vim windows
    let i = 0
    while i < pane_cnt
        " select the pane
        silent! exe "!tmux select-pane -t " . i

        " is vim open in this pane?
        let is_vim = system(g:is_vim)[0]

        " :wa if vim is open in pane
        if(is_vim)
            silent! exe "!tmux send-keys \":wa\""
        endif

        "TODO: ismodififed to see if done saving

        let i += 1
    endwhile

    call system("sleep 0.5")

    " switch to terminal pane and see if it has vim open
    silent! exe "!tmux select-pane -t " . terminal_pane
    let is_vim = system(g:is_vim)[0]

    " if the terminal pane actually has vim open, don't try to omake on it
    if(!is_vim)
        " clear the history buffer on terminal pane
        if(a:action != 0)
            silent! exe "!tmux select-pane -t " . terminal_pane
            silent! exe "!tmux send-keys -X cancel"
            silent! exe "!tmux send-keys \"clear\""
            silent! exe "!tmux clear-history"
        endif

        " omake or omake copy if specified
        if(a:action == 1)
            silent! exe "!tmux send-keys \"omake\""
        elseif(a:action == 2)
            " tries to get project name (parent_dir) and append _dev to it
            " not super modular
            silent! exe "!tmux send-keys \"omake copy_" . expand('%:p:h:t') . "_dev\""
        endif
    endif

    " go back to the pane this mess started from
    silent! exe "!tmux select-pane -t " . starting_pane

    " refresh screen
    exe "norm "
endfunction!
" F7 = save all, F8 = save all and omake, F9 = save all and omake copy
nnoremap <F7> :call SaveAllVim(0)<cr>
inoremap <F7> :call SaveAllVim(0)<cr>
nnoremap <F8> :call SaveAllVim(1)<cr>
inoremap <F8> :call SaveAllVim(1)<cr>
nnoremap <F9> :call SaveAllVim(2)<cr>
inoremap <F9> :call SaveAllVim(2)<cr>


" Autoformat
" TODO: spaces around operators
function! Autoformat()
    let l:winview = winsaveview()
    filetype detect
    silent! norm mz

    " Find and remove all whitespace on empty lines
    let _s=@/
    exe "%s:\\s\\+$::e"
    let @/=_s

    " if(x){ to if (x) {                                     >_>
    if((&ft == "c") || (&ft == "cpp") || (&ft == "ch"))
        silent! exe "%g/if(/exe \"norm f(i f{i \""
        silent! exe "%g/for(/exe \"norm f(i f{i \""
        silent! exe "%g/while(/exe \"norm f(i f{i \""
        silent! exe "%g/switch(/exe \"norm f(i f{i \""
    endif

    " only one space until \ on multiline cpp
    if((&ft == "c") || (&ft == "cpp") || (&ft == "ch"))
        silent! %g/\\$/exe "norm f\\\bbf ldt\\\ "
    endif

    " char=char to char = char
    " but leave stings of ==== untouched
    if(&ft != "vim")
        silent! %s/\(\w\|d\|\'\|\"\|\[\)=\(\w\|d\|\'\|\"\|\[\)/\1 = \2/g
        silent! %s/\(\w\|d\|\'\|\"\|\[\)==\(\w\|d\|\'\|\"\|\[\)/\1 == \2/g
    endif

    " function to remove unused imports
    function! RemoveImport(import)
        " if we don't see a <library>.<something>, remove the import
        if(match(readfile(expand("%:p")), a:import.'\.') == -1)
            exe "g/" . a:import . "/exe \"norm \\\"_dd\""
            " single global does not catch 2nd instances for some reason
            exe "g/" . a:import . "/exe \"norm \\\"_dd\""
        endif
    endfunction!

    " remove unused imports
    if(&ft=="python")
        g/import \<\w\+\>/exe "norm $" | let import=expand('<cword>') |
                \ call RemoveImport(import)
    endif

    retab

    silent! norm `z
    call winrestview(l:winview)
endfunction!
nnoremap <F5> :call Autoformat()<cr>:echo "Formatted!"<cr>


" Insert include guard on header file
function! IncludeGuard()
    let filename = expand('%:t')
    exe "norm ggi#ifndef __" . filename . "__#define __" . filename . "__"
    exe "norm Go#endif //__" . filename . "__"
    exe "1,2norm Wv$U:s/\\./_/g"
    exe line('$') . "norm Wv$U:s/\\./_/g"
endfunction!


" Hotkey to go to respective .h/.c file, creates if non-existent
function! SwitchToRespectiveFile()
    :filetype detect
    let file = expand('%:r')
    if(&ft == 'ch')
        " if there's a main.cpp, assume this is a cpp project
        if(filereadable("main.cpp"))
            exe "e " . file . ".cpp"
        else
            exe "e " . file . ".c"
        endif
    elseif((&ft == 'c') || (&ft == 'cpp'))
        exe "e " . file . ".h"
    endif
endfunction!
nnoremap  :call SwitchToRespectiveFile()<cr>
inoremap  :call SwitchToRespectiveFile()<cr>


" from_uppercase == 1: convert CAPS_WITH_UNDERSCORES to CapsWithUnderscores
" from_uppercase == 0: convert caps_with_underscores to CapsWithUnderscores
"FIXME: does not work for TEST_P_THING
function! CapsConvert(from_uppercase)
    " always start with CAPS_WITH_UNDERSCORES
    if(a:from_uppercase == 0)
        norm viw~
    endif

    " get number of underscores
    let underscore_cnt = strlen(substitute(expand('<cword>'), "[^_]", "", "g"))

    " select word and place cursor at beginning
    norm viwo

    " loop to each underscore and convert CAPS to Caps; then delete underscore
    let i = 0
    while i < underscore_cnt
        let i += 1
        norm lvt_uf_x"
    endwhile

    " get last part
    norm lvwu

    " place cursor at end of word
    norm e
endfunction!
noremap  :call CapsConvert(1)<cr>:echo ""<cr>


" create a penguin script from the penguin template file
function! CreatePenguin()
    " place contents of template file
    0r ~/.vim/templates/penguin

    let filename_plus_ext = expand('%:t')
    let filename = expand('%:t:r')

    " insert current date
    silent! exe "%s/templatetime/" . expand(strftime('%b %d, %Y')) . "/g"

    " insert file name with extension
    silent! exe "%s/penguin_template.py/" . filename_plus_ext . "/g"

    " insert file name without extension
    silent! exe "%s/PenguinTemplate/" . filename . "/g"

    " find instances of file name that are *not* functions and convert to proper caps
    " would use 'g' command but regex matching will match lines instead of the match
    " itself when used in a function for some raisin (there are only 3 to replace)
    silent! exe "/" . filename . "\\(\\.\\)\\@!"
    norm w
    :call CapsConvert(0)
    silent! exe "/" . filename . "\\(\\.\\)\\@!"
    norm ww
    :call CapsConvert(0)
    silent! exe "/" . filename . "\\(\\.\\)\\@!"
    norm w
    :call CapsConvert(0)

    " move to first 'todo' string
    silent! norm /TODOzz
endfunction!

" not in use yet
function! TypeOfChar()
    return join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'))
endfunction!

