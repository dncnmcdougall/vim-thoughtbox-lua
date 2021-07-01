if 'thoughtbox' !=# get(b:, 'current_syntax', 'thoughtbox')
  finish
endif

source $VIMRUNTIME/syntax/markdown.vim

syn match thoughtboxLink "\[\[.\{-}\]\]" 
hi def link thoughtboxLink htmlLink

let b:current_syntax = 'thoughtbox'
