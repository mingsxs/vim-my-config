
"----------------------------------------------------
" This file contains self-defined Functions and     |
" utilitys.                                         |
"                                                   |
" Date: 2019/05/24                                  |
" Author: Ming Li (adagio.ming@gmail.com)           |
"----------------------------------------------------


"-----------------------------------------------------------------------
" relativenumber toggle function.
"-----------------------------------------------------------------------
function! utils#self#NumberToggle()
    if &relativenumber
        set norelativenumber nonumber
    else
        set relativenumber  number
    endif
endfunction

"-----------------------------------------------------------------------
" tabs/spaces expanding toggle function.
"-----------------------------------------------------------------------
function! utils#self#TabSpaceToggle()
    if &expandtab
        set noexpandtab
        echomsg "Tab Expanded"
    else
        set shiftwidth=4
        set softtabstop=4
        set expandtab
        echomsg "Space Expand"
    endif
endfunction

"-----------------------------------------------------------------------
" trigger <esc> map/unmap on insert mode.
"-----------------------------------------------------------------------
function! utils#self#EscMapToggle()
    if get(s:, 'esc_key_mapped', 1)
        iunmap <esc>
        let s:esc_key_mapped = 0
    else
        inoremap <silent> <esc> <esc>l
        let s:esc_key_mapped = 1
    endif
endfunction

"-----------------------------------------------------------------------
" Get current function/struct array name for C source.
"-----------------------------------------------------------------------
" inside string status code.
if !exists('s:cInString')
    let s:cInString = 0
endif
" parse one line of C code to know if it's inside function/struct array.
function s:get_line_brace(line, lastLine) abort
    let l:lineBraceSum = 0
    let l:cIndex = 0
    let l:stringLength = strlen(a:line)
    while l:cIndex < l:stringLength
        let l:c = a:line[l:cIndex]
        " check is_inside_string flag.
        if l:c == '"' && a:line[l:cIndex - 1] != '\'
            let s:cInString = !s:cInString
        endif
        " if currently it's inside C format string, then skip.
        if s:cInString == 1
            let l:cIndex += 1
            continue
        endif
        " calculate braces
        if l:c == '{'
            let l:lineBraceSum += 1
        elseif l:c == '}'
            let l:lineBraceSum -= 1
        endif

        let l:cIndex += 1
    endwhile
    " if meet the last line, reset is_inside_string flag.
    if a:lastLine
        let s:cInString = 0
    endif

    return l:lineBraceSum
endfunction

" trim string by character * and ( ).
function s:trim_str(line) abort
    let l:headPos = 0
    let l:tailPos = strlen(a:line) - 1
    let l:cHeadValid = 0
    let l:cTailValid = 0
    while l:tailPos > l:headPos
        if (a:line[l:headPos] == '*') || (a:line[l:headPos] == '(')
            let l:headPos += 1
        else
            let l:cHeadValid = 1
        endif

        if (a:line[l:tailPos] == '*') || (a:line[l:tailPos] == ')')
            let l:tailPos -= 1
        else
            let l:cTailValid = 1
        endif

        if l:cHeadValid && l:cTailValid
            break
        endif
    endwhile

    return a:line[l:headPos:l:tailPos]
endfunction

" get head brace index.
function s:get_head_brace_index(line) abort
    let l:cIndex = strlen(a:line) - 1
    let l:lineHeadBraceIndex = 0
    let l:parenthesisFound = 0
    while l:cIndex >= 0
        if !l:parenthesisFound && a:line[l:cIndex] == '('
            let l:lineHeadBraceIndex = l:cIndex
            let l:parenthesisFound = 1
        endif
        if a:line[l:cIndex] == '[' || a:line[l:cIndex] == '='
            let l:lineHeadBraceIndex = l:cIndex
        endif
        let l:cIndex -= 1
    endwhile

    return l:lineHeadBraceIndex
endfunction

