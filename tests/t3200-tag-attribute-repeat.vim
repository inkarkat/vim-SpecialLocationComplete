" Test repeat of tag attribute completion.

runtime tests/helpers/insert.vim
source autoload/SpecialLocationComplete.vim
view tagged.txt
new

call SetCompletion("\<C-x>\<C-x>")
let g:key = ''
call SetCompleteExpr('SpecialLocationComplete#Expr(g:key)')

call InsertRepeat('alt=', 1, 0)
call InsertRepeat('alt=', 1)
call InsertRepeat('alt=', 2)

call InsertRepeat('bar=', 2, 0)
call InsertRepeat('bar=', 2)

call InsertRepeat('id', 0, 0, 0)
call InsertRepeat('id', 0, 0)
call InsertRepeat('id', 0)

call vimtest#SaveOut()
call vimtest#Quit()
