" check for vim event support.
if !(exists('##WinEnter') &&
            \ exists('##WinLeave') &&
            \ exists('##WinNew') &&
            \ exists('##WinClosed'))
    echomsg "Error: winloc requires events #WinEnter, #WinLeave, #WinNew and #WinClosed supported."
    finish
endif

" global vars
let s:windows = [win_getid()]
let s:winloc_fifo = [win_getid()]
let s:winloc_cursor = 0
let s:winloc_switch = 0

" collect all opened window IDs as list
"function! s:GetAllWins()
"    let winids = []
"    " iterate through all tabpages
"    for tabpage in range(1, tabpagenr('$'))
"        " iterate through all windows within tabpage
"        for window in range(1, tabpagewinnr(tabpage, '$'))
"            call add(winids, win_getid(window, tabpage))
"        endfor
"    endfor
"    return winids
"endfunction

" remove window ID from fifo once some opened window is closed.
function! winloc#winloc#OnCloseWin()
    if !get(g:, 'winloc_enable', 0)
        return
    endif

    let indice = index(s:windows, win_getid())
    if indice >= 0
        call remove(s:windows, indice)
    endif

    let cursor = 0
    while cursor < len(s:winloc_fifo)
        if index(s:windows, s:winloc_fifo[cursor]) < 0
            call remove(s:winloc_fifo, cursor)
            " update winloc cursor if front item is removed
            if cursor < s:winloc_cursor
                let s:winloc_cursor -= 1
            endif
        else
            let cursor += 1
        endif
    endwhile
endfunction

" add new window ID
function! winloc#winloc#OnWinNew()
    if !get(g:, 'winloc_enable', 0)
        return
    endif
    call add(s:windows, win_getid())
endfunction

" update the jump fifo after entering window.
function! winloc#winloc#OnWinEnter()
    if !get(g:, 'winloc_enable', 0)
        return
    endif
    if !s:winloc_switch && s:winloc_fifo[-1] != win_getid()
        if len(s:winloc_fifo) >= get(g:, 'winloc_fifo_len', 10)
            let s:winloc_fifo = s:winloc_fifo[1:]
        endif
        let s:winloc_cursor = len(s:winloc_fifo)
        call add(s:winloc_fifo, win_getid())
    endif
endfunction

" jump across winloc fifo
function! winloc#winloc#JumpWinloc(direction)
    if !get(g:, 'winloc_enable', 0)
        return
    endif

    " enable switch flag
    let s:winloc_switch = 1
    let curwinid = win_getid()
    if a:direction == 'prev'
        if v:count1 <= s:winloc_cursor
            let s:winloc_cursor -= v:count1
        else
            let s:winloc_cursor = 0
        endif
    else
        if s:winloc_cursor + v:count1 < len(s:winloc_fifo)
            let s:winloc_cursor += v:count1
        else
            let s:winloc_cursor = len(s:winloc_fifo) - 1
        endif
    endif

    let nextwinid = s:winloc_fifo[s:winloc_cursor]

    if nextwinid != curwinid
        if !win_gotoid(nextwinid)
            echomsg "Window ID .".nextwinid." not found, do nothing"
        endif
    endif
    " disable switch flag
    let s:winloc_switch = 0
endfunction
