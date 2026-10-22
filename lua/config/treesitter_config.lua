-- nvim-treesitter `main` branch: the old `configs` module is gone and
-- highlighting is started by Neovim's own ftplugins, so only the parser
-- list remains. Neovim bundles markdown/markdown_inline/lua/c/vim/query.
require('nvim-treesitter').install({
  "yaml", "markdown", "markdown_inline", "python", "lua", "json", "bash",
  "html", "css", "javascript", "typescript", "go", "rust", "latex", "julia",
})

-- Neovim 0.12 bug: add_injection() refuses empty range sets (they mean "the
-- whole buffer") but checks before clipping to the parent's ranges. When an
-- edit lands mid-parse the parent ranges go stale, the clip comes back empty,
-- and markdown notes got re-parsed whole as LaTeX on every edit (snacks then
-- drew each formula once per stray tree). Drop empty regions after the fact;
-- remove once fixed upstream.
local LanguageTree = require('vim.treesitter.languagetree')
local get_injections = LanguageTree._get_injections
if get_injections then
  function LanguageTree:_get_injections(...)
    local result = get_injections(self, ...)
    for lang, regions in pairs(result) do
      regions = vim.tbl_filter(function(region) return #region > 0 end, regions)
      result[lang] = #regions > 0 and regions or nil
    end
    return result
  end
end

-- Neovim 0.12 bug: an async parse (the highlighter, snacks) that runs out of
-- time stops inside an injected region, and the next parse on that parser
-- resumes it even when it asks for another region. A sync parse in between
-- (render-markdown) then stored one formula's LaTeX tree under another's, so
-- snacks drew that formula twice and never found the other. Notes are small,
-- so parse markdown buffers synchronously; remove once fixed upstream.
local parse = LanguageTree.parse
function LanguageTree:parse(range, on_parse)
  if on_parse and self:lang() == 'markdown' then
    local trees = parse(self, range)
    on_parse(nil, trees)
    return trees
  end
  return parse(self, range, on_parse)
end
