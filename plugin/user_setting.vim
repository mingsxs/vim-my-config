
"----------------------------------------------------
" This file contains self-defined mappings and some |
" useful auto-settings.                             |
" Date: 2019/05/24                                  |
" Author: Ming Li (adagio.ming@gmail.com)           |
"----------------------------------------------------


"-----------------------------------------------------------------------
" file sourced flag.
"-----------------------------------------------------------------------
"if !exists('g:user_setting_sourced')
"    let g:user_setting_sourced = 1
"endif

"-----------------------------------------------------------------------
" relative number toggle map.
"-----------------------------------------------------------------------
noremap <silent> <c-n> :call util#self#NumberToggle()<cr>


"-----------------------------------------------------------------------
" code fold method toggle map.
"-----------------------------------------------------------------------
nnoremap <silent> <leader>f :call util#self#CodeFoldToggle()<cr>


"-----------------------------------------------------------------------
" tabs/spaces expanding toggle map.
"-----------------------------------------------------------------------
nnoremap <silent> <Leader>t :call util#self#TabSpaceToggle()<cr>


"-----------------------------------------------------------------------
" BufReadPost event hanlder.
"-----------------------------------------------------------------------
augroup JumpLastCursor
    autocmd!
    autocmd BufReadPost *   :call util#onevent#BufReadPost()
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
            let l:buftype = getbufvar(l:bufnr, 'buftype')
            if l:buftype == 'nofile'
                if l:file =~ '\/.'
                    let l:file = substitute(l:file, '.*\/\ze.', '', '')
                endif
            else
                let l:file = fnamemodify(l:file, ':p:t')
            endif
            if l:file == ''
                let l:file = '[Untitled]'
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
augroup DetectFiletype
    autocmd!
    autocmd FileType php,ruby           setlocal tabstop=2 shiftwidth=2 softtabstop=2 | setlocal expandtab smarttab
    autocmd FileType coffee,javascript  setlocal tabstop=2 shiftwidth=2 softtabstop=2 | setlocal noexpandtab smarttab
    autocmd FileType html,htmldjango,xhtml,haml,css setlocal tabstop=2 shiftwidth=2 softtabstop=2 | setlocal noexpandtab smarttab
    autocmd FileType python             setlocal tabstop=4 shiftwidth=4 softtabstop=4 foldmethod=indent | setlocal nofoldenable expandtab smarttab
    autocmd FileType c,cpp,java         setlocal tabstop=4 softtabstop=4 shiftwidth=4 foldmethod=syntax | setlocal cindent nofoldenable noexpandtab
    autocmd FileType make               setlocal tabstop=4 softtabstop=4 shiftwidth=4 foldmethod=syntax | setlocal cindent nofoldenable noexpandtab
    autocmd FileType vim                setlocal tabstop=4 shiftwidth=4 softtabstop=4 | setlocal expandtab smarttab
    autocmd FileType zsh,tcsh           setlocal tabstop=4 shiftwidth=4 softtabstop=4 | setlocal expandtab smarttab
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
" Vim brackets auto-complement in insert mode.
"-----------------------------------------------------------------------
inoremap ( ()<ESC>i
inoremap [ []<ESC>i
inoremap { {}<ESC>i
" inoremap < <><ESC>i
inoremap " ""<ESC>i
inoremap ' ''<ESC>i


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
" Disable some stupid default key mappings by remapping to <NOP>.
"-----------------------------------------------------------------------
map <s-k> <Nop>
map <s-j> <Nop>
map <s-w> <Nop>


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
call util#self#TerminalMapAltKey()


"-----------------------------------------------------------------------
" Quickfix open.
"-----------------------------------------------------------------------
nnoremap <silent> qo :call util#self#SetQuickfixOpen()<CR>


"-----------------------------------------------------------------------
" Handle Esc.
"-----------------------------------------------------------------------
nnoremap <silent> <Esc> :call util#self#OnPressEsc()<CR>


"-----------------------------------------------------------------------
" Resize panels when vim is resized.
"-----------------------------------------------------------------------
augroup ResizePanels
    au!
    :au VimResized * wincmd =
augroup END


"-----------------------------------------------------------------------
" Open large files.
"-----------------------------------------------------------------------
let g:large_file_size = 1024 * 1024 * 8
augroup OpenLargeFile
    au!
    au BufReadPre * let fs = getfsize(expand("<afile>")) | if (fs > g:large_file_size || fs == -2) | set ei+=FileType | call util#self#OpenLargeFile() | else | set ei-=FileType | endif
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
" Move to window N by <Leader> + N.
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
