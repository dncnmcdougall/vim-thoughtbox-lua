
" 
" vertical: 1|0
" openpos: topleft|botright|aboveleft|belowright
" size: width in chars if vertical, lines if horizontal
" name: the name of the buffer
" filetype: the filetype to set it to
" autoclose: 1|0 whether to set autoclose
" jump: 1|0 whether to set jump to the newly opened window
function! utils#OpenListWindow( vertical, openpos, size, name, filetype, autoclose, jump)

    let prevwinid = win_getid()

    if a:vertical == 0
        let mode = ' '
    else
        let mode = ' vertical '
    endif

    exe 'silent keepalt ' . a:openpos . mode . a:size . 'split ' . a:name
    exe 'silent ' . mode . 'resize ' . a:size
    exe 'setlocal filetype=' . a:filetype

    setlocal noreadonly 
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal textwidth=0
    setlocal nolist
    setlocal nowrap
    setlocal nospell
    setlocal nonumber
    setlocal nofoldenable
    setlocal foldcolumn=0

    if a:autoclose == 1
        autocmd! WinLeave <buffer> ++once :quit
    endif

    let details = {'winnr': winnr(), 'tabnr': tabpagenr(), 'winid': win_getid(), 'bufnr': bufnr()}
    if a:jump == 0
        noautocmd call win_gotoid(prevwinid)
    endif

    return details
endfunction
