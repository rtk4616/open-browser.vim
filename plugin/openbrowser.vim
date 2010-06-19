" vim:foldmethod=marker:fen:
scriptencoding utf-8

" NEW BSD LICENSE {{{
"   Copyright (c) 2009, tyru
"   All rights reserved.
"
"   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
"
"       * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
"       * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
"       * Neither the name of the tyru nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
"
"   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
" }}}
" Change Log {{{
" }}}
" Document {{{
"
" Name: openbrowser
" Version: 0.0.0
" Author:  tyru <tyru.exe@gmail.com>
" Last Change: 2010-06-19.
"
" Description:
"   Simple plugin to open URL with your favorite browser
"
" Usage: {{{
"   Commands: {{{
"   }}}
"   Mappings: {{{
"   }}}
"   Global Variables: {{{
"   }}}
" }}}
" }}}

" Load Once {{{
if exists('g:loaded_openbrowser') && g:loaded_openbrowser
    finish
endif
let g:loaded_openbrowser = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" Scope Variables {{{
let s:is_unix = has('unix')
let s:is_mswin = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_macunix = has('macunix')
lockvar s:is_unix
lockvar s:is_mswin
lockvar s:is_cygwin
lockvar s:is_macunix
" }}}

" Check your platform {{{
if !(s:is_unix || s:is_mswin || s:is_cygwin || s:is_macunix)
    echoerr 'Your platform is not supported!'
    finish
endif
" }}}

" Get default open commands. "{{{
if s:is_cygwin
    function! s:get_default_open_commands()
        return ['cygstart']
    endfunction
elseif s:is_unix
    function! s:get_default_open_commands()
        return ['xdg-open', 'x-www-browser', 'firefox', 'w3m']
    endfunction
elseif s:is_mswin
    function! s:get_default_open_commands()
        return ['start']
    endfunction
elseif s:is_macunix
    function! s:get_default_open_commands()
        return ['open']
    endfunction
endif
" }}}

" Global Variables {{{
if !exists('g:openbrowser_open_commands')
    try
        let g:openbrowser_open_commands = s:get_default_open_commands()
    catch
        echoerr v:exception
        finish
    endtry
endif
" }}}

" Functions {{{

function! s:open_browser(url) "{{{
    for browser in g:openbrowser_open_commands
        if !executable(browser)
            continue
        endif

        " TODO
        " Check if it is correct url?
        " Or it is file path.
        " Convert it into url with `file:` scheme.

        if s:is_mswin
            call system(printf('%s %s %s %s', &shell, &shellcmdflag, browser, a:url))
        else
            call system(browser . ' ' . shellescape(a:url))
        endif

        let success = 0
        if v:shell_error ==# success
            return
        else
            echoerr printf("Can't open url with '%s'.", browser)
            return
        endif
    endfor
endfunction "}}}

function! s:get_selected_text() "{{{
    let save_z = getreg('z', 1)
    let save_z_type = getregtype('z')

    try
        normal! gv"zy
        return @z
    finally
        call setreg('z', save_z, save_z_type)
    endtry
endfunction "}}}

" }}}

" Interfaces {{{

" Ex command
command!
\   -bar -nargs=+ -complete=file
\   OpenBrowser
\   call s:open_browser(<q-args>)

" Key-mapping
nnoremap <Plug>(openbrowser-open) :<C-u>call <SID>open_browser(expand('<cfile>'))<CR>
vnoremap <Plug>(openbrowser-open) :<C-u>call <SID>open_browser(<SID>get_selected_text())<CR>
" TODO operator
" noremap <Plug>(openbrowser-op-open)

" }}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
