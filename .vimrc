set encoding=utf-8
set nocompatible "Don't maintain compatibility with Vi.
set t_Co=256

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'sheerun/vim-polyglot'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-endwise'
Plugin 'jiangmiao/auto-pairs'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'vim-scripts/SyntaxRange'
Plugin 'mileszs/ack.vim'
Plugin 'dracula/vim'
Plugin 'trevordmiller/nova-vim'
call vundle#end()            " required

set autoindent
filetype plugin indent on    " required

set laststatus=2
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)|vendor\/bundle|vendor\/gems|tmp|node_modules$'
syntax on
color nova
set tabstop=2                    " Softer tabs
set shiftwidth=2
set expandtab
set number                       " Display the line numbers beside the buffer
set hidden                       " Allow buffer change w/o saving
set history=1000                 " Remember last 1000 commands
set scrolloff=4                  " Keep at least 4 lines below the cursor
set listchars=tab:▸\ ,eol:¬      " Whitespace character for :set list
set noswapfile                   " Gets ride of the *.swp files
map <C-n> :NERDTreeToggle<CR>    " Keyboard shortcut for Nerdtree
autocmd BufNewFile,BufRead *.md set filetype=markdown "markdown syntax

" Airline stuff
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)|vendor\/bundle|vendor\/gems|tmp|node_modules$'

" Saner splits:
" https://robots.thoughtbot.com/vim-splits-move-faster-and-more-naturally
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Fixing backspace in Vim 8
set backspace=2 " make backspace work like most other apps
set backspace=indent,eol,start

" Start NERDTree automatically
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
