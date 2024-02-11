" Ctrl-K: quickfix implementation of grepping the word under the cursor/visual selection
function! QuickfixSearch(normal_mode)
    if a:normal_mode
        " Use word under cursor
        let word = expand('<cword>')
    else
        " Use 'z' reg to grab visual selection
        norm gv"zy
        let word = getreg("z")
    endif

    " Set search term (use the search pattern register directly, `set hls` must be executed after function exits)
    let @/ = word
    exe "norm /\<cr>``"
    
    " List of files to search
    let files = system('find -type f \( -name "*.cpp"
                                   \ -o -name "*.c"
                                   \ -o -name "*.h"
                                   \ -o -name "*.hpp"
                                   \ -o -name "*.py" \) | tr "\n" " "')
    
    " Find matches of word under cursor
    if a:normal_mode
        silent! exe 'grep! "' . word . '" -w ' . files
    else
        silent! exe 'grep! "' . word . '" ' . files
    endif
    
    " Open quickfix list of results with 15 rows
    copen 15
endfunction!
nnoremap  :call QuickfixSearch(1)<cr>:set hls<cr>
vnoremap  :call QuickfixSearch(0)<cr>:set hls<cr>

" Ctrl-K while in quickfix -> open file under cursor, center the screen, and go back to quickfix
" Enter while in quickfix -> open file under cursor, close quickfix, and center the screen
" Ctrl-\ while in quickfix -> open file under cursor in new tab, closing the original quickfix 
autocmd FileType qf nnoremap <buffer>  <cr>zzj
autocmd FileType qf nnoremap <buffer> <cr> <cr>:cclose<cr>zz
autocmd FileType qf nnoremap <buffer>  <cr>j:cclose<cr>T


" Ctrl-\ -> Open ctag jump in a new tab, or switch tabs if already open
" function! CtagJumpNewTab()
"     " Dupe buffer
"     " Jump to definition
"     " Cache filename
"     " Close tab
"     " Drop into filename
"         " does not work for a not-drop, does not remember tag stack
"         " we must work in the buffer that we invoked the jump in...
"         " or cache the tag stack?
" endfunction!
" noremap  :call CtagJumpNewTab<cr>


" :E -> destroy all swp files and reload all open buffers
function! ReloadAll()
    let l:winview = winsaveview()
    let file = expand('%:f')

    " Destroy all swp files
    call system("rm `find . -type f -name \"*.sw*\"`")

    " Reload all
    set autoread
    checktime

    " Restore position
    silent! exe "e! " . file
    call winrestview(l:winview)

    set noautoread

    echo "Done reloading files"
endfunction!
command! E :call ReloadAll()


" :C -> copy this file's absolute path to the clipboard
function! CopyFileNameToClipboard()
    if !executable('xclip')
        echo "xclip not installed!"
        return
    endif

    let file = simplify(expand("%:p"))
    call system("echo " . file . " | xclip -selection clipboard")

    echo 'Copied "' . file . '" to clipboard'
endfunction!
command! C :call CopyFileNameToClipboard()


" F3 -> remove this swap file
function! RemoveSwap()
    call system("rm " . expand("%:h") . "/." . expand("%:t") . ".sw?")

    " FIXME: Put back in call to remove all swaps?
    " call system("rm `find -name '*.sw?'`")

    echo "Swap file fucked"
endfunction!
noremap <F3> :call RemoveSwap()<cr>


" F4 -> generate a tags file at the current directory
function! TagGen()
    silent! !rm tags

    if !executable('ctags')
        echo "ctags not installed!"
        return
    endif

    silent! !ctags -R --languages=c,c++,python . 2>/dev/null

    " Clear the screen
    redraw!

    echo "Done generating tags"
endfunction!
noremap <F4> :call TagGen()<cr>


" Close all non-active buffers
function! CloseNonActive()
    redir @z
    silent! buffers
    redir END
    let buffers = split(@z, '\n')

    for b in buffers
        let b = split(b, " ")

        " If 'a' is in cols 1 or 2, it's active and we don't want to close it
        if ((stridx(b[1], "a") == -1) && (stridx(b[2], "a") == -1))
            let ix = substitute(b[0], "u", "", "")
            exe "bw! " . ix
        endif
    endfor
endfunction!


