execute pathogen#infect()

" Security
set modelines=0

set hidden

" Enable vim enhancements
set nocompatible

" avoid 'hit enter prompt'
set shortmess=astTI

" increase ruler height
set cmdheight=2

" always show status line
set ruler
set rulerformat=%80(%<%F\ %{(&fenc==\"\"?&enc:&fenc)}%Y%{&ff=='unix'?'':','.&ff}%=\ %2c\ %P%)

" searching

" use normal regexes
nnoremap / /\v
vnoremap / /\v

set showmatch " Show matching brackets.
set incsearch " Incremental search
set hlsearch " highlight found text

set ignorecase
set smartcase " case insensitive search when all lowercase
set infercase " case inferred by default

set autoread " Set to auto read when a file is changed from the outside

set nostartofline " leave my cursor where it was - even on page jump

set expandtab " Insert spaces when the tab key is hit
set tabstop=2 " Tab spacing of 2
set sw=2 " shift width (moved sideways for the shift command)
set smarttab

set backspace=indent,eol,start " make backspace more flexible

set wildmenu " use tab expansion in vim prompts

" try to restore last known cursor position
autocmd BufReadPost * if line("'\"") | exe "normal '\"" | endif

set nowrapscan " do not wrap while searching

" show arrows for too long lines / show trailing spaces
set list listchars=tab:\ \ ,trail:.,precedes:<,extends:>

" stay in the middle of the screen
set scrolloff=999
set sidescrolloff=0

" scroll by one char at end of line
set sidescroll=1

set iskeyword+=:,_,$,@,%,# " none of these are word dividers

set noerrorbells " don't make noise
set novisualbell

set ttyfast

let mapleader = ","
inoremap jj <ESC>jj

" disable F1
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

filetype on " detect filetypes and run filetype plugins - needed for taglist
filetype indent on
filetype plugin on

"### split windows #############################################################

" move between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" open new window an move into it
nnoremap <leader>w :80vs<cr><C-w>l
nnoremap <leader>wc <C-w>c

"### mappings ##################################################################

" these are the same for vim
" Tab and Ctrl-I
" Enter and Ctrl-M
" Esc and Ctrl-[ 

" clear all mappings
" :mapclear

" dont use Q for Ex mode
map Q :q

" write only if changed
" map :w :up

" nnoremap <c-k> g<c-]>
" nnoremap <c-j> <c-t>

" history jump
" nnoremap <s-h> <c-o>
" nnoremap <s-l> <c-i>

"### Highlight cursor line after cursor jump ###################################

au CursorMoved,CursorMovedI * call s:Cursor_Moved()
let g:last_pos = 0

function s:Cursor_Moved()
  let cur_pos = winline()
  if g:last_pos == 0
    set cul
    let g:last_pos = cur_pos
    return
  endif
  let diff = g:last_pos - cur_pos
  if diff > 1 || diff < -1
    set cul
  else
    set nocul
  endif
  let g:last_pos = cur_pos
endfunction

"### automatically give executable permissions #################################

au BufWritePost * silent call ModeChange()

function ModeChange()
  if getline(1) =~ "^#!"
    if getline(1) =~ "/bin/"
      silent !chmod a+x <afile>
    endif
  endif
endfunction

"### perl ######################################################################

au FileType perl silent call PerlStuff()
function! PerlStuff()

" syntax check on write
" au BufWritePost *.p[lm] !perl -wcIlib %

" map E :w<CR>:!r<CR>

"--- perltidy ------------------------------------------------------------------

map <silent> W :call PerlTidy()<CR>

function PerlTidy()
    let _view=winsaveview()
    %!perltidy -q
    call winrestview(_view)
endfunction

"--- :make with error parsing --------------------------------------------------

map E :make<cr>
set makeprg=$VIMRUNTIME/tools/efm_perl.pl\ -c\ %\ $*
set errorformat=%f:%l:%m

"--- show documentation for builtins and modules under cursor ------------------
" http://www.perlmonks.org/?node_id=441738

map <silent> M :call PerlDoc()<cr>:set nomod<cr>:set filetype=man<cr>

function! PerlDoc()

  normal yy

  let l:this = @

  if match(l:this, '^ *\(use\|require\) ') >= 0

    exe ':new'
    exe ':resize'

    let l:this = substitute(l:this, '^ *\(use\|require\) *', "", "")
    let l:this = substitute(l:this, ";.*", "", "")
    let l:this = substitute(l:this, " .*", "", "")

    exe ':0r!perldoc -t ' . l:this
    exe ':0'
    noremap <buffer> <esc> <esc>:q!<cr>

    return

  endif

  normal yiw
  exe ':new'
  exe ':resize'
  exe ':0r!perldoc -t -f ' . @
  exe ':0'
  noremap <buffer> <esc> <esc>:q!<cr>

endfunction

" PerlStuff() end
endfunction


"### XML #######################################################################

au FileType xml,html,xhtml silent call XmlStuff()
function! XmlStuff()

map <silent> W :call XMLTidy()<CR>

function XMLTidy()
    let _view=winsaveview()
    %!tidy -q -i -xml --tab-size 2
    " --indent-attributes 1
    " %!xmllint --format --recover -
    call winrestview(_view)
endfunction

" XmlStuff() end
endfunction

"### colorscheme ###############################################################

" NOTE
" to convert a highcolor theme to run in a 256-color-terminal-vim
" use CSApprox plugin and store theme with :CSApproxSnapshot

" enable colors only if terminal supports colors
if &t_Co > 1
    syntax enable
endif

set t_Co=256

"### taglist ###################################################################

if executable('ctags')

    map <silent> <c-o> :call My_TagList()<CR>/

    function My_TagList()

        exe ":TlistToggle"
        exe ":TlistUpdate"

        noremap <buffer> <esc> <esc>:q<cr>

    endfunction

    let Tlist_GainFocus_On_ToggleOpen = 1
    let Tlist_Close_On_Select = 1
    let Tlist_Compact_Format = 1
    let Tlist_Exit_OnlyWindow = 1
    let Tlist_Auto_Highlight_Tag = 1
    let Tlist_Highlight_Tag_On_BufEnter = 1
    let Tlist_Inc_Winwidth = 0
    let Tlist_Auto_Update = 1
    let Tlist_Display_Tag_Scope = 0

else

    let loaded_taglist = 'no'

endif

"### Keep cursor position on undo and redo #####################################

map <silent> u :call MyUndo()<CR>
function MyUndo()
    let _view=winsaveview()
    :undo
    call winrestview(_view)
endfunction

map <silent> <c-r> :call MyRedo()<CR>
function MyRedo()
    let _view=winsaveview()
    :redo
    call winrestview(_view)
endfunction

" TeX
autocmd Filetype tex setlocal nofoldenable

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

set background=light
colorscheme solarized


map <C-n> :NERDTreeToggle<CR>
