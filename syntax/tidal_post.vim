" Syntax highlighting for tidal post window.

scriptencoding utf-8

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'tidal_post'

syn case match

syn match superdirtwait /^Waiting for SuperDirt.*$/
syn match superdirthandshake /^Connected to SuperDirt\./

syn match ghciError /error:/

hi def link superdirtwait WarningMsg
hi def link superdirthandshake OkMsg

hi def link ghciError ErrorMsg
