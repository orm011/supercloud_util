
## rationale: local filesystem is fast and allows locking (used by conda and other programs), 
## global is slow for metadata (and small files) but ok for steamed reading large files.
## therefore: tar into single large file from local into global, untar into small files from global into local
## this works much better than parallel rsyncs, which takes forever to start bc the analysis phase is
## quite slow for directories with many files on the global filesystem

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
    mkdir -p $DIR

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
    tar -xf $TAR -C $TEMP 
    rm -rf $DIR
    mv -v -T $TEMP $DIR
    
    touch $DIR/.sync.time
    if [ $? -eq 0 ]; then
        echo 'done syncing '$TAR 'to' $DIR
        return 0
    else
        echo 'warning: problem syncing '$TAR 'to' $DIR
        return 1
    fi
}

function sync_dir_to_tar() {
    DIR=$1
    OUTPUT=$2

    # check there are 2  args
    if [[ -z $DIR || -z $OUTPUT ]]; then
        echo 'must specify dir and output'
        return 1
    fi 

    # check dir exists
    if [[ ! -d $DIR ]]; then
        echo 'dir '$DIR' does not exist'
        return 1
    fi

    # create output dir if it does not exist
    mkdir -p `dirname $OUTPUT`

    # check output is a full path, not a dir
    if [[ -d $OUTPUT ]]; then
        echo 'output '$OUTPUT' is a dir, not a file'
        return 1
    fi
    
    tar -cf $OUTPUT.tmp -C $DIR . 

    # back up old output if it exists
    if [[ -e $OUTPUT ]]; then
        mv $OUTPUT $OUTPUT.old
    fi
    mv $OUTPUT.tmp $OUTPUT
}