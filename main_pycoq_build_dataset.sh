# Goal: install of coq projs then use pycoq to mine data set
hostname

# --- make (& build) PyCoq's Proverbot's CoqGym Coq projects
# - build dependencies
bash ~/proverbot9001/pycoq_install_coqgym_deps.sh

# - install projs
# sh pycoq_build_coq_projects.sh

# - scrape data (done in pycoq)
# sh pycoq_scrape_coq_projects.sh

# --- Mine data using PyCoq
# -- make sure conda & env we need is setup
source $HOME/proverbot9001/install_conda.sh
source $HOME/install_iit_python_env.sh

# -- set up env for Python
echo 'make sure bash env is setup for python script (wish I could run the python script indepdently of anything else), for now see my .bashrc.user and .bashrc.lfs'
echo '.bashrc.ls: https://github.com/brando90/.dotfiles/blob/master/.bashrc.lfs'; echo '.bashrc.user: https://github.com/brando90/.dotfiles/blob/master/.bashrc.user'
#source $AFS/.bashrc.lfs
source /afs/cs.stanford.edu/u/brando9/.bashrc.lfs
conda activate iit_synthesis

# -- mine
python -u ~/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/pycoq_lf_debug/' --save_flatten_data_set_as_single_json_file

# - brando's debug
#python -m pdb -c continue ~/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/debug_proj/' --split train --save_flatten_data_set_as_single_json_file

# - compcert
#python ~/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/compcert/' --split train --save_flatten_data_set_as_single_json_file

# - coqgym
#python ~/iit-term-synthesis/iit-term-synthesis-src/data_pkg/data_gen.py --path_to_save_new_dataset '~/data/coqgym/' --split train --save_flatten_data_set_as_single_json_file
