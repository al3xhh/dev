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
set t_Co=256

source /opt/vim_runtime/vimrcs/basic.vim
source /opt/vim_runtime/vimrcs/filetypes.vim
source /opt/vim_runtime/vimrcs/plugins_config.vim
source /opt/vim_runtime/vimrcs/extended.vim

autocmd BufEnter * lcd %:p:h
autocmd BufWinEnter * NERDTreeMirror
autocmd StdinReadPre * let s:std_in=1

try
    source /opt/vim_runtime/my_configs.vim
catch
endtry

nnoremap tn  :tabn<CR>
nnoremap tp  :tabp<CR>
nnoremap tc  :tabc<CR>
noremap <F2> :NERDTreeToggle<CR>

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

colorscheme apprentice
