set nocompatible              " be iMproved, required
filetype off                   " required!
" autocmd BufWritePre *.py execute ':Black'
" autocmd BufWritePre *.py execute ':Isort'
autocmd BufEnter *.tsx set filetype=typescript
autocmd BufEnter *.js set filetype=javascript
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
" required! 
Plugin 'altercation/vim-colors-solarized'
" You can disable this option too
" if you don't want linters to run on opening a file
let g:ale_lint_on_enter = 0
Plugin 'pearofducks/ansible-vim'
Plugin 'WolfgangMehner/bash-support'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'spacewander/openresty-vim'
Plugin 'gmarik/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'fisadev/vim-isort'
Plugin 'leafgarland/typescript-vim'
Plugin 'Quramy/tsuquyomi'
let g:vim_isort_python_version = 'python3'
Plugin 'kien/ctrlp.vim'
Plugin 'python-mode/python-mode', { 'branch': 'develop'  }
let g:pymode = 1
let g:pymode_python = 'python3'
let g:pymode_options_max_line_length = 150 
Plugin 'skywind3000/asyncrun.vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'psf/black'
Plugin 'itchyny/lightline.vim'
Plugin 'tell-k/vim-autopep8'
Plugin 'ruanyl/vim-fixmyjs'
let g:fixmyjs_engine = 'fixmyjs'
let g:fixmyjs_legacy_jshint = 1
Plugin 'mhinz/vim-startify'
Plugin 'yuezk/vim-js'
Plugin 'maxmellon/vim-jsx-pretty'
" let g:vim_jsx_pretty_colorful_config = 1
"
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_next_key='<C-m>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

let g:go_version_warning = 0

Plugin 'taglist.vim'
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1

"启动vim自动打开taglist
" let Tlist_Auto_Open=1 

Plugin 'scrooloose/nerdtree'
map <F2> :NERDTreeToggle<CR>

let NERDTreeIgnore=['\.pyc$', '\.pyo$']
let g:NERDTreeWinSize=28

Plugin 'fatih/vim-go'
let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1

"F7检查语法
Plugin 'vim-flake8'

" 使用vim-syntastic需要flake8
Plugin 'scrooloose/syntastic'
"在打开文件的时候检查
let g:syntastic_check_on_open=1
let g:syntastic_python_flake8_post_args='--ignore=E501,F403,W503'
let g:syntastic_python_flake8_exec = 'python3'
let g:syntastic_python_flake8_args = ['-m', 'flake8']
let g:syntastic_javascript_checkers = ['eslint']
Plugin 'mxw/vim-jsx'    
let g:jsx_ext_required = 0 " Allow JSX in normal JS files"

call vundle#end()            " required

filetype plugin indent on     " required!

"开启语法高亮
syntax on

"窗口大小
if has('gui_running')
    set lines=35 columns=118
endif
"显示当前的行号列号：
"
set ruler
"在状态栏显示正在输入的命令
"
set showcmd
"关闭/打开配对括号高亮
"let loaded_matchparen = 1
"显示行号：
"
set number
"set relativenumber
"配色方案
colorscheme evening 
"colorscheme solarized
"去掉菜单栏
set guioptions-=m
"去掉工具栏
set guioptions-=T
"总是显示标签栏
set showtabline=2
" 数字都当成十进制
set nrformats=
"反显光标当前行颜色
if has('gui_running')
    set cursorline
    "hi cursorline guibg=#330003
endif
"编码
"set encoding=utf-8
let &termencoding=&encoding
set fileencodings=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936,iso-8859-6

"背景色
"set background=light
set background=dark
":highlight Normal ctermfg=DarkGrey ctermbg=DarkGrey


"自动补全  
"关键字补全
"    即简单地补全到文档中已有的词，快捷键为 Ctrl-N 或 Ctrl-P。 
"智能补全
"    Vim 7中引入 Omni Complete，可根据语义补全，快捷键为 Ctrl-X Ctrl-O。
"
set completeopt=longest,menu
"自动补全命令时候使用菜单式匹配列表  
set wildmenu

"开启自带的python提示
"autocmd FileType python set omnifunc=pythoncomplete#Complete
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

autocmd FileType python noremap <buffer> <F8> :call Autopep8()<CR>


" au FileType javascript.jsx setlocal sw=2 sts=2 et
au FileType javascript setlocal sw=2 sts=2 et


set expandtab
"一个tab4个空格
set tabstop=4
"每层缩进4个空格
set shiftwidth=4
"退格键，每次删除4个空格
set softtabstop=4
"
"代码折叠可以只以缩进为依据
autocmd FileType python setlocal foldmethod=indent
"默认展开所有代码	za会翻转当前位置的折叠状态
set foldlevel=99
" 增量式搜索，边输入边搜索
set incsearch
" 高亮搜索
set hlsearch
"自动切换目录
set autochdir


"""来自mswin.vim
" backspace and cursor keys wrap to previous/next line
set backspace=indent,eol,start whichwrap+=<,>,[,]
" backspace in Visual mode deletes selection
vnoremap <BS> d

" 安装ycm时可自行git clone
let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'  "设置全局配置文件的路径
let g:ycm_seed_identifiers_with_syntax=1    " 语法关键字补全
let g:ycm_confirm_extra_conf=0  " 打开vim时不再询问是否加载ycm_extra_conf.py配置
let g:ycm_key_invoke_completion = '<C-a>' " ctrl + a 触发补全
let g:ycm_server_python_interpreter='/usr/local/python3.7/bin/python3.7'
if !exists("g:ycm_semantic_triggers")
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

"修改成了tab标签的移动 
noremap <C-Tab> :tabn<CR>
inoremap <C-Tab> :tabn<CR>
cnoremap <C-Tab> :tabn<CR>
onoremap <C-Tab> :tabn<CR>

au BufRead,BufNewFile *.tpl set filetype=gohtmltmpl
