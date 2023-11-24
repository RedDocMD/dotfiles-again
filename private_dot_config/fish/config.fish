source /opt/local/share/fzf/shell/key-bindings.fish

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
    echo -n "MacMini:"
    echo (fish_prompt_pwd_dir_length=1 prompt_pwd);
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
set -px PATH $HOME/Android/cmdline-tools/latest/bin
set -px PATH /opt/local/libexec/perl5.34/sitebin/
set -px PATH /Applications/Inkscape.app/Contents/MacOS/inkscape

# Cargo
set -x CARGO_TARGET_DIR "$HOME/.cargo_target"

# Homebrew
set -gx HOMEBREW_PREFIX "/opt/homebrew";
set -gx HOMEBREW_CELLAR "/opt/homebrew/Cellar";
set -gx HOMEBREW_REPOSITORY "/opt/homebrew";
set -px PATH "/opt/homebrew/bin" "/opt/homebrew/sbin"
set -px MANPATH "/opt/homebrew/share/man"
set -px INFOPATH "/opt/homebrew/share/info"

# MacPorts
set -px PATH "/opt/local/bin" "/opt/local/sbin"
set -px LDPATH "/opt/local/lib"
set -px LIBRARY_PATH "/opt/local/lib"

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

set -x LANG en_US.UTF-8

source /Users/dknite/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

set -x EDITOR nvim
set -x RANGER_LOAD_DEFAULT_RC FALSE
set -x pager less

if command -v bat > /dev/null
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -x MANROFFOPT "-c"
end

# exa for ls
if command -v exa > /dev/null
    abbr -a ls exa
    abbr -a ll exa -l
    abbr -a la exa -a
    abbr -a lla exa -la
end

function diff -d "Fancy diff from Git"
    if command -v diff-so-fancy > /dev/null
        command git diff --color $argv | diff-so-fancy | less -r
    else
        command git diff --color $argv
    end
end


