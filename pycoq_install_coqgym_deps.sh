#!/usr/bin/env bash

# -- Install Opam : Opam is for managing OCaml compiler(s), tools, and libraries. But it can be used for related things e.g. Coq Theorem Prover.
source $HOME/proverbot9001/install_opam.sh

# -- install Ruby, as that is for some reason required to build the "system" project
if command -v ruby &>/dev/null; then
  echo "Ruby is installed and its version is $(ruby -v)."
else
  echo "Ruby is not installed, going to install it..."
  source $HOME/proverbot9001/install_ruby_snap.sh
fi
ruby -v

# -- Git submodule "pull" all submodules (and init it)
# - git submodule init initializes your local configuration file to track the submodules your repository uses, it just sets up the configuration so that you can use the git submodule update command to clone and update the submodules.
git submodule init
# -- only need git submodule update --init because we don't want to fetch from remote to not break proverbot9001 & there are no recursive submodules
#git submodule update --init --recursive --remote  # not needed, no git repo has other submodules so --recursive not needed, --remote not needed because it might update the coq proj and make it incompatible with the coq version we use
#git submodule update --init --remote  # not needed, --remote not needed because it might update the coq proj and make it incompatible with the coq version we use
git submodule update --init
# - for each submodule pull from the right branch according to .gitmodule file. ref: https://stackoverflow.com/questions/74988223/why-do-i-need-to-add-the-remote-to-gits-submodule-when-i-specify-the-branch?noredirect=1&lq=1
#git submodule foreach -q --recursive 'git switch $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master || echo main )'
# - check it's in specified branch. ref: https://stackoverflow.com/questions/74998463/why-does-git-submodule-status-not-match-the-output-of-git-branch-of-my-submodule
git submodule status

# --- Install all Opam Dependencies: 1. create opam switch needed 2. then install all opam dependencies & projs
opam list
# - Create the 8.10.2 switch
opam switch create coq-8.10 4.07.1
eval $(opam env --switch=coq-8.10 --set-switch)
opam pin add -y coq 8.10.2
# - Install dependency packages for 8.10
opam repo add coq-extra-dev https://coq.inria.fr/opam/extra-dev
# We don't need it in all opam switches due to incompatabilities: Run `opam repository add <coq-proj> --all-switches|--set-default' to use it in all existing switches, or in newly created switches, respectively. cmd: opam repository add coq-extra-dev --all-switches
opam repo add coq-released https://coq.inria.fr/opam/released
opam repo add psl-opam-repository https://github.com/uds-psl/psl-opam-repository.git
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
# install call prevents that. https://stackoverflow.com/questions/75452026/how-do-i-install-ocamlfind-first-properly-before-other-opam-packages-without-roo, untested for now
opam install -y ocamlfind
opam install -y coq-equations coq-metacoq coq-metacoq-checker coq-metacoq-template

# lin-alg-8.10 needs opam switch coq-8.10
git submodule add -f --name coq-projects/lin-alg-8.10 git@github.com:HazardousPeach/lin-alg-8.10.git coq-projects/lin-alg
git submodule update --init coq-projects/lin-alg
(cd coq-projects/lin-alg && make "$@" && make install)
# to confirm it installed look for lin-alg: https://github.com/UCSD-PL/proverbot9001/issues/81, for now you can confirm by trying to install it again and it all looks alright
#opam list
#opam list | grep lin-alg-8.10

# Install the psl base-library from source
mkdir -p deps
git clone -b coq-8.10 git@github.com:uds-psl/base-library.git deps/base-library
(cd deps/base-library && make "$@" && make install)
git clone git@github.com:davidnowak/bellantonicook.git deps/bellantonicook
(cd deps/bellantonicook && make "$@" && make install)
opam list | grep base-library

