" Disable special handling of # character for indentation
" This prevents the cursor from jumping to the beginning of the line when typing '#'

" Remove '#' from indentation trigger keys
setlocal indentkeys-=0#
setlocal cinkeys-=0#

" Disable smartindent which has special '#' handling for C-style preprocessor directives
setlocal nosmartindent

" Ensure we're not using cindent which also has special '#' behavior
setlocal nocindent

" Use autoindent only (simple indentation that maintains current indent level)
setlocal autoindent

" Set indentexpr to empty to prevent any custom indentation functions
setlocal indentexpr=