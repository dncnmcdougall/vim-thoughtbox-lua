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

