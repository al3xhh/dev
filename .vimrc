set runtimepath+=/opt/vim_runtime
set number

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

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0

let g:NERDTreeWinPos = "left"
colorscheme deus
