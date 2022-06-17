"-----------------------------------------------------------------------
" TabNew.
"-----------------------------------------------------------------------
function! util#onevent#TabNew()
    call util#self#SwitchTabWin(get(s:, 'prev_tabpage', 1))
endfunction


"-----------------------------------------------------------------------
" TabLeave.
"-----------------------------------------------------------------------
function! util#onevent#TabLeave()
    let s:prev_tabpage = tabpagenr()
    call mingsxs#tabpage#jumper#MaintainJumpQueueWhenLeave()
endfunction


"-----------------------------------------------------------------------
" TabEnter.
"-----------------------------------------------------------------------
function! util#onevent#TabEnter()
    call mingsxs#tabpage#jumper#MaintainJumpQueueWhenEnter()
endfunction


"-----------------------------------------------------------------------
" BufReadPost.
"-----------------------------------------------------------------------
function! util#onevent#BufReadPost()
    " always jump to the last cursor position when edit new file.
    if !exists("g:leave_my_cursor_position_alone")
        if line("'\"") > 0 && line ("'\"") <= line("$")
            exec "normal g'\""
        endif
    endif
endfunction


