""""""""""""""""""""""""""""""""""""
"         .vimrc - 09/10/20         "
"""""""""""""""""""""""""""""""""""""

" Auto install vim-plug if It's missing
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'altercation/vim-colors-solarized' 
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'mhinz/vim-startify'
Plug 'vimwiki/vimwiki'
Plug 'edkolev/tmuxline.vim'
Plug 'dense-analysis/ale'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'sbdchd/neoformat'
call plug#end()

set encoding=utf-8
let mapleader = ","
set backspace=indent,eol,start

set hidden
set nobackup
set nowritebackup
set noswapfile

set cmdheight=2
set updatetime=300

set ignorecase
set incsearch
set hlsearch 

set history=50
set ruler         
set showcmd      
set laststatus=0
set autowrite     
set modelines=0   
set nomodeline

set relativenumber
set noshowmode
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smartindent
set autoindent
set expandtab
set smarttab

set ttimeout
set ttimeoutlen=100
set timeoutlen=1000

map <C-f> :NERDTreeToggle<CR>

" Goyo Toggle, Enable Limelight when Entering Goyo
nnoremap <Leader>gy :Goyo<CR>
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Plugin Configuration
let g:startify_bookmarks = [ {'v': '~/.vimrc'}, {'z': '~/.zshrc'}, {'t': '~/.tmux.conf'}, {'d': '~/dotfiles'}, {'w': '~/vimwiki/index.wiki'} ]
let g:startify_custom_header = [
    \ '    ____ _               ____                    ',
    \ '   / ___| | __ _ _   _  |  _ \ _   _  __ _  ___  ',
    \ '  | |   | |/ _` | | | | | | | | | | |/ _` |/ _ \ ',
    \ '  | |___| | (_| | |_| | | |_| | |_| | (_| | (_) |',
    \ '   \____|_|\__,_|\__, | |____/ \__,_|\__, |\___/ ',
    \ '                 |___/               |___/       ',
    \ '',
    \ '  ===============================================',
    \ '',
    \ ]
let g:limelight_conceal_ctermfg = 253
nmap <C-p> <Plug>MarkdownPreviewToggle

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

