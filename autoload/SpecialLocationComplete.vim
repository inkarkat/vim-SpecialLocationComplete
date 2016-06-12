" SpecialLocationComplete.vim: Insert mode completion for special custom patterns.
"
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script
"   - Complete/Repeat.vim autoload script
"   - ingo/list.vim autoload script
"   - ingo/query/get.vim autoload script
"
" Copyright: (C) 2015-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.10.005	13-Jun-2016	ENH: Visualize remaining keys to be typed by
"				bracketing with [...] in s:PrintAvailableKeys().
"				Otherwise, if there's only a single match but
"				multiple keys remaining, there's no progress
"				indication.
"				Also print chosen completion after it has been
"				queried so that the last typing hint does not
"				remain on the screen, which is confusing.
"				Refactoring: Make s:GetAllConfigKeys() return
"				the entire configuration as s:GetConfig(), and
"				obsolete s:GetConfig(key), s:GetOptions().
"   1.10.004	10-Jun-2016	FIX: CompleteHelper#Repeat#Processor() condenses
"				a new line and the following indent to a single
"				space; need to translate that. Otherwise,
"				repeats using %S in the
"				a:options.repeatPatternTemplate will not work on
"				tab-indented or multi-line matches.
"				ENH: Support multiple keys for triggering a
"				special completion.
"				ENH: Support Lists of a:options.patternTemplate
"				and a:options.emptyBasePattern; these are
"				searched sequentially until one yields matches.
"				This allows fallbacks, e.g. a relaxed search
"				anywhere vs. a strict search for base at the
"				beginning.
"   1.00.003	19-Feb-2015	Support a:options.emptyBasePattern.
"				Add SpecialLocationComplete#SetKey() and
"				SpecialLocationComplete#GetKey() for testing.
"				Allow passing a key to
"				SpecialLocationComplete#Expr() to enable custom
"				direct mappings.
"   1.00.002	16-Feb-2015	Need to get repeat...Expr from a:options; there
"				are no local variables.
"	001	13-Feb-2015	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:SetDefaultComplete( config, defaultCompleteValue )
    for [l:key, l:options] in items(a:config)
	let l:options.complete = get(l:options, 'complete', a:defaultCompleteValue)
    endfor
endfunction
function! s:GetConfig()
    let l:config = {}
    if exists('w:SpecialLocationCompletions')
	call extend(l:config, w:SpecialLocationCompletions, 'keep')
	call s:SetDefaultComplete(l:config, '.,w')
    endif
    if exists('b:SpecialLocationCompletions')
	call extend(l:config, b:SpecialLocationCompletions, 'keep')
	call s:SetDefaultComplete(l:config, '.')
    endif
    if exists('g:SpecialLocationCompletions')
	call extend(l:config, g:SpecialLocationCompletions, 'keep')
	call s:SetDefaultComplete(l:config, &complete)
    endif

    return l:config
endfunction
function! s:CreateHint( config, key )
    return [a:key, get(a:config[a:key], 'description', '')]
