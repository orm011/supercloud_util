#! /bin/bash
set -x # print to output 
echo $-

ENVSETUP=$1
NAME=$2
HEAD=$3

# touching the sigfile will cause a restart of all ray nodes.
# this is useful for updating the env, or restarting the head node.
export SIGFILE=$HOME/$NAME.head

export TMPNAME=/state/partition1/user/$USER/raytmp/
## different nodes have differnt amounts available.
SHM_AVAILABLE_KB=`df /dev/shm | grep -v Available | awk '{print $4}'`
export OBJ_MEM_BYTES=$(( SHM_AVAILABLE_KB*1024 - 1024*1024*1024  )) # leave 1GB off

if [ -z "$SLURM_CPUS_ON_NODE" ]; 
then
    echo 'SLURM_CPUS_ON_NODE not set or zero, ensure running within slurm' 
    exit 1
fi


PREV=
ITER=0
while true
do
    CURRENT=`stat -c '%y' $SIGFILE`
    if [[ $PREV != $CURRENT ]]
    then
        echo "$SIGFILE changed... stopping ray"
        ray stop

        echo "sourcing $ENVSETUP"
        source $ENVSETUP
        echo "done sourcing $ENVSETUP"

        echo `which python`
        echo `which ray`
        echo `ray --version`
        PREV=$CURRENT

        COMMON_ARGS="--temp-dir=$TMPNAME  --object-store-memory=$OBJ_MEM_BYTES"

        if [[ $HEAD == "--head" ]]
        then
            echo 'starting head node'            
            ray start $COMMON_ARGS --num-cpus=$((SLURM_CPUS_ON_NODE/2)) --head
            echo $HOSTNAME > $SIGFILE # restart workers to connect to this new head
            CURRENT=`stat -c '%y' $SIGFILE` # match current and prev to not cause an infinite loop in the head node
            PREV=$CURRENT
        else 
            HEAD=`cat $SIGFILE`

            if [[ $HEAD == '-1' ]] # message to exit, ending the allocated job.
            then 
                echo 'exiting loop'
                break
            fi

            if [[ $HEAD != '' ]]
            then
                ray start $COMMON_ARGS --num-cpus=$((SLURM_CPUS_ON_NODE - 2)) --address=$HEAD:6379
                python -c 'import ray; ray.init("auto"); print(ray.available_resources());'
            fi
        fi
    else
        echo "$SIGFILE unchanged... sleeping"
        sleep 5
    fi

    ITER=$((ITER+1))
done