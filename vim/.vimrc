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
set colorcolumn=100
set nostartofline
set spell spelllang=en_us

call vundle#begin()
    Plugin 'dense-analysis/ale'
    Plugin 'jiangmiao/auto-pairs'
    Plugin 'chriskempson/base16-vim'
    Plugin 'kien/ctrlp.vim'
    Plugin 'junegunn/fzf'
    Plugin 'junegunn/fzf.vim'
    Plugin 'scrooloose/nerdtree'
    Plugin 'arcticicestudio/nord-vim'
    Plugin 'vim-airline/vim-airline'
    Plugin 'vim-airline/vim-airline-themes'
    Plugin 'ntpeters/vim-better-whitespace'
    Plugin 'tpope/vim-fugitive'
    Plugin 'itchyny/vim-gitbranch'
    Plugin 'airblade/vim-gitgutter'
    Plugin 'terryma/vim-multiple-cursors'
    Plugin 'ngmy/vim-rubocop'
    Plugin 'tpope/vim-surround'
    Plugin 'VundleVim/Vundle.vim'
    Plugin 'Yggdroot/indentLine'
    Plugin 'fatih/vim-go'
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
nnoremap <F8>        :set nospell!<CR>
nnoremap <c-f>       :Ag<CR>
" ==========================================

" Disable arrow keys
"===========================================
"noremap <Up>    <NOP>
"noremap <Down>  <NOP>
"noremap <Left>  <NOP>
"noremap <Right> <NOP>

set pastetoggle =<F9>
" set paste

" Revamp switch between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Open Nerdtree by defaul
" autocmd VimEnter * NERDTree

" Vim Airline
" ==========================================

let g:airline#extensions#tabline#fnamemod = ':.'
let g:airline#extensions#tabline#fnamecollapse = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='nord'
set laststatus=2

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif

" YAML syntax
" autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
let g:indentLine_char = '⦙'

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

let g:ale_set_highlights = "ALEErrorLine"
let g:ale_linters_explicit = 1
let g:ale_linters = {
      \ 'ruby': ['rubocop'],
      \ }

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

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set t_Co=256
set ignorecase
set nospell!
colorscheme nord
