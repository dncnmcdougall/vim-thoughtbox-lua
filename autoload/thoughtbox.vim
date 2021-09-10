let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'

function! thoughtbox#postThoughtWrite(name) 
    if executable(g:thoughtbox#write_cmd)
        let thought_folder = expand(g:thoughtbox#folder).s:sep
        let lines = getline(line('.'), line('$'))
        let thought = luaeval(
                    \'require("thoughtbox").parseThoughtContent(unpack(_A))',
                    \[lines, a:name])
        let tags = ''
        let links = ''
        for link in thought.links
            let links .= ' -l '.link
        endfor
        for tag in thought.tags
            let tags .= ' -t '.tag
        endfor

        let cmd = g:thoughtbox#write_cmd.' '.a:name.' '.thought.title . links . tags
        let cmd .= ' --database '.thought_folder.g:thoughtbox#database
        exec 'silent !'.cmd
    else
        echom "Not using read or write: ".g:thoughtbox#write_cmd
    end
endfunction


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
    if exists('b:use_previous') && b:use_previous == 1
        exe 'wincmd p'
    endif
    exe a:method.' '.fnameescape(path)
endfunction

function! thoughtbox#openTagAtPosition()
    let word = expand("<cword>")
    let pos = getcurpos()
    let start = searchpos('\[\[','bc', pos[1])
    let end = [0,0]
    if start[0] != 0
        let end = searchpos('\]\]','', pos[1])
    endif
    if end[0] != 0
        let word = strpart(getline(start[0]), start[1]+1, end[1]-start[1]-2)

        let thought_file = expand(g:thoughtbox#folder).s:sep.word.".tb"
        if filereadable(thought_file)
            echom "open file: ".thought_file
            exe ":edit ".thought_file
        else
            echoerr "Could not find file: ".thought_file
        endif
    else
        if exists('g:tag_jump_cmd')
            exe eval(g:tag_jump_cmd)
        else
            exe ":tag ".word
        endif
    endif
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

    let b:use_previous=0

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
                \ g:thoughtbox#jump_to_list_on_open)

    let b:use_previous=1

    call deletebufline("%",1,"$")
    call append(0,a:list_content)

    setlocal readonly 
    setlocal conceallevel=2
    setlocal concealcursor=nvc
    setlocal cursorline
    call cursor(1,0)
    call search(':', 'ce', line('.'))

endfunction

function! s:listThoughts() 
    let thought_folder = expand(g:thoughtbox#folder).s:sep

    if executable(g:thoughtbox#read_cmd)
        let read_cmd = g:thoughtbox#read_cmd
        let read_cmd .= ' --database '.thought_folder .g:thoughtbox#database
        let thought_names = []
        let params = [thought_folder, thought_names, read_cmd]
    else
        let thought_names = readdir(thought_folder, { n -> n =~ ".tb$"})
        let thought_names = luaeval(
                    \'require("thoughtbox").sortNames(_A)',
                    \thought_names)
        let params = [thought_folder, thought_names]
    endif
    let thoughts = luaeval(
                \'require("thoughtio").readThoughtsTitleAndTags(unpack(_A))',
                \params)

    if len(thought_names) == 0
        let thought_names = keys(thoughts)
        let thought_names = luaeval(
                    \'require("thoughtbox").sortNames(_A)',
                    \thought_names)
    endif

    return [thoughts, thought_names]
endfunction

function! thoughtbox#listThoughtsByName(content_sep)
    let thought_parts = s:listThoughts()
    let thoughts = thought_parts[0]
    let thought_names = thought_parts[1]

    let list_content = []
    for name in thought_names
        let list_content += [thoughts[name].file.':'.a:content_sep.thoughts[name].title]
    endfor
    return list_content
endfunction

function! thoughtbox#listThoughtsByNameWithName(content_sep)
    let thought_parts = s:listThoughts()
    let thoughts = thought_parts[0]
    let thought_names = thought_parts[1]

    let list_content = []
    for name in thought_names
        let list_content += [name.a:content_sep.thoughts[name].file.":".a:content_sep.thoughts[name].title]
    endfor
    return list_content
endfunction

function! thoughtbox#listThoughtsByTagWithName(content_sep)
    let thought_parts = s:listThoughts()
    let thoughts = thought_parts[0]
    let thought_names = thought_parts[1]

    let [tagged, keys] = luaeval(
                \'require("thoughtio").groupByTags(_A)',
                \thoughts)

    let list_content = []
    for key in keys
        for name in tagged[key] 
            let list_content += [key.a:content_sep.name.a:content_sep.thoughts[name].file.':'.a:content_sep.thoughts[name].title]
        endfor
    endfor
    return list_content
endfunction

function! thoughtbox#listThoughtsByTag()
    let thought_parts = s:listThoughts()
    let thoughts = thought_parts[0]
    let thought_names = thought_parts[1]

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
    call s:openList(thoughtbox#listThoughtsByName(' '), a:name)
endfunction

function! thoughtbox#splitThoughtListByName()
    call s:splitList(thoughtbox#listThoughtsByName(' '))
endfunction

function! thoughtbox#splitThoughtListByTag()
    call s:splitList(thoughtbox#listThoughtsByTag())
endfunction
