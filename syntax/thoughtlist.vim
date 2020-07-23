if 'thoughtlist' !=# get(b:, 'current_syntax', 'thoughtlist')
  finish
endif

let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'
let s:escape = 'substitute(escape(v:val, ".$~"), "*", ".*", "g")'

if !exists('b:current_syntax')
    exe 'syntax match ThoughtListPathHead =^\s*\zs.*\'.s:sep.'\ze[^\'.s:sep.']\+:= conceal'
    exe 'syntax match ThoughtListPathTail +[^\'.s:sep.']\+\.\@=+'
    exe 'syntax match ThoughtListSuffix   +\.[^\'.s:sep.']\{-}:\@=+ conceal'
endif

let b:current_syntax = 'thoughtlist'
