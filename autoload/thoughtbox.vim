let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'

function! thoughtbox#open(method) range
    echom 'range: '.a:firstline.': '.a:lastline
    if a:method == 'edit'
        let firstline=a:lastline
    else
        let firstline=a:firstline
    endif
    let paths = getline(firstline, a:lastline)
    for path in paths
        let path = split(trim(path),':')[0]
        exe 'wincmd p'
        exe a:method.' '.fnameescape(path)
    endfor
endfunction

function! thoughtbox#listThoughtsByName()
    let thoughts = readdir(expand(g:thoughtbox#folder), { n -> n =~ ".tb$"})

    let thoughts = luaeval(
                \'require("thoughtbox").sortNames(_A)',
                \thoughts)
    let sep = exists('+shellslash') && !&shellslash ? '\\' : '/'

    let thought_names = []
    for thought in thoughts
        let thought_file = expand(g:thoughtbox#folder. sep . thought. '.tb')
        let lines = readfile(thought_file,'', 3)
        let content = luaeval(
                    \ 'require("thoughtbox").parseThoughtContent(unpack(_A))',
                    \ [lines, thought])
        let thought_names += [thought_file.': '.content.title]
    endfor

    utils#OpenListWindow( 
                \ g:thoughtbox#vertical_split,
                \ g:thoughtbox#open_pos,
                \ g:thoughtbox#split_size,
                \ "_thought_list_",
                \ "thoughtlist",
                \ g:thoughtbox#list_auto_close,
                \ g:thoughtbox#list_jump_to_on_open)

    call append(0,thought_names)

    setlocal conceallevel=2
    setlocal concealcursor=nvc
    setlocal cursorline
    call search('.*\\'.sep.'\\ze[^\\'.sep.']\\.\\'.sep.'\\?:', 'ce', line('.'))

endfunction

