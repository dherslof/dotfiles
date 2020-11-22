set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" indentation
Plugin 'Yggdroot/indentLine'
let g:indentLine_color_term = 239

" Color theme
Plugin 'dracula/vim', { 'name': 'dracula' }

" Auto completion
Plugin 'zxqfl/tabnine-vim'

" fs help
Plugin 'preservim/nerdtree'

" highlight brackets etc.
Plugin 'frazrepo/vim-rainbow'

Plugin 'octol/vim-cpp-enhanced-highlight'
" extra c++ options
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1

" powerline
set  rtp+=/home/daniel/.local/lib/python3.6/site-packages/powerline/bindings/vim/
set laststatus=2
set t_Co=256

" Show line numbers
set number

" Show file stats
set ruler

" blink instead of beeping
set visualbell

" highlight matching parentheses
set showmatch

" highlight syntax
syntax enable

" always show what mode we're currently editing in
set showmode

" a tab is n spaces
set tabstop=3

" always set autoindenting on
set autoindent
filetype plugin indent on

" number of spaces to use for autoindenting
set shiftwidth=3

" copy the previous indentation on autoindenting
set copyindent

" keep 3 lines off the edges of the screen when scrolling
set scrolloff=3

" highlight search terms
set hlsearch

" show search matches as you type
set incsearch

set completeopt=longest,menu

 " set relative line numbering
set relativenumber

" Make invisible chars visible, for end-of-line and tab
set list
set listchars=tab:▸\ ,eol:¬

" Colorcolumn
set colorcolumn=81
highlight ColorColumn ctermbg=8

set cursorline

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ

" Set theme, needs to be outside vundle scope
colorscheme dracula"
