" NOTE: requires vim to be compiled with +clipboard
" (or install vim-gtk), and ctags + xclip to be installed!

" TODO; remap change/delete to put into th black hole register
"remap 'onoremap' for 'around' x
" TODO: something updates after a source
" TODO: tab = ctrl-p in insert
" if in insert, still actually tab is no chars before cursor
" maybe not

"TODO: increase paths, no path=**

" set path+=**
" function! GfInNewTab()
    " norm :tabnew %<cr>
    " norm 
    " norm gf
" endfunction!
" nnoremap gF :call GfInNewTab()<cr>


" ### Useful commands ###
" Loop through lines and do an operation based off conditional (e.g., pad lines up to a float ratio)
" let g:i = 0
" let g:i = g:i + 1 | let diff = 1163.0/445.0 | if (g:i < diff) | exe "norm yyp" | else | exe "norm j" | let g:i = g:i - diff | endif

" Do math on numbers in file (e.g., floats mutliply by 2)
" s/\(-*\d.*,\@<!\)/\=str2float(submatch(0))*2
" #######################

set undofile                    " Nonvolatile undo
set undodir=~/.vim/undodir

set laststatus=2                " Always display statusline
set wildmode=list:longest       " Tab-complete
set smartindent                 " Indent... smart-ish
set mouse=a                     " New-school
set clipboard=unnamedplus       " Combine system and vim clipboards
set timeoutlen=175              " 175 ms delays on hotkeys
set ttimeoutlen=175
set cmdheight=2                 " Less 'Press enter to continue' on cmd line
set backspace=indent,eol,start  " Fix backspacing after a newline
set display=lastline            " Show partial word-wrapped lines
set showtabline=2               " Always show tabs, even if only one file is open
set nofixendofline              " Don't autoappend a newline when saving a file
set number                      " Number lines
set hidden                      " Fix windowing
set expandtab                   " Insert spaces, not a tab, when tabbing

" Set tab size for different filetypes
" default
set tabstop=4                   
set shiftwidth=4
augroup FileTypeSpecificAutocommands
    autocmd FileType yaml setlocal tabstop=2 shiftwidth=2
augroup END

" Colors
set background=dark
let g:gruvbox_contrast_dark='hard'
colorscheme gruvbox
filetype detect

