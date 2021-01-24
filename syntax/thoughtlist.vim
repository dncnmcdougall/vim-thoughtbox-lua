if 'thoughtlist' !=# get(b:, 'current_syntax', 'thoughtlist')
  finish
endif

let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'
let s:escape = 'substitute(escape(v:val, ".$~"), "*", ".*", "g")'

if !exists('b:current_syntax')
    let start = '+^\s*\zs.*\'.s:sep.'\ze[^\'.s:sep.']\+:+'
    let end = '+\.[^\'.s:sep.'.]\{-}:\@=+'
    echom start.'     '.end
    exe 'syntax region ThoughtListTitle matchgroup=ThoughtListPath start='.start.' end='.end.' oneline concealends'

endif

let b:current_syntax = 'thoughtlist'
