
"----------------------------------------------------
" This file contains plugin related Functions and   |
" Utilitys.                                         |
"                                                   |
" Date: 2019/05/24                                  |
" Author: Ming Li (adagio.ming@gmail.com)           |
"----------------------------------------------------


"-----------------------------------------------------------------------
" Plugin Settings: Lookupfile.
"-----------------------------------------------------------------------
function! util#explugin#LookupFile_IgnoreCase(pattern)
    let _tags = &tags
    try
        let &tags = eval(g:LookupFile_TagExpr)
        let newpattern = '\c' . a:pattern
        let tags = taglist(newpattern)
    catch
        echohl ErrorMsg | echomsg "Exception: " . v:exception | echohl NONE
        return ""
    finally
        let &tags = _tags
    endtry
    " Show the matches for what is typed so far.
    let files = map(tags, 'v:val["filename"]')
    return files
endfunction


"-----------------------------------------------------------------------
" Plugin Settings: ale.
"-----------------------------------------------------------------------
function! util#explugin#LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction


"-----------------------------------------------------------------------
" Autotest script filetype detection.
"-----------------------------------------------------------------------
function! util#explugin#FiletypeAtScript()
    let l:filename = getreg('%')
    return (match(l:filename, '\(^.*\.spk$\)\|\(^.*\.inc$\)\|\(^.*\.def$\)\|\(^.*\.slot\)\|\(^.*\.cfg$\)') >= 0)
endfunction


"-----------------------------------------------------------------------
" Add database file for cscope.
"-----------------------------------------------------------------------
"function! util#explugin#AddCscopeDatabase()
"    if has('cscope')
"        let l:cscopeFileName = findfile('.cscope.out','.;$HOME')
"        if !filereadable(l:cscopeFileName)
"            let l:cscopeFileName = findfile('cscope.out', '.;HOME')
"        endif
"        if filereadable(l:cscopeFileName) " Do file name pattern match.
"            set nocscopeverbose                             " Suppress 'duplicate connection' error.
"            let l:cscopeFileDir = fnamemodify(l:cscopeFileName, ':p:h') " Get the cscope file directory.
"            " Attach cscope file by case insensitive search.
"            execute "cscope add ".l:cscopeFileName l:cscopeFileDir "-C"
"            set cscopeverbose
"        endif
"    else
"        echomsg "Vim doesn't support cscope!"
"    endif
"endfunction
"
