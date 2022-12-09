#!/usr/bin/env bash

# - official install ref: https://opam.ocaml.org/doc/Install.html
mkdir -p ~/.local/bin/
bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"
# type manually
~/.local/bin/
# note since it detects it in /usr/bin/opam it fails since then it tries to move opam from /usr/bin/opam to local
# ...

# if it's not at the systems level it seems to have worked
opam --versopm

# todo: without user interaction:
bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"

tr ':' '\n' <<< "$PATH"

opam init --disable-sandboxing
opam update --all
eval $(opam env)


# - not officially supported by opam
# - opam with conda
# maybe later, not needed I think...
# conda install -c conda-forge opam
# gave me an error in snap

# - as sudo opam
#add-apt-repository ppa:avsm/ppa
#apt update
#apt install opam
#eval $(opam env)