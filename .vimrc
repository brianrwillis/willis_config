" NOTE: requires vim-gtk, ctags, and xclip to be installed!

" TODO; remap change/delete to put into the black hole register
"remap 'onoremap' for 'around' x
" TODO: something updates after a source

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

let ch_syntax_for_h = 1         " Header filetype is 'ch'

" Colors
set background=dark
let g:gruvbox_contrast_dark='hard'
colorscheme gruvbox

" Blinky cursor in insert mode
let &t_SI = "\<esc>[5 q"
let &t_SR = "\<esc>[5 q"
let &t_EI = "\<esc>[2 q"

" TODO: not in use
function! StatuslineGit()
  let l:branchname = system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

"TODO: add git stuff
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

" Ctrl-j = ESC and exit highlighted search
nnoremap <C-j> :silent! nohls<cr>:echo ""<cr>
vnoremap <C-j> :silent! nohls<cr>:echo ""<cr>
inoremap <C-j> :silent! nohls<cr>:echo ""<cr>
cnoremap <C-j> :silent! nohls<cr>:echo ""<cr>

" Don't force '#' to the first column
inoremap # X#

" I don't need ex mode
nnoremap Q <nop>

" Always allow 10 line spacing around 'n' and 'N' searches
" TODO: when no more matches, doesn't set so=0
nnoremap n :set so=10<cr>n:set so=0<cr>
nnoremap N :set so=10<cr>N:set so=0<cr>

" On ctag find, center screen
nnoremap  zz

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
vnoremap A :call SurroundWithChar()<cr>

" Don't overwrite clipboard text on paste over
xmap p pgvy

" Change places into black hole register
"TODO: fix quote
nnoremap ciw "_ciw
nnoremap ciW "_ciW
nnoremap cib "_cib
nnoremap ci[ "_ci[
nnoremap ci] "_ci]
nnoremap ci( "_ci(
nnoremap ci) "_ci)
nnoremap ci{ "_ci{
nnoremap ci} "_ci}
nnoremap ci\" "_ci\"
nnoremap ci' "_ci'

" When sourcing vimrc, first try and remove all settings
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
    if ((&ft == 'cpp') || (&ft == 'c') || (&ft == 'ch'))
        silent! !ctags -R . /opt/capella-msp430/msp430-elf/include/msp430fr5964.h &
    else
        silent! !ctags -R . &
    endif

    " Clear the screen
    norm 
endfunction!
noremap <F4> :call TagGen()<cr>


