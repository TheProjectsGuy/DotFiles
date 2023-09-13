" From: https://github.com/amix/vimrc/blob/master/vimrcs/basic.vim

" Sets how many lines of history VIM has to remember
set history=500
" Highlight search results
set hlsearch
" Show matching brackets when text indicator is over them
set showmatch
" Show line numbers
set number
" Set relative line numbers
set relativenumber

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab
" Be smart when using tabs ;)
set smarttab
" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" Scroll offset when scrolling
"   From: https://stackoverflow.com/a/26915653
set scrolloff=4
