execute pathogen#infect()

syntax on
filetype plugin indent on
set omnifunc=syntaxcomplete#Complete

" Security
set modelines=0

set hidden

" Enable vim enhancements
set nocompatible

" avoid 'hit enter prompt'
set shortmess=astTI

" increase ruler height
set cmdheight=2

set expandtab " Insert spaces when the tab key is hit
set tabstop=2 " Tab spacing of 2
set sw=2 " shift width (moved sideways for the shift command)
set smarttab

set wildmenu " use tab expansion in vim prompts

" stay in the middle of the screen
set scrolloff=999
set sidescrolloff=0

" scroll by one char at end of line
set sidescroll=1

" disable F1
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

"### automatically give executable permissions #################################

au BufWritePost * silent call ModeChange()

function ModeChange()
  if getline(1) =~ "^#!"
    if getline(1) =~ "/bin/"
      silent !chmod a+x <afile>
    endif
  endif
endfunction

"### colorscheme ###############################################################

" enable colors only if terminal supports colors
if &t_Co > 1
    syntax enable
endif

set t_Co=256

"###############################################################################

"###############################################################################
"
" SLACKWARE
"

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc


if has('gui_running')
  " Make shift-insert work like in Xterm
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
endif

set nobackup
set noundofile

"set t_8f=[38;2;%lu;%lu;%lum
"set t_8b=[48;2;%lu;%lu;%lum

let g:gruvbox_italic=1

set background=dark
"colorscheme solarized
colorscheme monokai
"colorscheme gruvbox

map <C-n> :NERDTreeTabsToggle<CR>
let g:nerdtree_tabs_autofind=1

set laststatus=2

nmap <leader>pl v2ge:!pl<CR>
vmap <leader>pl :!pl<CR>

"let g:airline_theme='solarized'

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
