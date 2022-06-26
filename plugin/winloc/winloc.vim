" check for vim event support.
if !(has('timers') &&
            \ exists('##WinEnter') &&
            \ exists('##WinLeave') &&
            \ exists('##WinNew') &&
            \ exists('##WinClosed'))
    echomsg "Error: winloc requires feature `timers` and events #WinEnter, #WinLeave, #WinNew and #WinClosed support."
    finish
endif

" global vars
"let s:windows = [1000]
let s:winloc_fifo = [1000]
let s:winloc_cursor = 0
let s:winloc_update_timer = 0
let s:winloc_switch = 0
let s:winloc_skip_next_enter = 0

" collect all opened window IDs as list
function! s:GetAllWinIDs()
    let winids = []
    " iterate through all tabpages
    for tabpage in range(1, tabpagenr('$'))
        " iterate through all windows within tabpage
        for window in range(1, tabpagewinnr(tabpage, '$'))
            call add(winids, win_getid(window, tabpage))
        endfor
    endfor
    return winids
endfunction

function! winloc#winloc#DebugShow()
    echomsg "window ids all:".join(s:GetAllWinIDs(), ', ')
    echomsg "winloc fifo length: ".get(g:, 'winloc_fifo_len', 'default-16')
    echomsg "winloc fifo: ".join(s:winloc_fifo, ', ')
    echomsg "winloc cursor: ".s:winloc_cursor
endfunction

" add new window ID
"function! winloc#winloc#OnWinCreate() abort
"    if get(g:, 'winloc_enable', 0)
"        call add(s:windows, win_getid())
"    endif
"endfunction

" append new window id to the winloc fifo.
function! s:AppendWinloc(winid) abort
    if get(s:winloc_fifo, -1) != a:winid && !empty(getwininfo(a:winid))
        call add(s:winloc_fifo, a:winid)
        if len(s:winloc_fifo) > get(g:, 'winloc_fifo_len', 16)
            let s:winloc_fifo = s:winloc_fifo[1:]
        endif
    endif
endfunction

" function to add current window to winloc fifo on WinEnter.
function s:WinlocUpdateOnEnter(timer) abort
    " shift last window to winloc list end
    let prevwin = get(s:winloc_fifo, s:winloc_cursor)
    let curwin = win_getid()
    " not entering the previous window
    if curwin != prevwin
        if prevwin != 0 && prevwin != get(s:winloc_fifo, -1)
            call remove(s:winloc_fifo, s:winloc_cursor)
            while get(s:winloc_fifo, s:winloc_cursor) == get(s:winloc_fifo, s:winloc_cursor-1)
                call remove(s:winloc_fifo, s:winloc_cursor)
            endwhile
            call s:AppendWinloc(prevwin)
        endif
        " append win id only if it's not the latest
        call s:AppendWinloc(curwin)
        " point to the newest loc
        let s:winloc_cursor = len(s:winloc_fifo) - 1
    endif
endfunction

" handler for updating winloc fifo on event #WinEnter with delay timer.
" the default delay is 25 ms which can be specified with g:winloc_update_delay.
function! winloc#winloc#OnWinEnter() abort
    if get(g:, 'winloc_enable', 0) && !s:winloc_switch
        " check if previous window is a quickfix window
        let isprevwinqf = 0
        if s:winloc_skip_next_enter == 1
            " previous quickfix window closed, handled by WinClosed event
            let isprevwinqf = 1
            let s:winloc_skip_next_enter = 0 " unset the flag for next set
        else
            " previous quickfix window still open
            let prevwininfo = getwininfo(get(s:winloc_fifo, s:winloc_cursor))
            if !empty(prevwininfo) && prevwininfo[0]['quickfix']
                let isprevwinqf = 1
            endif
        endif
        if isprevwinqf == 1
            if empty(timer_info(s:winloc_update_timer))
                let l:WinlocUpdater = function('<SID>WinlocUpdateOnEnter')
                call timer_stop(s:winloc_update_timer)
                let s:winloc_update_timer = timer_start(get(g:, 'winloc_update_delay', 25), l:WinlocUpdater, {'repeat': 1})
            endif
        else
            call s:WinlocUpdateOnEnter(0)
        endif
    endif
endfunction

" update winloc fifo after an opened window is closed.
function! winloc#winloc#OnWinClose() abort
    if get(g:, 'winloc_enable', 0)
        " event WinClosed will store the closed Win-ID in <amatch> & <afile>
        let closed_win = str2nr(expand('<amatch>'))
        if index(s:winloc_fifo, closed_win) >= 0
            if getwininfo(closed_win)[0]['quickfix'] && s:winloc_cursor > 0
                " remove closed window and change window cursor to previous one for quickfix
                call remove(s:winloc_fifo, s:winloc_cursor)
                let s:winloc_cursor -= 1
                let s:winloc_skip_next_enter = 1 " skip next WinEnter
            else
                " remove closed window and continuous window duplicates
                let cursor = 1
                while cursor < len(s:winloc_fifo)
                    while (get(s:winloc_fifo, cursor) == closed_win) ||
                                \ (get(s:winloc_fifo, cursor) == get(s:winloc_fifo, cursor-1))
                        call remove(s:winloc_fifo, cursor)
                        if cursor < s:winloc_cursor
                            let s:winloc_cursor -= 1
                        elseif cursor == s:winloc_cursor
                            let s:winloc_cursor = -1 " current window closed, winloc_cursor is floating now
                        endif
                    endwhile
                    let cursor += 1
                endwhile
            endif
        endif
    endif
endfunction

" jump across winloc fifo
function! winloc#winloc#JumpWinloc(direction) abort
    if get(g:, 'winloc_enable', 0)
        " turn on switch to block incoming WinEnter event
        let s:winloc_switch = 1
        let curwin = win_getid()
        if a:direction == 'prev'
            let next_cursor = v:count1 <= s:winloc_cursor ? s:winloc_cursor - v:count1 : -1
        else
            let next_cursor = (s:winloc_cursor + v:count1) < len(s:winloc_fifo) ? s:winloc_cursor + v:count1 : -1
        endif
        if next_cursor == -1
            echo "exceed winloc jump range"
        else
            let nextwin = get(s:winloc_fifo, next_cursor)
            if nextwin != curwin
                if win_gotoid(nextwin)
                    let s:winloc_cursor = next_cursor
                else
                    echomsg "Window ID .".nextwin." not found, do nothing"
                    if nextwin != 0
                        call remove(s:winloc_fifo, next_cursor)
                    endif
                    call s:WinlocUpdateOnEnter(0)
                endif
            endif
        endif
        " turn off switch for incoming WinEnter event
        let s:winloc_switch = 0
    endif
endfunction
