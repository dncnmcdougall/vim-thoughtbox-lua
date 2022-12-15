if exists('g:loaded_thoughtbox') 
    finish
endif
let g:loaded_thoughtbox = 1

augroup thoughtbox_filetype +detect
    autocmd!
    autocmd! BufRead,BufNewFile *.tb set filetype=thoughtbox
augroup END

if !exists('g:thoughtbox#folder') 
    let g:thoughtbox#folder='~/thoughtbox'
endif

if !exists('g:thoughtbox#database') 
    let g:thoughtbox#database='thought_details.db'
endif

if !exists('g:thoughtbox#read_cmd') 
    let g:thoughtbox#read_cmd='read'
endif

if !exists('g:thoughtbox#write_cmd') 
    let g:thoughtbox#write_cmd='write'
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
if !exists('g:thoughtbox#jump_to_list_on_open') 
    let g:thoughtbox#jump_to_list_on_open=1
endif
if !exists('g:thoughtbox#fzf') 
    let g:thoughtbox#fzf=1
endif

if g:thoughtbox#fzf

    function s:wrap(key, opts)
        let a:opts.options = a:opts.options.' --expect='.a:key.' --print-query'
        let a:opts['thoughtbox#key'] = a:key
        let a:opts['thoughtbox#sink'] = a:opts.sink
        unlet a:opts.sink

        unlet a:opts.window
        let a:opts['down'] = '60%'

        function a:opts.sinklist(lines)
            if len(a:lines) < 2
                return
            endif
            if a:lines[1] == self['thoughtbox#key']
                if self.name == 'thoughtbox#grep'
                    call thoughtbox#SearchThoughtTitles(self['thoughtbox#key'], a:lines[0])
                elseif self.name == 'thoughtbox#titles'
                    call thoughtbox#SearchThoughtTags(self['thoughtbox#key'], a:lines[0])
                elseif self.name == 'thoughtbox#tags'
                    call thoughtbox#SearchThoughts(self['thoughtbox#key'], a:lines[0])
                endif
            else
                call self['thoughtbox#sink'](a:lines[2])
            endif
        endfunction

        return a:opts
    endfunction



    function! s:fzfEditThoughtByName(line)
        let line_parts = split(a:line,"\t")
        call thoughtbox#open(line_parts[1].line_parts[2], 'edit')
    endfunction

    function thoughtbox#SearchThoughtTitles(key, query)
        call fzf#run(s:wrap(a:key, fzf#wrap('thoughtbox#titles', {
                    \ 'source': thoughtbox#listThoughtsByNameWithName("\t"), 
                    \ 'sink':funcref('s:fzfEditThoughtByName') ,
                    \ 'options': '
                    \ --with-nth=1,3 
                    \ --delimiter="\t" 
                    \ --prompt="TBX title>"
                    \ --query="'.a:query.'"'
                    \ })))
    endfunction


    function! s:fzfEditThoughtByTag(line)
        let line_parts = split(a:line,"\t")
        call thoughtbox#open(line_parts[2].line_parts[3], 'edit')
    endfunction
    function thoughtbox#SearchThoughtTags(key, query)
        call fzf#run(s:wrap(a:key, fzf#wrap('thoughtbox#tags',{
                    \ 'source': thoughtbox#listThoughtsByTagWithName("\t"), 
                    \ 'sink':funcref('s:fzfEditThoughtByTag') ,
                    \ 'options': '
                    \ --with-nth=1,2,4 
                    \ --delimiter="\t" 
                    \ --prompt="TBX tag>"
                    \ --query="'.a:query.'"'
                    \ })))
    endfunction

    function! s:ParseEFMLine(line)
        let l:line = getqflist({'efm':&gfm,'lines': [a:line]})
        let l:filename=bufname(l:line.items[0].bufnr)
        execute('edit '.l:filename)
    endfunction
    function thoughtbox#SearchThoughts(key, query)
        if executable('ag')
            let s:search_command='ag --noheading --nogroup --numbers --filename --color'
        else
            let s:search_command='grep --H -n --color=always'
        endif
        call fzf#run(s:wrap(a:key, fzf#wrap('thoughtbox#grep', {
                    \ 'options':' 
                    \ --bind "change:reload:'.s:search_command.' {q} '.g:thoughtbox#folder.' || true" 
                    \ --prompt="TBX grep>"
                    \ --ansi --color="hl:black"
                    \ --query="'.a:query.'"',
                    \ 'source': [],
                    \ 'sink': function('s:ParseEFMLine')
                    \})))
    endfunction

    command! -nargs=0 SearchThoughtTitles call thoughtbox#SearchThoughtTitles('ctrl-t', '')
    command! -nargs=0 SearchThoughtTags call thoughtbox#SearchThoughtTags('ctrl-t', '')
    command! -nargs=0 SearchThoughts call thoughtbox#SearchThoughts('ctrl-t', '')

endif


highlight default link ThoughtListPath String
highlight default link ThoughtListTitle Title

command! -nargs=? NewThought call ThoughtboxNewThought(<q-args>)
command! -nargs=0 ListThoughts call thoughtbox#splitThoughtListByName()
command! -nargs=0 ListThoughtTags call thoughtbox#splitThoughtListByTag()


