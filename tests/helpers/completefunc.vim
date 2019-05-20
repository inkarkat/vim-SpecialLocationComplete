function! StaticCompletion( findstart, base ) abort
    if a:findstart
	return searchpos('\k*\%#', 'bn', line('.'))[1] - 1
    else
	return map(
	\   filter(['foobar', 'bar', 'baz'], 'v:val =~ "\\V\\^" . escape(a:base, "\\")'),
	\   '{"word": v:val}'
	\)
    endif
endfunction
let g:SpecialLocationCompletions['f'] = {
\   'completefunc': 'StaticCompletion'
\}