endfunction
function! s:PrintAvailableKeys( config, keys, typedKey )
    if empty(a:keys)
	return 0
    endif

    echohl ModeMsg
    echo '-- Special location completion:'

    for [l:key, l:description] in map(copy(a:keys), 's:CreateHint(a:config, v:val)')
	let l:keyWithTypeHint = (empty(a:typedKey) ?
	\   l:key :
	\   substitute(l:key, '\C\V\^\(' . escape(a:typedKey, '\') . '\)\(\.\+\)\$', '\1[\2]', '')
	\)

	if empty(l:description)
	    echon ' ' . l:keyWithTypeHint
	else
	    echon ' ' . l:keyWithTypeHint
	    echohl None
	    echon '(' . l:description . ')'
	    echohl ModeMsg
	endif
    endfor

    echohl None
    return 1
endfunction

function! s:ExpandTemplate( template, value, ... )
    return substitute(a:template, '%' . (a:0 ? '[sS]' : 's'), "\\='\\V' . (a:0 && submatch(0) ==# '%S' ? a:1 : a:value) . '\\m'", 'g')
endfunction
function! SpecialLocationComplete#GetKey( config )
    let l:key = ''

    while 1
	call inputsave()
	    let l:keypress = ingo#query#get#Char()
	call inputrestore()

	if empty(l:keypress)
	    " Abort.
	    return ''
	endif
	let l:key .= l:keypress
	if has_key(a:config, l:key)
	    call s:PrintAvailableKeys(a:config, [l:key], '')
	    return l:key
	endif
	let l:applicableKeys = filter(keys(a:config), 'ingo#str#StartsWith(v:val, l:key)')
	if empty(l:applicableKeys)
	    " No such key.
	    return ''
	endif

	call s:PrintAvailableKeys(a:config, l:applicableKeys, l:key)
    endwhile
endfunction
function! SpecialLocationComplete#SetKey( key )
    let s:key = a:key
endfunction
let s:repeatCnt = 0
function! SpecialLocationComplete#SpecialLocationComplete( findstart, base )
    let l:config = s:GetConfig()
    if ! exists('s:key')
	if ! s:PrintAvailableKeys(l:config, keys(l:config), '')
	    return -1
	endif

	let s:key = SpecialLocationComplete#GetKey(l:config)

	if a:findstart
	    " Invoked by CompleteHelper#Repeat#TestForRepeat(); continue to
	    " determine the base.
	else
	    " Just invoked to query for s:key.
	    return ''
	endif
    endif

    try
	let l:options = l:config[s:key]

	if s:repeatCnt
	    if a:findstart
		return col('.') - 1
	    else
		if has_key(l:options, 'repeatPatternTemplate')
		    let l:previousFullCompleteExpr = escape(s:fullText, '\')
		    let l:previousAddedCompleteExpr = escape(s:addedText, '\')

		    " CompleteHelper#Repeat#Processor() condenses a new line and
		    " the following indent to a single space; need to translate
		    " that. (But only for the added text; the other is kept
		    " as-is!)
		    let l:previousAddedCompleteExpr = substitute(l:previousAddedCompleteExpr, '^ ', '\\_s\\+', '')

		    " Need to translate the embedded ^@ newline into the \n atom.
		    let l:previousFullCompleteExpr = substitute(l:previousFullCompleteExpr, '\n', '\\n', 'g')
		    let l:previousAddedCompleteExpr = substitute(l:previousAddedCompleteExpr, '\n', '\\n', 'g')

		    let l:repeatPattern = s:ExpandTemplate(l:options.repeatPatternTemplate, l:previousFullCompleteExpr, l:previousAddedCompleteExpr)
		else
		    let l:repeatPatternArguments = [s:fullText]
		    if has_key(l:options, 'repeatAnchorExpr')
			call add(l:repeatPatternArguments, l:options.repeatAnchorExpr)
			if has_key(l:options, 'repeatPositiveExpr')
			    call add(l:repeatPatternArguments, l:options.repeatPositiveExpr)
			    if has_key(l:options, 'repeatNegativeExpr')
				call add(l:repeatPatternArguments, l:options.repeatNegativeExpr)
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
	    let l:isSpecialEmptyBasePattern = (empty(a:base) && has_key(l:options, 'emptyBasePattern'))
	    let l:rawPatterns = ingo#list#Make(
	    \   (l:isSpecialEmptyBasePattern ?
	    \       get(l:options, 'emptyBasePattern') :
	    \       get(l:options, 'patternTemplate', '\<%s\k\+')
	    \   ),
	    \   1
	    \)

	    let l:matches = []
	    let l:fallbackCnt = 0
	    while ! empty(l:rawPatterns)
		if l:fallbackCnt > 0
		    echohl ModeMsg
		    echo printf('-- User defined completion (^U^N^P) -- Fallback%s search...', (l:fallbackCnt > 1 ? ' ' . l:fallbackCnt : ''))
		    echohl None
		endif

		let l:pattern = remove(l:rawPatterns, 0)
		if ! l:isSpecialEmptyBasePattern
		    let l:pattern =  s:ExpandTemplate(l:pattern, escape(a:base, '\'))
		endif

		call CompleteHelper#FindMatches(l:matches, l:pattern, l:options)
		if ! empty(l:matches)
		    break
		endif

		let l:fallbackCnt += 1
	    endwhile
	    return l:matches
	endif
    catch /^SpecialLocationComplete:/
	return -1
    endtry
endfunction

function! SpecialLocationComplete#Expr( ... )
    if a:0
	let s:key = a:1
    else
	" If this is not a repeat, CompleteHelper#Repeat#TestForRepeat() invokes
	" 'completefunc' to determine the future base. We need to query the user
	" (once!) before that.
	let l:save_key = (exists('s:key') ? s:key : '')
	unlet! s:key
    endif

    set completefunc=SpecialLocationComplete#SpecialLocationComplete

    let s:repeatCnt = 0 " Important!
    let [s:repeatCnt, s:addedText, s:fullText] = CompleteHelper#Repeat#TestForRepeat()

    if s:repeatCnt && exists('l:save_key')
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
