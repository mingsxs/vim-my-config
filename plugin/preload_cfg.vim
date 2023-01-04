"------------------------------------------------------------
" This file contains all the configs which will be loaded   |
" prior to loading other plugins.                           |
" Date Create: 2019/05/24                                   |
" Author: Ming Li (adagio.ming@gmail.com)                   |
"------------------------------------------------------------


"-----------------------------------------------------------------------
" set the leader key for vim.
"-----------------------------------------------------------------------
let g:mapleader = ','


"-----------------------------------------------------------------------
" Plugin Settings: Nerdtree.
"-----------------------------------------------------------------------
let NERDChristmasTree=0
let NERDTreeWinSize=24
let NERDTreeChDirMode=2
let NERDTreeIgnore=['\.pyc$', '\.pyo', '\.swp$', '\.swo$']
" let NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$',  '\~$']
" let NERDTreeShowBookmarks=1
let NERDTreeWinPos = "left"
let NERDTreeShowHidden=1
" let NERDTreeAutoDeleteBuffer=1

nmap <F12> :NERDTreeToggle<cr>
nmap <F11> :NERDTreeToggleVCS <cr>


"-----------------------------------------------------------------------
" Plugin Settings: Vim-session.
"-----------------------------------------------------------------------
set sessionoptions-=help        " don't want help windows to be restored
let g:session_autoload='no'     " don't load vim session automatically
let g:session_autosave='no'     " don't save vim session automatically
let g:session_menu=0
nmap <M-s> :SaveSession<cr>
nmap <M-r> :OpenSession<cr>


"-----------------------------------------------------------------------
" Plugin Settings: Python-indent.
"-----------------------------------------------------------------------
let g:python_pep8_indent_multiline_string=-2
let g:python_pep8_indent_hang_closing=1


"-----------------------------------------------------------------------
" Plugin Settings: Vim-easy-align.
"-----------------------------------------------------------------------
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


"-----------------------------------------------------------------------
" Plugin Settings: Lookupfile.
"-----------------------------------------------------------------------
let g:LookupFile_LookupFunc = 'utils#explugin#LookupFile_IgnoreCase'


"-----------------------------------------------------------------------
" Plugin Settings: Ctags.
"-----------------------------------------------------------------------
let g:tags_file_path = findfile("tags",".;$HOME")
let g:autotagTagsFile = "tags"
set tags=./tags,tags;$HOME
if !filereadable(g:tags_file_path)
    let g:tags_file_path = findfile("TAGS", ".;$HOME")
    if filereadable(g:tags_file_path)
        let g:autotagTagsFile = "TAGS"
        set tags=./TAGS,TAGS;$HOME
    endif
endif
let g:autotagCtagsCmd = "ctags"
" let g:autotagDisabled = 1

" Update ctags database file.
augroup UpdateCtagsDatabase
    au!
    autocmd BufWritePost *
        \ if filereadable(g:tags_file_path) |
        \ :call system('ctags -a -f '.expand(g:tags_file_path)) |
        \ endif
augroup END

" Open ctags search in tab/vertical split
nmap <silent> <c-\> :tab split<cr>:exec("tag ".expand("<cword>"))<cr>
nmap <silent> <leader><c-\> :vsp<cr>:exec("tag ".expand("<cword>"))<cr>

"-----------------------------------------------------------------------
" Plugin Settings: cscope.
"-----------------------------------------------------------------------
" no finding tags file
set nocst

" set what to show in quickfix window
" Normal vim with no cscope autojump patch, nvim included
" Vim with cscope autojump patch and compiled by me
" 9999 is customized patch number
if exists('v:versionlong') && v:versionlong % 10000 == 9999
    set cscopequickfix=s-!,c-!,d-!,i-!,t-!,e-
endif

