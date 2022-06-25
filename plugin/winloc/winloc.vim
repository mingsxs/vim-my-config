" check for vim event support.
if !(exists('##WinEnter') &&
            \ exists('##WinLeave') &&
            \ exists('##WinNew') &&
            \ exists('##WinClosed'))
    echomsg "Error: winloc requires events #WinEnter, #WinLeave, #WinNew and #WinClosed supported."
    finish
endif

" global vars
"let s:windows = [1000]
let s:winloc_fifo = [1000]
let s:winloc_cursor = 0
let s:winloc_switch = 0

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
"    echomsg "window ids opened: ".join(s:windows, ', ')
    echomsg "winloc fifo length: ".get(g:, 'winloc_fifo_len', 'default-10')
    echomsg "winloc fifo: ".join(s:winloc_fifo, ', ')
    echomsg "winloc cursor: ".s:winloc_cursor
endfunction

" remove window ID from fifo after an opened window is closed.
function! winloc#winloc#OnWinClose() abort
    if get(g:, 'winloc_enable', 0)
        " event WinClosed will store the closed Win-ID in <amatch> & <afile>
        let closed_win = expand('<amatch>')
        " remove closed window
        let cursor = 0
        while cursor < len(s:winloc_fifo)
            if s:winloc_fifo[cursor] == closed_win
                call remove(s:winloc_fifo, cursor)
                if cursor <= s:winloc_cursor
                    let s:winloc_cursor -= 1
                endif
            else
                let cursor += 1
            endif
        endwhile
        " remove continued duplicates
        let cursor = 0
        while cursor < len(s:winloc_fifo) - 1
            if s:winloc_fifo[cursor] == s:winloc_fifo[cursor+1]
                call remove(s:winloc_fifo, cursor+1)
                if cursor+1 <= s:winloc_cursor
                    let s:winloc_cursor -= 1
                endif
            else
                let cursor += 1
            endif
        endwhile
    endif
endfunction

" add new window ID
"function! winloc#winloc#OnWinCreate() abort
"    if get(g:, 'winloc_enable', 0)
"        call add(s:windows, win_getid())
"    endif
"endfunction

" update the jump fifo after entering window.
function! winloc#winloc#OnWinEnter() abort
    if get(g:, 'winloc_enable', 0) && !s:winloc_switch
        let curwin = win_getid()
        " append win id only if it's not the latest
        if get(s:winloc_fifo, -1) != curwin
            " shift last window to winloc list end
            let prevwin = s:winloc_fifo[s:winloc_cursor]
            call remove(s:winloc_fifo, s:winloc_cursor)
            call add(s:winloc_fifo, prevwin)
            if len(s:winloc_fifo) >= get(g:, 'winloc_fifo_len', 10)
                let s:winloc_fifo = s:winloc_fifo[1:]
            endif
            call add(s:winloc_fifo, curwin)
        endif
        let s:winloc_cursor = len(s:winloc_fifo) - 1
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
            echomsg "invalid winloc jump count"
        else
            if s:winloc_fifo[next_cursor] != curwin
                if win_gotoid(s:winloc_fifo[next_cursor])
                    let s:winloc_cursor = next_cursor
                else
                    echomsg "Window ID .".s:winloc_fifo[next_cursor]." not found, do nothing"
                endif
            endif
        endif
        " turn off switch for incoming WinEnter event
        let s:winloc_switch = 0
    endif
endfunction
