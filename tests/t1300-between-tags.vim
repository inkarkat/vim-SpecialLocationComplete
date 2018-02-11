" Test completion of text between tags.

set completefunc=SpecialLocationComplete#SpecialLocationComplete
call SpecialLocationComplete#SetKey('it')
edit tagged.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(8)

call IsMatchesInIsolatedLine('doesnotexist', [], 'no matches for doesnotexist')
call IsMatchesInIsolatedLine('in', ['inner', 'inside'], 'matches for in')
call IsMatchesInIsolatedLine('quu', [], 'no matches for quu')
call IsMatchesInIsolatedLine('<gaga>some t', ['some text'], 'matches for <gaga>some t')
call IsMatchesInIsolatedLine('some t', ['tag', 'there'], 'matches for some t')
call IsMatchesInIsolatedLine('', ['here', 'inner', 'inside', 'second', 'some text', 'tag', 'there'], 'all matches')

call IsMatchesInIsolatedLine('con', ['second'], 'relaxed match for side')
call IsMatchesInIsolatedLine('side', ['inside'], 'relaxed match for side')

call vimtest#Quit()
