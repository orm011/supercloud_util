
## rationale: local filesystem is fast and allows locking (used by conda and other programs), 
## global is slow for metadata but ok for steamed reading large files.
## then, tar from local into global, untar from global into local
## this works much better than parallel rsyncs, which takes forever to start bc the analysis phase is
## quite slow for directories with many files on the global filesystem, so even if there are no updates
## to make, rsync takes a long time to check.

function sync_tar_to_dir() {
    TAR=$1
    DIR=$2

    if [[ -z $TAR || -z $DIR ]]; then
        echo 'must specify tar and dir'
        return 1
    fi

    if [[ ! -e $TAR ]]; then
        echo 'tar '$TAR' does not exist'
        return 1
    fi

    TEMP=`mktemp -d`
    GLOBAL_TIME=`stat -c '%y' $TAR`

    if [ -e  $DIR/.sync.time ]; then
        LOCAL_TIME=`stat -c '%y' $DIR/.sync.time`
    else
        LOCAL_TIME='0'
    fi

    # check if local time < global time, if not, return 0
    if [[ $LOCAL_TIME > $GLOBAL_TIME ]]; then
        #echo 'local time '$LOCAL_TIME' > global time '$GLOBAL_TIME', skipping sync'
        return 0
    fi

    echo 'syncing '$TAR 'to' $DIR
    tar -xf $TAR -C $TEMP && \
        rm -rf $DIR && \
        mv $TEMP $DIR && \
        touch $DIR/.sync.time
    if [ $? -eq 0 ]; then
        echo 'done syncing '$TAR 'to' $DIR
        return 0
    else
        echo 'warning: problem syncing '$TAR 'to' $DIR
        return 1
    fi
}


MAMBA_GLOBAL=/home/gridsan/omoll/mambaforge_tars/
MAMBA_LOCAL=/state/partition1/user/$USER/mambaforge/


function sync_conda_global_to_worker() {
    ENV=$1

    # check we are running in host with name of form d-*, otherwise error out
    if [[ `hostname` != d-* ]]; then 
    	echo 'must run in work node, not login'    
        return 1
    fi

    sync_tar_to_dir $MAMBA_GLOBAL/base.tar $MAMBA_LOCAL || return 1

    if [ ! -z $ENV ]; then
        sync_tar_to_dir $MAMBA_GLOBAL/envs/$ENV.tar $MAMBA_LOCAL/envs/$ENV
        if [ $? -eq 0 ]; then   
            echo 'done syncing '$ENV
        else
            echo 'warning: problem syncing '$ENV
            return 1
        fi
    fi
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


function setup_worker_mamba() {
    ENV=$1
    sync_conda_global_to_worker $ENV
    . $MAMBA_LOCAL/etc/profile.d/conda.sh
    . $MAMBA_LOCAL/etc/profile.d/mamba.sh
}