return {
    'lewis6991/satellite.nvim',
    event = 'BufReadPre',
    config = function()
        require('satellite').setup({
            excluded_filetypes = {
                'markdown',
                'yaml',
                'gitcommit',
                'gitrebase',
            },
        })
    end
}

