set undolevels=1000
set inputtab=spaces noautotab
set shiftwidth=2
set autoindent
set showmode
set showmatch
set ruler
set nu
set remap
set report=1
set nonascii=all
set incsearch
set hlsearch
set ignorecase
set smartcase

map  :sfb

" reformat paragraph with no arguments:
map gq {!}par

" like vim's set scrolloff=999
map j jz.
map k kz.
map  z.
map  z.
map G Gz.

map gg 1G

try {
 alias Mail {
  set bufdisplay="syntax email" equalprg="elvfmt -M"
  display syntax email
  if color("signature") == ""
  then color signature italic red on gray
  try $;?^-- *$?,$ region signature
 }
}

load since
load sfb

au BufReadPost *spec.rb {
  set ww=uk
  set mp="PS_MARKET=(ww) bundle exec rspec ($1?($2;char(58);$1;):$2) 2>&1"
}

au BufReadPost *.feature {
  set ww=uk
  set mp="PS_MARKET=(ww) bundle exec cucumber ($1?($2;char(58);$1;):$2) 2>&1"
}

au BufReadPost * {
  if knownsyntax(filename) == "ksh"
  then set mp="shellcheck $2 \| shellerr"
}

