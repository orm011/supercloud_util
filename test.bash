#! /bin/bash

source $HOME/supercloud_util/conda_env_tools.bash

ENV=$1
setup_worker_mamba $ENV
if [ ! $? -eq 0 ]; then
    echo 'ERROR: problem syncing env to worker'
    exit 1
fi

PYPATH=`which python`
# check PYPATH starts with $MAMBA_LOCAL
if [[ ! $PYPATH == $MAMBA_LOCAL* ]]; then
    echo 'ERROR: python path '$PYPATH' does not start with '$MAMBA_LOCAL
    exit 1
fi

# if specific env is used, check envs/$ENV
if [[ ! -z $1 ]]; then
    if [[ ! $PYPATH == "$MAMBA_LOCAL/envs/$1/"* ]]; then
        echo 'ERROR: python path '$PYPATH' does not contain envs/'$1
        exit 1
    fi
fi

echo 'python path '$PYPATH' is valid' for env $ENV
echo 'SUCCESS'



