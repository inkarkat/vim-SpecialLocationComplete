" Test completion of full tags.

set completefunc=SpecialLocationComplete#SpecialLocationComplete
call SpecialLocationComplete#SetKey('T')
edit tagged.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(9)

call IsMatchesInIsolatedLine('<doesnotexist', [], 'no matches for <doesnotexist')
call IsMatchesInIsolatedLine('<ba', ['<bar>', '<baz>', '<baz alt="true">'], 'matches for <ba')
call IsMatchesInIsolatedLine('</ba', ['</bar>', '</baz>'], 'matches for </ba')
call IsMatchesInIsolatedLine('<r', ['<right border="2">', '<ring/>', '<root>', '<runtime scope="really">'], 'matches for <r')
call IsMatchesInIsolatedLine('<pre', ['<prefix:foo bar="quux" baz="more"/>', '<prefix:fox description="lala">'], 'matches for <pre')
call IsMatchesInIsolatedLine('<Miss', [], 'no matches for <Miss')
call IsMatchesInIsolatedLine('</Miss', ['</MissingOpeningTag>'], 'match for </Miss')
call IsMatchesInIsolatedLine('<dis', [], 'no match for <dis; multi-line tags are not supported')
    :let g:CompleteHelper_DebugPatterns = []
call IsMatchesInIsolatedLine('', ['</Foo>', '</MissingOpeningTag>', '</atr>', '</bar>', '</baz>', '</distinctive>', '</fooxy>', '</prefix:fox>', '</right>', '</root>', '</runtime>', '<Foo>', '<atr wrap=off>', '<atr alt="false" nowrap>', '<bar>', '<baz>', '<baz alt="true">', '<doubled up>', '<fooxy>', '<prefix:foo bar="quux" baz="more"/>', '<prefix:fox description="lala">', '<right border="2">', '<ring/>', '<root>', '<runtime scope="really">', '<suffix:foo bar=''nono''/>'], 'all matches')

call vimtest#Quit()
