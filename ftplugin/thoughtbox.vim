if exists('b:loaded_thoughtbox') 
  finish
endif

let b:loaded_thoughtbox = 1

if resolve(expand('%:p:h')) != resolve(expand(g:thoughtbox#folder))
    echom 'not true thought'
    finish
endif

let b:thought = expand('%:t:r')
let s:line1 = getline(1)

let s:thought = luaeval(
            \'require("thoughtbox").parseThoughtContent(unpack(_A))',
            \[[s:line1], b:thought])

let b:title = s:thought.title

let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'

function s:openTag()
endfunction

nnoremap <nowait><buffer><silent> - :<C-U>call thoughtbox#openThoughtListByName(b:thought)<CR>
nnoremap <c-]> :<C-U>call thoughtbox#openTagAtPosition()<CR>

autocmd! BufWritePost,FileAppendPost,FileWritePost <buffer> call thoughtbox#postThoughtWrite(expand("<afile>:t:r"))
