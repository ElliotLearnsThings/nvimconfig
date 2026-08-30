-- In your LuaSnip configuration file (e.g., lua/config/luasnip.lua)

local ls = require("luasnip")

ls.setup({
	enable_autosnippets = true,
	update_events = "TextChanged,TextChangedI",
})
-- Pull in the snippet functions
local s = ls.s
local i = ls.i
local t = ls.t

ls.add_snippets("typescriptreact", {
	-- Example snippet: A simple print statement
	s("cfun", {
		-- Anon typescript function
		t("("), i(1, ') => {\n'), i(2, "\n"), t("}"), i(0)
	}),
	s("ust", { -- useState hook
		t('const ['),
		i(1, "state"),
		t(', set'), 
		i(2, "State"),
		t('] = useState<'),
		i(3, "Any"),
		t(' | null>('),
		i(4, "null"),
		t(');'), i(0)
	}),
	s("uef", { -- useEffect hook
		t('useEffect(() => {'),
		t({ '' }),
		i(1),
		t({ '' }),
		t('}, ['), i(2), t(']);'),
		t({ '' }),
		i(0)
	}),
	s("ppp", { -- console.log
		t('console.log('), i(1, "value"), t(');'),
		i(0)
	}),
	s("edfp", { -- Export default function page
		t('"use client";'), t({ '', '' }),
		t('export default function '), i(1, "ComponentName"), t('() {'),
		t({ '', '\treturn (' }),
		t({ '\t\t<div>' }), i(2, "Content"), t({ '</div>', '\t);' }),
		t({ '}' }),
		i(0)
	}),
	s("edafp", { -- Export default async function page
		t('"use client";'), t({ '', '' }),
		t('export default async function '), i(1, "ComponentName"), t('() {'),
		t({ '', '\treturn (' }),
		t({ '\t\t<div>' }), i(2, "Content"), t({ '</div>', '\t);' }),
		t({ '}' }),
		i(0)
	}),
	s("impt", { -- Import statement
		t('import { '), i(1, "module"), t(' } from "'), i(2, "package"), t('";'),
		i(0)
	}),
	s("flexc", { -- Flex container div
		t('<div className="flex justify-center items-center '), i(1, "additionalClasses"), t('">'),
		t({ '', '\t' }), i(2, "Content"),
		t({ '', '</div>' }),
		i(0)
	}),
	s("absc", { -- Flex container div
		t('<div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 '), i(1, "additionalClasses"), t('">'),
		t({ '', '\t' }), i(2, "Content"),
		t({ '', '</div>' }),
		i(0)
	}),
	s("umemo", { -- useMemo hook
		t('const '), i(1, "memoizedValue"), t(' = useMemo(() => {'),
		t({ '', '\treturn ' }), i(2, "computeValue()"), t(';'),
		t({ '', '}, [' }), i(3, "dependencies"), t(']);'),
		i(0)
	}),
	s("ismob", { -- isMobile check
		t('const isMobile = useMediaQuery({ query: "(max-width: 768px)" });'),
		i(0)
	}),
	s("rout", { -- useRouter hook
		t('const router = useRouter();'),
		i(0)
	}),
	s("bclass", { -- Create a class with constructor
		t('class '), i(1, "ClassName"), t(' {'),
		t({ '', '\tconstructor(' }), i(2, "params"), t(') {'),
		t({ '', '\t\t' }), i(3, "// initialization code"), t({ '', '\t}' }),
		t({ '', '\t' }), i(4, "// methods"), t({ '', '}' }),
		i(0)
	}),
})

ls.add_snippets("typescript", {
	-- Example snippet: A simple print statement
	s("cfun", {
		-- Anon typescript function
		t("("), i(1, ') => {\n'), i(2, "\n"), t("}"), i(0)
	}),
	s("ppp", { -- console.log
		t('console.log('); i(1, "value"); t(');'),
		i(0)
	}),
	s("impt", { -- Import statement
		t('import { '), i(1, "module"), t(' } from "'), i(2, "package"), t('";'),
		i(0)
	}),
	s("bclass", { -- Create a class with constructor
		t('class '), i(1, "ClassName"), t(' {'),
		t({ '', '\tconstructor(' }), i(2, "params"), t(') {'),
		t({ '', '\t\t' }), i(3, "// initialization code"), t({ '', '\t}' }),
		t({ '', '\t' }), i(4, "// methods"), t({ '', '}' }),
		i(0)
	}),
})

ls.add_snippets("python", {
	s("lamfun", { -- Lambda function
		t('lambda '), i(1, "args"), t(': '), i(2, "expression"),
		i(0)
	}),
	s("defun", { -- Define function
		t('def '), i(1, "function_name"), t('('), i(2, "params"), t(') -> '), i(3, "return_type"), t(':'),
		t({ '', '\t' }), i(4, "pass"),
		i(0)
	}),
	s("name", { -- if __name__ == "__main__":
		t('if __name__ == "__main__":'),
		t({ '', '\t' }), i(1, "main()"),
		i(0)
	}),
	s("bclass", { -- Create a class with constructor
		t('class '), i(1, "ClassName"), t(':'),
		t({ '', '\tdef __init__(' }), i(2, "self, params"), t('):'),
		t({ '', '\t\t' }), i(3, "pass"),
		t({ '', '\t' }), i(4, "# methods"),
		i(0)
	}),
	s("dclass", { -- Create a dataclass
		t('from dataclasses import dataclass'),
		t({ '', '', '@dataclass' }),
		t('class '), i(1, "ClassName"), t(':'),
		t({ '', '\t' }), i(2, "# fields"),
		i(0)
	}),
	s("proto", { -- Create a protocol
		t('from typing import Protocol'),
		t({ '', '', 'class ' }), i(1, "ProtocolName"), t('(Protocol):'),
		t({ '', '\t' }), i(2, "# methods"),
		i(0)
	}),
	s("abclass", { -- Create an abstract class
		t('from abc import ABC, abstractmethod'),
		t({ '', '', 'class ' }), i(1, "ClassName"), t('(ABC):'),
		t({ '', '\t@abstractmethod' }),
		t({ '', '\tdef ' }), i(2, "method_name"), t('(self):'),
		t({ '', '\t\t' }), i(3, "pass"),
		i(0),
		s("statm", { -- Static method
			t('@staticmethod'),
			t({ '', 'def ' }), i(1, "method_name"), t('('), i(2, "params"), t(') -> '), i(3, "return_type"), t(':'),
			t({ '', '\t' }), i(4, "pass"),
			i(0)
		}),
	})
})

