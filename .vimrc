" NOTE: requires vim to be compiled with +clipboard
" (or install vim-gtk), and ctags + xclip to be installed!

" TODO; remap change/delete to put into th black hole register
"remap 'onoremap' for 'around' x
" TODO: something updates after a source
" TODO: tab = ctrl-p in insert
" if in insert, still actually tab is no chars before cursor
" maybe not

"TODO: increase paths, no path=**


" Useful commands
" Loop through lines and do an operation based off conditional (e.g., pad lines up to a float ratio)
" let g:i = 0
" let g:i = g:i + 1 | let diff = 1163.0/445.0 | if (g:i < diff) | exe "norm yyp" | else | exe "norm j" | let g:i = g:i - diff | endif

" Do math on numbers in file (e.g., floats mutliply by 2)
" s/\(-*\d.*,\@<!\)/\=str2float(submatch(0))*2

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
set display=lastline            " Show partial word-wrapped lines
set showtabline=2               " Always show tabs, even if only one file is open

set nofixendofline              " Don't autoappend a newline when saving a file

let ch_syntax_for_h=1           " Header filetype is 'ch'

" Colors
set background=dark
let g:gruvbox_contrast_dark='hard'
colorscheme gruvbox

" Dont highlight underscores on markdown files
:hi link markdownError Normal

" Force transparent background first here
" highlight Normal guibg=NONE ctermbg=NONE
" highlight NonText guibg=NONE ctermbg=NONE

" Force transparent background again on buf open
" FIXME: figure out what in gruvbox is fucking with this
" autocmd BufEnter * highlight Normal guibg=NONE ctermbg=NONE
" autocmd BufEnter * highlight NonText guibg=NONE ctermbg=NONE

" Set scroll (Ctrl-U/D)
" FIXME: something is changing this randomly but :verbose only lists this line as
"        affecting the setting, use CursorMoved to force on
autocmd BufEnter,CursorMoved * let &scroll=min([15, winheight(0) / 3])

" Set scroll offset to seventh of a page
" autocmd BufEnter,CursorMoved * let &scrolloff=min([15, winheight(0) / 7])

" Force the cursor to cmd mode on entering vim
autocmd VimEnter * norm! 

" Open to last position
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Force syntax on buf open
autocmd VimEnter * syntax enable

" Preserve clipboard on exit, requires xclip on system
autocmd VimLeave * call system("xclip -selection clipboard -i", getreg('+'))

" Auto-close the quickfix file created by `copen` after hitting enter 
" (and set cursorline, center screen)
autocmd FileType qf nnoremap <buffer> <cr> <cr>:cclose<cr>zz

" Hitting Ctrl-L while in quickfix file will open file under cursor 
" (and set cursorline, center screen)
autocmd FileType qf nnoremap <buffer>  <cr>zzj

