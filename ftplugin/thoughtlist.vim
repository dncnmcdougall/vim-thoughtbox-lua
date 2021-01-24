if exists('b:loaded_thoughtlist') 
  finish
endif
let b:loaded_thoughtlist = 1

nnoremap <nowait><buffer><silent> <CR> :<C-U>.call thoughtbox#open('edit')<CR>
nnoremap <nowait><buffer><silent> i :<C-U>.call thoughtbox#open('edit')<CR>
nnoremap <nowait><buffer><silent> o :'<,'>call thoughtbox#open('split')<CR>

vnoremap <nowait><buffer><silent> <CR> :'<,'>call thoughtbox#open('edit')<CR>
vnoremap <nowait><buffer><silent> o :'<,'>call thoughtbox#open('split')<CR>

