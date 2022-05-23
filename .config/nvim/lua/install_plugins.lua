local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    -- lua users / lsp / cmp
    use 'lewis6991/impatient.nvim'
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use 'tree-sitter/tree-sitter-python'
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
    use 'kyazdani42/nvim-web-devicons'
    use 'nvim-lualine/lualine.nvim'
    use {
        "nvim-telescope/telescope-frecency.nvim",
        requires = {
            "tami5/sqlite.lua"
        }
    }
    -- dirty vim dependencies
    use 'tpope/vim-commentary'
    use 'tpope/vim-surround'
    use 'junegunn/vim-easy-align'
    --organization
    use 'vimwiki/vimwiki'

  if packer_bootstrap then
    require('packer').sync()
  end
end)
