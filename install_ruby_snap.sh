#!/usr/bin/env bash

ruby --version
if ! command -v ruby &> /dev/null
then
    echo "Going to try to install ruby (ideally 3.1.2)"
    ruby -v
# Proverbot's way to install ruby
#    # First, install Ruby, as that is for some reason required to build
#    # the "system" project
#    git clone https://github.com/rbenv/ruby-build.git ~/ruby-build
#    mkdir -p ~/.local
#    PREFIX=~/.local ./ruby-build/install.sh
#    ~/.local/ruby-build 3.1.2 ~/.local/
# ref: https://superuser.com/questions/340490/how-to-install-and-use-different-versions-of-ruby/1756372#1756372
    mkdir ~/.rbenv
    cd ~/.rbenv
    git clone https://github.com/rbenv/rbenv.git .

    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc.user
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc.user
    #    exec $SHELL
    # bash

    rbenv -v

    # - install ruby-build
    mkdir ~/.ruby-build
    cd ~/.ruby-build
    git clone https://github.com/rbenv/ruby-build.git .

    export PATH="$HOME/.ruby-build/bin:$PATH"
    echo 'export PATH="$HOME/.ruby-build/bin:$PATH"' >> ~/.bashrc.user
    #    exec $SHELL
    # bash

    ruby-build --version

    # - install ruby without sudo -- now that ruby build was install
    mkdir -p ~/.local
    #    ruby-build 3.1.2 ~/.local/
    rbenv install 3.1.2
    rbenv global 3.1.2

    ruby -v
fi


# - above worked but what was ruby's official way to do this?