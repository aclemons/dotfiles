" Run Rg in a new tmux window and open the selected file in a new split.
alias Rg split +"rgtweak !*" !tmux new-window 'tmux set-buffer "$($HOME/.elvis/bin/elvis_rg)" ; tmux wait-for -S elvis-worker-done' \; wait-for elvis-worker-done \; show-buffer && echo ""
alias rgtweak {
  eval 1,1s/.*/set a=&/x
  eval 2,2s/.*/set b=&/x
  eval edit (a) (b)
}