" for cscope shortkey mapping
" The following maps all invoke one of the following cscope search types:
"
"   's'   symbol: find all references to the token under cursor
"   'g'   global: find global definition(s) of the token under cursor
"   'c'   calls:  find all calls to the function name under cursor
"   't'   text:   find all instances of the text under cursor
"   'e'   egrep:  egrep search for the word under cursor
"   'f'   file:   open the filename under cursor
"   'i'   includes: find files that include the filename under cursor
"   'd'   called: find functions that function under cursor calls

" To do the first type of search, hit 'CTRL-\', followed by one of the
" cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
" search will be displayed in the current window.  You can use CTRL-T to
" go back to where you were before the search.  
"nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>  
"nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>  
"nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>  
"nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>  
"nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>  
"nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>  
"nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
"nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

" Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
" makes the vim window split horizontally, with search result displayed in
" the new window.
"
" (Note: earlier versions of vim may not have the :scs command, but it
" can be simulated roughly via:
"    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>
"nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR> 
"nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR> 
"nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR> 
"nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR> 
"nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR> 
"nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR> 
"nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>   
"nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>


"-----------------------------------------------------------------------
" Plugin Settings: ale.
"-----------------------------------------------------------------------
" Eable ale.
let g:ale_enabled = 1

" Set ale linters globally.
let g:ale_linters = {
            \ 'javascript': ['eslint'],
            \ 'python': ['flake8', 'pylint'],
            \ 'c': ['gcc'],
            \ 'cpp': ['g++'],
            \    }
" configure options for particular linter commands
" python flake8
" https://pycodestyle.pycqa.org/en/latest/intro.html#error-codes
call ale#Set('python_flake8_options', '--ignore=E221,E222,E501,E241')

" Only run linters specified in ale_linters settings.
let g:ale_linters_explicit = 0

" Disable ale completion.
let g:ale_completion_enabled = 0

" Set max suggestion number of ale completion.
"let g:ale_completion_max_suggestions = 20

" Enable ale airline extension.
let g:airline#extensions#ale#enabled = 1

" Set ale error signs.
let g:ale_sign_error = '>'

" Set ale warning signs.
let g:ale_sign_warning = '-'

" Set format for Error message.
let g:ale_echo_msg_error_str = 'E'

" Set format for Warning message.
let g:ale_echo_msg_warning_str = 'W'

" Set message format.
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

" Select loclist window to show Error items.
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 0

" Set number of the list for ale to display Errors.
let g:ale_list_window_size = 6

" Close preview window upon insert mode.
let g:ale_close_preview_on_insert = 1

" Set ale linter delay.
let g:ale_lint_delay = 2000


"-----------------------------------------------------------------------
" Plugin Settings: air-line.
"-----------------------------------------------------------------------
" disable crypt detection.
let g:airline_detect_crypt = 0

" exclude preview window from being modified.
let g:airline_exclude_preview = 1

" cache highlighting, faster.
let g:airline_highlighting_cache = 1


"-----------------------------------------------------------------------
" Plugin Settings: Command-T.
"-----------------------------------------------------------------------
map <c-t> :CommandT <cr>
let g:CommandTCancelMap = ['<ESC>', '<C-c>']


"-----------------------------------------------------------------------
" Plugin Settings: fzf.
"-----------------------------------------------------------------------
" map the shortcut
map <M-f> :FZF <cr>
" set defualt FZF command to ag
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git --ignore .pycache -l -g ""'


"-----------------------------------------------------------------------
" Plugin Settings: auto pop menu.
"-----------------------------------------------------------------------
" enable for certain filetypes
let g:apc_enable_ft = {'c':1, 'cpp':1, 'python':1, 'ruby':1, 'perl':1, 'vim':1, 'zsh':1, 'sh':1, 'make':1, 'go':1}
let g:apc_cr_confirm = 1

" source for dictionary, current or other loaded buffers, see ':help cpt'
set cpt+=k

" don't select the first item
set completeopt=menu,menuone,noselect

" suppress messages
set shortmess+=c


"-----------------------------------------------------------------------
" Plugin Settings: ag.
"-----------------------------------------------------------------------
" Set ag program name
let g:ag_prg = "ag --vimgrep"

" Set search from project root instead of current directory
let g:ag_working_path_mode = "R"

