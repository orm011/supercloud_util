source $HOME/supercloud_util/sync_tools.bash
setup_worker_mamba open_flamingo

if [ ! $? -eq 0 ]; then
    echo 'ERROR: problem syncing env to worker'
    return 1
fi

export PYTHONNOUSERSITE=1
mamba activate open_flamingo

if [ ! -z $SLURM_CPUS_PER_TASK ]; then
    export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
fi

python /home/gridsan/omoll/supercloud_util/test.py
