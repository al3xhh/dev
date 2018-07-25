set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'ervandew/supertab'

call vundle#end()
filetype plugin indent on

set runtimepath+=/opt/vim_runtime
set number relativenumber
set softtabstop=4
set tabstop=2
set shiftwidth=4
set expandtab

source /opt/vim_runtime/vimrcs/plugins_config.vim

autocmd BufEnter * lcd %:p:h
autocmd BufWinEnter * NERDTreeMirror
autocmd StdinReadPre * let s:std_in=1

nnoremap tn  :tabn<CR>
nnoremap tp  :tabp<CR>
nnoremap tc  :tabc<CR>
noremap <F2> :NERDTreeToggle<CR>
noremap <F8> :call ToggleNumbers()<CR>
noremap <F9> :call ToggleMouse()<CR>

set pastetoggle=<F10>

let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-n>"
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }
let g:NERDTreeWinPos = "left"
let g:airline_theme='base16'
let g:strip_whitespace_on_save = 1

" Airline tabs plugin:
" ==================
let g:airline#extensions#tabline#enabled = 1
set laststatus=2 "enable airline on start

if !exists('g:airline_symbols')
let g:airline_symbols = {}
endif

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

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
    set relativenumber!
    set number!
endfunc

set t_Co=256
set background=dark
colorscheme gruvbox
