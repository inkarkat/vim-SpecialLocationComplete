" SpecialLocationComplete.vim: Insert mode completion for special custom patterns.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - SpecialLocationComplete.vim autoload script
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
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
    \       'description': 'tags',
    \       'base': '\%(<[^>]*\)*\%#',
    \       'patternTemplate': '<<\@!\&<\?%s[^>]\+>',
    \       'repeatPatternTemplate': '%S\_.\{-}\zs<[^<]\+>',
    \   }
    \}
endif


"- mappings --------------------------------------------------------------------

inoremap <silent> <expr> <Plug>(SpecialLocationComplete) SpecialLocationComplete#Expr()
if ! hasmapto('<Plug>(SpecialLocationComplete)', 'i')
    imap <C-x><C-x> <Plug>(SpecialLocationComplete)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