function! s:agSearchExpandWord()
    let l:agCmd = "Ag! " . expand('<cword>')
    let l:regexEscs = "^$.\\+?*()[]{}|"
    let l:ichar = 4
    let l:cmdLen = strlen(l:agCmd)
    while l:ichar < l:cmdLen
        if stridx(l:regexEscs, l:agCmd[l:ichar]) != -1
            let l:agCmd = l:agCmd[:l:ichar-1] . '\' . l:agCmd[l:ichar:]
            let l:ichar = l:ichar + 1
        endif
        let l:ichar = l:ichar + 1
    endwhile

    return substitute(l:agCmd, '#', '.', 'g')
endfunction

cabbrev ag Ag!
nnoremap <silent> <Leader>ag :execute(<SID>agSearchExpandWord())<CR>


"-----------------------------------------------------------------------
" Plugin Settings: gutentags.
"-----------------------------------------------------------------------
let $GTAGSLABEL = 'native-pygments'
if filereadable(expand('~/.globalrc'))
    let $GTAGSCONF = expand('~/.globalrc')
elseif filereadable(expand('~/.gtags.conf'))
    let $GTAGSCONF = expand('~/.gtags.conf')
else
    let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
endif
" configure gutentags settings, https://github.com/ludovicchabant/vim-gutentags/blob/master/doc/gutentags.txt
let g:gutentags_project_root = ['.git', '.svn', '.root', '.hg', '.project', '.github']
let g:gutentags_ctags_tagfile = '.tags'
let g:gutentags_modules = []
if executable('gtags-cscope') && executable('gtags')
    let g:gutentags_modules += ['gtags_cscope']
endif
if executable('ctags')
    let g:gutentags_modules += ['ctags']
endif
let g:gutentags_cache_dir = expand('~/.cache/tags')
" configure ctags arguments
let g:gutentags_ctags_extra_args = ['--fields=+niazS']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
" use gutentags_plus plugin to auto switch databases, https://github.com/skywind3000/gutentags_plus
let g:gutentags_plus_switch = 1
let g:gutentags_plus_height = 10
" gutentags trace debug info, set to 1 to enable gutentags debug trace.
let g:gutentags_trace = 0


"-----------------------------------------------------------------------
" Plugin Settings: fzf.vim.
"-----------------------------------------------------------------------
nnoremap <silent> <leader>ff :Files<cr>
nnoremap <silent> <leader>gf :GFiles<cr>


"-----------------------------------------------------------------------
" Plugin Settings: vim-rooter.
"-----------------------------------------------------------------------
let g:rooter_patterns = ['.git', '.svn', '.hg', '.bzr', '_darcs', '.root']
if exists(":lcd")
    let g:rooter_cd_cmd = 'lcd'
endif


"-----------------------------------------------------------------------
" Plugin Settings: vim-sneak.
"-----------------------------------------------------------------------
let g:sneak#label = 0           " disable label mode
let g:sneak#use_ic_scs = 1      " use ignorecase/smartcase setting
let g:sneak#s_next = 1          " like clever-f
" map f,F,t,T jump
map <silent> f <Plug>Sneak_f
map <silent> F <Plug>Sneak_F
map <silent> t <Plug>Sneak_t
map <silent> T <Plug>Sneak_T


"-----------------------------------------------------------------------
" Plugin Settings: vim-my-config.winloc.
"-----------------------------------------------------------------------
function! s:LeftMouseClik()
    if (&mouse ==# 'nv' || &mouse ==# 'a') && get(g:, "left_mouse_click") == 0
        let g:left_mouse_click = 1
    endif
endfunction
"nnoremap <silent> <expr> <LeftMouse> <SID>LeftMouseClik()
"vnoremap <silent> <expr> <LeftMouse> <SID>LeftMouseClik()


"-----------------------------------------------------------------------
" Plugin Settings: vim-go.
"-----------------------------------------------------------------------
let g:go_doc_keywordprg_enabled = 0  " disable `K` map for godoc
