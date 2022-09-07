local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require'packer'.startup(function(use)
    -- nearly essential
    use 'wbthomason/packer.nvim'
    use 'lewis6991/impatient.nvim'
    use 'nathom/filetype.nvim'
    -- lua users / lsp / cmp
    use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim"
    }
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    -- use 'williamboman/nvim-lsp-installer'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use 'nvim-treesitter/nvim-treesitter-context'
    use 'tree-sitter/tree-sitter-python'
    use {
        'lewis6991/gitsigns.nvim',
        requires = {
            'nvim-lua/plenary.nvim'
        }
    }
    -- fzf telescope ripgrep harpoon
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'}
        }
    }
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use 'ThePrimeagen/harpoon'
    -- color scheme / styling
    use 'folke/tokyonight.nvim'
    use {
        'nvim-lualine/lualine.nvim',
        requires = {
            'kyazdani42/nvim-web-devicons'
        }
    }
    -- dirty vim dependencies
    use 'tpope/vim-commentary'
    use 'tpope/vim-surround'
    use 'junegunn/vim-easy-align'
    --organization
    use 'vimwiki/vimwiki'

  if packer_bootstrap then
    require'packer'.sync()
  end
end)
