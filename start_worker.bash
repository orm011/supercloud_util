#! /bin/bash
set -x # print to output 
echo $-

ENVSETUP=$1
NAME=$2
HEAD=$3


# echo '' > SIGFILE will cause all nodes to restart with updated env
# echo -1 > SIGFILE will cause all nodes to exit this loop

export SIGFILE=$HOME/$NAME.head
if [[ $HEAD == "--head" ]]; then
    echo '' > $SIGFILE
fi

export TMPNAME=/state/partition1/user/$USER/raytmp/
## different nodes have differnt amounts available.
SHM_AVAILABLE_KB=`df /dev/shm | grep -v Available | awk '{print $4}'`
export OBJ_MEM_BYTES=$(( SHM_AVAILABLE_KB*1024 - 1024*1024*1024  )) # leave 1GB off

if [ -z "$SLURM_CPUS_ON_NODE" ]; then
    echo 'SLURM_CPUS_ON_NODE not set or zero, ensure running within slurm' 
    exit 1
fi

. $ENVSETUP # import definitions of hooks

init_env

PREV=
ITER=0
while true; do
    CURRENT=`stat -c '%y' $SIGFILE`
    if [[ $PREV != $CURRENT ]]; then
        echo "$SIGFILE changed... restarting ray"
        ray stop

        CONTENT=`cat $SIGFILE`
        if [[ $CONTENT == '-1' ]]; then
            echo 'exiting loop'
            break
        fi

        init_env

        echo `which python`
        echo `which ray`
        echo `ray --version`
        PREV=$CURRENT

        COMMON_ARGS="--temp-dir=$TMPNAME --object-store-memory=$OBJ_MEM_BYTES"

        if [[ $HEAD == "--head" ]]; then
            echo 'starting head node'            
            ray start $COMMON_ARGS --num-cpus=$((SLURM_CPUS_ON_NODE/2)) --head
            echo $HOSTNAME > $SIGFILE # restart workers to connect to this new head
            PREV=`stat -c '%y' $SIGFILE` # match current and prev to not cause an infinite loop in the head node
            after_start_head #hook
        else 
            if [[ $CONTENT != '' ]]; then
                ray start $COMMON_ARGS --num-cpus=$((SLURM_CPUS_ON_NODE - 2)) --address=$CONTENT:6379
                python -c 'import ray; ray.init("auto"); print(ray.available_resources());'
            fi
        fi
    else
        echo "$SIGFILE unchanged... sleeping"
        sleep 5
    fi

    ITER=$((ITER+1))
done