" function/struct array name string match pattern.
let s:funcNamePattern = "^[^ \t#{/]\\{2}.*[^:]\s*$"
" return current function name/struct array name for C source code.
function! utils#self#CShowCurFuncName() abort
    if &filetype == 'c'
        let l:blkBraceSum = 0
        let l:funcNameLineNumber = search(s:funcNamePattern, 'bWn')
        let l:lineNumber = l:funcNameLineNumber
        let l:cursorLineNumber = line('.')
        " By mean of calculating the brace number, to know if current line is
        " inside C function or not.
        while l:lineNumber < l:cursorLineNumber
            let l:blkBraceSum += s:get_line_brace(getline(l:lineNumber), (l:lineNumber == l:cursorLineNumber - 1))
            let l:lineNumber += 1
        endwhile
        " If inside a function/struct array.
        if l:blkBraceSum > 0
            let l:funcNameLineText = getline(l:funcNameLineNumber)
            let l:headBraceIndex = s:get_head_brace_index(l:funcNameLineText)
            if l:headBraceIndex == 0
                let l:funcNameLineNumber -= 1
                while match(getline(l:funcNameLineNumber), '^\s*$') == 0
                    let l:funcNameLineNumber -= 1
                endwhile
                let l:funcNameLineText = getline(l:funcNameLineNumber)
            elseif l:headBraceIndex > 0
                let l:headBraceIndex -= 1
                let l:funcNameLineText = l:funcNameLineText[0:l:headBraceIndex]
            endif

            let l:wordList = split(l:funcNameLineText)
            let s:funcName = l:wordList[-1]
            " Trim the character * of string head and tail.
            let s:funcName = s:trim_str(s:funcName)
            return '['.s:funcName.']'
        " Out of a function/struct array.
        else
            return '[None]'
        endif
    endif
endfunction


"-----------------------------------------------------------------------
" Window size adjustment both vertically and horizontally.
"-----------------------------------------------------------------------
function! utils#self#AdjustWindowSize(scale, action)
    if a:scale == 'horizontal'
        if a:action == 'less'
            exec 'resize -' .. v:count1
        else
            exec 'resize +' .. v:count1
        endif
    else
        if a:action == 'less'
            exec 'vertical resize -' .. v:count1
        else
            exec 'vertical resize +' .. v:count1
        endif
    endif
endfunction


"-----------------------------------------------------------------------
" Map alt (normaly <Esc>) key as modifier key.
"-----------------------------------------------------------------------
function! utils#self#TerminalMapAltKey() abort
    if !has('nvim')
        " set alt key combined with a-z, A-Z
        for ascval in range(65, 90) + range(97, 122)
            exec "set <M-" .. nr2char(ascval) .. ">=\<Esc>" .. nr2char(ascval)
        endfor
        " set key response timeout to 50ms, otherwise you can't hit <Esc> in 1 sec
        set ttimeoutlen=25
    endif
endfunction


"-----------------------------------------------------------------------
" Close quickfix window or help window on pressing esc key.
"-----------------------------------------------------------------------
function! utils#self#OnPressEsc() abort
    let l:winnrs = winnr('$')
    " only handle multiple window cases
    if l:winnrs > 1
        for winnr in range(1, l:winnrs)
            " [untitled] buffer
            if empty(bufname(winbufnr(winnr)))
                exec winnr .. "quit"
                return
            " vim help doc
            elseif getwinvar(winnr, "&ft") == "help"
                exec winnr .. "quit"
                return
            " quickfix window
            elseif win_gettype(winnr) == "quickfix"
                cclose
                return
            " loclist window
            elseif win_gettype(winnr) == "loclist"
                lclose
                return
            endif
        endfor
    endif
endfunction


"-----------------------------------------------------------------------
" Strip some setting that to open big file quickly.
"-----------------------------------------------------------------------
function! utils#self#OpenLargeFile()
    " save memory when other file is viewed
    setlocal bufhidden=unload
    " is read-only (write with :w new_filename)
    setlocal buftype=nowrite
    " no swap file
    setlocal noswapfile
    " no undo possible
    setlocal undolevels=-1
    " disable airline plugin for current buffer
    let b:airline_disable_statusline = 1
    " disable ale plugin for current buffer
    let b:ale_enabled = 0
    " display message
    au VimEnter *  echo 'The file is larger than ' . (g:large_file_size/1024/1024) . ' MB.'
