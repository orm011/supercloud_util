source $HOME/supercloud_util/sync_tools.bash
setup_worker_mamba open_flamingo

if [ ! $? -eq 0 ]; then
    echo 'ERROR: problem syncing env to worker'
    return 1
fi

export PYTHONNOUSERSITE=1
mamba activate open_flamingo
python /home/gridsan/omoll/supercloud_util/test.py