" If there's no uncommented lines, uncomment everything
" Else, comment everything
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

    if(symbol_cnt[1] == 'E')
        let symbol_cnt = 0
    else
        let symbol_cnt = symbol_cnt[1]
    endif

    if(a:with_range == 1)
        " Get number of total lines in selection
        redir => line_cnt
            silent! exe a:firstline . "," . a:lastline . "s/.//n"
        redir END
        let line_cnt = line_cnt[1]

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
" For range, does not fix indentation of individual lines.
" Assumes indents are already divisible by 4
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
inoremap <expr> <Tab> ((col('.') == 1) && !(getline('.') !~ '\S')) ?
        \'<space><backspace>:call TabHotkey(0)<cr>:echo ""<cr>i':
        \'<space><backspace>:call TabHotkey(0)<cr>:echo ""<cr>a'
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
inoremap <expr> [Z (col('.') <= 5) ?
    \'<space><backspace>:call UnTabHotkey(0)<cr>:echo ""<cr>i':
    \'<space><backspace>:call UnTabHotkey(0)<cr>:echo ""<cr>a'
vnoremap [Z :call UnTabHotkey(1)<cr>:echo ""<cr>gv


" Save all vim windows in tmux window. Compiles/Uploads on 'omake pane' if specified
" Warning: clears scrollback buffer on the terminal pane
" TODO: doesn't work when done on right pane
" TODO: omake clean && omake
function! SaveAllVim(action)
    let starting_pane = system("tmux list-panes | grep active")[0]
    let pane_cnt = system("tmux list-panes | wc -l")[0]

    " Set terminal pane where omake or omake copy will run
    " if(a:action != 0)
        " " TODO: improve this
        " " Assumes pane 1 is the terminal pane unless 5 panes are open
        " if(pane_cnt == 5)
            " let terminal_pane = 2
        " else
            " let terminal_pane = 1
        " endif
    " endif

    " Cycle through panes and save all vim windows
    let i = 0
    while i < pane_cnt
        " Select the pane
        silent! exe "!tmux select-pane -t " . i

        

        let i += 1
    endwhile

    " Cycle through panes and save all vim windows
    let i = 0
    while i < pane_cnt
        " Select the pane
        silent! exe "!tmux select-pane -t " . i

        " Is vim open in this pane?
        let is_vim = system(g:is_vim)[0]

        " :wa if vim is open in pane
        if(is_vim)
            silent! exe "!tmux send-keys \":wa\""
        endif

        " TODO: ismodififed to see if done saving

        let i += 1
    endwhile

    "TODO: find if buffer is saved (close the loop)
    call system("sleep 0.5")

    " Switch to terminal pane and see if it has vim open
    silent! exe "!tmux select-pane -t " . terminal_pane
    let is_vim = system(g:is_vim)[0]

    " If the terminal pane actually has vim open, don't try to omake on it
    if(!is_vim)
        " Clear the history buffer on terminal pane
        if(a:action != 0)
            silent! exe "!tmux select-pane -t " . terminal_pane
            silent! exe "!tmux send-keys -X cancel"
            silent! exe "!tmux send-keys \"clear\""
            silent! exe "!tmux clear-history"
        endif

        " Omake or omake copy if specified
        if(a:action == 1)
            silent! exe "!tmux send-keys \"omake\""
        elseif(a:action == 2)
            " Tries to get project name (parent_dir) and append _dev to it
            " Not super modular
            silent! exe "!tmux send-keys \"omake copy_" . expand('%:p:h:t') . "_dev\""
        endif
    endif

    " Go back to the pane this mess started from
    silent! exe "!tmux select-pane -t " . starting_pane

    " Refresh screen
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
" TODO: visual select area to change
" TODO: slow mode
" TODO: count number of changes and print at end
function! Autoformat()
    let l:winview = winsaveview()
    filetype detect
    silent! norm mz

    " Find and remove all whitespace on empty lines
    let _s=@/
    exe "%s:\\s\\+$::e"
    let @/=_s

    " If(x){ to if (x) {                                     >_>
    if((&ft == "c") || (&ft == "cpp") || (&ft == "ch"))
        silent! exe "%g/if(/exe \"norm f(i f{i \""
        silent! exe "%g/for(/exe \"norm f(i f{i \""
        silent! exe "%g/while(/exe \"norm f(i f{i \""
        silent! exe "%g/switch(/exe \"norm f(i f{i \""
    endif

    " Only one space until \ on multiline cpp
    if((&ft == "c") || (&ft == "cpp") || (&ft == "ch"))
        silent! %g/\\$/exe "norm f\\\bbf ldt\\\ "
    endif

    " Char=char to char = char
    " But leave stings of ==== untouched
    if(&ft != "vim")
        silent! %s/\(\w\|d\|\'\|\"\|\[\|\]\|(\|)\|{\|}\)=\(\w\|d\|\'\|\"\|\[\|\]\|(\|)\|{\|}\)/\1 = \2/g
        silent! %s/\(\w\|d\|\'\|\"\|\[\|\]\|(\|)\|{\|}\)==\(\w\|d\|\'\|\"\|\[\|\]\|(\|)\|{\|}\)/\1 == \2/g
    endif


    " Remove unused imports
    " Function to remove unused imports
    function! RemoveImport(import)
        " If we don't see a <library>.<something>, remove the import
        if(match(readfile(expand("%:p")), a:import.'\.') == -1)
            exe "g/" . a:import . "/exe \"norm \\\"_dd\""
            " Single global does not catch 2nd instances for some reason
            exe "g/" . a:import . "/exe \"norm \\\"_dd\""
        endif
    endfunction!

    " Removal
    if(&ft == "python")
        g/import \<\w\+\>/exe "norm $" | let import=expand('<cword>') |
                \ call RemoveImport(import)
    endif

    " Fix tabbies
    retab

    silent! norm `z
    call winrestview(l:winview)
endfunction!
nnoremap <F5> :call Autoformat()<cr>

" Convert every comment to '# Comment' not '#comment'
function! FixComments()
    filetype detect
    " Get comment symbol per filetype
    if(&ft == "vim")
        let symbol = "\""
    elseif((&ft == "c") || (&ft == "cpp") || (&ft == "ch"))
        let symbol = "\\/\\/"
    elseif(&ft == "python")
        let symbol = "#"
    else
        let symbol = "NONE"
    endif

    " Maybe wise to do nothing if filetype not explicitly accounted for
    if(symbol != "NONE")
        " Add space
        silent! exe "%s/^\\(\\s*\\)" . symbol . "\\(\\S\\)/\\1" . symbol . " \\2/g"
        " Caps
        silent! exe "%s/^\\(\\s*\\)" . symbol . " \\(\\w\\)/\\1" . symbol . " \\u\\2/g"
    endif
endfunction!


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
" FIXME: does not work for TEST_P_THING (single char inbetween underscores)
function! CapsConvert(from_uppercase)
    " Always start with CAPS_WITH_UNDERSCORES
    if(a:from_uppercase == 0)
        norm viw~
    endif

    " Get number of underscores
    let underscore_cnt = strlen(substitute(expand('<cword>'), "[^_]", "", "g"))

    " Select word and place cursor at beginning
    norm viwo

    " Loop to each underscore and convert CAPS to Caps; then delete underscore
    let i = 0
    while i < underscore_cnt
        let i += 1
        norm lvt_uf_x"
    endwhile

    " Get last part
    norm lvwu

    " Place cursor at end of word
    norm e
endfunction!
noremap  :call CapsConvert(1)<cr>:echo ""<cr>

" Auto-increments a selection of numbers in visual selection, e.g.:
" 0      0
" 0  ->  1
" 0      2
function! LinearIncrement() range
    " Don't touch first line in selection
    let curr_line = getpos("'<")[1] + 1
    let last_line = getpos("'>")[1]

    let i = curr_line
    while i <= last_line
        " If a digit does not exist on this line, skip
        let num = match(getline(i), '\(\d\)')
        if num < 0
            continue
        endif

        " For all lines after this one, increment by 1
        let j = i
        while j <= last_line
            exe "norm! " . j . "G" . num . "|"
            let j += 1
        endwhile

        let i += 1
    endwhile
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
    norm w
    :call CapsConvert(0)
    silent! exe "/" . filename . "\\(\\.\\)\\@!"
    norm ww
    :call CapsConvert(0)
    silent! exe "/" . filename . "\\(\\.\\)\\@!"
    norm w
    :call CapsConvert(0)

    " Move to first 'todo' string
    silent! norm /TODOzz
endfunction!

" Not in use yet
function! TypeOfChar()
    return join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'))
endfunction!

