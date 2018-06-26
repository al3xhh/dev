set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()
filetype plugin indent on

set runtimepath+=/opt/vim_runtime
set number relativenumber
set t_Co=256
set mouse=a

source /opt/vim_runtime/vimrcs/basic.vim
source /opt/vim_runtime/vimrcs/filetypes.vim
source /opt/vim_runtime/vimrcs/plugins_config.vim
source /opt/vim_runtime/vimrcs/extended.vim

autocmd BufEnter * lcd %:p:h
autocmd BufWinEnter * NERDTreeMirror
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

try
    source /opt/vim_runtime/my_configs.vim
catch
endtry

nnoremap tn :tabn
nnoremap tp :tabp
nnoremap tc :tabc

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_prompt_mappings = {
            \ 'AcceptSelection("e")': [],
            \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
            \ }
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }
let g:NERDTreeWinPos = "left"
let g:airline_theme='base16'
let g:strip_whitespace_on_save = 1

colorscheme apprentice
