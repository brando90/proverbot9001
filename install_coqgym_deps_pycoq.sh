#!/usr/bin/env bash

# -
which python

# -

if ! command -v ruby &> /dev/null
then
    echo "Going to try to install ruby (ideally 3.1.2)"
    ruby -v
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

git submodule update && git submodule init

# Sync opam state to local
#rsync -av --delete $HOME/.opam.dir/ /tmp/${USER}_dot_opam | tqdm --desc="Reading shared opam state" > /dev/null

# Create the 8.10 switch
#opam switch create coq-8.10 4.07.1
#eval $(opam env --switch=coq-8.10 --set-switch)
#opam pin add -y coq 8.10.2
# - since prev create a switch, check the version our coq, VPs coq is 8.11.0
# opam switch ocaml-variants.4.07.1+flambda_coq-serapi.8.11.0+0.11.1
# eval $(opam env)
# above should already but on from Dockerfile
# opam switch
# opam list

# Install dependency packages for 8.10
opam repo add coq-extra-dev https://coq.inria.fr/opam/extra-dev
opam repo add coq-released https://coq.inria.fr/opam/released
opam repo add psl-opam-repository https://github.com/uds-psl/psl-opam-repository.git
opam install -y coq-serapi \
     coq-struct-tact \
     coq-inf-seq-ext \
     coq-cheerios \
     coq-verdi \
     coq-smpl \
     coq-int-map \
     coq-pocklington \
     coq-mathcomp-ssreflect coq-mathcomp-bigenough coq-mathcomp-algebra\
     coq-fcsl-pcm \
     coq-ext-lib \
     coq-simple-io \
     coq-list-string \
     coq-error-handlers \
     coq-function-ninjas \
     coq-algebra \
     coq-zorns-lemma

opam pin -y add menhir 20190626
# coq-equations seems to rely on ocamlfind for it's build, but doesn't
# list it as a dependency, so opam sometimes tries to install
# coq-equations before ocamlfind. Splitting this into a separate
# install call prevents that.
opam install -y coq-equations \
     coq-metacoq coq-metacoq-checker coq-metacoq-template

# Metalib doesn't install properly through opam unless we use a
# specific commit.
(cd coq-projects/metalib && opam install .)

(cd coq-projects/lin-alg && make "$@" && make install)

# Install the psl base-library from source
mkdir -p deps
git clone -b coq-8.10 git@github.com:uds-psl/base-library.git deps/base-library
(cd deps/base-library && make "$@" && make install)

git clone git@github.com:davidnowak/bellantonicook.git deps/bellantonicook
(cd deps/bellantonicook && make "$@" && make install)

# Create the coq 8.12 switch
#opam switch create coq-8.12 4.07.1
#eval $(opam env --switch=coq-8.12 --set-switch)
#opam pin add -y coq 8.12.2

# Install the packages that can be installed directly through opam
opam repo add coq-released https://coq.inria.fr/opam/released
opam repo add coq-extra-dev https://coq.inria.fr/opam/extra-dev
opam install -y coq-serapi \
     coq-smpl=8.12 coq-metacoq-template coq-metacoq-checker \
     coq-equations \
     coq-mathcomp-ssreflect coq-mathcomp-algebra coq-mathcomp-field \
     menhir

# Install some coqgym deps that don't have the right versions in their
# official opam packages
git clone git@github.com:uwplse/StructTact.git deps/StructTact
(cd deps/StructTact && opam install -y . )
git clone git@github.com:DistributedComponents/InfSeqExt.git deps/InfSeqExt
(cd deps/InfSeqExt && opam install -y . )
# Cheerios has its own issues
git clone git@github.com:uwplse/cheerios.git deps/cheerios
(cd deps/cheerios && opam install -y --ignore-constraints-on=coq . )
(cd coq-projects/verdi && opam install -y --ignore-constraints-on=coq . )
(cd coq-projects/fcsl-pcm && make "$@" && make install)

# Finally, sync the opam state back to global
rsync -av --delete /tmp/${USER}_dot_opam/ $HOME/.opam.dir | tqdm --desc="Writing shared opam state" > /dev/null


# -
which python
