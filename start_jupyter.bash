#! /bin/bash
set -x 

export PYTHONNOUSERSITE=1

source ~/supercloud_util/sync_tools.bash
sync_conda_global_to_worker
. $MAMBA_LOCAL/etc/profile.d/conda.sh
. $MAMBA_LOCAL/etc/profile.d/mamba.sh
mamba activate


which python
which jupyter
jupyter lab --ServerApp.token='' --ServerApp.port=12345 --ServerApp.ip='*' --ServerApp.notebook_dir=~ -ServerApp.allow_origin='*'