local M = {}

local ram_table = {}

local function load_ram_table()
local path = vim.fn.expand("~/.config/nvim/bitburner-ram.json") -- You can make this configurable
local file = io.open(path, "r")
if not file then
	vim.g.bitburner_ram = "RAM: ERR"
	return
end
local content = file:read("*a")
file:close()
ram_table = vim.fn.json_decode(content)
end

local function is_bitburner_file(bufnr)
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(10, vim.api.nvim_buf_line_count(bufnr)), false)
for _, line in ipairs(lines) do
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
local total_ram = 1.6
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
