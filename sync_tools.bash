PATH=$HOME/fpart_install/bin:$PATH
MAMBA_GLOBAL=/home/gridsan/omoll/mambaforge_backup/
MAMBA_LOCAL=/state/partition1/user/omoll/mambaforge/

function sync_conda_global_to_worker() {
    ENV=$1

    ## avoid expensive rsync filesystem checks in the common case, by using the license file as a signal.
    LOCAL_TIME=`stat -c '%y' $MAMBA_LOCAL/LICENSE.txt`
    GLOBAL_TIME=`stat -c '%y' $MAMBA_GLOBAL/LICENSE.txt`
 
    # check we are running in host with name of form d-*, otherwise error out
    if [[ `hostname` != d-* ]]; then 
    	echo 'must run in work node, not login'    
        return 1
    fi
        
    # check if env exists
    if [[ ! -d $MAMBA_GLOBAL/envs/$ENV ]]; then
    	echo 'env '$ENV' does not exist in global'
        return 1
    fi

    if [[ $LOCAL_TIME != $GLOBAL_TIME ]]; then
    	echo "syncing mamba $ENV from global to local"
        # rsync $OPTIONS $MAMBA_GLOBAL $MAMBA_LOCAL
        mkdir -p $MAMBA_LOCAL
        mkdir -p $MAMBA_LOCAL/envs/$ENV

    	# rsync -av --filter="- /pkgs/**" --filter="- /include/**" --filter="- __pycache__" --filter="- /envs/**" $MAMBA_GLOBAL $MAMBA_LOCAL
        fpsync -n 80 -v -o '-a --exclude="/pkgs/**" --exclude="/include/**" --exclude="__pycache__" --exclude="/envs/**"' $MAMBA_GLOBAL $MAMBA_LOCAL
        fpsync -n 80 -v -o '-a --exclude="/include/**" --exclude="/*/include/**"' $MAMBA_GLOBAL/envs/$ENV/ $MAMBA_LOCAL/envs/$ENV/

    	EXIT=$?
	    [ $EXIT -eq 0 ] && echo 'done syncing conda env' || echo 'Warning: problem syncing conda'
    else
    	echo 'LICENSE.txt up to date, skipping fpsync. Touch LICENSE.txt to force update'
	    EXIT=0
    fi
    
    return $EXIT
}

function sync_conda_login_to_global() {
    echo 'backing up login env to global'
    if [[ `hostname` != login-4 ]]; then # only do from login-4, otherwise --delete flag would erase
    	echo 'must run in login-4'
	    return 1
    fi

    mamba clean -a # clean up old pkgs to avoid long copies

    fpsync -n 180 -v -o '-av --delete --exclude="__pycache__/**"' $MAMBA_LOCAL $MAMBA_GLOBAL
    return $EXIT
}

function restore_conda_global_to_login() {
    # only used when login-4 is cleared
    if [[ `hostname` != login-4 ]]; then # only do from login-4, otherwise could erase
    	echo 'run in login-4'
	    return 1
    fi

    fpsync -n 180 -v -o '-av --exclude="__pycache__/**"' $MAMBA_GLOBAL $MAMBA_LOCAL
}

function setup_worker_mamba() {
    ENV=$1
    sync_conda_global_to_worker $ENV
    . $MAMBA_LOCAL/etc/profile.d/conda.sh
    . $MAMBA_LOCAL/etc/profile.d/mamba.sh
    mamba activate $ENV
}