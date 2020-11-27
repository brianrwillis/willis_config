" NOTE: requires vim to be compiled with +clipboard, 
" and ctags + xclip to be installed!

" TODO; remap change/delete to put into th black hole register
"remap 'onoremap' for 'around' x
" TODO: something updates after a source
" TODO: tab = ctrl-p in insert
" if in insert, still actually tab is no chars before cursor
" maybe not

" TODO: %s/( \(.*\) )/(\1)/g

" This mess tells us if the current tmux pane is running vim. invoke with:
" let is_vim = system(g:is_vim)[0]
let g:is_vim = "tmux if-shell \"ps -o state= -o comm= -t #{pane_tty} | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'\" \"run \\\"echo 1\\\"\" \"run \\\"echo 0\\\"\""

set tabstop=4                   " Correct tabs
set expandtab
set shiftwidth=4

set undofile                    " Nonvolatile undo
set undodir=~/.vim/undodir

set laststatus=2                " Always display statusline
set wildmode=list:longest       " Tab-complete
set smartindent                 " Indent... smart-ish
set number                      " Number lines
set mouse=a                     " New-school
set clipboard=unnamedplus       " Combine system and vim clipboards
set hidden                      " Fix windowing
set timeoutlen=250              " Quarter second delays on hotkeys
set ttimeoutlen=250
set cmdheight=2                 " Less 'Press enter to continue' on cmd line
set backspace=indent,eol,start  " Fix backspacing after a newline
set scroll=15                   " Set scroll to ~25% of a page

syntax on

let ch_syntax_for_h = 1         " Header filetype is 'ch'

" Colors
set background=dark
let g:gruvbox_contrast_dark='hard'
colorscheme gruvbox

" Blinky cursor in insert mode
let &t_SI = "\<esc>[5 q"
let &t_SR = "\<esc>[5 q"
let &t_EI = "\<esc>[2 q"

set statusline=%F\ %m%r                        " name_of_file_tail [+][RO]
set statusline+=%=                             " start right-aligning
set statusline+=\ alt:\ %{expand('#:t')}\ \    " alternate_file_tail
set statusline+=[%l,\ %c]\ %p%%                " [line, col] file%

" Highlighting searches
set hlsearch
set incsearch

" Don't highlight shit on source vimrc wtf
:nohls

" Preserve clipboard on exit, requires xclip on system
autocmd VimLeave * call system("xclip -selection clipboard -i", getreg('+'))

" Force syntax on buf open
autocmd BufEnter * syntax enable

" Ctrl-H -> open new tab with file list of current dir
" Ctrl-G -> open current tab with file list of current dir
nnoremap  :tabe %:h
nnoremap  :e %:h

" Ctrl-j = ESC and exit highlighted search
nnoremap <C-j> :silent! nohls<cr>:set so=0<cr>:echo ""<cr>
vnoremap <C-j> :silent! nohls<cr>:set so=0<cr>:echo ""<cr>
inoremap <C-j> :silent! nohls<cr>:set so=0<cr>:echo ""<cr>
cnoremap <C-j> :silent! nohls<cr>:set so=0<cr>:echo ""<cr>

" Don't force '#' to the first column
inoremap # X#

" Don't let '[' do anything in visual mode
vnoremap [ <nop>
	
" I don't use D to delete
nnoremap D <nop>
vnoremap D <nop>

" I don't need ex mode
nnoremap Q <nop>

" Get rid of x-server
" nnoremap y "+y
" nnoremap p "+p
" vnoremap y "+y
" vnoremap p "+p

" Center screen on search results
nnoremap n nzz
nnoremap N Nzz

" On ctag find, center screen
nnoremap  zz
nnoremap  zz

" Don't select whitespace preceding a word when selecting around it
" TODO

" Surround a highlighted section with a char
function! SurroundWithChar()
    " Get char
    let c = nr2char(getchar())

    " Set surrounding chars
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

    " Insert
    exe "norm gv\"zc" . firstc . "\"zpa" . lastc
endfunction!
vnoremap S :call SurroundWithChar()<cr>

" Don't overwrite clipboard text on paste over
xmap p pgvy

" When sourcing vimrc, first try and remove all settings
command! So mapc | set all& | so ~/.vimrc | :filetype detect
command! SO mapc | set all& | so ~/.vimrc | :filetype detect

" Previous in jump list (remap Ctrl-I)
nnoremap  <C-I>

" Tab for completion
" FIXME: removing insert-mode tab for this
" just do if no text before cursor, do tab
inoremap <tab> <C-P>
inoremap <S-tab> <C-N>

" '/' in visual mode means 'search for this'
" TODO

" Ctrl-\ = open this tag in a new window
nnoremap  :tabnew %<cr><C-o><C-]>

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
        silent! 0,20g/By/exe "norm /ByWv$h\"zy"
        if(getreg('z')!="Brian Willis")
            silent! 0,20g/By/exe "norm /ByW\"_d$aBrian Willis"
        endif
    endif

    " Restore position
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
    if ((&ft == 'c') || (&ft == 'ch'))
        silent! !ctags -R . /opt/capella-msp430/msp430-elf/include/msp430fr5964.h &
    else
        silent! !ctags -R . &
    endif

    " Clear the screen
    norm 
