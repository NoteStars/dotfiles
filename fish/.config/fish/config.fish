source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

oh-my-posh init fish --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/velvet.omp.json' | source

#Set up zoxide PATH
zoxide init fish | source

# --- Set Yazi to use Emacs by default ---
export EDITOR=emacs

