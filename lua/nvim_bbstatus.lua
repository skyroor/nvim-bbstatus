local M = {}

local label_prefix = vim.g.bbstatus_label_prefix or "RAM Estimate ~ "
local ram_table = {}

local function get_plugin_dir()
	local info = debug.getinfo(1, "S")
	local source = info.source:sub(2)
	return source:match("(.*/)")
end

-- Load RAM cost table from plugin directory
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

-- Check if the file looks like a Bitburner script
local function is_bitburner_file(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(10, vim.api.nvim_buf_line_count(bufnr)), false)
	for _, line in ipairs(lines) do
		if line:match("import%s+{%s*NS%s*}%s+from%s+['\"]@ns['\"]") then
			return true
		end
	end
	return false
end

-- Main RAM estimation function
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

	local total_ram = 1.6	-- Base RAM for any script
	local seen = {}

	-- Count each ns.method only once
	for fn in code:gmatch("ns%.([a-zA-Z0-9_%.]+)%s*%(") do
		if not seen[fn] then
			seen[fn] = true
			total_ram = total_ram + (ram_table[fn] or 0)
		end
	end

	-- Account for special top-level objects
	local special_objects = {
		hacknet = 1.0,
		document = 1.0,
		window = 1.0
	}
	for name, cost in pairs(special_objects) do
		if code:find(name, 1, true) then
			total_ram = total_ram + cost
		end
	end

	total_ram = math.min(total_ram, 64)

	-- Set airline var
	vim.g.bitburner_ram = string.format("%s%.2f GB", label_prefix, total_ram)

end

-- Load once

function M.setup()
	load_ram_table()

	vim.api.nvim_create_user_command("BBStatus", function(opts)
		label_prefix = opts.args
		vim.g.bbstatus_label_prefix = label_prefix
		M.estimate_ram()
	end, {
		nargs = 1,
		desc = "Set the RAM display label prefix"
	})
end


return M