# -- Get cheerios, req to have old versions work in opam: https://github.com/uwplse/cheerios/issues/17
eval $(opam env --switch=coq-8.10 --set-switch)
# opam install might give issues since it gets the most recent version from the official OPAM repository
#opam -y install coq-cheerios
#opam install -y coq-verdi
# use opam pin since pin is created to install specific version (e.g. from git, local, etc.)
opam pin add coq-cheerios git+https://github.com/uwplse/cheerios.git#9c7f66e57b91f706d70afa8ed99d64ed98ab367
#opam pin add coq-cheerios https://github.com/uwplse/cheerios.git\#9c7f66e57b91f706d70afa8ed99d64ed98ab367d
#opam pin add coq-verdi https://github.com/uwplse/verdi/tree/f3ef8d77afcac495c0864de119e83b25d294e8bb
opam pin add coq-verdi git+https://github.com/uwplse/verdi.git#f3ef8d77afcac495c0864de119e83b25d294e8bb
# use opam pin since pin is created to install specific version (e.g. from git, local, etc.)


# -- Get metalib for coq-8.10 via commit when getting it through git submodules (unsure if needed)
#rm -rf coq-projects/metalib
#git submodule add -f --name coq-projects/metalib https://github.com/plclub/metalib.git coq-projects/metalib
# - use the one with commit even if it doesn't work just to document the commit explicitly in the .modules file
git submodule add -f --name coq-projects/metalib git+https://github.com/plclub/metalib.git#104fd9efbfd048b7df25dbac7b971f41e8e67897 coq-projects/metalib
git submodule update --init coq-projects/metalib
(cd coq-projects/metalib && git checkout 104fd9efbfd048b7df25dbac7b971f41e8e67897)
(git rev-parse HEAD && cd ..)
# Metalib doesn't install properly through opam unless we use a specific commit.
eval $(opam env --switch=coq-8.10 --set-switch)
(cd coq-projects/metalib && opam install .)

# install it again since I think his code has pointers to a version under deps, could unify with above but it's less work to just accept as is and install it, ref: https://github.com/UCSD-PL/proverbot9001/issues/77
rm -rf deps/metalib
#git submodule add -f --name deps/metalib git+https://github.com/plclub/metalib.git deps/metalib
# - use the one with commit even if it doesn't work just to document the commit explicitly in the .modules file
git submodule add -f --name deps/metalib git+https://github.com/plclub/metalib.git#104fd9efbfd048b7df25dbac7b971f41e8e67897 deps/metalib
git submodule update --init deps/metalib
(cd deps/metalib && git checkout 104fd9efbfd048b7df25dbac7b971f41e8e67897)
(git rev-parse HEAD && cd ..)
# Metalib doesn't install properly through opam unless we use a specific commit.
eval $(opam env --switch=coq-8.10 --set-switch)
(cd deps/metalib && opam install .)

# -- Install metalib for coq-8.10 via opam pin (it seems to overwrite the isntalled versions so let's have opam pin be the last one?)
eval $(opam env --switch=coq-8.10 --set-switch)
opam pin add -y coq-metalib git+https://github.com/plclub/metalib.git#104fd9efbfd048b7df25dbac7b971f41e8e67897

# - Create the 8.14 switch (todo, why?)
#opam switch
#opam switch create coq-8.14 4.07.1
#eval $(opam env --switch=coq-8.14 --set-switch)
#opam pin add -y coq 8.14
# - trying to instal with 8.14 but can't install coq 8.14
#opam install -y coq-verdi

# Create the coq 8.12 switch
opam switch create coq-8.12 4.07.1
eval $(opam env --switch=coq-8.12 --set-switch)
opam pin add -y coq 8.12.2

# Install the packages that can be installed directly through opam
opam repo add coq-released https://coq.inria.fr/opam/released
#opam repository add coq-released --all-switches
opam repo add coq-extra-dev https://coq.inria.fr/opam/extra-dev
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
# NOT NEEDED rsync -av --delete /tmp/${USER}_dot_opam/ $HOME/.opam.dir | tqdm --desc="Writing shared opam state" > /dev/null





