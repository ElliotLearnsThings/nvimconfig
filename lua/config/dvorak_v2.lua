local M = {}

function M:set_dvorak_permutations()
    -- (nl)(tk)(jdh) and (NL)(TK)(JDH)
    self.forward = {
        -- lowercase
        {'n', 'j', 'd', {noremap = true}},
        {'n', 'd', 'h', {noremap = true}},
        {'n', 'h', 'j', {noremap = true}},
        {'n', 't', 'k', {noremap = true}},
        {'n', 'k', 't', {noremap = true}},
        {'n', 'n', 'l', {noremap = true}},
        {'n', 'l', 'n', {noremap = true}},
        {'v', 'j', 'd', {noremap = true}},
        {'v', 'd', 'h', {noremap = true}},
        {'v', 'h', 'j', {noremap = true}},
        {'v', 't', 'k', {noremap = true}},
        {'v', 'k', 't', {noremap = true}},
        {'v', 'n', 'l', {noremap = true}},
        {'v', 'l', 'n', {noremap = true}},
        -- uppercase: (NL)(TK)(JDH)
        -- J→D (join→delete-to-eol), D→H (del-eol→top), H→J (top→join)
        -- T→K (T-motion→bottom), K→T (keyword→T-motion)
        -- N→L (prev-match→bottom), L→N (bottom→prev-match)
        {'n', 'J', 'D', {noremap = true}},
        {'n', 'D', 'H', {noremap = true}},
        {'n', 'H', 'J', {noremap = true}},
        {'n', 'T', 'K', {noremap = true}},
        {'n', 'K', 'T', {noremap = true}},
        {'n', 'N', 'L', {noremap = true}},
        {'n', 'L', 'N', {noremap = true}},
        {'v', 'J', 'D', {noremap = true}},
        {'v', 'D', 'H', {noremap = true}},
        {'v', 'H', 'J', {noremap = true}},
        {'v', 'T', 'K', {noremap = true}},
        {'v', 'K', 'T', {noremap = true}},
        {'v', 'N', 'L', {noremap = true}},
        {'v', 'L', 'N', {noremap = true}},
    }
end

function M:enable()
    for _, el in ipairs(self.forward) do
        local mode, lhs, rhs, opts = unpack(el)
        vim.keymap.set(mode, lhs, rhs, opts)
    end
    self.appied = true
end

function M:disable()
    for _, el in ipairs(self.forward) do
        local mode, lhs, _, _ = unpack(el)
        pcall(vim.keymap.del, mode, lhs)
    end
    self.appied = false
end

function M:toggle()
    if self.appied then
        M:disable()
    else
        M:enable()
    end
end

function M.setup()
    M.appied = false
    M:set_dvorak_permutations()
    M:enable()
    vim.api.nvim_create_user_command("DvorakToggle", function()
        M:toggle()
        if M.appied then
            vim.notify("[Dvorak] enabled", vim.log.levels.INFO)
        else
            vim.notify("[Dvorak] disabled", vim.log.levels.INFO)
        end
    end, { nargs = 0 })
end

M.setup()

return M
