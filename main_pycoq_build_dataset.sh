# Goal: install of coq projs then use pycoq to mine data set, main ref for building Provebot's data set https://github.com/UCSD-PL/proverbot9001/issues/27
# ssh brando9@hyperturing1.stanford.edu
# ssh brando9@hyperturing2.stanford.edu
# ssh brando9@turing1.stanford.edu
# ssh brando9@ampere1.stanford.edu
# ssh brando9@ampere2.stanford.edu
#ssh brando9@ampere3.stanford.edu
#ssh brando9@ampere4.stanford.edu

source $AFS/.bashrc.lfs
conda activate iit_synthesis
export CUDA_VISIBLE_DEVICES=5; export SLURM_JOBID=$(python -c "import random;print(random.randint(0, 1_000_000))")
echo CUDA_VISIBLE_DEVICES = $CUDA_VISIBLE_DEVICES; echo SLURM_JOBID = $SLURM_JOBID; echo hostname = $(hostname)
ulimit -n 120000; ulimit -Sn; ulimit -Hn
#nvidia-smi; (echo "GPU_ID PID UID APP" ; for GPU in 0 1 2 3 ; do for PID in $( nvidia-smi -q --id=${GPU} --display=PIDS | awk '/Process ID/{print $NF}') ; do echo -n "${GPU} ${PID} " ; ps -up ${PID} | awk 'NR-1 {print $1,$NF}' ; done ; done) | column -t; hostname; tmux ls;
nvidia-smi; (echo "GPU_ID PID MEM% UTIL% UID APP" ; for GPU in 0 1 2 3 ; do for PID in $( nvidia-smi -q --id=${GPU} --display=PIDS | awk '/Process ID/{print $NF}') ; do echo -n "${GPU} ${PID} " ; nvidia-smi -q --id=${GPU} --display=UTILIZATION | grep -A4 -E '^[[:space:]]*Utilization' | awk 'NR=0{gut=0 ;mut=0} $1=="Gpu"{gut=$3} $1=="Memory"{mut=$3} END{printf "%s %s ",mut,gut}' ; ps -up ${PID} | gawk 'NR-1 {print $1,$NF}' ; done ; done) | column -t; hostname;

(echo "GPU_ID PID UID APP" ; for GPU in 0 1 2 3 ; do for PID in $( nvidia-smi -q --id=${GPU} --display=PIDS | awk '/Process ID/{print $NF}') ; do echo -n "${GPU} ${PID} " ; ps -up ${PID} | awk 'NR-1 {print $1,$NF}' ; done ; done) | column -t

# --- Step 0: Optiona, make sure coq-projects are there
# run unzip if for some reaosn coq-projects is missing
unzip $HOME/proverbot9001/coq-projects.zip -d $HOME/proverbot9001/coq-projects
# 136
find $HOME/proverbot9001/coq-projects -maxdepth 1 -type d | wc -l
# 124
total_num_coq_projs=$(jq length coqgym_projs_splits.json)
echo total_num_coq_projs = $total_num_coq_projs
# git submodule init
git submodule init
git submodule update --init
git submodule status

# --- Step1: Build dependencies for Coq Projects built later, which will later be used for data mining by PyCoq. Also install opam
bash $HOME/proverbot9001/pycoq_install_coqgym_deps.sh

# --- Step2: create the make files for the coq projects/packages later build to work
cd $HOME/proverbot9001/
sh $HOME/proverbot9001/pycoq_build_coq_projects.sh

# - proverbot gets data differently: scrape data (done in pycoq)
# sh pycoq_scrape_coq_projects.sh

# --- Step3: Mine data using PyCoq
# - make sure conda & env we need is setup
source $HOME/proverbot9001/install_conda.sh
source $HOME/install_iit_python_env.sh

# - Set up env for Python
echo 'make sure bash env is setup for python script (wish I could run the python script indepdently of anything else), for now see my .bashrc.user and .bashrc.lfs'
echo '.bashrc.ls: https://github.com/brando90/.dotfiles/blob/master/.bashrc.lfs'; echo '.bashrc.user: https://github.com/brando90/.dotfiles/blob/master/.bashrc.user'
#source $AFS/.bashrc.lfs
source /afs/cs.stanford.edu/u/brando9/.bashrc.lfs
# - Mine with PyCoq
cd $HOME/iit-term-synthesis
conda activate iit_synthesis
#python $HOME/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/coqgym/' --split train --save_flatten_data_set_as_single_json_file
#python -m pdb -c continue $HOME/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/coqgym/' --split train --save_flatten_data_set_as_single_json_file
python -m pdb -c continue ~/pycoq/tutorial/tutorial_pycoq_execute_stmts_coq_file_for_coq_projs.py
#python  ~/pycoq/tutorial/tutorial_pycoq_execute_stmts_coq_file_for_coq_projs.py
