#!/usr/bin/env bash

source ~/.bashrc.user
echo running: $0
echo $HOME
cd $HOME/proverbot9001
realpath .

# - install Ruby, as that is for some reason required to build the "system" project
## idk why this doesn't work, doesn't matter for now
#if ! command -v ruby &> /dev/null
#then
#    ruby -v
#    echo ruby NOT found
##    sh ~/pycoq/install_ruby_snap.sh
#else
#    echo ruby found
#fi
ruby -v

# - I think this pulls the coq projects properly in proverbot
# todo, metalib missing, how do I pull it with gitsubmodules? https://stackoverflow.com/questions/74757297/how-do-i-make-sure-to-re-add-a-submodule-correctly-with-a-git-command-without-ma
#rm -rf coq-projects/metalib
git submodule add -f --name coq-projects/metalib https://github.com/plclub/metalib.git coq-projects/metalib

# todo: can't make it work: https://stackoverflow.com/questions/74757702/why-is-git-submodules-saying-there-isnt-a-url-when-there-is-one-even-when-i-try, https://github.com/UCSD-PL/proverbot9001/issues/61
# todo: I suggest we use the original lin-alg https://github.com/coq-contribs/lin-alg
#ls coq-projects/lin-alg
#ls coq-projects/coq-projects/lin-alg
#rm -rf coq-projects/lin-alg
#rm -rf coq-projects/coq-projects/lin-alg
#git submodule add -f git@github.com:HazardousPeach/lin-alg-8.10.git coq-projects/lin-alg
#git submodule add -f --name coq-projects/lin-alg-8.10 git@github.com:HazardousPeach/lin-alg-8.10.git coq-projects/lin-alg
#git submodule add -f --name coq-projects/lin-alg-8.10 https://github.com/HazardousPeach/lin-alg-8.10.git coq-projects/lin-alg
#git submodule add -f --name coq-projects/lin-alg https://github.com/coq-contribs/lin-alg.git coq-projects/lin-alg
# note you might have to delete the contents of those path above for it to work
# you might also need to update the .gitmodules manually, make sure no double counts
git submodule update && git submodule init

# - Sync opam state to local https://github.com/UCSD-PL/proverbot9001/issues/52
#rsync -av --delete $HOME/.opam.dir/ /tmp/${USER}_dot_opam | tqdm --desc="Reading shared opam state" > /dev/null

opam update

# - Use pycoq's switch
#opam switch create ocaml-variants.4.07.1+flambda_coq-serapi.8.11.0+0.11.1 ocaml-variants.4.07.1+flambda
#opam switch ocaml-variants.4.07.1+flambda_coq-serapi.8.11.0+0.11.1
#eval $(opam env --switch=ocaml-variants.4.07.1+flambda_coq-serapi.8.11.0+0.11.1 --set-switch)
#opam pin add -y coq 8.11.0

# - one of the commands bellow want coq 8.14...would be nice to
opam switch
opam switch create coq-8.14 4.07.1
eval $(opam env --switch=coq-8.14 --set-switch)
opam pin add -y coq 8.14

# - trying to instal with 8.14 but can't install coq 8.14
#opam install -y coq-cheerios
#opam install -y coq-verdi

# - Create the 8.10 switch
opam switch
opam switch create coq-8.10 4.07.1
eval $(opam env --switch=coq-8.10 --set-switch)
opam pin add -y coq 8.10.2

# - Install dependency packages for coq 8.10 (this might fail since this VPs switch is: ...)
opam repo add coq-extra-dev https://coq.inria.fr/opam/extra-dev
# Run `opam repository add coq-extra-dev --all-switches|--set-default' to use it in all existing switches, or in newly created switches, respectively.
#opam repository add coq-extra-dev --all-switches
opam repo add coq-released https://coq.inria.fr/opam/released
#opam repository add coq-released --all-switches
opam repo add psl-opam-repository https://github.com/uds-psl/psl-opam-repository.git
#opam repository add psl-opam-repository --all-switches

