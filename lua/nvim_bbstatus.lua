local M = {}

local ram_table = {}

-- Utility: Get the directory of this Lua file (plugin folder)
local function get_plugin_dir()
	local info = debug.getinfo(1, "S")
	local source = info.source:sub(2)
	return source:match("(.*/)")
end

local function load_ram_table()
	local base_path = get_plugin_dir() or ""
	local json_path = base_path .. "bitburner-ram.json"
	local file = io.open(json_path, "r")
	if not file then
		vim.g.bitburner_ram = "RAM: ERR"
		return
	end
	local content = file:read("*a")
	file:close()
	ram_table = vim.fn.json_decode(content)
end

-- Check if buffer looks like a Bitburner TS file
local function is_bitburner_file(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(10, vim.api.nvim_buf_line_count(bufnr)), false)
	for _, line in ipairs(lines) do
		-- Match: import { NS } from '@ns'
		if line:match("import%s+{%s*NS%s*}%s+from%s+['\"]@ns['\"]") then
			return true
		end
	end
	return false
end

function M.estimate_ram()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_get_option(bufnr, "filetype") ~= "typescript" then
		vim.g.bitburner_ram = ""
		return
	end
	if not is_bitburner_file(bufnr) then
		vim.g.bitburner_ram = ""
		return
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local code = table.concat(lines, "\n")

	local seen = {}
	local total_ram = 1.6 -- base RAM for a script
	for fn in code:gmatch("ns%.([a-zA-Z0-9_]+)") do
		if not seen[fn] then
			seen[fn] = true
			total_ram = total_ram + (ram_table[fn] or 0)
		end
	end

	vim.g.bitburner_ram = string.format("BB RAM: %.2f GB", total_ram)
end

function M.setup()
	load_ram_table()
end

return M