" F5 -> autoformat
function! Autoformat()
    let ft = expand('%:e')
    let pos = getpos('.')
    let search = @/

    let is_c = ((ft == 'h') || (ft == 'c') || (ft == 'cpp') || (ft == 'hpp'))

    if (is_c && filereadable(".clang-format"))
        " Use clang-format
        :%!clang-format
        echom "Applied clang-format"
    else
        " Find and remove all whitespace on empty lines
        :%s/\s\+$//e

        " Retab only if not a Makefile (easier to use &ft here)
        if (&ft != "make")
            retab
        endif
    endif

    let @/ = search
    call setpos('.', pos)
endfunction!
nnoremap <F5> :call Autoformat()<cr>


" Insert include guard on header file
function! IncludeGuard()
    let filename = expand('%:t')
    let pos = getpos('.')
    let search = @/

    exe "norm ggO#ifndef __" . filename . "__#define __" . filename . "__"
    exe "norm Go#endif //__" . filename . "__"
    exe "1,2norm Wv$U:s/\\./_/g"
    exe "norm GWv$U:s/\\./_/g"

    let @/ = search
    call setpos('.', pos)
    echo
endfunction!


" Ctrl-F -> go to respective .h/.c file; create if non-existent
function! SwapToRespectiveFile()
    let ft = expand('%:e')
    let file_dir = expand('%:h')
    let file_name = expand('%:t')
    let file_name_no_ft = expand('%:t:r')

    " Special swaps:
    " * Between .bashrc and .bash_aliases
    " * Between rc.lua and funs.vim
    if (stridx(".bashrc", file_name) >= 0)
        exe "e ~/.bash_aliases"
        return
    elseif (stridx(".bash_aliases", file_name) >= 0)
        exe "e ~/.bashrc"
        return
    elseif (stridx("rc.lua", file_name) >= 0)
        exe "e ~/.config/nvim/after/plugin/funs.vim"
        return
    elseif (stridx("funs.vim", file_name) >= 0)
        exe "e ~/.config/nvim/after/plugin/rc.lua"
        return
    endif

    " If there's any *.cpp or *.hpp, assume this is a cpp project
    let cpp_proj = system('find \( -name "*.cpp" -o -name "*.hpp" \) | wc -l')

    " Detect if header or source, then switch to respective file
    " If opened a file with no extension (didn't enter 'c' or 'h' after tabbing), open .c/.cpp
    if ((ft == 'h') || (ft == 'hpp') || (matchstr(file_name, '.$') == "."))
        if (cpp_proj)
            let file_name_to_open = file_name_no_ft . ".cpp"
        else
            let file_name_to_open = file_name_no_ft . ".c"
        endif
    elseif ((ft == 'c') || (ft == 'cpp'))
        if (cpp_proj)
            let file_name_to_open = file_name_no_ft . ".hpp"
        else
            let file_name_to_open = file_name_no_ft . ".h"
        endif
    else
        " Not a .c, .cpp, .h, .hpp, or file ending in '.', so do nothing
        echo "Nothing to do"
        return
    endif

    " First check if the file exists already at the current dir or up/down one dir
    let file_path_to_open = system("find " . file_dir . "/.. -name " . file_name_to_open . " | head -n 1")

    " v:shell_error isn't populating, just search for the error string
    if (stridx(file_path_to_open, "No such file or directory") != -1)
        echo file_dir . " not found"
        return
    endif

    " Remove any "../" in the file path
    let file_path_to_open = simplify(file_path_to_open)

    " If the file doesn't exist anywhere, open it at the current buffer
    if (file_path_to_open != "")
        exe "e " . file_path_to_open
    else 
        echo "Did not exist, creating!"
        exe "e " . expand('%:h') . '/' . file_name_to_open
    endif
endfunction!
nnoremap  :call SwapToRespectiveFile()<cr>
inoremap  :call SwapToRespectiveFile()<cr>
vnoremap  :call SwapToRespectiveFile()<cr>

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


" Loop through lines and align all '\'s
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

" Ctrl-C -> Toggle color column at column 100
function! ToggleColorColumn()
    if (&colorcolumn == 0)
        set colorcolumn=100
    else
        set colorcolumn=0
    endif
endfunction!
nnoremap  :call ToggleColorColumn()<cr>
inoremap  :call ToggleColorColumn()<cr>a

" Create a C program from the C template file
function! CreateC()
    " Place contents of template file
    0r ~/.config/nvim/templates/c
    set ft=c
endfunction!
