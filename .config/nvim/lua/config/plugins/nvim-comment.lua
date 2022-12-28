return {
    'terrortylor/nvim-comment',
    event = "BufReadPost",
    config = function()
        require('nvim_comment').setup()
    end
}
