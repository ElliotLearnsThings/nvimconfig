-- LaTeX/math snippets transcribed from snippets.js (Obsidian Latex Suite format)
-- into LuaSnip format for nvim-cmp. Applies to tex, latex, markdown filetypes.

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local parse = ls.parser.parse_snippet

-- ============================================================================
-- Math zone detection
-- ============================================================================

local function md_in_math()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  -- Check $$ block above
  local lines_above = vim.api.nvim_buf_get_lines(0, 0, row - 1, false)
  local in_display = false
  for _, line in ipairs(lines_above) do
    local _, n = line:gsub("%$%$", "")
    for _ = 1, n do in_display = not in_display end
  end
  if in_display then return true end

  -- Check $ on current line before cursor
  local current = vim.api.nvim_get_current_line():sub(1, col)
  current = current:gsub("\\%$", ""):gsub("%$%$", "")
  local _, count = current:gsub("%$", "")
  return count % 2 == 1
end

local function in_math()
  local ft = vim.bo.filetype
  if ft == "tex" or ft == "latex" or ft == "plaintex" then
    if vim.fn.exists("*vimtex#syntax#in_mathzone") == 1 then
      return vim.fn["vimtex#syntax#in_mathzone"]() == 1
    end
    return true
  end
  if ft == "markdown" or ft == "markdown.mdx" or ft == "quarto" or ft == "rmd" then
    return md_in_math()
  end
  return false
end

local function in_text()
  return not in_math()
end

-- ============================================================================
-- Helpers
-- ============================================================================

-- Capture group from regex trigger
local function cap(n)
  return f(function(_, snip) return snip.captures[n] or "" end, {})
end

-- Build a parsed snippet with options
local function ps(trig, body, opts)
  opts = opts or {}
  opts.trig = trig
  if opts.wordTrig == nil then opts.wordTrig = false end
  return parse(opts, body)
end

-- Math-mode auto-trigger parsed snippet
local function ma(trig, body, extra)
  local opts = vim.tbl_extend("force", { condition = in_math }, extra or {})
  return ps(trig, body, opts)
end

-- Text-mode auto-trigger parsed snippet
local function ta(trig, body, extra)
  local opts = vim.tbl_extend("force", { condition = in_text }, extra or {})
  return ps(trig, body, opts)
end

-- Math-mode regex auto-trigger (use s + function nodes for captures)
local function rma(trig, body_fn, extra)
  local opts = vim.tbl_extend("force", {
    trig = trig,
    regTrig = true,
    wordTrig = false,
    condition = in_math,
  }, extra or {})
  return s(opts, body_fn)
end

-- ============================================================================
-- Auto-trigger snippets (expand as typed)
-- ============================================================================

