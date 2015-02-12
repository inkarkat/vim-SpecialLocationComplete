" SpecialLocationComplete.vim: Insert mode completion for special custom patterns.
"
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script
"   - Complete/Repeat.vim autoload script
"   - ingo/plugin/setting.vim autoload script
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	13-Feb-2015	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:GetConfig( key )
    if exists('w:SpecialLocationCompletions') && has_key(w:SpecialLocationCompletions, a:key)
	return ['w', w:SpecialLocationCompletions[a:key]]
    elseif exists('b:SpecialLocationCompletions') && has_key(b:SpecialLocationCompletions, a:key)
	return ['b', b:SpecialLocationCompletions[a:key]]
    elseif exists('g:SpecialLocationCompletions') && has_key(g:SpecialLocationCompletions, a:key)
	return ['g', g:SpecialLocationCompletions[a:key]]
    else
	return ['', {}]
    endif
endfunction
function! s:GetAllConfigKeys()
    let l:keys = []
    for l:key in
    \   (exists('w:SpecialLocationCompletions') ? sort(keys(w:SpecialLocationCompletions)) : []) +
    \   (exists('b:SpecialLocationCompletions') ? sort(keys(b:SpecialLocationCompletions)) : []) +
    \   (exists('g:SpecialLocationCompletions') ? sort(keys(g:SpecialLocationCompletions)) : [])
	if index(l:keys, l:key) == -1
	    call add(l:keys, l:key)
	endif
    endfor
    return l:keys
endfunction
function! s:CreateHint( key )
    let l:config = s:GetConfig(a:key)[1]
    return (has_key(l:config, 'description') ?
    \   printf('%s:%s', a:key, l:config.description) :
    \   a:key
    \)
endfunction
function! s:PrintAvailableKeys()
    let l:keys = s:GetAllConfigKeys()
    if empty(l:keys)
	return 0
    endif

    let keyHints = map(l:keys, 's:CreateHint(v:val)')

    echohl ModeMsg
    echo printf('-- Special location completion: %s', join(l:keyHints, ' '))
    echohl None
    return 1
endfunction

let s:repeatCnt = 0
function! SpecialLocationComplete#SpecialLocationComplete( findstart, base )
    if s:repeatCnt
	if a:findstart
	    return col('.') - 1
	else
	    let l:matches = []
	    call CompleteHelper#FindMatches(l:matches,
	    \   CompleteHelper#Repeat#GetPattern(s:fullText, '\%(\^\|\A\)', '\a', '\A'),
	    \   {'complete': s:GetCompleteOption(), 'processor': function('CompleteHelper#Repeat#Processor')}
	    \)
	    if empty(l:matches)
		call CompleteHelper#Repeat#Clear()
	    endif
	    return l:matches
	endif
    endif

    let [l:scope, l:options] = s:GetConfig(s:key)
    if empty(l:options)
	return -1
    elseif ! has_key(l:options, 'complete')
	" Default to a completion scope that corresponds to the config scope.
	if l:scope ==# 'w'
	    let l:options.complete = '.,w'
	elseif l:scope ==# 'b'
	    let l:options.complete = '.'
	elseif l:scope ==# 'g'
	    let l:options.complete = &complete
	else
	    throw 'ASSERT: Unknown scope: ' . string(l:scope)
	endif
    endif

    if a:findstart
	" Locate the start of the configured characters.
	let l:base = get(l:options, 'base', '\k\*\%#')

	let l:startCol = searchpos(l:base, 'bn', line('.'))[1]
	if l:startCol == 0
	    let l:startCol = col('.')
	endif
	return l:startCol - 1 " Return byte index, not column.
    else
	" Find matches.
	let l:pattern = substitute(get(l:options, 'patternTemplate', '\<%s\k\+'), '%s', "\\='\\V' . escape(a:base, '\\') . '\\m'", 'g')

	let l:matches = []
	call CompleteHelper#FindMatches(l:matches, l:pattern, l:options)
	return l:matches
    endif
endfunction

function! SpecialLocationComplete#Query( findstart, base )
    if ! s:PrintAvailableKeys()
	return -1
    endif

    let s:key = ingo#query#get#Char()

    return (a:findstart ? SpecialLocationComplete#SpecialLocationComplete(a:findstart, a:base) : '')
endfunction
function! SpecialLocationComplete#Expr()
    " If this is not a repeat, CompleteHelper#Repeat#TestForRepeat() invokes
    " 'completefunc' to determine the future base. We need to query the user
    " (once!) before that. So install the query temporarily.
    unlet! s:key
    set completefunc=SpecialLocationComplete#Query

    let s:repeatCnt = 0 " Important!
    let [s:repeatCnt, l:addedText, s:fullText] = CompleteHelper#Repeat#TestForRepeat()
    if ! exists('s:key')
	" In the repeat case, above 'completefunc' hasn't yet been invoked. Do
	" this now in order to query the user for the key. Don't unnecessarily
	" determine the base again; disable that via a:findstart = 0.
	call SpecialLocationComplete#Query(0, '')
    endif

    " Now install the actual complete function, and trigger it.
    set completefunc=SpecialLocationComplete#SpecialLocationComplete
    return "\<C-x>\<C-u>"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
