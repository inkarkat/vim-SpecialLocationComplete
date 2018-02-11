" Test repeat of completion of text between tags.

runtime tests/helpers/insert.vim
source autoload/SpecialLocationComplete.vim
view tagged.txt
new

call SetCompletion("\<C-x>\<C-x>")
let g:key = 'it'
call SetCompleteExpr('SpecialLocationComplete#Expr(g:key)')

call InsertRepeat('insi', 0, 0, 0)
call InsertRepeat('insi', 0, 0)
call InsertRepeat('insi', 0)

call vimtest#SaveOut()
call vimtest#Quit()
