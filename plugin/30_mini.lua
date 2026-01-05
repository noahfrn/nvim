local now, later = MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

now(function()
	require("mini.basics").setup({
		options = { basic = false },
		mappings = {
			windows = true,
			move_with_alt = true,
		},
	})
end)

now(function()
	local ext3_blocklist = { scm = true, txt = true, yml = true }
	local ext4_blocklist = { json = true, yaml = true }
	require("mini.icons").setup({
		use_file_extension = function(ext, _)
			return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
		end,
	})

	later(MiniIcons.mock_nvim_web_devicons)

	later(MiniIcons.tweak_lsp_kind)
end)

now_if_args(function()
	require("mini.misc").setup()
	MiniMisc.setup_auto_root()

	MiniMisc.setup_restore_cursor()

	MiniMisc.setup_termbg_sync()
end)

now(function()
	require("mini.notify").setup()
end)

now(function()
	require("mini.sessions").setup()
end)

now(function()
	require("mini.starter").setup()
end)

now(function()
	require("mini.statusline").setup()
end)

now(function()
	require("mini.tabline").setup()
end)

later(function()
	require("mini.extra").setup()
end)

later(function()
	local ai = require("mini.ai")
	ai.setup({
		custom_textobjects = {
			B = MiniExtra.gen_ai_spec.buffer(),
			F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		},

		search_method = "cover",
	})
end)

later(function()
	require("mini.align").setup()
end)

later(function()
	require("mini.bracketed").setup()
end)

later(function()
	require("mini.bufremove").setup()
end)

later(function()
	local miniclue = require("mini.clue")
	miniclue.setup({
		clues = {
			Config.leader_group_clues,
			miniclue.gen_clues.builtin_completion(),
			miniclue.gen_clues.g(),
			miniclue.gen_clues.marks(),
			miniclue.gen_clues.registers(),
			miniclue.gen_clues.square_brackets(),
			miniclue.gen_clues.windows({ submode_resize = true }),
			miniclue.gen_clues.z(),
		},
		triggers = {
			{ mode = { "n", "x" }, keys = "<Leader>" }, -- Leader triggers
			{ mode = "n", keys = "\\" }, -- mini.basics
			{ mode = { "n", "x" }, keys = "[" }, -- mini.bracketed
			{ mode = { "n", "x" }, keys = "]" },
			{ mode = "i", keys = "<C-x>" }, -- Built-in completion
			{ mode = { "n", "x" }, keys = "g" }, -- `g` key
			{ mode = { "n", "x" }, keys = "'" }, -- Marks
			{ mode = { "n", "x" }, keys = "`" },
			{ mode = { "n", "x" }, keys = '"' }, -- Registers
			{ mode = { "i", "c" }, keys = "<C-r>" },
			{ mode = "n", keys = "<C-w>" }, -- Window commands
			{ mode = { "n", "x" }, keys = "z" }, -- `z` key
		},
	})
end)

later(function()
	require("mini.cmdline").setup()
end)

later(function()
	require("mini.comment").setup()
end)

later(function()
	local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
	local process_items = function(items, base)
		return MiniCompletion.default_process_items(items, base, process_items_opts)
	end
	require("mini.completion").setup({
		lsp_completion = {
			source_func = "omnifunc",
			auto_setup = false,
			process_items = process_items,
		},
	})

	local on_attach = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
	end
	_G.Config.new_autocmd("LspAttach", nil, on_attach, "Set 'omnifunc'")

	vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

later(function()
	require("mini.diff").setup()
end)

later(function()
	require("mini.files").setup({ windows = { preview = true } })

	local add_marks = function()
		MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
		local minideps_plugins = vim.fn.stdpath("data") .. "/site/pack/deps/opt"
		if vim.uv.fs_stat(minideps_plugins) then
			MiniFiles.set_bookmark("p", minideps_plugins, { desc = "Plugins" })
		end
		MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
	end
	_G.Config.new_autocmd("User", "MiniFilesExplorerOpen", add_marks, "Add bookmarks")
end)

later(function()
	require("mini.git").setup()
end)

later(function()
	local hipatterns = require("mini.hipatterns")
	local hi_words = MiniExtra.gen_highlighter.words
	hipatterns.setup({
		highlighters = {
			fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
			hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
			todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
			note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})
end)

later(function()
	require("mini.indentscope").setup()
end)

later(function()
	require("mini.jump").setup()
end)

later(function()
	require("mini.jump2d").setup()
end)

later(function()
	require("mini.keymap").setup()
	MiniKeymap.map_multistep("i", "<Tab>", { "pmenu_next" })
	MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev" })
	MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
	MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })
end)

later(function()
	local map = require("mini.map")
	map.setup({
		symbols = { encode = map.gen_encode_symbols.dot("4x2") },
		integrations = {
			map.gen_integration.builtin_search(),
			map.gen_integration.diff(),
			map.gen_integration.diagnostic(),
		},
	})

	for _, key in ipairs({ "n", "N", "*", "#" }) do
		local rhs = key .. "zv" .. "<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
		vim.keymap.set("n", key, rhs)
	end
end)

later(function()
	require("mini.move").setup()
end)

later(function()
	require("mini.operators").setup()

	vim.keymap.set("n", "(", "gxiagxila", { remap = true, desc = "Swap arg left" })
	vim.keymap.set("n", ")", "gxiagxina", { remap = true, desc = "Swap arg right" })
end)

later(function()
	require("mini.pairs").setup({ modes = { command = true } })
end)

later(function()
	require("mini.pick").setup()
end)

later(function()
	local latex_patterns = { "latex/**/*.json", "**/latex.json" }
	local lang_patterns = {
		tex = latex_patterns,
		plaintex = latex_patterns,
		markdown_inline = { "markdown.json" },
	}

	local snippets = require("mini.snippets")
	local config_path = vim.fn.stdpath("config")
	snippets.setup({
		snippets = {
			-- snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
			snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
		},
	})
end)

later(function()
	require("mini.splitjoin").setup()
end)

later(function()
	require("mini.surround").setup()
end)

later(function()
	require("mini.trailspace").setup()
end)

later(function()
	require("mini.visits").setup()
end)
