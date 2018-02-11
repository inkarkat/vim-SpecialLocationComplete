" Test repeat of full tags completion.

source ../helpers/insert.vim
source autoload/SpecialLocationComplete.vim
view tagged.txt
new

call SetCompletion("\<C-x>\<C-x>")
let g:key = 'T'
call SetCompleteExpr('SpecialLocationComplete#Expr(g:key)')

call InsertRepeat('<run', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
call InsertRepeat('<run', 0, 0, 0, 0, 0, 0, 0, 0, 0)
call InsertRepeat('<run', 0, 0, 0, 0, 0, 0, 0, 0)
call InsertRepeat('<run', 0, 0, 0, 0, 0, 0, 0)
call InsertRepeat('<run', 0, 0, 0, 0, 0, 0)
call InsertRepeat('<run', 0, 0, 0, 0, 0)
call InsertRepeat('<run', 0, 0, 0, 0)
call InsertRepeat('<run', 0, 0, 0)
call InsertRepeat('<run', 0, 0)
call InsertRepeat('<run', 0)

call InsertRepeat('<ba', 2, 1)
call InsertRepeat('<ba', 2, 2)

call vimtest#SaveOut()
call vimtest#Quit()
