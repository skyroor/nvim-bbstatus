" Only load if airline is installed
if !exists('g:airline_section_x')
	echom "bitburner-ram: vim-airline not detected, skipping plugin load"
	finish
endif

lua require("nvim-bbstatus").setup()

" Run on relevant events
autocmd BufReadPost,BufEnter,BufWritePost *.ts lua require("nvim-bbstatus").estimate_ram()

" Show in airline
let g:airline_section_x = '%{get(g:, "nvim-bbstatus", "")}'
