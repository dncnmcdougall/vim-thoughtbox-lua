if exists('b:loaded_thoughtlist') 
  finish
endif
let b:loaded_thoughtlist = 1

nnoremap <nowait><buffer><silent> <CR> :<C-U>.call thoughtbox#openSelection('edit')<CR>
nnoremap <nowait><buffer><silent> i :<C-U>.call thoughtbox#openSelection('edit')<CR>
nnoremap <nowait><buffer><silent> o :<C-U>.call thoughtbox#openSelection('split')<CR>

vnoremap <nowait><buffer><silent> <CR> :'<,'>call thoughtbox#openSelection('edit')<CR>
vnoremap <nowait><buffer><silent> o :'<,'>call thoughtbox#openSelection('split')<CR>