endfunction!
noremap <F4> :call TagGen()<cr>


" If there's no uncommented lines, uncomment everything
" else, comment everything
" TODO: single line comment after a return and auto indent puts cursor back (visual too)
function! CommentHotkey(with_range) range
    let l:winview = winsaveview()
    silent! norm mz
    :filetype detect

    " Get comment symbol per filetype
    if(&ft=='vim')
        let symbol = "\""
    elseif((&ft == 'c') || (&ft == 'cpp') || (&ft == 'ch'))
        let symbol = "\/\/"
    else
        let symbol = "#"
    endif

    " Get number of symbols in selection
    redir => symbol_cnt
        silent! exe a:firstline . "," . a:lastline . "s:\\(^\\s*" . symbol .
                \ "\\)\\|\\(^" . symbol . "\\)::n"
    redir END

    let symbol_cnt = split(symbol_cnt, ' ')[0][1:]

    if(symbol_cnt == 'Error')
        let symbol_cnt = 0
    endif

    if(a:with_range == 1)
        " Get number of total lines in selection
        let line_cnt = a:lastline - a:firstline + 1

        " Add/remove comment symbols
        if(symbol_cnt != line_cnt)
            " Insert comment
            exe a:firstline . "," . a:lastline . "norm I" . symbol . " "
         else
            " Remove comments
            silent! exe a:firstline . "," . a:lastline . "s:" . symbol . " ::"
            silent! exe a:firstline . "," . a:lastline . "s:^" . symbol . "::"
        endif
    else
        " Add/remove comment symbol
        if(symbol_cnt == 0)
            " Insert comment
            exe a:firstline . "," . a:lastline . "norm I" . symbol . " "
        else
            " Remove comments
            silent! exe a:firstline . "," . a:lastline . "s:" . symbol . " ::"
            silent! exe a:firstline . "," . a:lastline . "s:^" . symbol . "::"
        endif
     endif

    " Restore position
    silent! norm `z
    call winrestview(l:winview)
    norm ll

    " Move one more char back for //
    if((&ft == 'c') || (&ft == 'cpp') || (&ft == 'ch'))
        norm l
    endif
endfunction!
nnoremap  :call CommentHotkey(0)<cr>
inoremap  :call CommentHotkey(0)<cr>a
vnoremap  :call CommentHotkey(1)<cr>


" Tab
" For range, does not fix indentation of individual lines and 
" assumes indents are already divisible by 4
function! TabHotkey(with_range) range
    silent! norm mz

    " Get number of spaces until a clean multiple of 4
    let tab_amount = 4 - indent('.') % 4

    " If already aligned, tab over 4
    if(tab_amount == 0)
        let tab_amount = 4
    endif

    " Tab
    if(a:with_range==0)
        silent! exe "norm ^" . tab_amount . "i "
    else
        silent! exe "'<,'>norm ^" . tab_amount . "i "
    endif

    " Move cursor to original location
    exe "silent! norm `z" . tab_amount . "l"
endfunction!
nnoremap <Tab> :call TabHotkey(0)<cr>:echo ""<cr>
 " Warning; stupid. If before tabbing we are on column 1,
 " want to return to insert mode via 'i'. Otherwise, want 'a'
 " But we ALSO want to use an 'a' if the line is only whitespaces. For some reason.
" inoremap <expr> <Tab> ((col('.') == 1) && !(getline('.') !~ '\S')) ?
        " \'<space><backspace>:call TabHotkey(0)<cr>:echo ""<cr>i':
        " \'<space><backspace>:call TabHotkey(0)<cr>:echo ""<cr>a'
vnoremap <Tab> :call TabHotkey(1)<cr>:echo ""<cr>gv


