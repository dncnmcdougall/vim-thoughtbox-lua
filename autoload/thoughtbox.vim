let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'

function! thoughtbox#openSelection(method) range
    if a:method == 'edit'
        let firstline=a:lastline
    else
        let firstline=a:firstline
    endif
    let paths = getline(firstline, a:lastline)
    for path in paths
        call thoughtbox#open(path, a:method)
    endfor
endfunction

function! thoughtbox#open(line, method) 
    let parts = split(trim(a:line),':')
    let path = parts[0]
    if len(parts) == 1
        echom 'Ignoring: '.a:line
        continue
    end
    exe 'wincmd p'
    exe a:method.' '.fnameescape(path)
endfunction

function! s:openList(list_content, initial_search)
    let prevwinid = win_getid()

    exe 'silent keepalt edit _thought_list_'
    exe 'setlocal filetype=thoughtlist'

    setlocal noreadonly 
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal textwidth=0
    setlocal nolist
    setlocal nowrap
    setlocal winfixwidth
    setlocal nospell
    setlocal nonumber
    setlocal nofoldenable
    setlocal foldcolumn=0

    call deletebufline("%",1,"$")
    call append(0,a:list_content)

    setlocal readonly 
    setlocal conceallevel=2
    setlocal concealcursor=nvc
    setlocal cursorline
    call cursor(1,0)
    if a:initial_search != '' 
        call search(a:initial_search,'c')
    else
        call search(':', 'ce', line('.'))
    endif
endfunction

function! s:splitList(list_content)
    call utils#OpenListWindow( 
                \ g:thoughtbox#vertical_split,
                \ g:thoughtbox#open_pos,
                \ g:thoughtbox#split_size,
                \ "_thought_list_",
                \ "thoughtlist",
                \ g:thoughtbox#list_auto_close,
                \ g:thoughtbox#list_jump_to_on_open)

    call deletebufline("%",1,"$")
    call append(0,a:list_content)

    setlocal readonly 
    setlocal conceallevel=2
    setlocal concealcursor=nvc
    setlocal cursorline
    call cursor(1,0)
    call search(':', 'ce', line('.'))

endfunction

function! thoughtbox#listThoughtsByName()
    let thought_folder = expand(g:thoughtbox#folder).s:sep

    let thought_names = readdir(thought_folder, { n -> n =~ ".tb$"})

    let thought_names = luaeval(
                \'require("thoughtbox").sortNames(_A)',
                \thought_names)

    let thoughts = luaeval(
                \'require("thoughtio").readThoughtsTitleAndTags(unpack(_A))',
                \[thought_folder, thought_names])

    let list_content = []
    for name in thought_names
        let list_content += [thoughts[name].file.': '.thoughts[name].title]
    endfor
    return list_content
endfunction

function! thoughtbox#listThoughtsByNameWithName()
    let thought_folder = expand(g:thoughtbox#folder).s:sep

    let thought_names = readdir(thought_folder, { n -> n =~ ".tb$"})

    let thought_names = luaeval(
                \'require("thoughtbox").sortNames(_A)',
                \thought_names)

    let thoughts = luaeval(
                \'require("thoughtio").readThoughtsTitleAndTags(unpack(_A))',
                \[thought_folder, thought_names])

    let list_content = []
    for name in thought_names
        let list_content += [name."\t".thoughts[name].file.":\t".thoughts[name].title]
    endfor
    return list_content
endfunction

function! thoughtbox#listThoughtsByTag()
    let thought_folder = expand(g:thoughtbox#folder).s:sep

    let thought_names = readdir(thought_folder, { n -> n =~ ".tb$"})

    let thought_names = luaeval(
                \'require("thoughtbox").sortNames(_A)',
                \thought_names)

    let thoughts = luaeval(
                \'require("thoughtio").readThoughtsTitleAndTags(unpack(_A))',
                \[thought_folder, thought_names])

    let [tagged, keys] = luaeval(
                \'require("thoughtio").groupByTags(_A)',
                \thoughts)

    let list_content = []
    for key in keys
        let list_content += [s:sep.key.'.: ']
        for name in tagged[key] 
            let list_content += ['  '.thoughts[name].file.': '.thoughts[name].title]
        endfor
    endfor

    return list_content
endfunction

function! thoughtbox#openThoughtListByName(name)
    call s:openList(thoughtbox#listThoughtsByName(), a:name)
endfunction

function! thoughtbox#splitThoughtListByName()
    call s:splitList(thoughtbox#listThoughtsByName())
endfunction

function! thoughtbox#splitThoughtListByTag()
    call s:splitList(thoughtbox#listThoughtsByTag())
endfunction