local autosnippets = {

  -- Math mode
  ta("mk", "$$0$ "),
  ta("dm", "$$\n$0\n$$"),
  ma("beg", "\\begin{$1}\n\t$0\n\\end{$1}"),

  -- Spacing
  ma(",", ",\\, $0"),
  ma("bre", "\\quad"),
  ma("circ", "\\circ"),

  -- Greek letters
  ma("@a", "\\alpha"),
  ma("@b", "\\beta"),
  ma("@g", "\\gamma"),
  ma("@G", "\\Gamma"),
  ma("@d", "\\delta"),
  ma("@D", "\\Delta"),
  ma("@e", "\\epsilon"),
  ma(":e", "\\varepsilon"),
  ma("@z", "\\zeta"),
  ma("@t", "\\theta"),
  ma("@T", "\\Theta"),
  ma(":t", "\\vartheta"),
  ma("@i", "\\iota"),
  ma("@k", "\\kappa"),
  ma("@l", "\\lambda"),
  ma("@L", "\\Lambda"),
  ma("@s", "\\sigma"),
  ma("@S", "\\Sigma"),
  ma("@u", "\\upsilon"),
  ma("@U", "\\Upsilon"),
  ma("@o", "\\omega"),
  ma("@O", "\\Omega"),
  ma("ome", "\\omega"),
  ma("Ome", "\\Omega"),

  -- Text environment
  ma("text", "\\text{$1}$0"),

  -- Basic operations
  ma("sr", "^{2}"),
  ma("cb", "^{3}"),
  ma("rd", "^{$1}$0"),
  ma("sts", "_\\text{$1}"),
  ma("sq", "\\sqrt{ $1 }$0"),
  ma("//", "\\frac{$1}{$2}$0"),
  ma("ee", "e^{ $1 }$0"),
  ma("invs", "^{-1}"),
  ma("conj", "^{*}"),
  ma("Ree", "\\mathrm{Re}($1) $0"),
  ma("imm", "\\mathrm{im}($1) $0"),
  ma("Log", "\\mathrm{Log}($1) $0"),
  ma("eLog", "\\mathsf{L}\\mathrm{og}($1) $0"),
  ma("ord", "\\mathrm{ord}($1) $0"),

  ma("bf", "\\mathbf{$1}$0"),
  ma("rm", "\\mathrm{$1}$0"),
  ma("bb", "\\mathbb{$1}$0"),

  -- Linear algebra
  ma("trace", "\\mathrm{Tr}"),
  ma("trans", "\\mathsf{T}"),

  ma("hat", "\\hat{$1}$0"),
  ma("bar", "\\bar{$1}$0"),
  ma("dot", "\\dot{$1}$0", { priority = -1 }),
  ma("ddot", "\\ddot{$1}$0"),
  ma("cdot", "\\cdot"),
  ma("tilde", "\\tilde{$1}$0"),
  ma("und", "\\underline{$1}$0"),
  ma("vec", "\\vec{$1}$0"),

  -- Common subscripted vars
  ma("xnn", "x_{n}"),
  ma("xjj", "x_{j}"),
  ma("xp1", "x_{n+1}"),
  ma("ynn", "y_{n}"),
  ma("yii", "y_{i}"),
  ma("yjj", "y_{j}"),

  -- Symbols
  ma("ooo", "\\infty"),
  ma("sum", "\\sum"),
  ma("prod", "\\prod"),
  ma("lim", "\\lim_{ ${1:n} \\to ${2:\\infty} } $0"),

  ma("+-", "\\pm"),
  ma("-+", "\\mp"),
  ma("...", "\\dots"),
  ma("nabl", "\\nabla"),
  ma("del", "\\nabla"),
  ma("xx", "\\times"),
  ma("**", "\\cdot"),
  ma("para", "\\parallel"),

  ma("===", "\\equiv $0"),
  ma("!=", "\\neq $0"),
  ma(">=", "\\geq $0"),
  ma("<=", "\\leq $0"),
  ma(">>", "\\gg $0"),
  ma("<<", "\\ll $0"),
  ma("<>", "\\langle $1 \\rangle $0"),
  ma("simm", "\\sim"),
  ma("sim=", "\\simeq"),
  ma("prop", "\\propto"),

  ma("<->", "\\leftrightarrow "),
  ma("->", "\\to"),
  ma("|->", "\\mapsto"),
  ma("!>", "\\mapsto "),
  ma("=>", "\\implies "),
  ma("=<", "\\impliedby $0"),

  ma("and", "\\cap "),
  ma("orr", "\\cup "),
  ma("inn", "\\in "),
  ma("notin", "\\not\\in "),
  ma("sub-", "\\setminus $0"),
  ma("sub=", "\\subseteq $0"),
  ma("sup=", "\\supseteq $0"),
  ma("eset", "\\emptyset $0"),
  ma("set", "\\{ $1 \\}$0"),

  ma("LL", "\\mathcal{L}"),
  ma("HH", "\\mathcal{H}"),
  ma("CC", "\\mathbb{C}"),
  ma("RR", "\\mathbb{R}"),
  ma("ZZ", "\\mathbb{Z}"),
  ma("NN", "\\mathbb{N}"),

  -- Derivatives / integrals
  ma("ddt", "\\frac{d}{dt} "),
  ma("dint", "\\int_{${1:0}}^{${2:1}} $0 \\, d${3:x}"),
  ma("oint", "\\oint"),
  ma("iint", "\\iint"),
  ma("iiint", "\\iiint"),
  ma("oinf", "\\int_{0}^{\\infty} $1 \\, d${2:x} $0"),
  ma("infi", "\\int_{-\\infty}^{\\infty} $1 \\, d${2:x} $0"),

  -- Physics
  ma("kbt", "k_{B}T"),
  ma("msun", "M_{\\odot}"),

  -- Quantum mechanics
  ma("dag", "^{\\dagger}"),
  ma("o+", "\\oplus "),
  ma("ox", "\\otimes "),
  ma("bra", "\\bra{$1} $0"),
  ma("ket", "\\ket{$1} $0"),
  ma("brk", "\\braket{ $1 | $2 } $0"),
  ma("outer", "\\ket{${1:\\psi}} \\bra{${1:\\psi}} $0"),

  -- Chemistry
  ma("pu", "\\pu{ $1 }$0"),
  ma("cee", "\\ce{ $1 }$0"),
  ma("he4", "{}^{4}_{2}He "),
  ma("he3", "{}^{3}_{2}He "),
  ma("iso", "{}^{${1:4}}_{${2:2}}${3:He}"),

  -- Environments (auto, M=block math)
  ma("pmat", "\\begin{pmatrix}\n\t$0\n\\end{pmatrix}"),
  ma("bmat", "\\begin{bmatrix}\n\t$0\n\\end{bmatrix}"),
  ma("Bmat", "\\begin{Bmatrix}\n\t$0\n\\end{Bmatrix}"),
  ma("vmat", "\\begin{vmatrix}\n\t$0\n\\end{vmatrix}"),
  ma("Vmat", "\\begin{Vmatrix}\n\t$0\n\\end{Vmatrix}"),
  ma("matrix", "\\begin{matrix}\n\t$0\n\\end{matrix}"),
  ma("cases", "\\begin{cases}\n\t$0\n\\end{cases}"),
  ma("align", "\\begin{align}\n\t$0\n\\end{align}"),
  ma("array", "\\begin{array}\n\t$0\n\\end{array}"),

  -- Brackets
  ma("avg", "\\langle $1 \\rangle $0"),
  ma("norm", "\\lvert $1 \\rvert $0", { priority = 1 }),
  ma("Norm", "\\lVert $1 \\rVert $0", { priority = 1 }),
  ma("ceil", "\\lceil $1 \\rceil $0"),
  ma("floor", "\\lfloor $1 \\rfloor $0"),
  ma("lr(", "\\left( $1 \\right) $0"),
  ma("lr{", "\\left\\{ $1 \\right\\} $0"),
  ma("lr[", "\\left[ $1 \\right] $0"),
  ma("lr|", "\\left| $1 \\right| $0"),
  ma("lra", "\\left< $1 \\right> $0"),

  -- ==========================================================================
  -- Regex auto-triggers
  -- ==========================================================================

  -- Auto letter subscript: X1 -> X_{1}
  rma("([A-Za-z])(%d)", {
    cap(1), t("_{"), cap(2), t("}"),
  }, { priority = -1 }),

  -- Add backslash before exp/log/ln (when not already escaped)
  rma("([^\\])(exp|log|ln)", {
    cap(1), t("\\"), cap(2),
  }),

  -- Add backslash before det
  rma("([^\\])(det)", {
    cap(1), t("\\"), cap(2),
  }),

  -- xhat -> \hat{x}
  rma("([a-zA-Z])hat", {
    t("\\hat{"), cap(1), t("}"),
  }),
  rma("([a-zA-Z])bar", {
    t("\\bar{"), cap(1), t("}"),
  }),
  rma("([a-zA-Z])dot", {
    t("\\dot{"), cap(1), t("}"),
  }, { priority = -1 }),
  rma("([a-zA-Z])ddot", {
    t("\\ddot{"), cap(1), t("}"),
  }, { priority = 1 }),
  rma("([a-zA-Z])tilde", {
    t("\\tilde{"), cap(1), t("}"),
  }),
  rma("([a-zA-Z])und", {
    t("\\underline{"), cap(1), t("}"),
  }),
  rma("([a-zA-Z])vec", {
    t("\\vec{"), cap(1), t("}"),
  }),

  -- Two-digit subscript: X_12 -> X_{12}
  rma("([A-Za-z])_(%d%d)", {
    cap(1), t("_{"), cap(2), t("}"),
  }),

  -- Auto-subscript after hat/vec/mathbf: \hat{x}1 -> \hat{x}_{1}
  rma("\\hat{([A-Za-z])}(%d)", {
    t("\\hat{"), cap(1), t("}_{"), cap(2), t("}"),
  }),
  rma("\\vec{([A-Za-z])}(%d)", {
    t("\\vec{"), cap(1), t("}_{"), cap(2), t("}"),
  }),
  rma("\\mathbf{([A-Za-z])}(%d)", {
    t("\\mathbf{"), cap(1), t("}_{"), cap(2), t("}"),
  }),

  -- Trig functions: sin -> \sin (when not preceded by backslash)
  rma("([^\\])(arcsin)", { cap(1), t("\\"), cap(2) }),
  rma("([^\\])(arccos)", { cap(1), t("\\"), cap(2) }),
  rma("([^\\])(arctan)", { cap(1), t("\\"), cap(2) }),
  rma("([^\\])(sinh)",   { cap(1), t("\\"), cap(2) }, { priority = 1 }),
  rma("([^\\])(cosh)",   { cap(1), t("\\"), cap(2) }, { priority = 1 }),
  rma("([^\\])(tanh)",   { cap(1), t("\\"), cap(2) }, { priority = 1 }),
  rma("([^\\])(coth)",   { cap(1), t("\\"), cap(2) }, { priority = 1 }),
  rma("([^\\])(sin)",    { cap(1), t("\\"), cap(2) }),
  rma("([^\\])(cos)",    { cap(1), t("\\"), cap(2) }),
  rma("([^\\])(tan)",    { cap(1), t("\\"), cap(2) }),
  rma("([^\\])(csc)",    { cap(1), t("\\"), cap(2) }),
  rma("([^\\])(sec)",    { cap(1), t("\\"), cap(2) }),
  rma("([^\\])(cot)",    { cap(1), t("\\"), cap(2) }),

  -- Partial derivative: paxy -> \frac{ \partial x }{ \partial y }
  rma("pa([A-Za-z])([A-Za-z])", {
    f(function(_, snip)
      return string.format("\\frac{ \\partial %s }{ \\partial %s } ",
        snip.captures[1], snip.captures[2])
    end, {}),
  }),

  -- ([^\\])int -> [^\\]\int
  rma("([^\\])int", { cap(1), t("\\int") }, { priority = -1 }),
}

