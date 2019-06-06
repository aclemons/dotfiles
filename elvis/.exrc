" more undo
set undolevels=1000
" auto indent the start of each line
set autoindent
" show current mode in bottom right corner
set showmode
" show matching ),],}
set showmatch
" show line and column numbers at bottom of screen
set ruler
" so line numbers at the beginning of the line
set number
" show all changed lines in a file
set report=1
" show all characters
set nonascii=all
" search while typing
set incsearch
" highlight matches
set hlsearch
" ignore case
set ignorecase
" respect case if search has uppercase letters
set smartcase

" like vim's set scrolloff=999
map j jz.
map k kz.
map  z.
map  z.
map G Gz.

" go to first line
map gg 1G

au BufReadPost *.rb {
  set makeprg="bundle exec rubocop --format emacs ($1?($2;char(58);$1;):$2)"
}

au BufReadPost *.info {
  set bufdisplay="syntax ksh"
}

au BufReadPost *_spec.rb {
  set ww=uk
  set ccprg="COUNTRY=(ww) bundle exec spring rspec ($1?($2;char(58);$1;):$2) 2>&1"
}

au BufReadPost *.feature {
  set ww=uk
  set ccprg="COUNTRY=(ww) bundle exec spring cucumber ($1?($2;char(58);$1;):$2) 2>&1"
}

au BufReadPost * {
  if !knownsyntax(filename) && buflines >= 1
  then {
    try 1s/\V^#! *\/usr\/bin\/env \([^ ]\+\).*/set! bufdisplay="syntax \1"/x
  }

  if knownsyntax(filename) == "ksh" || bufdisplay=="syntax bash"
  then set makeprg="shellcheck -f gcc $2"
}

load fzf
load copy

" some more mappings
map <SPACE>pf :fzf<ENTER>
map <SPACE>bo :only<ENTER>
map <SPACE>wn w
map <SPACE>fyY :grabfile<ENTER>
map <SPACE>en :errlist<ENTER>

" elvis doesn't support CTRL-0 to paste in ex mode, so make a map which sort of does the same thing
map 0 :("1)s/.*/! &/x
