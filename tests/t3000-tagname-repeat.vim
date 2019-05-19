" Test repeat of tagname completion.

runtime tests/helpers/insert.vim
view tagged.txt
new

call SetCompletion("\<C-x>\<C-x>")
let g:key = 't'
call SetCompleteExpr('SpecialLocationComplete#Expr(g:key)')

call InsertRepeat('<Fo', 0, 2, 0, 0, 0, 0, 0, 0, 0, 0)
call InsertRepeat('<Fo', 0, 2, 0, 0, 0, 0, 0, 0, 0)
call InsertRepeat('<Fo', 0, 2, 0, 0, 0, 0, 0, 0)
call InsertRepeat('<Fo', 0, 1, 0, 0, 0, 0, 0)
call InsertRepeat('<Fo', 0, 1, 0, 0, 0, 0)
call InsertRepeat('<Fo', 0, 1, 0, 0, 0)
call InsertRepeat('<Fo', 0, 1, 0, 0)
call InsertRepeat('<Fo', 0, 1, 0)
call InsertRepeat('<Fo', 0, 1)
call InsertRepeat('<Fo', 0)

call InsertRepeat('pref', 1, 2, 0, 0, 0)
call InsertRepeat('pref', 2, 1, 0, 0)
call InsertRepeat('pref', 2, 1, 0)
call InsertRepeat('pref', 2, 1)
call InsertRepeat('pref', 2)

call vimtest#SaveOut()
call vimtest#Quit()