# - worked with 8.10.2
#opam install -y coq-serapi \
#     coq-struct-tact \
#     coq-inf-seq-ext \
#     coq-cheerios \
#     coq-verdi \
#     coq-smpl \
#     coq-int-map \
#     coq-pocklington \
#     coq-mathcomp-ssreflect coq-mathcomp-bigenough coq-mathcomp-algebra\
#     coq-fcsl-pcm \
#     coq-ext-lib \
#     coq-simple-io \
#     coq-list-string \
#     coq-error-handlers \
#     coq-function-ninjas \
#     coq-algebra \
#     coq-zorns-lemma
opam install -y coq-serapi
opam install -y coq-struct-tact
opam install -y coq-inf-seq-ext
opam install -y coq-smpl
opam install -y coq-int-map
opam install -y coq-pocklington
opam install -y coq-mathcomp-ssreflect coq-mathcomp-bigenough coq-mathcomp-algebra
opam install -y coq-fcsl-pcm
opam install -y coq-list-string
opam install -y coq-error-handlers
opam install -y coq-function-ninjas
opam install -y coq-algebra
opam install -y coq-zorns-lemma


opam pin -y add menhir 20190626
# coq-equations seems to rely on ocamlfind for it's build, but doesn't
# list it as a dependency, so opam sometimes tries to install
# coq-equations before ocamlfind. Splitting this into a separate
# install call prevents that.
opam install -y coq-equations coq-metacoq coq-metacoq-checker coq-metacoq-template

# todo why is $@ needed?, https://stackoverflow.com/questions/74757702/why-is-git-submodules-saying-there-isnt-a-url-when-there-is-one-even-when-i-try, https://github.com/UCSD-PL/proverbot9001/issues/61
#(cd coq-projects/lin-alg && make "$@" && make install)

# Install the psl base-library from source
mkdir -p deps
git clone -b coq-8.10 git@github.com:uds-psl/base-library.git deps/base-library
(cd deps/base-library && make "$@" && make install)

git clone git@github.com:davidnowak/bellantonicook.git deps/bellantonicook
(cd deps/bellantonicook && make "$@" && make install)

# Create the coq 8.12 switch
opam switch create coq-8.12 4.07.1
eval $(opam env --switch=coq-8.12 --set-switch)
opam pin add -y coq 8.12.2

# Install the packages that can be installed directly through opam
opam repo add coq-released https://coq.inria.fr/opam/released
#opam repository add coq-released --all-switches
opam repo add coq-extra-dev https://coq.inria.fr/opam/extra-dev
#opam install -y coq-serapi \
#  coq-smpl=8.12 coq-metacoq-template coq-metacoq-checker \
#  coq-equations \
#  coq-mathcomp-ssreflect coq-mathcomp-algebra coq-mathcomp-field \
#  menhir
opam install -y coq-serapi
opam install -y coq-smpl=8.12 coq-metacoq-template coq-metacoq-checker
opam install -y coq-equations
opam install -y coq-mathcomp-ssreflect coq-mathcomp-algebra coq-mathcomp-field
opam install -y menhir

# - succeeded with 8.12 switch
opam install -y coq-ext-lib
opam install -y coq-simple-io

# Install some coqgym deps that don't have the right versions in their
# official opam packages
git clone git@github.com:uwplse/StructTact.git deps/StructTact
(cd deps/StructTact && opam install -y .)
git clone git@github.com:DistributedComponents/InfSeqExt.git deps/InfSeqExt
(cd deps/InfSeqExt && opam install -y .)
# Cheerios has its own issues
git clone git@github.com:uwplse/cheerios.git deps/cheerios
(cd deps/cheerios && opam install -y --ignore-constraints-on=coq .)
(cd coq-projects/verdi && opam install -y --ignore-constraints-on=coq .)
(cd coq-projects/fcsl-pcm && make "$@" && make install)

# Finally, sync the opam state back to global https://github.com/UCSD-PL/proverbot9001/issues/52
#rsync -av --delete /tmp/${USER}_dot_opam/ $HOME/.opam.dir | tqdm --desc="Writing shared opam state" > /dev/null

# Create the coq 8.15 switch
#opam switch create coq-8.15 4.07.1
#eval $(opam env --switch=coq-8.15 --set-switch)
#opam pin add -y coq 8.15

# - worked with 8.15
#opam install metalib
## Metalib doesn't install properly through opam unless we use a
## specific commit.
#(cd coq-projects/metalib && opam install .)