-- ============================================================================
-- Tab-trigger snippets (manual expansion via cmp completion)
-- ============================================================================

local snippets = {

  -- Math mode (with placeholders, non-auto)
  parse({ trig = "\\sum", wordTrig = false, condition = in_math },
    "\\sum_{${1:i}=${2:1}}^{${3:N}} $0"),
  parse({ trig = "\\prod", wordTrig = false, condition = in_math },
    "\\prod_{${1:i}=${2:1}}^{${3:N}} $0"),
  parse({ trig = "\\int", wordTrig = false, condition = in_math },
    "\\int $1 \\, d${2:x} $0"),

  -- Partial derivative (with placeholders)
  parse({ trig = "par", wordTrig = true, condition = in_math },
    "\\frac{ \\partial ${1:y} }{ \\partial ${2:x} } $0"),

  -- Taylor expansion
  parse({ trig = "tayl", wordTrig = true, condition = in_math },
    "${1:f}(${2:x} + ${3:h}) = ${1:f}(${2:x}) + ${1:f}'(${2:x})${3:h} "
    .. "+ ${1:f}''(${2:x}) \\frac{${3:h}^{2}}{2!} + \\dots$0"),

  -- N x N identity matrix via dynamic function
  s({
    trig = "iden(%d)",
    regTrig = true,
    wordTrig = false,
    condition = in_math,
  }, {
    f(function(_, snip)
      local n = tonumber(snip.captures[1]) or 2
      local rows = {}
      for r = 1, n do
        local cols = {}
        for col = 1, n do cols[col] = (r == col) and "1" or "0" end
        rows[r] = table.concat(cols, " & ")
      end
      return "\\begin{pmatrix}\n" .. table.concat(rows, " \\\\\n") .. "\n\\end{pmatrix}"
    end, {}),
  }),
}

-- ============================================================================
-- Register for math-aware filetypes
-- ============================================================================

for _, ft in ipairs({ "tex", "latex", "plaintex", "markdown", "markdown.mdx", "quarto" }) do
  ls.add_snippets(ft, snippets, { type = "snippets", key = "latex_" .. ft })
  ls.add_snippets(ft, autosnippets, { type = "autosnippets", key = "latex_auto_" .. ft })
end
