call vimtest#AddDependency('vim-ingo-library')
call vimtest#AddDependency('vim-CompleteHelper')

if g:runVimTest =~# '-repeat[.-]'
    set runtimepath+=.
    runtime! autoload/SpecialLocationComplete.vim
endif

runtime plugin/SpecialLocationComplete.vim
