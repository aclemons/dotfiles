" Run fzf in a new tmux window and open the selected file in a new split
alias fzf split +"fzftweak !*" !tmux new-window 'tmux set-buffer "$(fzf)" ; tmux wait-for -S elvis-worker-done' \; wait-for elvis-worker-done \; show-buffer && echo ""
alias fzftweak {
 eval 1,$s/.*/set a=&/x
 eval edit (a)
}
