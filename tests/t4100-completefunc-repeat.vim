" Test repeat of completion via complete function.

source helpers/completefunc.vim
runtime tests/helpers/insert.vim
view tagged.txt
new

call SetCompletion("\<C-x>\<C-x>")
let g:key = 'f'
call SetCompleteExpr('SpecialLocationComplete#Expr(g:key)')

call InsertRepeat('ba', 1, 3, 0)
call InsertRepeat('ba', 2, 5, 0)
call InsertRepeat('f', 0, -1)

call vimtest#SaveOut()
call vimtest#Quit()
