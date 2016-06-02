" reformat paragraph with no arguments:
map gq {!}par}

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

set undolevels=12
set inputtab=spaces noautotab
set shiftwidth=2
set autoindent
set showmode
set showmatch
set ruler
set remap
set report=1

