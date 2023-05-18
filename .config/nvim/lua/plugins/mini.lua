return {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
        require'mini.starter'.setup({
            items         = { { name = '', action = '', section = '' } },
            header        = '',
            footer        = '',
            silent        = true,
            content_hooks = {
              starter.gen_hook.aligning("center", "top"),
            },
        })
    end
}
