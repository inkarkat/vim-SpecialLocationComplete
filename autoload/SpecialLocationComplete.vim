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
    return [a:key, get(s:GetConfig(a:key)[1], 'description', '')]
endfunction
function! s:PrintAvailableKeys()
    let l:keys = s:GetAllConfigKeys()
    if empty(l:keys)
	return 0
    endif

    echohl ModeMsg
    echo '-- Special location completion:'

    for [l:key, l:description] in map(l:keys, 's:CreateHint(v:val)')
	if empty(l:description)
	    echon ' ' . l:key
	else
	    echon ' ' . l:key
	    echohl None
	    echon '(' . l:description . ')'
	    echohl ModeMsg
	endif
    endfor

    echohl None
    return 1
endfunction

function! s:GetOptions()
    let [l:scope, l:options] = s:GetConfig(s:key)
    if empty(l:options)
	throw 'SpecialLocationComplete: No such key'
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

    return l:options
endfunction
function! s:ExpandTemplate( template, value )
    return substitute(a:template, '%s', "\\='\\V' . a:value . '\\m'", 'g')
endfunction
let s:repeatCnt = 0
function! SpecialLocationComplete#SpecialLocationComplete( findstart, base )
    if ! exists('s:key')
	if ! s:PrintAvailableKeys()
	    return -1
	endif

	let s:key = ingo#query#get#Char()

	if a:findstart
	    " Invoked by CompleteHelper#Repeat#TestForRepeat(); continue to
	    " determine the base.
	else
	    " Just invoked to query for s:key.
	    return ''
	endif
    endif

    try
	let l:options = s:GetOptions()

	if s:repeatCnt
	    if a:findstart
		return col('.') - 1
	    else
		if has_key(l:options, 'repeatPatternTemplate')
		    " Need to translate the embedded ^@ newline into the \n atom.
		    let l:previousCompleteExpr = substitute(escape(s:fullText, '\'), '\n', '\\n', 'g')

		    let l:repeatPattern = s:ExpandTemplate(l:options.repeatPatternTemplate, l:previousCompleteExpr)
		else
		    let l:repeatPatternArguments = [s:fullText]
		    if has_key(l:options, 'repeatAnchorExpr')
			call add(l:repeatPatternArguments, l:repeatAnchorExpr)
			if has_key(l:options, 'repeatPositiveExpr')
			    call add(l:repeatPatternArguments, l:repeatPositiveExpr)
			    if has_key(l:options, 'repeatNegativeExpr')
				call add(l:repeatPatternArguments, l:repeatNegativeExpr)
			    endif
			endif
		    endif
		    let l:repeatPattern = call('CompleteHelper#Repeat#GetPattern', l:repeatPatternArguments)
		endif

		let l:options.processor = function('CompleteHelper#Repeat#Processor')

		let l:matches = []
		call CompleteHelper#FindMatches(l:matches,
		\   l:repeatPattern,
		\   l:options
		\)
		if empty(l:matches)
		    call CompleteHelper#Repeat#Clear()
		endif
		return l:matches
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
	    let l:pattern = s:ExpandTemplate(get(l:options, 'patternTemplate', '\<%s\k\+'), escape(a:base, '\'))

	    let l:matches = []
	    call CompleteHelper#FindMatches(l:matches, l:pattern, l:options)
	    return l:matches
	endif
    catch /^SpecialLocationComplete:/
	return -1
    endtry
endfunction

function! SpecialLocationComplete#Expr()
    " If this is not a repeat, CompleteHelper#Repeat#TestForRepeat() invokes
    " 'completefunc' to determine the future base. We need to query the user
    " (once!) before that.
    let l:save_key = (exists('s:key') ? s:key : '')
    unlet! s:key
    set completefunc=SpecialLocationComplete#SpecialLocationComplete

    let s:repeatCnt = 0 " Important!
    let [s:repeatCnt, l:addedText, s:fullText] = CompleteHelper#Repeat#TestForRepeat()
echomsg '****' string([s:repeatCnt, l:addedText, s:fullText])
    if s:repeatCnt
	" In the repeat case, above 'completefunc' hasn't yet been invoked.
	" Restore the previous key to enable proper repeat without re-querying
	" it from the user.
	let s:key = l:save_key
    endif

    return "\<C-x>\<C-u>"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
