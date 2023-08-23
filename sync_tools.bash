PATH=$HOME/fpart_install/bin:$PATH

function sync_conda_global_to_worker {
    ## avoid expensive rsync filesystem checks in the common case, by using the license file as a signal.
    #LOCAL_TIME=`stat -c '%y' /state/partition1/user/omoll/miniconda3/LICENSE.txt`
    #GLOBAL_TIME=`stat -c '%y' /home/gridsan/omoll/miniconda3_backup/LICENSE.txt`

    LOCAL_TIME=`stat -c '%y' /state/partition1/user/omoll/mambaforge/LICENSE.txt`
    GLOBAL_TIME=`stat -c '%y' /home/gridsan/omoll/mambaforge_backup/LICENSE.txt`
 
    if [[ $LOCAL_TIME != $GLOBAL_TIME ]]; then
	echo 'syncing conda env from gridsan to local'
	#fpsync -n 180 -o '-rlugpt --quiet --delete --exclude="/pkgs/**" --exclude="__pycache__/**" --exclude=".h" --exclude=".hpp" ' /home/gridsan/omoll/miniconda3_backup/  /state/partition1/user/omoll/miniconda3
	fpsync -n 180 -o '-rlugpt --quiet --delete --exclude="/pkgs/**" --exclude="__pycache__/**" --exclude=".h" --exclude=".hpp" ' /home/gridsan/omoll/mambaforge_backup/  /state/partition1/user/omoll/mambaforge/
	
	#fpsync -n 180 -o '-rlugpt --quiet --delete --exclude="/pkgs/**" --exclude="__pycache__/**" --exclude=".h" --exclude=".hpp" ' /home/gridsan/omoll/huggingface_cache/  /state/partition1/user/omoll/huggingface_cache	

	EXIT=$?
	[ $EXIT -eq 0 ] && echo 'done syncing conda env' || echo 'Warning: problem syncing conda'
    else
	echo 'LICENSE.txt up to date, skipping fpsync. Touch LICENSE.txt to force update'
	EXIT=0
    fi
    return $EXIT
}

function restore_conda_global_to_login {
    if [[ `hostname` != login-4 ]]; then # only do from login-4, otherwise could erase
	echo 'run in login-*'
	return 1
    fi

    fpsync -n 180 -o '-rlugpt --quiet --exclude="__pycache__/**"' /home/gridsan/omoll/mambaforge_backup/  /state/partition1/user/omoll/mambaforge/
#    fpsync -n 180 -o '-rlugpt --delete  --exclude="__pycache__/**"' /home/gridsan/omoll/huggingface_cache/ /state/partition1/user/omoll/huggingface_cache/    
}

function sync_conda_login_to_global {
    echo 'backing up conda env to global'
    if [[ `hostname` != login-4 ]]; then # only do from login-4, otherwise could erase
	echo 'must run in correct login-* host.'
	return 1
    fi

    ## skip pycache, but do copy /pkgs etc 
    # fpsync -n 180 -o '-rlugpt --quiet --delete  --exclude="__pycache__/**"' /state/partition1/user/omoll/miniconda3/ /home/gridsan/omoll/miniconda3_backup/
    fpsync -n 180 -o '-rlugpt --delete  --exclude="__pycache__/**"' /state/partition1/user/omoll/mambaforge/ /home/gridsan/omoll/mambaforge_backup/ && touch /home/gridsan/omoll/mambaforge_backup/LICENSE.txt
#    fpsync -n 180 -o '-rlugpt --delete "' /state/partition1/user/omoll/huggingface_cache/ /home/gridsan/omoll/huggingface_cache/ && touch GLOBAL_HF_BASE/message.txt
    

    EXIT=$?
    
    if [ $EXIT -eq 0 ]; then
	# will trigger eventual sync in other nodes
#	touch /home/gridsan/omoll/miniconda3_backup/LICENSE.txt


	echo 'done backing up conda env'
    else
	echo 'Warning: problem syncing conda'
    fi

    return $EXIT
}
