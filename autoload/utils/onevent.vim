"-----------------------------------------------------------------------
" TabLeave.
"-----------------------------------------------------------------------
function! utils#onevent#TabLeave()
    call mingsxs#tabpage#jumper#MaintainJumpQueueWhenLeave()
endfunction


"-----------------------------------------------------------------------
" TabEnter.
"-----------------------------------------------------------------------
function! utils#onevent#TabEnter()
    call mingsxs#tabpage#jumper#MaintainJumpQueueWhenEnter()
endfunction


"-----------------------------------------------------------------------
" BufReadPost.
"-----------------------------------------------------------------------
function! utils#onevent#BufReadPost()
    " always jump to the last cursor position when edit new file.
    if get(g:, 'g:go_last_cursor_location', 1)
        if line("'\"") > 0 && line ("'\"") <= line("$")
            exec "normal g'\""
        endif
    endif
endfunction
