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
        let path = split(path,':')[0]
        exe 'wincmd p'
        exe a:method.' '.fnameescape(path)
    endfor
endfunction



function! thoughtbox#newThought(name)
python3 << endOfPython

from pythoughts import NewThought

directory = vim.eval('g:thoughtbox#folder')
name = vim.eval('a:name')

nextName = NewThought.findNextFileNameInDirectory(directory, name)

vim.command(':e %s' % nextName)

cb = vim.current.buffer
cb[:] = NewThought.getNewThoughtTemplate()

endOfPython
endfunction

function! thoughtbox#listThoughts()
    let window_details = utils#OpenListWindow(g:thoughtbox#vertical_split, 
                \ g:thoughtbox#open_pos, 
                \ g:thoughtbox#split_size, 
                \ '_thought_list_', 
                \ 'thoughtlist',
                \ g:thoughtbox#list_auto_close, 
                \ g:thoughtbox#list_jump_to_on_open)

python3 << endOfPython

from pythoughts import ThoughtInfo

directory = vim.eval('g:thoughtbox#folder')

names = ThoughtInfo.listThougthNumberAndTitle(directory)
content = [ '%s: %s' % (f, t) for n,f, t in names ]

cb = vim.current.buffer
cb[:] = content

endOfPython

    setlocal conceallevel=2 
    setlocal concealcursor=nvc
    setlocal cursorline
    call search('.*\'.s:sep.'\ze[^\'.s:sep.']\+\'.s:sep.'\?:', 'ce', line('.'))
endfunction
