if exists('g:loaded_thoughtbox') 
  finish
endif
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

if !exists('g:thoughtbox#fzf') 
    let g:thoughtbox#fzf=1
endif

if g:thoughtbox#fzf
    function! s:fzfEditThought(line)
        let line_parts = split(a:line,"\t")
        call thoughtbox#open(line_parts[1].line_parts[2], 'edit')
    endfunction
    command! -nargs=0 SearchThoughts call fzf#run(fzf#wrap('thoughts',{
                \ "source": thoughtbox#listThoughtsByNameWithName(), 
                \ 'sink':funcref('s:fzfEditThought') ,
                \ 'options': "--with-nth=1,3 --delimiter='\t'"
                \ }))
endif


highlight default link ThoughtListPath String
highlight default link ThoughtListTitle Title

command! -nargs=? NewThought call ThoughtboxNewThought(<q-args>)
command! -nargs=0 ListThoughts call thoughtbox#splitThoughtListByName()
command! -nargs=0 ListThoughtTags call thoughtbox#splitThoughtListByTag()
