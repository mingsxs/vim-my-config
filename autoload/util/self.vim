
"----------------------------------------------------
" This file contains self-defined Functions and     |
" Utilitys.                                         |
"                                                   |
" Date: 2019/05/24                                  |
" Author: Ming Li (adagio.ming@gmail.com)           |
"----------------------------------------------------


"-----------------------------------------------------------------------
" check the leader key.
"-----------------------------------------------------------------------
if !exists("g:mapleader")
    let g:mapleader = ','
endif

"-----------------------------------------------------------------------
" relativenumber toggle function.
"-----------------------------------------------------------------------
function! util#self#NumberToggle()
    if &relativenumber
        set norelativenumber nonumber
    else
        set relativenumber  number
    endif
endfunction

"-----------------------------------------------------------------------
" code fold method toggle function.
"-----------------------------------------------------------------------
function! util#self#CodeFoldToggle()
    if exists('&foldmethod')
        if &foldenable
            setlocal nofoldenable
        else
            setlocal foldenable foldmethod=syntax
        endif
    else
        echomsg "Vim doesn't support option foldmethod"
    endif
endfunction

"-----------------------------------------------------------------------
" tabs/spaces expanding toggle function.
"-----------------------------------------------------------------------
function! util#self#TabSpaceToggle()
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
" tabs/spaces expanding toggle function.
"-----------------------------------------------------------------------
function! util#self#setFileRetab()
    let l:filename = getreg('%')
    try
        if filewritable(l:filename) && (match(l:filename, '.*udi_.*') == -1)
            :%retab
        endif
    catch
    endtry
endfunction

"-----------------------------------------------------------------------
" Get current function/struct array name for C source.
"-----------------------------------------------------------------------
" inside string status code.
if !exists('s:cInString')
    let s:cInString = 0
endif
" parse one line of C code to know if it's inside function/struct array.
function s:get_line_brace(line, lastLine)
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
function s:trim_str(line)
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
function s:get_head_brace_index(line)
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
function! util#self#CShowCurFuncName()
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
" Horizontally narrow windows.
"-----------------------------------------------------------------------
function! util#self#HoriNarrowWindow()
    let l:resizeCmd = ':resize -'.v:count1
    exe l:resizeCmd
endfunction


"-----------------------------------------------------------------------
" Horizontally enlarge windows.
"-----------------------------------------------------------------------
function! util#self#HoriEnlargeWindow()
    let l:resizeCmd = ':resize +'.v:count1
    exe l:resizeCmd
endfunction


"-----------------------------------------------------------------------
" Vertically narrow window.
"-----------------------------------------------------------------------
function! util#self#VertNarrowWindow()
    let l:resizeCmd = ':vertical resize -'.v:count1
    exe l:resizeCmd
endfunction


"-----------------------------------------------------------------------
" Vertically enlarge window.
"-----------------------------------------------------------------------
function! util#self#VertEnlargeWindow()
    let l:resizeCmd = ':vertical resize +'.v:count1
    exe l:resizeCmd
endfunction


"-----------------------------------------------------------------------
" Map alt (normaly <Esc>) key as modifier key.
"-----------------------------------------------------------------------
function! util#self#TerminalMapAltKey()
    " set alt key combined with a-z, A-Z
    for ascval in range(65, 90) + range(97, 122)
        exe "set <M-".nr2char(ascval).">=\<Esc>".nr2char(ascval)
    endfor
    " set key response timeout to 50ms, otherwise you can't hit <Esc> in 1 sec
    set ttimeoutlen=25
endfunction


"-----------------------------------------------------------------------
" Set go to previous window on closing quickfix window.
"-----------------------------------------------------------------------
function! util#self#OnPressEsc()
    " Close quickfix window
    let l:winnrs = winnr('$')
    for winnr in range(1, l:winnrs)
        if getwinvar(winnr, '&ft') == 'qf'
            exe "cclose"
            exe "winc p"
            return
        endif
    endfor

    " Close help window
    for winnr in range(1, l:winnrs)
        if winnrs > 1 && getwinvar(winnr, '&ft') == 'help'
            exe winnr."quit"
            return
        endif
    endfor
endfunction

