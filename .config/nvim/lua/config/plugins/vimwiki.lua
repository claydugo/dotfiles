-- noone makes a plugin like this
-- they all want to copy org mode
-- with their own pointless format
-- i just wanna use markdown
return {
    'vimwiki/vimwiki',
    ft = 'markdown',
    config = function()
        vim.g.vimwiki_global_ext = 0
        vim.g.vimwiki_list = {
            {
              path = '~/vimwiki/',
              syntax = 'markdown',
              ext = '.md',
            }
        }
    end
}

