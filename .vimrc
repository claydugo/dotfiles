""""""""""""""""""""""""""""""""""""
"         .vimrc - 01/27/21         "
"""""""""""""""""""""""""""""""""""""

" Auto install vim-plug if It's missing
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'mhinz/vim-startify'
Plug 'vimwiki/vimwiki'
Plug 'edkolev/tmuxline.vim'
Plug 'dracula/vim', { 'as': 'dracula' }
"Plug 'tomlion/vim-solidity'
Plug 'preservim/nerdtree'
call plug#end()

let g:airline_theme='dracula'

set encoding=utf-8
let mapleader = ","
set backspace=indent,eol,start

set completeopt=menu,menuone,noselect

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

set visualbell
set showmatch

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
let g:vimwiki_global_ext = 0
let g:vimwiki_list = [{'path': $HOME . '/vimwiki',
  \ 'syntax': 'markdown', 'ext': '.md'}]
let g:startify_bookmarks = [ {'v': '~/.vimrc'}, {'z': '~/.zshrc'}, {'t': '~/.tmux.conf'}, {'d': '~/dotfiles'}, {'w': '~/vimwiki/index.md'} ]
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

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Make double-<Esc> clear search highlights
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>

" LSP shit
lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        -- For `vsnip` user.
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` user.

        -- For `luasnip` user.
        -- require('luasnip').lsp_expand(args.body)

        -- For `ultisnips` user.
        -- vim.fn["UltiSnips#Anon"](args.body)
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' })
    },
    sources = {
      { name = 'nvim_lsp' },

      -- For vsnip user.
      { name = 'vsnip' },

      -- For luasnip user.
      -- { name = 'luasnip' },

      -- For ultisnips user.
      -- { name = 'ultisnips' },

      { name = 'buffer' },
    }
  })

  -- Setup lspconfig.
  require('lspconfig').pyright.setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  }
EOF
