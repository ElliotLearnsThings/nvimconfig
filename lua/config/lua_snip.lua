-- In your LuaSnip configuration file (e.g., lua/config/luasnip.lua)

local ls = require("luasnip")
-- Pull in the snippet functions
local s = ls.s
local i = ls.i
local t = ls.t

-- Automatically load snippets from the friendly-snippets collection
require("luasnip.loaders.from_vscode").lazy_load()
