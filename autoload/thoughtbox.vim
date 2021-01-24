let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'

function! thoughtbox#open(method) range
    if a:method == 'edit'
        let firstline=a:lastline
    else
        let firstline=a:firstline
    endif
    let paths = getline(firstline, a:lastline)
    for path in paths
        let parts = split(trim(path),':')
        let path = parts[0]
        if len(parts) == 1
            echom 'Ignoring: '.path
            continue
        end
        exe 'wincmd p'
        exe a:method.' '.fnameescape(path)
    endfor
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

    call utils#OpenListWindow( 
                \ g:thoughtbox#vertical_split,
                \ g:thoughtbox#open_pos,
                \ g:thoughtbox#split_size,
                \ "_thought_list_",
                \ "thoughtlist",
                \ g:thoughtbox#list_auto_close,
                \ g:thoughtbox#list_jump_to_on_open)

    call deletebufline("%",1,"$")
    call append(0,list_content)

    setlocal conceallevel=2
    setlocal concealcursor=nvc
    setlocal cursorline
    call cursor(1,0)
    call search(':', 'ce', line('.'))

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

    call utils#OpenListWindow( 
                \ g:thoughtbox#vertical_split,
                \ g:thoughtbox#open_pos,
                \ g:thoughtbox#split_size,
                \ "_thought_list_",
                \ "thoughtlist",
                \ g:thoughtbox#list_auto_close,
                \ g:thoughtbox#list_jump_to_on_open)

    call deletebufline("%",1,"$")
    call append(0,list_content)

    setlocal conceallevel=2
    setlocal concealcursor=nvc
    setlocal cursorline
    call cursor(1,0)
    call search(':', 'ce', line('.'))
endfunction
