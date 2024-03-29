
"------------------------------------------------------------
" This file contains all the configs which will be loaded   |
" after other plugins get loaded.                           |
" Date Create: 2019/05/24                                   |
" Author: Ming Li (adagio.ming@gmail.com)                   |
"------------------------------------------------------------


"-----------------------------------------------------------------------
" relative number toggle map.
"-----------------------------------------------------------------------
noremap <silent> <c-n> :call utils#self#NumberToggle()<cr>


"-----------------------------------------------------------------------
" fold toggling map.
"-----------------------------------------------------------------------
nnoremap <silent> <space> za
vnoremap <silent> <space> zf
nnoremap <silent> <c-space> :call utils#self#OpenAllFoldsToggle()<cr>

"-----------------------------------------------------------------------
" Jump to last cursor position.
"-----------------------------------------------------------------------
augroup JumpLastCursor
    autocmd!
    autocmd BufReadPost * :call utils#onevent#BufReadPost()
augroup END


"-----------------------------------------------------------------------
" Highlight cursor column and line, dehighlight them when leaving window
"-----------------------------------------------------------------------
augroup HighlightCursorPosition
    au!
    au WinEnter,TabEnter,BufEnter * if !&cursorcolumn | set cursorline cursorcolumn | endif
    au WinLeave,TabLeave * if &cursorcolumn | set nocursorline nocursorcolumn | endif
augroup END


"-----------------------------------------------------------------------
" show tab line.
"-----------------------------------------------------------------------
if exists("+showtabline")
    function! MyTabLine()
        let l:s = ''
        let l:wn = ''
        let l:t = tabpagenr()
        let l:i = 1
        while l:i <= tabpagenr('$')
            let l:buflist = tabpagebuflist(l:i)
            let l:winnr = tabpagewinnr(l:i)
            let l:s .= '%' . l:i . 'T'
            let l:s .= (l:i == l:t ? '%1*' : '%2*')
            let l:s .= ' '
            let l:wn = tabpagewinnr(l:i,'$')

            let l:s .= (l:i== l:t ? '%#TabNumSel#' : '%#TabNum#')
            let l:s .= l:i
            if tabpagewinnr(l:i,'$') > 1
                let l:s .= '.'
                let l:s .= (l:i== l:t ? '%#TabWinNumSel#' : '%#TabWinNum#')
                let l:s .= (tabpagewinnr(l:i,'$') > 1 ? l:wn : '')
            endif

            let l:s .= ' %*'
            let l:s .= (l:i == l:t ? '%#TabLineSel#' : '%#TabLine#')
            let l:bufnr = buflist[l:winnr - 1]
            let l:file = bufname(l:bufnr)
            if getbufvar(l:bufnr, 'buftype') == 'nofile'
                if l:file =~ '\/.'
                    let l:file = substitute(l:file, '.*\/\ze.', '', '')
                endif
            else
                let l:file = fnamemodify(l:file, ':p:t')
            endif
            if empty(l:file)
                let l:ft = gettabwinvar(l:i, l:wn, '&ft')
                if l:ft == 'qf' || l:ft == 'quickfix'
                    let l:file = '[Quickfix]'
                elseif l:ft == 'netrw' || l:ft == 'nerdtree'
                    let l:file = '[Nerdtree]'
                else
                    let l:file = '[Untitled]'
                endif
            endif
            let l:s .= l:file
            let l:s .= (l:i == l:t ? '%m' : '')
            let l:i = l:i + 1
        endwhile
        let l:s .= '%T%#TabLineFill#%='
        return l:s
    endfunction
    set stal=2
    set tabline=%!MyTabLine()
endif


"-----------------------------------------------------------------------
" filetype detect and settings.
"-----------------------------------------------------------------------
augroup FiletypeConfig
    autocmd!
    autocmd FileType python             setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab smarttab nofoldenable foldmethod=indent foldnestmax=2
    autocmd FileType c,cpp,make,java    setlocal tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab nofoldenable foldmethod=syntax cindent foldnestmax=2
    autocmd FileType php,ruby           setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab smarttab
    autocmd FileType coffee,javascript  setlocal tabstop=2 shiftwidth=2 softtabstop=2 noexpandtab smarttab
    autocmd FileType vim,zsh,tcsh       setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab smarttab
    autocmd FileType html,htmldjango,xhtml,haml,css setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab smarttab nofoldenable
    autocmd FileType yaml               setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab smarttab nofoldenable foldmethod=indent foldnestmax=2
