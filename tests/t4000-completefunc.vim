" Test completion via complete function.

source helpers/completefunc.vim
set completefunc=SpecialLocationComplete#SpecialLocationComplete
call SpecialLocationComplete#SetKey('f')

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(3)

call IsMatchesInIsolatedLine('doesnotexist', [], 'no matches for doesnotexist')
call IsMatchesInIsolatedLine('f', ['foobar'], 'single match for f')
call IsMatchesInIsolatedLine('ba', ['bar', 'baz'], 'matches for ba')

call vimtest#Quit()
