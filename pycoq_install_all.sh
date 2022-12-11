#!/usr/bin/env bash
# see: https://github.com/UCSD-PL/proverbot9001/issues/27

# top -u brando9
#
# pkill -9 tmux -u brando9; pkill -9 krbtmux -u brando9; pkill -9 reauth -u brando9; pkill -9 python -u brando9; pkill -9 wandb-service* -u brando9;
#
# pkill -9 python -u brando9; pkill -9 wandb-service* -u brando9;
#
# krbtmux
# reauth
# nvidia-smi
# sh main_krbtmux.sh
# sh ~/iit-term-synthesis/main_krbtmux.sh
#
# tmux attach -t 0
# tmux new -s iit
# tmux new -s iit2
#
#tr ':' '\n' <<< "$PATH"

# ssh brando9@hyperturing1.stanford.edu
# ssh brando9@hyperturing2.stanford.edu
# ssh brando9@turing1.stanford.edu
# ssh brando9@ampere1.stanford.edu
# ssh brando9@ampere4.stanford.edu

#source ~/.bashrc.user
source ~/.bashrc.lfs
conda activate iit_synthesis
cd /afs/cs.stanford.edu/u/brando9/proverbot9001

echo running: $PWD $0

#export SLURM_JOBID=$(python -c "import random;print(random.randint(0, 1_000_000))")
#export OUT_FILE=$PWD/pycoq_install_coqgym_deps.o$SLURM_JOBID
#export ERR_FILE=$PWD/pycoq_install_coqgym_deps.e$SLURM_JOBID
#echo $SLURM_JOBID
#echo $OUT_FILE
#echo $ERR_FILE

# - build dependencies
#bash pycoq_install_coqgym_deps.sh > pycoq_install_coqgym_deps.o$SLURM_JOBID 2> pycoq_install_coqgym_deps.e$SLURM_JOBID
#bash pycoq_install_coqgym_deps.sh
bash pycoq_install_coqgym_deps.sh > pycoq_install_coqgym_deps.out

# - install projs (note this will be done in pycoq)
# sh build_coq_projects.sh

# - scrape data (done in pycoq)
# scrape_coq_projects.sh