augroup END


"-----------------------------------------------------------------------
" Vim auto-complete feature map.
"-----------------------------------------------------------------------
imap <F3> <c-p>
imap <F4> <c-n>


"-----------------------------------------------------------------------
" Vim tabpage feature map.
"-----------------------------------------------------------------------
" edit a file in new tab.
cabbrev<silent> te tabedit

" find a file in path and open it in new tab.
cabbrev<silent> tf tabfirst

" move to the last tab page.
cabbrev<silent> tl tablast

" close current tab.
cabbrev<silent> tc tabclose

" creat a new tab and do E.
nnoremap <silent> <Leader>n :Texplore<cr> :setlocal relativenumber<cr>

" go to previous tabpage in tabpage jump list.
nnoremap <silent> [t :call mingsxs#tabpage#jumper#GoPreviousTabpage()<cr>

" go to next tabpage in tabpage jump list.
nnoremap <silent> ]t :call mingsxs#tabpage#jumper#GoNextTabpage()<cr>


"-----------------------------------------------------------------------
" Vim buffer edit feature map.
"-----------------------------------------------------------------------
" map previous buffer and next buffer short keys.
nnoremap [b :bp<cr>
nnoremap ]b :bn<cr>

" to simplify buffer N operation.
nnoremap gb :ls<cr>:b<space>


"-----------------------------------------------------------------------
" Vim easily navigate across different windows.
"-----------------------------------------------------------------------
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l


"-----------------------------------------------------------------------
" javascript syntax support.
"-----------------------------------------------------------------------
"autocmd Syntax javascript set syntax=jquery   "JQuery syntax support
" java script.
let g:html_indent_inctags = "html,body,head,tbody"
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"


"-----------------------------------------------------------------------
" Disable some useless default key mappings by remapping to <NOP>.
"-----------------------------------------------------------------------
nmap <s-k> <Nop>
nmap <s-j> <Nop>
nmap <s-w> <Nop>
nmap <s-m> <Nop>


"-----------------------------------------------------------------------
" Disable jumping-to-next by default while searching words.
"-----------------------------------------------------------------------
map<silent> * :let @/ = '\<'.expand("<cword>").'\>' \| set hlsearch<cr>


"-----------------------------------------------------------------------
" Window terminal copy (write) highlighted text to .vimbuffer.
"-----------------------------------------------------------------------
vmap <C-c> y:new ~/.vimbuffer<CR>VGp:x<CR> \| :!cat ~/.vimbuffer \| clip.exe <CR><CR>


"-----------------------------------------------------------------------
" Extend alt key as modifier.
"-----------------------------------------------------------------------
call utils#self#TerminalMapAltKey()


"-----------------------------------------------------------------------
" Quickfix open.
"-----------------------------------------------------------------------
nnoremap <silent> qo :call utils#self#SetQuickfixOpen()<CR>


"-----------------------------------------------------------------------
" Handle Esc.
"-----------------------------------------------------------------------
nnoremap <silent> <Esc> :call utils#self#OnPressEsc()<CR>


"-----------------------------------------------------------------------
" Resize panels when vim is resized.
"-----------------------------------------------------------------------
augroup ResizePanels
    au!
    :au VimResized * let winid = win_getid() | noautocmd silent! tabdo wincmd = | call win_gotoid(winid)
augroup END


"-----------------------------------------------------------------------
" Open large files.
"-----------------------------------------------------------------------
let g:large_file_size = 1024 * 1024 * 8
augroup OpenLargeFile
    au!
    au BufReadPre * let fs = getfsize(expand("<afile>")) | if (fs > g:large_file_size || fs == -2) | set ei+=FileType | call utils#self#OpenLargeFile() | else | set ei-=FileType | endif
augroup END


"-----------------------------------------------------------------------
" Quick access help.
"-----------------------------------------------------------------------
nmap <silent> <Leader>h :exe "help " . expand("<cword>")<cr>


"-----------------------------------------------------------------------
" Windows WSL clipboard support.
"-----------------------------------------------------------------------
let s:win_clip = get(g:, 'win_clip', '/mnt/c/Windows/System32/clip.exe')
if executable(s:win_clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:win_clip, @0) | endif
    augroup END
endif


"-----------------------------------------------------------------------
" Open in readonly mode when swapfile detected.
"-----------------------------------------------------------------------
augroup ViewWithSwap
    autocmd!
    autocmd SwapExists * let v:swapchoice = "o"
