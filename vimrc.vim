syntax on
filetype plugin indent on
set spell
set autoread autowrite hidden mouse=a
set completeopt=menu,menuone,noinsert
set omnifunc=ale#completion#OmniFunc
set sessionoptions-=buffers
set splitbelow splitright
set list listchars=tab:›\ ,space:·,trail:· sbr=>>>\
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab autoindent wrap linebreak
set relativenumber
set timeoutlen=500
set background=dark
set termguicolors
set spelllang=en_us

let g:session_autosave_periodic=1

let g:session_autosave='yes'
let g:session_autoload='yes'

function! SetupHighlight()
  highlight TrailWS ctermbg=red guibg=red

  let l:twgrp = 'TrailWS'
  let l:twpat = '\s\+$'
  let l:twpri = -1

  if exists('w:TrailWSMatch')
    call matchdelete(w:TrailWSMatch)
    call matchadd(twgrp, twpat, twpri, w:TrailWSMatch)
  else
    let w:TrailWSMatch = matchadd(twgrp, twpat, twpri)
  endif
endfunction

function! RemoveHighlight()
  if exists('w:TrailWSMatch')
    call matchdelete(w:TrailWSMatch)
    unlet w:TrailWSMatch
  endif
endfunction

augroup SetupHighlight
  autocmd!
  autocmd BufNew * call RemoveHighlight() | if &filetype != '' | call SetupHighlight()
  autocmd FileType * call RemoveHighlight() | if &filetype != '' | call SetupHighlight()
  autocmd TermOpen * call RemoveHighlight()
  autocmd BufWinLeave * call RemoveHighlight()
augroup end

augroup FileTypeConfig
  autocmd!
  autocmd FileType rust setlocal spell
augroup end

function! CargoFmt()
  silent! !cargo fmt > /dev/null
endfunction

augroup RustFmt
  autocmd!
  autocmd FileType rust autocmd BufWritePost * call CargoFmt()
augroup end

" Mappings

let mapleader=","
map <Leader>w :wa<Cr>
map! <Leader>w <C-c>:wa<Cr>
inoremap <C-BS> <C-w>

map <Leader>r :RangerCurrentFile<Cr>
map <Leader>R :RangerCurrentFileNewTab<Cr>

map <F2> :ALERename<Cr>
map <Leader>a :ALECodeAction<Cr>
map <Leader>f :ALEFix<Cr>
map <Leader>F :ALEOrganizeImports<Cr>
map <Leader>d :ALEGoToDefinition<Cr>
map <Leader>dd :ALEGoToDefinition -tab<Cr>
map <Leader>dt :ALEGoToTypeDefinition<Cr>
map <Leader>dtt :ALEGoToTypeDefinition -tab<Cr>
map <Leader>da :ALEFindReferences<Cr>
map <Leader>daa :ALEFindReferences -tab<Cr>
map <Leader>g :ALEDetail<Cr>
imap <Leader>g <C-c>:ALEDetail<Cr>a
map <Leader>h :ALEHover<Cr>

inoremap <C-Space> <C-x><C-o>
inoremap <expr> <Cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<Cr>"
inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<C-g>u\<Tab>"
inoremap <expr> <C-i> pumvisible() ? "\<C-y>" : "\<C-g>u\<C-i>"
inoremap <expr> <C-[> pumvisible() ? "\<C-e>" : "\<C-g>u\<C-[>"

map <Leader>. <Esc>
imap <Leader>. <C-c>
cmap <Leader>. <C-c>
vmap <Leader>. <C-c>
omap <Leader>. <C-c>
tmap <Leader>. <C-\><C-n>

map <A-1> 1gt
map <A-2> 2gt
map <A-3> 3gt
map <A-4> 4gt
map <A-5> 5gt
map <A-6> 6gt
map <A-7> 7gt
map <A-8> 8gt
map <A-9> 9gt
map <A-0> 10gt

noremap <Leader>sv :source $MYVIMRC<Cr>
noremap <Leader>se :edit $MYVIMRC<Cr>

packloadall
colorscheme nightfox

silent! helptags ALL
