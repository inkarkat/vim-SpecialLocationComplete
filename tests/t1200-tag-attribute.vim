" Test completion of tag attribute.

set completefunc=SpecialLocationComplete#SpecialLocationComplete
call SpecialLocationComplete#SetKey('')
edit tagged.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(15)

call IsMatchesInIsolatedLine('doesnotexist', [], 'no matches for doesnotexist')
call IsMatchesInIsolatedLine('cription', [], 'no matches for cription')
call IsMatchesInIsolatedLine('sco', ['scope="really"'], 'match for sco')
call IsMatchesInIsolatedLine('cla', ['class="foo"'], 'match for cla')
call IsMatchesInIsolatedLine('bar', ['bar="quux"', 'bar=''nono'''], 'matches for bar')
call IsMatchesInIsolatedLine('bar=', ['bar="quux"', 'bar=''nono'''], 'matches for bar=')
call IsMatchesInIsolatedLine('bar="', ['bar="quux"'], 'match for bar="')
call IsMatchesInIsolatedLine('bar=''', ['bar=''nono'''], 'match for bar=''')
call IsMatchesInIsolatedLine('alt="f', ['alt="false"'], 'match for alt="f')
call IsMatchesInIsolatedLine('alt="true', ['alt="true"'], 'match for alt="true')
call IsMatchesInIsolatedLine('wr', [], 'no matches for wr')
call IsMatchesInIsolatedLine('nowr', ['nowrap'], 'match for nowr')
call IsMatchesInIsolatedLine('real', [], 'no matches for real')
call IsMatchesInIsolatedLine('="fal', [], 'no matches for ="fal')
call IsMatchesInIsolatedLine('', ['alt="false"', 'alt="true"', 'bar=''nono''', 'bar="quux"', 'baz="more"', 'border="2"', 'class="foo"', 'description="lala"', 'foony="bold"', 'id="#434234"', 'nowrap', 'scope="really"', 'up'], 'all matches')

call vimtest#Quit()
