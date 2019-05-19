" SpecialLocationComplete.vim: Insert mode completion for special custom patterns.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"
" Copyright: (C) 2015-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_SpecialLocationComplete') || (v:version < 700)
    finish
endif
let g:loaded_SpecialLocationComplete = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration ---------------------------------------------------------------

if ! exists('g:SpecialLocationCompletions')
    let g:SpecialLocationCompletions = {
    \   't': {
    \       'priority': 1000,
    \       'description': 'tagname',
    \       'base': '\%(</\?\)\?\zs\%([[:alpha:]_:]\|[^\x00-\x7F]\)\%([-._:[:alnum:]]\|[^\x00-\x7F]\)*\%#',
    \       'patternTemplate': '</\?\zs%s\%([-._:[:alnum:]]\|[^\x00-\x7F]\)\+',
    \       'repeatAnchorExpr': '',
    \   },
    \   'T': {
    \       'priority': 1010,
    \       'description': 'full tag',
    \       'base': '<[^>]*\%#',
    \       'patternTemplate': '<<\@!\&<\?%s[^>]\+>',
    \       'repeatPatternTemplate': '%S\_.\{-}\zs<[^<]\+>',
    \   },
    \   '': {
    \       'priority': 1020,
    \       'description': 'tag attribute',
    \       'base': '\%([a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\%(\%(''[^'']*\|"[^"]*\)\)\?\)\?\)\?\%#',
    \       'patternTemplate': '<\_[^>]*\%(\s\+[a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)*\s\+\zs\%(%s\&\%([a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)\)\ze\%(\_s\|/\?>\)',
    \       'emptyBasePattern': '\%(\%(<\_[^>]*\%(\s\+[a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)*\s\+\)\@<=\|\%(\n\s*\)\@<=\)\%([a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)\ze\%(\_s\|/\?>\)',
    \       'repeatPatternTemplate': '%S\zs\_s\+\%([a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)\ze\%(\_s\|/\?>\)',
    \   },
    \   'it': {
    \       'priority': 1030,
    \       'description': 'between tags',
    \       'base': '\%(>\zs[^<>]*\|\k*\)\%#',
    \       'patternTemplate': ['>\zs%s\_[^<>]\{-}\%(\S\&[^<>]\)\_[^<>]*\ze<', '>\zs\_[^<>]\{-1,}%s\_[^<>]*\ze<'],
    \       'repeatPatternTemplate': '%s\zs<\_[^>]\+>\_[^<>]\{-}\%(\S\&[^<>]\)\_[^<>]*\ze<',
    \   },
    \   'num': {
    \       'priority': 5000,
    \       'base': '\d*\%#',
    \       'patternTemplate': ['\%(^\|\D\)\zs%s\d\+\ze\%(\D\|$\)', '\%(^\|\D\)\zs\d\+%s\d*\ze\%(\D\|$\)'],
    \   },
    \   'hex': {
    \       'priority': 5010,
    \       'base': '\x*\%#',
    \       'patternTemplate': ['\%(0x\|^\|\X\)\zs%s\x\+\ze\%(\X\|$\)', '\%(0x\|^\|\X\)\zs\x\+%s\x*\ze\%(\X\|$\)'],
    \       'emptyBasePattern': '\%(0x\|^\|\X\)\zs\x\{2,}\ze\%(\X\|$\)',
    \   },
    \   'uuid': {
    \       'priority': 5050,
    \       'base': '[[:xdigit:]-]*\%#',
    \       'patternTemplate': ['\%(^\|\X\)\zs\%(%s\&\x\{8}-\?\x\{4}-\?\x\{4}-\?\x\{4}-\?\x\{12}\)\ze\%(\X\|$\)', '\%(^\|\X\)\zs\%([[:xdigit:]-]\+%s\&\x\{8}-\?\x\{4}-\?\x\{4}-\?\x\{4}-\?\x\{12}\)\ze\%(\X\|$\)',],
    \       'emptyBasePattern': '\%(^\|\X\)\zs\x\{8}-\?\x\{4}-\?\x\{4}-\?\x\{4}-\?\x\{12}\ze\%(\X\|$\)',
    \   },
    \}
    " ^T emptyBasePattern: The \@<= only looks behind _one_ additional line; in
    " order to also capture attributes on further lines, we need the alternative
    " branch that only checks for \n\s* instead of looking back to the tag
    " start.
endif


"- mappings --------------------------------------------------------------------

inoremap <silent> <expr> <Plug>(SpecialLocationComplete) SpecialLocationComplete#Expr()
if ! hasmapto('<Plug>(SpecialLocationComplete)', 'i')
    imap <C-x><C-x> <Plug>(SpecialLocationComplete)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
