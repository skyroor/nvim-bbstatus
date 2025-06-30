" Only load if airline is installed
if !exists('g:airline_section_x')
	echom "bitburner-ram: vim-airline not detected, skipping plugin load"
	finish
endif

lua require("bitburner_ram").setup()

" Run on relevant events
autocmd BufReadPost,BufEnter,BufWritePost *.ts lua require("bitburner_ram").estimate_ram()

" Show in airline
let g:airline_section_x = '%{get(g:, "bitburner_ram", "")}'
