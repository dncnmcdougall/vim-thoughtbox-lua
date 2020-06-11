" if exists('g:loaded_thoughtbox') || &cp || v:version < 700 || &cpo =~# 'C'
"   finish
" endif
let g:loaded_thoughtbox = 1

augroup thoughtboxfiltypedetect
    autocmd!
    autocmd! BufRead,BufNewFile *.tb set filetype=thoughtbox
augroup END

if !exists('g:thoughtbox#folder') 
    let g:thoughtbox#folder='~/thoughtbox'
endif

if !exists('g:thoughtbox#vertical_split') 
    let g:thoughtbox#vertical_split=1
endif
if !exists('g:thoughtbox#open_pos') 
    let g:thoughtbox#open_pos='botright'
endif
if !exists('g:thoughtbox#split_size') 
    let g:thoughtbox#split_size=40
endif
if !exists('g:thoughtbox#list_auto_close') 
    let g:thoughtbox#list_auto_close=1
endif
if !exists('g:thoughtbox#list_jump_to_on_open') 
    let g:thoughtbox#list_jump_to_on_open=1
endif

highlight default link ThoughtListPathTail Title

" --------------------------------
" Add our plugin to the path
" --------------------------------
python3 import sys, os, vim
python3 sys.path.append(os.path.join(vim.eval('expand("<sfile>:p:h:h")'))); import pythoughts

command! PrintPath python3 print(sys.path)
command! ReloadPyThoughts python3 import importlib; importlib.reload(pythoughts)
command! -nargs=? NewThought call thoughtbox#newThought(<q-args>)
command! -nargs=0 ListThoughts call thoughtbox#listThoughts()
" command! -nargs=0 ListThoughtTags call thoughtbox#listThoughtTags()
" command! -nargs=1 ListThoughtsWithTag call thoughtbox#listThoughtsWithTag(<q-args>)
