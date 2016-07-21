" reformat paragraph with no arguments:
map gq {!}par}

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

set undolevels=1000
set inputtab=spaces noautotab
set shiftwidth=2
set autoindent
set showmode
set showmatch
set ruler
set remap
set report=1
set nonascii=all

source /usr/share/elvis-2.2_0/scripts/sfb.ex

