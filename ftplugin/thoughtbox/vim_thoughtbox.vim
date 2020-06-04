" --------------------------------
" Add our plugin to the path
" --------------------------------
python import sys
python import vim
python sys.path.append(oa.path.join(vim.eval('expand("<sfile>:p:h:h")'), 'pythoughts')

" --------------------------------
"  Function(s)
" --------------------------------
function! TemplateExample()
python << endOfPython

from vim_thoughtbox import vim_thoughtbox_example

for n in range(5):
    print(vim_thoughtbox_example())

endOfPython
endfunction

" --------------------------------
"  Expose our commands to the user
" --------------------------------
command! Example call TemplateExample()
