#!/usr/bin/env bash
# source swarm-prelude.sh

#source ~/.bashrc.lfs
#conda activate iit_synthesis
#echo $HOME
#cd $HOME/proverbot9001
#realpath .

#echo "done setting up the .bashrc.lfs etc."

#bash pycoq_build_coq_projects.sh

# - for weird umass cluster permission, we don't need it I think: https://github.com/UCSD-PL/proverbot9001/issues/54
#INIT_CMD="~/opam-scripts/read-opam.sh"
#INIT_CMD=""

NTHREADS=1
#while getopts ":j:" opt; do
#  case "$opt" in
#    j)
#      NTHREADS="${OPTARG}"
#      ;;
#  esac
#done

# Make sure ruby is in the path
ruby -v
#export PATH=$HOME/.local/bin:$PATH

# - doing the git submodule thing is likely a good idea for safety but until lin-alg is fixed it's a problem
#git submodule init && git submodule update

echo "-- about to build the make files for the coq projects:"

# change to point to absolute path
#for project in $(jq -r '.[].project_name' coqgym_projs_splits.json); do
for project in $(jq -r '.[].project_name' compcert_projs_splits.json); do
    echo $project

    echo "#!/usr/bin/env bash" > coq-projects/$project/make.sh
    echo ${INIT_CMD} >> coq-projects/$project/make.sh
    if $(jq -e ".[] | select(.project_name == \"$project\") | has(\"build_command\")" \
         coqgym_projs_splits.json); then
        BUILD=$(jq -r ".[] | select(.project_name == \"$project\") | .build_command" \
                   coqgym_projs_splits.json)
    else
        BUILD="make"
    fi

    SWITCH=$(jq -r ".[] | select(.project_name == \"$project\") | .switch" coqgym_projs_splits.json)

    # todo: why not just call opam switch? or `opam switch set {$SWITCH}`
    echo "eval \"$(opam env --set-switch --switch=$SWITCH)\"" >> coq-projects/$project/make.sh

    echo "$BUILD $@" >> coq-projects/$project/make.sh
    chmod u+x coq-projects/$project/make.sh
#    (cd coq-projects/$project && sbatch --cpus-per-task=${NTHREADS} $SBATCH_FLAGS -o build-output.out make.sh)
    realpath coq-projects/$project/make.sh
    cat coq-projects/$project/make.sh
done

echo "done creating all the make files!"

cd /afs/cs.stanford.edu/u/brando9/proverbot9001/CompCert/
configure x86_64-linux
make .
#
#configure x86_64-linux && make /afs/cs.stanford.edu/u/brando9/proverbot9001/CompCert/make.sh
