" Check if vim-airline plugin is loaded
if empty(globpath(&rtp, 'autoload/airline.vim'))
	echom "bitburner-ram: vim-airline not detected, skipping plugin load"
	finish
endif

lua require("nvim_bbstatus").setup()

autocmd BufReadPost,BufEnter,BufWritePost *.ts lua require("nvim_bbstatus").estimate_ram()

" Display the RAM usage variable in airline section x
let g:airline_section_x = '%{get(g:, "bitburner_ram", "")}'
