source ~/supercloud_util/sync_tools.bash
setup_worker_mamba open_flamingo
export PYTHONNOUSERSITE=1
mamba activate open_flamingo
python /home/gridsan/omoll/supercloud_util/test.py
