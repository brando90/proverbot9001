#!/usr/bin/env bash
# see: https://github.com/UCSD-PL/proverbot9001/issues/27

cd /afs/cs.stanford.edu/u/brando9/proverbot900
echo running: $0

#export OUT_FILE=$PWD/main.sh.o$SLURM_JOBID
#export ERR_FILE=$PWD/main.sh.e$SLURM_JOBID
#python -u ~/diversity-for-predictive-success-of-meta-learning/div_src/diversity_src/experiment_mains/main_sl_with_ddp.py --manual_loads_name sl_hdb1_5cnn_adam_cl_filter_size --filter_size 4 > $OUT_FILE 2> $ERR_FILE &
export SLURM_JOBID=$(python -c "import random;print(random.randint(0, 1_000_000))")

# - build depedencies
#sh install_coqgym_deps.sh
sh pycoq_install_coqgym_deps.sh > pycoq_install_coqgym_deps.o$SLURM_JOBID 2> pycoq_install_coqgym_deps.e$SLURM_JOBID

# - install projs (note this will be done in pycoq)
# sh build_coq_projects.sh

# - scrape data (done in pycoq)
# scrape_coq_projects.sh
