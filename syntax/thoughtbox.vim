if 'thoughtbox' !=# get(b:, 'current_syntax', 'thoughtbox')
  finish
endif

source $VIMRUNTIME/syntax/markdown.vim

let b:current_syntax = 'thoughtbox'
