" VIM config
"   From: https://www.baeldung.com/linux/vim-neovim-configs
source ~/.vimrc


" cd into the PWD
"	From: https://vi.stackexchange.com/a/34872
augroup cdpwd
    autocmd!
    autocmd VimEnter * cd $PWD
augroup END

" Synchronize system clipboard (default register)
"   From: https://ploegert.gitbook.io/til/tools/vim/allow-neovim-to-copy-paste-with-system-clipboard 
set clipboard+=unnamedplus

" Set mouse mode
set mouse=ar
