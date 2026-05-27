require('render-markdown').setup({
    latex = {
        enabled = true,
        render_modes = false,
        converter = { 'utftex', 'latex2text' },
        highlight = 'RenderMarkdownMath',
        position = 'center',
        top_pad = 0,
        bottom_pad = 0,
    },
    win_options = {
        number = { default = true, rendered = true },
        relativenumber = { default = true, rendered = true },
    },
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'markdown.mdx' },
    callback = function()
        vim.opt_local.number = true
        vim.opt_local.relativenumber = true
    end,
})