" Set scroll (Ctrl-U/D)
autocmd BufEnter,CursorMoved * let &scroll=min([15, winheight(0) / 3])

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
" FIXME: can't get spaces in names to work.  -printf '"\%p" ' after `find` is insufficient
" FIXME: also this muddies stdout (after exiting vim)
" Highlight first with `*`
nnoremap  *:grep! "\<<cword>\>" `find -type f \( -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.py" -o -name "*.cs" \)`<cr>:copen 15<cr>
" In visual mode, use the visually selected (use `"` reg)
" Highlight first with searching for `"` register contents
vnoremap  ""y/\V<C-R>=escape(@",'/\')<cr><cr>:grep! "<C-R>=escape(@",'/\')<cr>" `find -type f \( -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.py" -o -name "*.cs" \)`<cr>:copen 15<cr>

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
" FIXME: dont like this
" nnoremap cc $v^"_c

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
    " Get our current position and current file
    let pos = getpos('.')
    let file = expand('%')

    " Open a new tab
    exe ":tabnew " . file

    " Move to our old position, then execute the ctag jump
    call setpos('.', pos)
    norm 

    let new_file = expand('%')
    let new_pos = getpos('.')

    if ((new_file == file) && (new_pos[1] == pos[1]))
        " We're in the same file at the same row: no jump, close this file
        :q!
    endif
endfunction!
nnoremap  :call CtagJumpNewTab()<cr>zz


" Ctrl-B = duplicate this buffer in a new tab
function! DupeBufferNewTab()
    " Get our current position, current file, and current window position
    let pos = getpos('.')
    let file = expand('%')
    let l:winview = winsaveview()

    " Open a new tab
    exe ":tabnew " . file

    " Move to our old position
    call winrestview(l:winview)
    call setpos('.', pos)

    echom "Duplicated Buffer"
endfunction!
nnoremap  :call DupeBufferNewTab()<cr>


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
    if (c == '(' || c == ')')
        let firstc = '('
        let lastc = ')'
    elseif (c == '{' || c == '}')
        let firstc = '{'
        let lastc = '}'
    elseif (c == '[' || c == ']')
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

    if (&modified)
        " Keep the current search item
        let search = @/

        let current_date=strftime('%b %d, %Y')
        silent! 0,20g/Last Rev/exe "norm /RevWv$h\"zy"
        if (current_date != getreg('z'))
            silent! 0,20g/Last Rev/exe "norm /RevW\"_d$a" . current_date
        endif
        silent! 0,20g/By\: /exe "norm /ByWv$h\"zy"
        if (getreg('z')!="Brian Willis")
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


" Generate a tags file at the current directory
function! TagGen()
    silent! :call system("rm tags")

    silent! !ctags -R . 2>/dev/null &

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
    let ft = expand('%:e')
    :filetype detect

    " Get comment symbol per filetype (use builtin &ft for extensionless vimrc)
    if (&ft == 'vim')
        let symbol = "\""
    elseif ((ft == 'c') || (ft == 'cpp') || (ft == 'h') || (ft == 'hpp') || (ft == 'rust') || (ft == 'ld') || (ft == 'cs'))
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

    if (symbol_cnt == 'Error')
        let symbol_cnt = 0
    endif

    if (a:with_range == 1)
        " Get number of total lines in selection
        let line_cnt = a:lastline - a:firstline + 1

        " Add/remove comment symbols
        if (symbol_cnt != line_cnt)
            " Insert comment
            exe a:firstline . "," . a:lastline . "norm I" . symbol . " "
            let comment = 1
         else
            " Remove comments
            silent! exe a:firstline . "," . a:lastline . "s:" . symbol . " ::"
            let comment = 0
        endif
    else
        " Add/remove comment symbol
        if (symbol_cnt == 0)
            " Insert comment
            exe a:firstline . "," . a:lastline . "norm I" . symbol . " "
            let comment = 1
        else
            " Remove comments
            silent! exe a:firstline . "," . a:lastline . "s:" . symbol . " ::"
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

    " Get number of spaces until a clean multiple of &tabstop
    if (a:with_range==1)
        " Use the first line in selection to control the tab amount
        let tab_amount = &tabstop - indent("'<") % &tabstop
    else
        let tab_amount = &tabstop - indent(".") % &tabstop
    endif

    " If already aligned, tab over &tabstop
    if (tab_amount == 0)
        let tab_amount = &tabstop
    endif

    " Tab
    if (a:with_range==0)
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

    if (a:with_range==1)
        " Use the first line in selection to control the tab amount
        let marker = "'<'"
    else
        let marker = "."
    endif

    " If no indentation, just exit
    if (indent(marker) == 0)
        return 0
    endif

    " Get number of spaces past a clean multiple of &tabstop
    let untab_amount = indent(marker) % &tabstop

    if (untab_amount == 0)
        let untab_amount = &tabstop
    endif

    " Figure out how much to move the cursor
    let line_length = strwidth(getline('.'))
    let cursor_pos = col('.')
    if (cursor_pos >= (line_length - untab_amount))
    let cursor_move_amount = line_length - cursor_pos
    else
        let cursor_move_amount = untab_amount
    endif

    " Get current cursor position to know how far to move the cursor
    " Remove 'untab_amount' spaces
    if (a:with_range==0)
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
    let ft = expand('%:e')
    let pos = getpos('.')
    let l:winview = winsaveview()

    if (((ft == 'h') || (ft == 'c') || (ft == 'cpp') || (ft == 'hpp')) && filereadable(".clang-format"))
        " Use clang-format
        :%!clang-format
        echom "Applied clang-format"
    else
        " Find and remove all whitespace on empty lines
        let _s=@/
        :%s/\s\+$//e
        let @/=_s
        " Retab only if not a Makefile
        if !((expand('%:t') == "Makefile") || (expand('%:p') == "mk"))
            retab
        endif
    endif

    " Move to our old position
    call winrestview(l:winview)
    call setpos('.', pos)
endfunction!
nnoremap <F5> :call Autoformat()<cr>


" Workaround for WSL: quick substitute away all s
function! FixWindowsEOL()
    :%s/$//g
endfunction!
nnoremap <F6> :call FixWindowsEOL()<cr>


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
    let ft = expand('%:e')
    let file = expand('%:f')

    function! OpenCppOrC(file)
        " If there's any *.cpp, assume this is a cpp project
        if (len(glob(expand('%:h') . "/*.cpp")))
            exe "e " . a:file . ".cpp"
        else
            exe "e " . a:file . ".c"
        endif
    endfunction!

    function! OpenHppOrH(file)
        " If there's any *.cpp, assume this is a cpp project
        if (len(glob(expand('%:h') . "/*.cpp")))
            exe "e " . a:file . ".hpp"
        else
            exe "e " . a:file . ".h"
        endif
    endfunction!

    " If opened a file with no extension (didn't enter 'c' or 'h' after tabbing), open .c/.cpp
    " Unless this is a CHANGELOG
    if (file[len(expand('%:f')) - 1] == ".")
        let file = file[0:len(file) - 2]
        if (stridx("CHANGELOG", file) >= 0)
            exe "e " . file . "." . expand('%:p:h:t') . ".md"
        else
            :call OpenCppOrC(file)
        endif
        return
    endif

    " Detect if header or source, then switch to respective file
    let file = expand('%:r')
    if ((ft == 'h') || (ft == 'hpp'))
        :call OpenCppOrC(file)
    elseif ((ft == 'c') || (ft == 'cpp'))
        :call OpenHppOrH(file)
    else
        " Not a c, cpp, h, hpp, or file ending in '.', so do nothing
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

" Make status checker in c
function! PlaceStatusChecker()
    norm Aif (status != 0) {return status;}
endfunction!
nnoremap  :call PlaceStatusChecker()<cr>

" Create a c program from the c template file
function! CreateC()
    " Place contents of template file
    0r ~/.vim/templates/c
endfunction!
