if exists('g:loaded_thoughtbox') || &cp || v:version < 700 || &cpo =~# 'C'
  finish
endif
let g:loaded_thoughtbox = 1

augroup thoughtboxfiltypedetect
    autocmd! BufRead,BufNewFile *.tb set filetype=thoughtbox
augroup END


" --------------------------------
" Add our plugin to the path
" --------------------------------
python import sys
python import os
python import vim
python sys.path.append(oa.path.join(vim.eval('expand("<sfile>:p:h:h")'), 'pythoughts')

command! ReloadPyThoughts python import importlib; importlib.reload(pythoughts)