" Ctrl-L: quickfix implementation for the word under the cursor
nnoremap  :grep! "\<<cword>\>" `find -type f \( -name "*.c" -o -name "*.h" -o -name "*.py" \)`<cr>:copen<cr>
" In visual mode, use the visually selected (use `"` reg)
vnoremap  ""y:grep! "<C-R>=escape(@",'/\')<cr>" `find -type f \( -name "*.c" -o -name "*.h" -o -name "*.py" \)`<cr>:copen<cr>

" `//` and `??` in visual mode: search for visual selection (use `"` reg)
vnoremap // ""y/\V<C-R>=escape(@",'/\')<cr><cr>
vnoremap ?? ""y?\V<C-R>=escape(@",'/\')<cr><cr>

" Blinky cursor in insert mode
let &t_SI = "\<esc>[5 q"
let &t_SR = "\<esc>[5 q"
let &t_EI = "\<esc>[2 q"

" Set statusline stuff
set statusline=%F\ %m%r                        " name_of_file_tail [+][RO]
set statusline+=%=                             " start right-aligning
set statusline+=\ alt:\ %{expand('#:t')}\ \    " alternate_file_tail
set statusline+=[%l,\ %c]\ %p%%                " [line, col] file%

" Highlighting searches
set hlsearch
set incsearch

" Don't highlight shit on source vimrc wtf
:nohls

" Always copy yank to clipboard
" nnoremap y "*y:call system("xclip -selection clipboard -i", getreg('*'))<cr>
" vnoremap y "*y:call system("xclip -selection clipboard -i", getreg('*'))<cr>

" Ctrl-H -> open new tab with file list of current dir
" Ctrl-G -> open current tab with file list of current dir
nnoremap  :tabe %:h/
nnoremap  :e %:h/

" fucksake
nnoremap tg gt
nnoremap Tg gT

" Ctrl-j = ESC and exit highlighted search, turn off cursorline
nnoremap <C-j> :silent! nohls<cr>:echo ""<cr>
vnoremap <C-j> :silent! nohls<cr>:echo ""<cr>
inoremap <C-j> :silent! nohls<cr>:echo ""<cr>
cnoremap <C-j> :silent! nohls<cr>:echo ""<cr>

" Don't force '#' to the first column
inoremap # X#

" Don't let '[' do anything in visual mode
vnoremap [ <nop>

" Remove K functionality
nnoremap K <nop>
vnoremap K <nop>

" Make D/C delete without overwriting reg
nnoremap D "_d
vnoremap D "_d
nnoremap DD "_dd
nnoremap C "_c
vnoremap C "_c
nnoremap CC "_cc

" cc = change to first char
nnoremap cc $v^"_c

" Disable command history
" FIXME: why does this work intermittently?
nnoremap q: <nop>
nnoremap Q <nop>

" Don't jump on first match
nnoremap # :keepjumps normal! mz#`z<cr>
nnoremap * :keepjumps normal! mz*`z<cr>


" Center screen on search results, ctag jump, Ctrl-o
nnoremap n nzz
nnoremap N Nzz
nnoremap  zz


" Center screen on ctag jumps
nnoremap  zz
nnoremap  zz

" Ctrl-\ = open this tag in a new tab
function! CtagJumpNewTab()
    let file = expand('%')
    exe ":tabnew " . file
    norm 
    let new_file = expand('%')

    if new_file == file
        " There was no match
        :q!
    endif
endfunction!
nnoremap  :call CtagJumpNewTab()<cr>zz


" Previous in jump list (remap Ctrl-I)
nnoremap  <C-I>zz

" Ctrl-n = jump to next c function
" FIXME
" nnoremap  /^\(u\{0,1\}int\d*\)\\|^void\\|^\S*_t
" nnoremap  /^\S\+.*(zz


" Don't overwrite clipboard with cuts
" TODO: WORDs dont work?
" nnoremap cw "_cw
" nnoremap cW "_cW
" nnoremap ciw "_ciw
" nnoremap ciW "_ciW
" nnoremap cb "_cb
" nnoremap cB "_cB
" xnoremap c "_c

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
    exe "norm gv\"zygv\"_c" . firstc . "\"zpa" . lastc
endfunction!
vnoremap S :call SurroundWithChar()<cr>

" Don't overwrite clipboard text on paste over
xmap p pgvy

" When sourcing vimrc, first try and remove all settings
command! So mapc | set all& | so ~/.vimrc | :filetype detect
command! SO mapc | set all& | so ~/.vimrc | :filetype detect

" FIXME
function! Suds()
    exe "norm :w !sudo tee %"
endfunction!


" On file save, make sure the last revision actually says today.
" Assumes text 'Last Rev' is in first 20 lines.
" Doesn't change the date if it's already correct so undo doesn't get messed up.
function! OnSave()
    let l:winview = winsaveview()
    silent! norm mz

    if(&modified)
        " Keep the current search item
        let search = @/

        let current_date=strftime('%b %d, %Y')
        silent! 0,20g/Last Rev/exe "norm /RevWv$h\"zy"
        if(current_date != getreg('z'))
            silent! 0,20g/Last Rev/exe "norm /RevW\"_d$a" . current_date
        endif
        silent! 0,20g/By\: /exe "norm /ByWv$h\"zy"
        if(getreg('z')!="Brian Willis")
            silent! 0,20g/By\: /exe "norm /ByW\"_d$aBrian Willis"
        endif

        " Restore search item
        let @/ = search
    endif

    " Restore position
    silent! :keepjumps normal! `z
    call winrestview(l:winview)
endfunction!
autocmd BufWritePre,FileWritePre * :call OnSave()


" Create parent dirs if not exist on file save
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) |
            \ execute "silent! !mkdir -p ".shellescape(expand('%:h'), 1) | redraw! | endif
augroup END


" :E to destroy all swp files and reload all open buffers
function! ReloadAll()
    let l:winview = winsaveview()
    let file = expand('%:f')

    " Destroy all swp files
    :call system("rm -rf `find . -type f -name \"*.sw*\"`")

    " Reload all, will as for conf
    :set autoread
    :checktime

    " Restore position
    silent! exe "e! " . file
    call winrestview(l:winview)

    :set noautoread

    :echo "Done reloading files"
endfunction!
command! E :call ReloadAll()


" Generate a tags file at the current directory. If a c program, includes the msp430 PAL
function! TagGen()
    :filetype detect
    silent! :call system("rm tags")

    if ((&ft == 'c') || (&ft == 'ch'))
        " silent! !ctags --c-kinds=+p -R . /opt/capella-msp430/msp430-elf/include/msp430fr5964.h 2>/dev/null &
        silent! !ctags -R . /opt/capella-msp430/msp430-elf/include/msp430fr5964.h 2>/dev/null &
    else
        silent! !ctags -R . 2>/dev/null &
    endif

    " Clear the screen
    redraw!

    echo "Done generating tags"
endfunction!
noremap <F4> :call TagGen()<cr>


" Close all non-active buffers
function! CloseNonActive()
    :redir @z
    :silent! buffers!
    :redir END
    let buffers = split(@z, '\n')
    for b in buffers
        let b = split(b, " ")
        " if 'a' is in cols 1 or 2, it's active and we don't want to close it
        if ((stridx(b[1], "a") == -1) && (stridx(b[2], "a") == -1))
            let ix = substitute(b[0], "u", "", "")
            exe "bw! " . ix
        endif
    endfor
endfunction!


" If there's no uncommented lines, uncomment everything
" else, comment everything
" TODO: single line comment after a return and auto indent puts cursor back (visual too)
function! CommentHotkey(with_range) range
    let l:winview = winsaveview()
    silent! norm mz
    :filetype detect

    " Get comment symbol per filetype
    if (&ft == 'vim')
        let symbol = "\""
    elseif((&ft == 'c') || (&ft == 'cpp') || (&ft == 'ch') || (&ft == 'rust'))
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
            let comment = 1
         else
            " Remove comments
            silent! exe a:firstline . "," . a:lastline . "s:" . symbol . " ::"
            silent! exe a:firstline . "," . a:lastline . "s:^" . symbol . "::"
            let comment = 0
        endif
    else
        " Add/remove comment symbol
        if(symbol_cnt == 0)
            " Insert comment
            exe a:firstline . "," . a:lastline . "norm I" . symbol . " "
            let comment = 1
        else
            " Remove comments
            silent! exe a:firstline . "," . a:lastline . "s:" . symbol . " ::"
            silent! exe a:firstline . "," . a:lastline . "s:^" . symbol . "::"
            let comment = 0
        endif
     endif

    " Restore position
    silent! norm `z
    call winrestview(l:winview)

    if (symbol == "\/\/")
        let move_cnt = 3
    else
        let move_cnt = 2
    endif

    if (comment)
        exe "norm " . move_cnt . "l"
    else
        exe "norm " . move_cnt . "h"
    endif
endfunction!
nnoremap  :call CommentHotkey(0)<cr>
inoremap  :call CommentHotkey(0)<cr>a
vnoremap  :call CommentHotkey(1)<cr>


" Tab for completion
" just do if no text before cursor, do tab
" function! ParseTab()
    " " Move us back to where we were
    " startinsert
    " let p = getpos('.')
    " let p[2] = p[2] + 1
    " :call setpos('.', p)
"
    " " Are we on the first col or is the char under the cursor a space
    " if ((col('.') == 1) || (matchstr(getline('.'), '\%' . col('.') . 'c.') == ' '))
        " " For some reason, we need to use 'a' if the line is only whitespaces
        " if ((col('.') == 1) && !(getline('.') !~ '\S'))
            " norm <space><backspace>:call TabHotkey(0)<cr>:echo ""<cr>i
            " echo "HEYO"
        " else
            " norm :call TabHotkey(0)
            " norm l
            " startinsert
        " endif
    " else
        " norm l
        " startinsert
        " :call feedkeys("")
    " endif
" endfunction!
" inoremap <tab> :call ParseTab()<cr>
" inoremap <S-tab> <C-N>

" Tab for completion
" TODO: just do if no text before cursor, do tab
inoremap <tab> <C-P>
inoremap <S-tab> <C-N>

" Tab
" For range, does not fix indentation of individual lines
function! TabHotkey(with_range) range
    silent! norm mz

    " Get number of spaces until a clean multiple of 4
    if(a:with_range==1)
        " Use the first line in selection to control the tab amount
        let tab_amount = 4 - indent("'<") % 4
    else
        let tab_amount = 4 - indent(".") % 4
    endif

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
" For range, does not fix indentation of individual lines
function! UnTabHotkey(with_range) range
    silent! norm mz

    if(a:with_range==1)
        " Use the first line in selection to control the tab amount
        let marker = "'<'"
    else
        let marker = "."
    endif

    " If no indentation, just exit
    if(indent(marker) == 0)
        return 0
    endif

    " Get number of spaces past a clean multiple of 4
    let untab_amount = indent(marker) % 4

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
    filetype detect
    let l:winview = winsaveview()
    silent! norm mz

    if (((&ft == 'ch') || (&ft == 'c') || (&ft == 'cpp')) && filereadable(".clang-format"))
        " Use clang
        :%!clang-format
    else
        " Find and remove all whitespace on empty lines
        let _s=@/
        :%s/\s\+$//e
        let @/=_s
        retab
    endif

    silent! norm `z
    call winrestview(l:winview)
endfunction!
nnoremap <F5> :call Autoformat()<cr>


" Insert include guard on header file
function! IncludeGuard()
    let filename = expand('%:t')
    exe "norm ggi#ifndef __" . filename . "__#define __" . filename . "__"
    exe "norm Go#endif //__" . filename . "__"
    exe "1,2norm Wv$U:s/\\./_/g"
    exe "norm GWv$U:s/\\./_/g"
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
    " Unless this is a CHANGELOG
    if (file[len(expand('%:f'))-1] == ".")
        let file = file[0:len(file)-2]
        if stridx("CHANGELOG", file) >= 0
            exe "e " . file . "." . expand('%:p:h:t') . ".md"
        else
            :call OpenCppOrC(file)
        endif
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


" `gf` but look in more places
" function! BetterGf()
" 
" endfunction!
" nnoremap gf :call BetterGf()<cr>


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
" FIXME: does not work if there is a newline between entries
function! LinearIncrement() range
    " Don't touch first line in selection
    let curr_line = getpos("'<")[1] + 1
    let last_line = getpos("'>")[1]
    let col = getpos("'>")[2]

    let i = curr_line
    while i <= last_line
        " If a digit does not exist on this line, skip
        if match(getline(i), '\(\d\)') < 0
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


" Loop through macro and align all '\'s
function! AlignSlashes() range
    let l:winview = winsaveview()
    let max_len = 0

    let curr_line = getpos("'<")[1]
    let last_line = getpos("'>")[1]

    " Remove all trailing '\'s
    let _s=@/
    silent! :'<,'>s/\\\s*$//g
    let @/=_s

    " Remove all whitespace on empty lines
    let _s=@/
    silent! :%s/\s\+$//e
    let @/=_s

    " Find max line length
    let i = curr_line
    while i <= last_line
        let len = strwidth(getline(i))
        if (len > max_len)
            let max_len = len
        endif
        let i = i + 1
    endwhile

    " Loop again, adding '\'s
    let i = curr_line
    while i <= last_line
        " If a digit does not exist on this line, skip
        let len = strwidth(getline(i))
        let spaces = max_len - len + 1
        exe "norm " . i . "G" . spaces . "A A\\j"
        let i = i + 1
    endwhile

    call winrestview(l:winview)
endfunction!

" Make status checker in c (CFE)
function! PlaceStatusChecker()
    norm Aif (status != CFE_SUCCESS) {return status;}
endfunction!
nnoremap  :call PlaceStatusChecker()<cr>

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
