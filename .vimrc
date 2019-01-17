set nocompatible
set rtp+=~/.vim/bundle/Vundle.vim
set runtimepath^=~/.vim/bundle/ctrlp.vim
set number
set softtabstop=4
set tabstop=2
set shiftwidth=4
set expandtab

call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'
    Plugin 'kien/ctrlp.vim'
    Plugin 'ntpeters/vim-better-whitespace'
    Plugin 'itchyny/lightline.vim'
    Plugin 'itchyny/vim-gitbranch'
    Plugin 'scrooloose/nerdtree'
    Plugin 'ap/vim-buftabline'
call vundle#end()

filetype plugin indent on

" Key maps
" ====================================
nnoremap tn  :tabn<CR>
nnoremap tp  :tabp<CR>
nnoremap tc  :tabc<CR>
noremap <F2> :NERDTreeToggle<CR>
noremap <F8> :call ToggleNumbers()<CR>
noremap <F9> :call ToggleMouse()<CR>
" ====================================

" Split windows maps
" ====================
nnoremap sq <c-w>q<CR>
nnoremap s_ <c-w>_<CR>
nnoremap s= <c-w>=<CR>
nnoremap sa <c-w>h<CR>
nnoremap sx <c-w>j<CR>
nnoremap sw <c-w>k<CR>
nnoremap sd <c-w>l<CR>
" ====================

set pastetoggle=<F10>

" Don't mix kitty colors with vim colors
" ======================================
let &t_ut=''

let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-n>"
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:NERDTreeWinPos = "left"
let g:strip_whitespace_on_save = 0
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ }

" Airline tabs plugin:
" ==================
set laststatus=2 "enable airline on start

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

if !has('gui_running')
    set t_Co=256
endif

set background=dark
colorscheme gruvbox
syntax on
