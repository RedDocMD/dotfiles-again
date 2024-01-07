# greeting
function fish_greeting
end

# function fish_user_key_bindings
#     fzf_key_bindings
# end

# terminal title
function fish_title
    set -q argv[1]; or set argv fish
    # Looks like ~/d/fish: git log
    # or /e/apt: fish
    echo (fish_prompt_pwd_dir_length=1 prompt_pwd);
end

# Set environment variables
set -x EDITOR nvim
if command -v bat > /dev/null
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -x MANROFFOPT "-c"
end
set -x RANGER_LOAD_DEFAULT_RC FALSE
set -x pager less
set -x NEOVIDE_MULTIGRID true
if command -v chromium > /dev/null
    set -x CHROME_EXECUTABLE chromium
end
if command -v nnn > /dev/null
    set -x NNN_PLUG 'f:finder;t:nmount;v:imgview;g:dragdrop'
end

# eza for ls
if command -v eza > /dev/null
    abbr -a ls eza
    abbr -a ll eza -l
    abbr -a la eza -a
    abbr -a lla eza -la
end

# git abbreviations
abbr -a gaa git add .
abbr -a gcam git commit -am
abbr -a gcm git commit -m
abbr -a glog git log --oneline --decorate --graph
abbr -a gst git status
if command -v bat > /dev/null
    abbr -a gdf "git diff --name-only --diff-filter=d | xargs bat --diff"
end

function diff -d "Fancy diff from Git"
    if command -v diff-so-fancy > /dev/null
        command git diff --color $argv | diff-so-fancy | less -r
    else
        command git diff --color $argv
    end
end


abbr -a e nvim
abbr -a m emacsclient -c -a 'emacs'

# Dotfile repo
alias config '/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Pacman "interactive"
abbr -a paci "pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"

# PATH
set -px PATH $HOME/.local/bin
set -px PATH $HOME/.cargo/bin
set -px PATH $HOME/software/node/bin
set -px PATH $HOME/software/platform-tools
set -px PATH $HOME/software/julia-1.8.1/bin
set -px PATH $HOME/fuchsia/.jiri_root/bin
set -px PATH $HOME/software/go/bin
set -px PATH $HOME/go/bin
if test -e ~/fuchsia/scripts/fx-env.fish
    source ~/fuchsia/scripts/fx-env.fish
end
set -px PATH $HOME/.linuxbrew/bin $HOME/.linuxbrew/sbin
set -px PATH $HOME/.ghcup/bin
set -px PATH $HOME/software/flutter/bin
set -px PATH $HOME/.emacs.d/bin
set -px PATH $HOME/.dotnet

# Homebrew
set -x HOMEBREW_PREFIX "/home/dknite/.linuxbrew"
set -x HOMEBREW_CELLAR "/home/dknite/.linuxbrew/Cellar"
set -x HOMEBREW_REPOSITORY "/home/dknite/.linuxbrew/Homebrew"

# For ccache
if command -v ccache > /dev/null
    set -x USE_CCACHE 1
    set -x CCACHE_EXEC /usr/bin/ccache
    if test ! -e $HOME/.ccache
        mkdir $HOME/.ccache
    end
    set -x CCACHE_DIR $HOME/.ccache
end

# starship
if command -v starship &> /dev/null
    starship init fish | source
end

# zoxide
if command -v zoxide > /dev/null
    zoxide init fish | source
    abbr -a cd z
end

# Actiavte venv if present, on cd
function __venv_hook --on-variable PWD
    set --local venv_path "$PWD/.venv"
    if test -d $venv_path && test -e $venv_path
        source "$venv_path/bin/activate.fish"
    else
        functions -q deactivate &> /dev/null
        and deactivate
    end
end
set --local venv_path "$PWD/.venv"
if test -d $venv_path && test -e $venv_path
    source "$venv_path/bin/activate.fish"
end

# Make sure this is at the end
if test -e $HOME/.rvm
    set -px PATH $HOME/.rvm/bin
    rvm default
end

# opam configuration
set --local opam_path "/home/dknite/.opam/opam-init/init.fish"
if test -e $opam_path
    source $opam_path > /dev/null 2> /dev/null; or true
end

# tere
if command -v tere > /dev/null
    function tere
        set --local tere_path (which tere)
        set --local result ($tere_path $argv)
        [ -n "$result" ] && cd -- "$result"
    end
end

# Cargo
set -x CARGO_TARGET_DIR $HOME/.cargo_target

# Start X on login
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec startx -- -keeptty
    end
end

set -x npm_config_prefix "$HOME/.local"
