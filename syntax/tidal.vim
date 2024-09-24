if exists("b:current_syntax")
  finish
endif

syn match tidalOperator "\$"
syn match tidalOperator "<\$>"
syn match tidalOperator "#"

syn match tidalOperator "+"
syn match tidalOperator "|+"
syn match tidalOperator "|+|"
syn match tidalOperator "+|"

syn match tidalOperator "-"
syn match tidalOperator "|-"
syn match tidalOperator "|-|"
syn match tidalOperator "-|"

syn match tidalOperator "\*"
syn match tidalOperator "|\*"
syn match tidalOperator "|\*|"
syn match tidalOperator "\*|"

syn match tidalNumber "\v\d+"
syn match tidalString "\"[^\"]*\""

syn match tidalComment "-- .*"

hi def link tidalOperator Operator
hi def link tidalNumber Number
hi def link tidalString String
hi def link tidalComment Comment

let b:current_syntax = "tidal"
