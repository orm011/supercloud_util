# depends on definitions in ./sync_tools.bash
# source that first
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source $DIR/sync_tools.bash

export MAMBA_GLOBAL=/home/gridsan/$USER/miniforge_tars # global storage. used for communication.
export MAMBA_LOCAL=/state/partition1/user/$USER/miniforge # fast storage, used for running mamba.
export PYTHONNOUSERSITE=1 # dont use packages in .local, only what you install in conda.

function sync_conda_global_to_worker() {
    ENV=$1

    # check we are running in host with name of form d-*, otherwise error out
    if [[ `hostname` != d-* ]]; then 
    	echo 'must run in work node, not login'    
        return 1
    fi

    mkdir -p $MAMBA_LOCAL/

    ( # NB parens: runs in child shell so that lock is released before function returns
        lockfile $MAMBA_LOCAL/sync.lock && echo 'acquired lock'
        trap 'rm -f $MAMBA_LOCAL/sync.lock && echo "released lock"' EXIT

        sync_tar_to_dir $MAMBA_GLOBAL/base.tar $MAMBA_LOCAL || exit 1

        if [ ! -z $ENV ]; then
            sync_tar_to_dir $MAMBA_GLOBAL/envs/$ENV.tar $MAMBA_LOCAL/envs/$ENV
            if [ $? -eq 0 ]; then   
                echo 'done syncing '$ENV
            else
                echo 'warning: problem syncing '$ENV
                exit 1
            fi
        fi
    )
}

function sync_conda_login_to_global() {
    echo 'backing up login env to global'
    ENV=$1
    if [[ `hostname` != login-4 ]]; then # only do from login-4, otherwise --delete flag would erase
    	echo 'must run in login-4'
	    return 1
    fi

    # mambalocal must exist
    if [[ ! -d $MAMBA_LOCAL ]]; then
        echo 'mamba local does not exist'
        return 1
    fi

    mkdir -p $MAMBA_GLOBAL/envs

    echo 'backing up base env...'
    sync_dir_to_tar
    tar -cf $MAMBA_GLOBAL/base.tar -C $MAMBA_LOCAL/ --exclude=envs/* --exclude=pkgs/* .
    echo 'done backing up base'

    if [[ -z $ENV ]]; then
        echo 'syncing all envs'
        for env in `ls $MAMBA_LOCAL/envs/`; do
            echo 'syncing env '$env
            tar -cf $MAMBA_GLOBAL/envs/$env.tar -C $MAMBA_LOCAL/envs/$env/ .
            echo 'synced env '$env to $MAMBA_GLOBAL/envs/$env.tar
        done
    else
        if [[ ! -d $MAMBA_LOCAL/envs/$ENV ]]; then
            echo 'env '$ENV' does not exist in local'
            return 1
        fi
        tar -cf $MAMBA_GLOBAL/envs/$ENV.tar -C $MAMBA_LOCAL/envs/$ENV/ .
        echo 'synced env '$ENV to $MAMBA_GLOBAL/envs/$ENV.tar
    fi
}

function sync_conda_global_to_login() {
    echo 'restoring login envs from global storage'
    if [[ `hostname` != login-4 ]]; then # only do from login-4, otherwise --delete flag would erase
    	echo 'must run in login-4'
	    return 1
    fi

    # mambaglobal must exist
    if [[ ! -d $MAMBA_GLOBAL ]]; then
        echo 'mamba local does not exist'
        return 1
    fi

    mkdir -p $MAMBA_LOCAL/envs

    sync_tar_to_dir $MAMBA_GLOBAL/base.tar $MAMBA_LOCAL || return 1

    ENVS=`ls mambaforge_tars/envs/*tar | xargs -I {} basename {} | sed 's/.tar//g'`
    echo restoring $ENVS
    for env in $ENVS; do
        echo 'restoring env '$env
        sync_tar_to_dir $MAMBA_GLOBAL/envs/$env.tar $MAMBA_LOCAL/envs/$env
        echo 'restored env '$env to $MAMBA_LOCAL/envs/$env
    done
}

function setup_worker_mamba() {
    ENV=$1
    sync_conda_global_to_worker $ENV
    if [ ! $? -eq 0 ]; then
        echo 'warning: problem syncing'
        return 1
    fi
    . $MAMBA_LOCAL/etc/profile.d/conda.sh
    . $MAMBA_LOCAL/etc/profile.d/mamba.sh
}


function maybe_setup_mamba_base() {
    if [[ $- == *i* ]]; then # interactive shells (not scripts)
        if [[ `hostname` != login* ]]; then # worker node, set up base mamba
            sync_conda_global_to_worker
        fi
    fi
}