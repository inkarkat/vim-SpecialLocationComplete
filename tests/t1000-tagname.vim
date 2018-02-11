" Test completion of tagnames.

set completefunc=SpecialLocationComplete#SpecialLocationComplete
call SpecialLocationComplete#SetKey('t')
edit tagged.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(7)

call IsMatchesInIsolatedLine('doesnotexist', [], 'no matches for doesnotexist')
call IsMatchesInIsolatedLine('dis', ['distinctive'], 'single match for dis')
call IsMatchesInIsolatedLine('ba', ['bar', 'baz'], 'matches for ba')
call IsMatchesInIsolatedLine('r', ['right', 'ring', 'root', 'runtime'], 'matches for r')
call IsMatchesInIsolatedLine('pre', ['prefix:foo', 'prefix:fox'], 'matches for pre')
call IsMatchesInIsolatedLine('Miss', ['MissingOpeningTag'], 'match for Miss')
call IsMatchesInIsolatedLine('', ['Foo', 'MissingOpeningTag', 'atr', 'bar', 'baz', 'distinctive', 'doubled', 'fooxy', 'prefix:foo', 'prefix:fox', 'right', 'ring', 'root', 'runtime', 'suffix:foo'], 'all matches')

call vimtest#Quit()
