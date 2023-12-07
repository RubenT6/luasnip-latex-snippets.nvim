--[
-- LuaSnip Conditions
--]

local M = {}

local lsp_util = require("lspconfig.util")
local function get_envs()
	local client = lsp_util.get_active_client_by_name(0, "texlab")
	local pos = vim.api.nvim_win_get_cursor(0)
	local params = {
		command = 'texlab.findEnvironments',
		arguments = {
			{
				textDocument = { uri = vim.uri_from_bufnr(0) },
				position = { line = pos[1] - 1, character = pos[2] },
			}
		}
	}
	if client then
		return client.request('workspace/executeCommand', params, function(err, result, ctx, config)
			if err then
				error(tostring(err))
			end
			return result
		end, 0)
	end
end

local function is_inside(envname)
	local envs = get_envs()
	for i = #envs, 1, -1 do
	-- going backwards is probably quicker, as environments closer to the cursor are more relevant?
		if envs[i] == envname then
			return true
		end
	end
	return false
end

-- math / not math zones

function M.in_math()
	-- return vim.api.nvim_eval("vimtex#syntax#in_mathzone()") == 1
	-- texlab does not seem to support this
	-- we allow math snippets everywhere for now
	return true
end

-- comment detection
function M.in_comment()
	-- return vim.fn["vimtex#syntax#in_comment"]() == 1
	-- also not supported by texlab
	-- we again allow comment snippets always
	return true
end

-- document class
function M.in_beamer()
	-- return vim.b.vimtex["documentclass"] == "beamer"
	-- not supported by texlab
	-- allow beamer snippets always
	return true
end

function M.in_preamble()
	return not is_inside("document")
end

function M.in_text()
	return is_inside("document")
end

function M.in_tikz()
	return is_inside("tikzpicture")
end

function M.in_bullets()
	return is_inside("itemize") or is_inside("enumerate")
end

function M.in_align()
	return is_inside("align") or is_inside("align*") or is_inside("aligned")
end

return M
