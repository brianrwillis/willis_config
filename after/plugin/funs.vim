" :E to destroy all swp files and reload all open buffers
function! ReloadAll()
    let l:winview = winsaveview()
    let file = expand('%:f')

    " Destroy all swp files
    :call system("rm `find . -type f -name \"*.sw*\"`")

    " Reload all
    :set autoread
    :checktime

    " Restore position
    silent! exe "e! " . file
    call winrestview(l:winview)

    :set noautoread

    :echo "Done reloading files"
endfunction!
command! E :call ReloadAll()


" Remove this swap file
function! RemoveSwaps()
    :call system("rm " . expand("%:p") . ".sw?")

    " FIXME: Put back in call to remove all swaps?
    " :call system("rm `find -name '*.sw?'`")

    echo "Swap file fucked"
endfunction!
noremap <F3> :call RemoveSwaps()<cr>


" Generate a tags file at the current directory
function! TagGen()
    silent! !rm tags

    silent! !ctags -R --languages=c,c++,python . 2>/dev/null

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


" Autoformat
function! Autoformat()
    let ft = expand('%:e')
    let pos = getpos('.')
    let search = @/

    if (((ft == 'h') || (ft == 'c') || (ft == 'cpp') || (ft == 'hpp')) && filereadable(".clang-format"))
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


" Hotkey to go to respective .h/.c file, creates if non-existent
function! SwitchToRespectiveFile()
    let ft = expand('%:e')
    let file_path = expand('%:f')
    let file_path_no_ft = expand('%:r')
    let file_name_no_ft = expand('%:t:r')
    let file_name = expand('%:t')

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
    if (matchstr(file_path, '.$') == ".")
        :call OpenCppOrC(file_path_no_ft)
        return
    endif

    " Detect if header or source, then switch to respective file
    if ((ft == 'h') || (ft == 'hpp'))
        :call OpenCppOrC(file_path_no_ft)
    elseif ((ft == 'c') || (ft == 'cpp'))
        :call OpenHppOrH(file_path_no_ft)
    else
        " Not a c, cpp, h, hpp, or file ending in '.', so do nothing
    endif
endfunction!
nnoremap  :call SwitchToRespectiveFile()<cr>

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

" Create a C program from the C template file
function! CreateC()
    " Place contents of template file
    0r ~/.config/nvim/templates/c
endfunction!
