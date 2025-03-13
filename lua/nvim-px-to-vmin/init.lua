local M = {}

M.options = {
	root_font_size = 16,
	decimal_count = 4,
	show_virtual_text = true,
	add_cmp_source = false,
	filetypes = {
		"css",
		"scss",
		"sass",
	},
}

-- operatorfunc doesn't support passing arguments
M.range = {
	range = 0,
	line1 = 0,
	line2 = 0,
}

M.setup = function(options)
	options = options or {}

	M.options = vim.tbl_deep_extend("keep", options, M.options)

	vim.api.nvim_create_user_command("PxToVminCursor", function()
		vim.api.nvim_feedkeys(M.px_to_vmin_at_cursor(), "n", false)
	end, {})
	vim.api.nvim_create_user_command("PxToVminLine", function(opts)
		M.range.range = opts.range
		M.range.line1 = opts.line1
		M.range.line2 = opts.line2

		vim.api.nvim_feedkeys(M.px_to_vmin_on_line(), "n", false)
	end, { range = true })

	if M.options.disable_keymaps ~= nil then
		vim.notify(
			"nvim-px-to-vmin: Keymaps aren't defined anymore, you can remove the `disable_keymaps` option and set you owns (see README.md)",
			vim.log.levels.WARN
		)
	end

	if M.options.show_virtual_text then
		M.virtual_text()
	end

	if M.options.add_cmp_source then
		require("nvim-px-to-vmin.integrations.cmp").setup(M.options)
	end

	return M.options
end

M.virtual_text = function()
	M.namespace = vim.api.nvim_create_namespace("nvim-px-to-vmin")

	-- Change filtype format from "*.css" to "css"
	local filetypes = {}
	for _, filetype in ipairs(M.options.filetypes) do
		table.insert(filetypes, "*" .. filetype)
	end

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "CursorMoved", "CursorMovedI" }, {
		pattern = filetypes,
		callback = function()
			M.px_to_vmin()
		end,
	})
end

M.px_to_vmin = function()
	-- Get current line content
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
	local virtual_text = {}
	local utils = require("nvim-px-to-vmin.utils")

	for vmin in line_content:gmatch("(-?%d+%.?%d*)vmin") do
		local vmin_size = tonumber(vmin)
		local px_size = vmin_size * 0.0926
		local pxvmin = string.format("%spx", tostring(px_size))
		table.insert(virtual_text, pxvmin)
	end

	-- Check if an extmark already exists
	local extmark = vim.api.nvim_buf_get_extmark_by_id(0, M.namespace, M.namespace, {})
	if extmark ~= nil then
		vim.api.nvim_buf_del_extmark(0, M.namespace, M.namespace)
	end

	local ns_id = tonumber(M.namespace)
	if #virtual_text > 0 and ns_id ~= nil then
		vim.api.nvim_buf_set_extmark(
			0,
			ns_id,
			line - 1,
			0,
			{
				virt_text = { { table.concat(virtual_text, " "), "Comment" } },
				id = M.namespace,
				priority = 100,
			}
			-- { { table.concat(virtual_text, " "), "Comment" } }
		)
	end
end

M.px_to_vmin_at_cursor = function()
	vim.go.operatorfunc = "v:lua.require'nvim-px-to-vmin'.dot_px_to_vmin_at_cursor"
	return "g@l"
end

M.dot_px_to_vmin_at_cursor = function()
	local regex = "%d+%.?%d*"
	local utils = require("nvim-px-to-vmin.utils")

	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
	local input, word_start, word_end = utils.get_start_of_word_under_cursor(line_content, col)

	local px = string.match(input, regex)

	if px == nil then
		vim.notify("No px value found", vim.log.levels.WARN)
		return
	end

	local px_size = tonumber(px)

	if px_size == nil then
		vim.notify("No px value found", vim.log.levels.WARN)
		return
	end

	local vmin_size = px_size * 0.0926
	local vmin = string.format("%svmin", tostring(vmin_size))

	vim.api.nvim_buf_set_text(0, line - 1, word_start, line - 1, word_end, { vmin })
end

M.px_to_vmin_on_line = function()
	vim.go.operatorfunc = "v:lua.require'nvim-px-to-vmin'.dot_px_to_vmin_on_line"
	return "g@l"
end

M.dot_px_to_vmin_on_line = function()
	local line_start
	local line_end

	if M.range.range == 0 then
		line_start = vim.api.nvim_win_get_cursor(0)[1]
		line_end = line_start
	else
		line_start = M.range.line1
		line_end = M.range.line2
	end

	local found = false
	local new_lines = {}
	for line = line_start, line_end do
		local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
		local new_line = line_content
		local utils = require("nvim-px-to-vmin.utils")

		for vmin in line_content:gmatch("(-?%d+%.?%d*)px") do
			local vmin_size = tonumber(vmin)
			local px_size = vmin_size / M.options.root_font_size
			local pxvmin = string.format("%vmin", tostring(utils.round(px_size, M.options.decimal_count)))

			found = true
			new_line = new_line:gsub("(-?%d+%.?%d*)px", pxvmin, 1)
		end

		table.insert(new_lines, new_line)
	end

	if not found then
		vim.notify("No px value found", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, new_lines)
end

return M