augroup END


"-----------------------------------------------------------------------
" Set up winloc plugin.
"-----------------------------------------------------------------------
let g:winloc_enable = has('nvim')     " enable winloc with nvim
augroup Winloc
    autocmd!
    autocmd WinEnter *  :call winloc#winloc#OnWinEnter()
    autocmd WinClosed * :call winloc#winloc#OnWinClose()
augroup END
nnoremap <silent> <M-i> :call winloc#winloc#JumpWinloc('next')<CR>
nnoremap <silent> <M-o> :call winloc#winloc#JumpWinloc('prev')<CR>


"-----------------------------------------------------------------------
" Tabpage/window movement mapping.
"-----------------------------------------------------------------------
nnoremap <silent> <Leader>1 :1wincmd w<CR>
nnoremap <silent> <Leader>2 :2wincmd w<CR>
nnoremap <silent> <Leader>3 :3wincmd w<CR>
nnoremap <silent> <Leader>4 :4wincmd w<CR>
nnoremap <silent> <Leader>5 :5wincmd w<CR>
nnoremap <silent> <Leader>6 :6wincmd w<CR>
nnoremap <silent> <Leader>7 :7wincmd w<CR>
nnoremap <silent> <Leader>8 :8wincmd w<CR>
nnoremap <silent> <Leader>9 :9wincmd w<CR>
nnoremap <silent> <M-j> :call utils#self#GoToTabWin("tabpage")<CR>
nnoremap <silent> <M-k> :call utils#self#GoToTabWin("window")<CR>


"-----------------------------------------------------------------------
" Airline tabline show window number.
"-----------------------------------------------------------------------
function! ShowWinNumber(...)
    let builder = a:1
    let context = a:2
    call builder.add_section('airline_b', '%{tabpagewinnr(tabpagenr())}')
    return 0
endfunction

call airline#add_statusline_func('ShowWinNumber')
call airline#add_inactive_statusline_func('ShowWinNumber')


"-----------------------------------------------------------------------
" Easy window size adjustment.
"-----------------------------------------------------------------------
" Vertically narrow window, eg: 20<Leader>-.
nnoremap <silent> _ :<C-U>call utils#self#AdjustWindowSize("vertical", "less")<cr>
" Vertically enlarge window, eg: 20<Leader>=.
nnoremap <silent> + :<C-U>call utils#self#AdjustWindowSize("vertical", "more")<cr>
" Horizontally narrow window. eg: shift - -.
nnoremap <silent> <Leader>- :<C-U>call utils#self#AdjustWindowSize("horizontal", "less")<cr>
" Horizontally enlarge window. eg: shift - +.
nnoremap <silent> <Leader>= :<C-U>call utils#self#AdjustWindowSize("horizontal", "more")<cr>


"-----------------------------------------------------------------------
" Enable copy/paste with visual block.
"-----------------------------------------------------------------------
function! s:ClipboardOptSwitch()
    if &clipboard =~# 'unnamed'
        set clipboard-=unnamed
        echo "remove clipboard setting"
    else
        set clipboard+=unnamed
        echo "restore clipboard setting"
    endif
endfunction
nnoremap <silent><M-p> :call <SID>ClipboardOptSwitch()<cr>


"-----------------------------------------------------------------------
" Disable cursor moving by mouse when losting/gaining window focus.
"-----------------------------------------------------------------------
augroup NoCursorMoveOnFocus
    autocmd!
    autocmd FocusLost * let g:mouse_opt_save=&mouse | set mouse=
    autocmd FocusGained * if exists('g:mouse_opt_save') | let &mouse=g:mouse_opt_save | unlet g:mouse_opt_save | endif
augroup END


"-----------------------------------------------------------------------
" Close popup window on WinLeave event.
"-----------------------------------------------------------------------
augroup ClosePopupOnWinLeave
    autocmd!
    autocmd WinLeave * if win_gettype() == 'popup' | wincmd c | endif
augroup END


"-----------------------------------------------------------------------
" Disable cursor leftmove when exit from insert mode.
"-----------------------------------------------------------------------
inoremap <silent> <esc> <esc>l
nnoremap <silent> <Leader>e :call utils#self#EscMapToggle()<cr>


"-----------------------------------------------------------------------
" Switch between tab/tab expanded modes.
"-----------------------------------------------------------------------
nnoremap <silent> <Leader>t :call utils#self#TabSpaceToggle()<cr>
