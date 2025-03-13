---@class blink-cmp-nvim-px-to-vmin.Options
---@field root_font_size number
---@field decimal_count number
---@field filetypes string[]

local utils = require("nvim-px-to-vmin.utils")
local px_to_vmin = require("nvim-px-to-vmin")

local M = {}

---@param opts blink-cmp-nvim-px-to-vmin.Options
function M.new(opts)
	opts = opts or {}
	opts = vim.tbl_deep_extend("keep", opts, px_to_vmin.options)

	return setmetatable({
		root_font_size = opts.root_font_size,
		decimal_count = opts.decimal_count,
		filetypes = opts.filetypes,
	}, { __index = M })
end

function M:enabled()
	return vim.tbl_contains(self.filetypes, vim.bo.filetype)
end

---@param context blink.cmp.Context
---@param callback fun(items: blink.cmp.CompletionItem[])
function M:get_completions(context, callback)
	local input, word_start, word_end = utils.get_start_of_word_under_cursor(context.line, context.cursor[2] - 1)

	if input == "" then
		callback()
		return
	end

	local px = string.match(input, "%d+%.?%d*")

	local px_size = tonumber(px)
	if px_size == nil then
		callback()
		return
	end
	local vmin_size = px_size / self.root_font_size
	local pxvmin = string.format("%svmin", tostring(utils.round(vmin_size, self.decimal_count)))

	local items = {
		{
			label = pxvmin,
			kind = vim.lsp.protocol.CompletionItemKind.Value,
			insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
			filterText = input,
			textEdit = {
				newText = pxvmin,
				range = {
					start = {
						line = context.cursor[1] - 1,
						character = word_start,
					},
					["end"] = {
						line = context.cursor[1] - 1,
						character = word_end,
					},
				},
			},
			documentation = {
				kind = "markdown",
				value = "`" .. px .. "px -> " .. pxvmin .. "`",
			},
		},
	}

	local is_incomplete = string.find(input, "(-?%d+%.?%d*)px") == nil

	callback({
		context = context,
		is_incomplete_forward = is_incomplete,
		is_incomplete_backward = true,
		items = items,
	})
end

return M
