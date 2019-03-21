set nocompatible
syntax enable
set rtp+=~/.vim/bundle/Vundle.vim
set runtimepath^=~/.vim/bundle/ctrlp.vim
set number
set nowrap
set tabstop=4
set smarttab
set tags=tags
set softtabstop=4
set expandtab
set shiftwidth=4
set shiftround
set backspace=indent,eol,start
set autoindent
set copyindent
set colorcolumn=80

call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'
    Plugin 'kien/ctrlp.vim'
    Plugin 'ntpeters/vim-better-whitespace'
    Plugin 'itchyny/vim-gitbranch'
    Plugin 'scrooloose/nerdtree'
    Plugin 'tpope/vim-fugitive'
    Plugin 'airblade/vim-gitgutter'
    Plugin 'junegunn/fzf'
    Plugin 'junegunn/fzf.vim'
    Plugin 'ngmy/vim-rubocop'
    Plugin 'vim-airline/vim-airline'
    Plugin 'vim-airline/vim-airline-themes'
call vundle#end()

" Key maps
" ==========================================
nnoremap <tab>       :bn<CR>
nnoremap <Up><tab>   :bp<CR>
nnoremap <Down><tab> :bc<CR>
nnoremap <F2>        :NERDTreeToggle<CR>
nnoremap <F3>        :Gblame<CR>
nnoremap <F4>        :RuboCop<CR>
nnoremap <F5>        :call ToggleNumbers()<CR>
nnoremap <F6>        :call ToggleMouse()<CR>
nnoremap <F7>        :StripWhitespace<CR>
nnoremap <c-f>       :Ag<CR>
" ==========================================

" Disable arrow keys
"===========================================
noremap <Up>    <NOP>
noremap <Down>  <NOP>
noremap <Left>  <NOP>
noremap <Right> <NOP>

set pastetoggle =<F8>

" Vim Airline
" ==========================================

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='base16'
set laststatus=2

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif

" powerline symbols
let g:airline_left_sep = ''
let g:airline#extensions#tabline#left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-n>"
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:NERDTreeWinPos = "left"
let g:strip_whitespace_on_save = 0

function! ToggleMouse()
    " check if mouse is enabled
    if &mouse == 'a'
        " disable mouse
        set mouse=
    else
        " enable mouse everywhere
        set mouse=a
    endif
endfunc

function! ToggleNumbers()
    set number!
endfunc

set background=dark
set t_Co=256
colorscheme gruvbox