endfunction


"-----------------------------------------------------------------------
" On switch to a new tabpage, TabNew event triggered.
"-----------------------------------------------------------------------
function! utils#self#SwitchTabWin() abort
    let curwinid = win_getid()
    let curtab = tabpagenr()
    let bufwinidlist = win_findbuf(bufnr())
    "close duplicated windows
    for bufwinid in bufwinidlist
        let [ntab, nwin] = win_id2tabwin(bufwinid)
        let winft = gettabwinvar(ntab, nwin, "&ft")
        if !(empty(winft) ||
                    \ ntab == curtab ||
                    \ winft == 'qf' ||
                    \ winft == 'quickfix' ||
                    \ winft == 'help')
            if win_gotoid(bufwinid)
                exec "wincmd c"
            endif
        endif
    endfor
    "iterate all windows
    for ntab in range(1, tabpagenr('$'))
        for nwin in range(1, tabpagewinnr(ntab, '$'))
            " No file type
            if empty(gettabwinvar(ntab, nwin, "&ft"))
                let winid = win_getid(nwin, ntab)
                if win_gotoid(winid)
                    exec "wincmd c"
                endif
            endif
        endfor
        " Close tabpage if it only contains a quickfix window
        if (tabpagewinnr(ntab, '$') == 1)
            let winft = gettabwinvar(ntab, 1, "&ft")
            if winft == 'qf' ||
                    \ winft == 'quickfix' ||
                    \ winft == 'help'
                exec ntab .. "tabclose"
            endif
        endif
    endfor
    " jump back to current window
    if !win_gotoid(curwinid)
        echoerr "window jump back failed, ID:".curwinid
    endif
endfunction


"-----------------------------------------------------------------------
" On openning quickfix window.
"-----------------------------------------------------------------------
function! utils#self#SetQuickfixOpen()
    exec "botright copen"
    nnoremap <silent> <buffer> h  <C-W><CR><C-w>K
    nnoremap <silent> <buffer> H  <C-W><CR><C-w>K<C-w>b
    nnoremap <silent> <buffer> v  <C-w><CR><C-w>H<C-W>b<C-W>J<C-W>t
endfunction


"-----------------------------------------------------------------------
" Enable block paste.
"-----------------------------------------------------------------------
function! utils#self#LocalClipboardPaste() abort
    set clipboard-=unnamed
    call feedkeys("p", "t")
    set clipboard+=unnamed
endfunction


"-----------------------------------------------------------------------
" Toggling open/close all folds in local buffer.
"-----------------------------------------------------------------------
function! utils#self#OpenAllFoldsToggle()
    if &foldenable && &foldlevel
        normal zM
    else
        normal zR
    endif
endfunction


"-----------------------------------------------------------------------
" Tabpage/Window jump.
"-----------------------------------------------------------------------
function! utils#self#GoToTabWin(target)
    if a:target == 'window'
        exec v:count1 .. "wincmd w"
    elseif a:target == 'tabpage'
        exec "normal" v:count1 .. "gt"
    else
        echomsg 'invalid movement target' .. a:target
    endif
endfunction


"-----------------------------------------------------------------------
" vim-go fmt-autosave/imports-autosave switch.
"-----------------------------------------------------------------------
function! utils#self#VimGoAutoSaveToggle()
    if &ft == 'go'
        if get(g:, 'go_fmt_autosave', 1) == 1
            let g:go_fmt_autosave = 0
        else
            let g:go_fmt_autosave = 1
        endif

        if get(g:, 'go_imports_autosave', 1) == 1
            let g:go_imports_autosave = 0
        else
            let g:go_imports_autosave = 1
        endif
    endif
endfunction
