" SpecialLocationComplete.vim: Insert mode completion for special custom patterns.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - SpecialLocationComplete.vim autoload script
"
" Copyright: (C) 2015-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.10.004	10-Jun-2016	ENH: Add new <C-t> default completion of full
"				tag attributes (e.g. <tag foo="bar">).
"				ENH: Add new it default completion for text
"				between tags.
"   1.00.003	19-Feb-2015	Tweak default tagname configuration to also
"				consider closing tags, and complete only the
"				tagname without leading < when that isn't part
"				of the base.
"   1.00.002	16-Feb-2015	Add another default pattern for tagname.
"				Simplify base pattern; it doesn't need to match.
"	001	13-Feb-2015	file creation

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
    \       'description': 'tagname',
    \       'base': '\%(</\?\)\?\zs\%([[:alpha:]_:]\|[^\x00-\x7F]\)\%([-._:[:alnum:]]\|[^\x00-\x7F]\)*\%#',
    \       'patternTemplate': '</\?\zs%s\%([-._:[:alnum:]]\|[^\x00-\x7F]\)\+',
    \       'repeatAnchorExpr': '',
    \   },
    \   'T': {
    \       'description': 'full tag',
    \       'base': '<[^>]*\%#',
    \       'patternTemplate': '<<\@!\&<\?%s[^>]\+>',
    \       'repeatPatternTemplate': '%S\_.\{-}\zs<[^<]\+>',
    \   },
    \   '': {
    \       'description': 'tag attribute',
    \       'base': '\%([a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\%(\%(''[^'']*\|"[^"]*\)\)\?\)\?\)\?\%#',
    \       'patternTemplate': '<\_[^>]*\%(\s\+[a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)*\s\+\zs\%(%s\&\%([a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)\)\ze\%(\_s\|/\?>\)',
    \       'emptyBasePattern': '\%(\%(<\_[^>]*\%(\s\+[a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)*\s\+\)\@<=\|\%(\n\s*\)\@<=\)\%([a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)\ze\%(\_s\|/\?>\)',
    \       'repeatPatternTemplate': '%S\zs\_s\+\%([a-zA-Z:_][-.0-9a-zA-Z:_]*\%(=\([''"]\).\{-\}\1\)\?\)\ze\%(\_s\|/\?>\)',
    \   },
    \   'it': {
    \       'description': 'between tags',
    \       'base': '\%(>\zs[^<>]*\|\k*\)\%#',
    \       'patternTemplate': ['>\zs%s\_[^<>]\{-}\%(\S\&[^<>]\)\_[^<>]*\ze<', '>\zs\_[^<>]\{-1,}%s\_[^<>]*\ze<'],
    \       'repeatPatternTemplate': '%s\zs<\_[^>]\+>\_[^<>]\{-}\%(\S\&[^<>]\)\_[^<>]*\ze<',
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
