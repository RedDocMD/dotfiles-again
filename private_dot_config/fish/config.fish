# greeting
function fish_greeting
end

function fish_user_key_bindings
    fzf_key_bindings
end

# terminal title
function fish_title
    set -q argv[1]; or set argv fish
    # Looks like ~/d/fish: git log
    # or /e/apt: fish
    echo -n "Collosus:"
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

# Cargo target dir
set --local cargo_tgt_dir $HOME/.cargo-target
if test -d $cargo_tgt_dir
    set -x CARGO_TARGET_DIR $cargo_tgt_dir
else
    mkdir $cargo_tgt_dir
    set -x CARGO_TARGET_DIR $cargo_tgt_dir
end

# exa for ls
if command -v exa > /dev/null
    abbr -a ls exa
    abbr -a ll exa -l
    abbr -a la exa -a
    abbr -a lla exa -la
end

# source autojump
set --local AUTOJUMP_PATH /usr/share/autojump/autojump.fish
if test -e $AUTOJUMP_PATH
    source $AUTOJUMP_PATH
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

# Dotfile repo
alias config '/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Pacman "interactive"
abbr -a paci "pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"

# PATH
set -px PATH $HOME/.local/bin
set -px PATH $HOME/.cargo/bin
set -px PATH $HOME/software/node-v14.17.3-linux-x64/bin
set -px PATH $HOME/software/platform-tools
set -px PATH $HOME/software/julia-1.6.2/bin
set -px PATH $HOME/fuchsia/.jiri_root/bin
set -px PATH $HOME/software/go/bin
set -px PATH $HOME/go/bin
set -px PATH $HOME/.local/share/coursier/bin
if test -e ~/fuchsia/scripts/fx-env.fish
    source ~/fuchsia/scripts/fx-env.fish
end
set -px PATH $HOME/.linuxbrew/bin $HOME/.linuxbrew/sbin
set -px PATH $HOME/.ghcup/bin

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
if command -v starship > /dev/null
    starship init fish | source
end

# zoxide
if command -v zoxide > /dev/null
    zoxide init fish | source
    abbr -a cd z
end

# Generated for envman. Do not edit.
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"

set -x FIDLMISC_DIR "$HOME/software/fidl-misc"
function fidldev
    $FIDLMISC_DIR/fidldev/fidldev.py $argv
end
set -x ASAN_SYMBOLIZER_PATH  "$HOME/fuchsia/prebuilt/third_party/clang/linux-x64/bin/llvm-symbolizer"

set -x npm_config_prefix "$HOME/.local"

# opam configuration
source /home/dknite/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