" Untab
" For range, does not fix indentation of individual lines.
" Assumes indents are already divisible by 4
function! UnTabHotkey(with_range) range
    silent! norm mz

    " If no indentation, just exit
    if(indent('.') == 0)
        return 0
    endif

    " Get number of spaces past a clean multiple of 4
    let untab_amount = indent('.') % 4
    if(untab_amount == 0)
        let untab_amount = 4
    endif

    " Figure out how much to move the cursor
    let line_length = strwidth(getline('.'))
    let cursor_pos = col('.')
    if(cursor_pos >= (line_length - untab_amount))
    let cursor_move_amount = line_length - cursor_pos
    else
        let cursor_move_amount = untab_amount
    endif

    " Get current cursor position to know how far to move the cursor
    " Remove 'untab_amount' spaces
    if(a:with_range==0)
        silent! exe "s:^ \\{" . untab_amount . "\\}::"
    else
        silent! exe "'<,'>s:^ \\{" . untab_amount . "\\}::"
    endif

    " Move cursor to original location
    if cursor_move_amount > 0
        exe "norm `z" . cursor_move_amount . "h"
    else
        norm `z
    endif
endfunction!
nnoremap [Z :call UnTabHotkey(0)<cr>:echo ""<cr>
 " Warning; stupid. If after untabbing we would be on column 1,
 " Want to return to insert mode via 'i'. Otherwise, want 'a'
" inoremap <expr> [Z (col('.') <= 5) ?
    " \'<space><backspace>:call UnTabHotkey(0)<cr>:echo ""<cr>i':
    " \'<space><backspace>:call UnTabHotkey(0)<cr>:echo ""<cr>a'
vnoremap [Z :call UnTabHotkey(1)<cr>:echo ""<cr>gv


" Autoformat
function! Autoformat()
    let l:winview = winsaveview()
    filetype detect
    silent! norm mz

    " Find and remove all whitespace on empty lines
    let _s=@/
    :%s/\s\+$//e
    let @/=_s

    retab

    silent! norm `z
    call winrestview(l:winview)
endfunction!
nnoremap <F5> :call Autoformat()<cr>


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
    let file = expand('%:f')

    function! OpenCppOrC(file)
        " If there's a main.cpp, assume this is a cpp project
        if(filereadable(expand('%:h') . "/main.cpp"))
            exe "e " . a:file . ".cpp"
        else
            exe "e " . a:file . ".c"
        endif
    endfunction!

    " If opened a file with no extension (didn't enter 'c' or 'h' after tabbing), open .c
    if (file[len(expand('%:f'))-1] == ".")
        let file = file[0:len(file)-2]
        :call OpenCppOrC(file)
        return
    endif

    " Detect if header or c, then switch to respective
    let file = expand('%:r')
    if(&ft == 'ch')
        :call OpenCppOrC(file)
    elseif((&ft == 'c') || (&ft == 'cpp'))
        exe "e " . file . ".h"
    else
        " Not a c, cpp, h, or file ending in '.', so do nothing
    endif
endfunction!
nnoremap  :call SwitchToRespectiveFile()<cr>
inoremap  :call SwitchToRespectiveFile()<cr>


" From_uppercase == 1: convert CAPS_WITH_UNDERSCORES to CapsWithUnderscores
" From_uppercase == 0: convert caps_with_underscores to CapsWithUnderscores
function! ConvertCaps()
    " Get number of underscores
    let underscore_cnt = strlen(substitute(expand('<cword>'), "[^_]", "", "g"))

    " Select word and place cursor at beginning
    norm viwo

    " Loop to each underscore and convert CAPS to Caps; then delete underscore
    let i = 0
    while i < underscore_cnt
        let i += 1
        norm vt_~~hf_x"
    endwhile

    " Get last part
    norm lvwu

    " Place cursor at end of word
    norm e
endfunction!

" Auto-increments a selection of numbers in visual selection, e.g.:
" 0      0
" 0  ->  1
" 0      2
" TODO: multiple columns of numbers independently
" 0   0      0   0
" 0   0  ->  0   1
" 0   0      0   2
" FIXME: this is slow
function! LinearIncrement() range
    " Don't touch first line in selection
    let curr_line = getpos("'<")[1] + 1
    let last_line = getpos("'>")[1]

    let i = curr_line
    while i <= last_line
        " If a digit does not exist on this line, skip
        let col = match(getline(i), '\(\d\)')
        if col < 0
            continue
        endif

        " For all lines after this one, increment by 1
        let j = i
        while j <= last_line
            exe "norm! " . j . "G" . col . "|"
            let j += 1
        endwhile

        let i += 1
    endwhile
endfunction!

" Create a c program from the c template file
function! CreateC()
    " Place contents of template file
    0r ~/.vim/templates/c
endfunction!

" Create a penguin script from the penguin template file
function! CreatePenguin()
    " Place contents of template file
    0r ~/.vim/templates/penguin

    let filename_plus_ext = expand('%:t')
    let filename = expand('%:t:r')

    " Insert current date
    silent! exe "%s/templatetime/" . expand(strftime('%b %d, %Y')) . "/g"

    " Insert file name with extension
    silent! exe "%s/penguin_template.py/" . filename_plus_ext . "/g"

    " Insert file name without extension
    silent! exe "%s/PenguinTemplate/" . filename . "/g"

    " Find instances of file name that are *not* functions and convert to proper caps
    " Would use 'g' command but regex matching will match lines instead of the match
    " Itself when used in a function for some raisin (there are only 3 to replace)
    silent! exe "/" . filename . "\\(\\.\\)\\@!"
    norm wveU
    :call ConvertCaps()
    silent! exe "/" . filename . "\\(\\.\\)\\@!"
    norm wwveU
    :call ConvertCaps()
    silent! exe "/" . filename . "\\(\\.\\)\\@!"
    norm wveU
    :call ConvertCaps()

    " Move to first 'todo' string
    silent! norm /TODOzz
endfunction!
