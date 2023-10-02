UTILREPO="$HOME/supercloud_util/"
source $UTILREPO/conda_env_tools.bash

export TMPDIR=/state/partition1/user/$USER/tmpdir/
mkdir -p $TMPDIR

export LOGIN4=172.31.130.22

export TMUX_TMPDIR=/state/partition1/user/omoll/tmux_tmpdir
mkdir -p $TMUX_TMPDIR/tmux-`id -u`/ ## seems like tmux needs this folder to exist
alias tmux='tmux -u'

PATH=$PATH:$HOME/bin
PATH=/state/partition1/user/omoll/local/bin:$HOME/local/bin/:$PATH
PATH=$HOME/goroot/bin/:$HOME/go/bin/:$HOME/local/nginx/sbin/:/home/gridsan/omoll/askem_shared/local/bin:$PATH
PATH=/home/gridsan/groups/fastai/seesaw/node-v16.13.2-linux-x64/bin:$PATH

LOCAL_HOME=/state/partition1/user/$USER/

LOCAL_HF_BASE=$LOCAL_HOME/huggingface_cache/
GLOBAL_HF_BASE=$HOME/huggingface_cache/

if [[ `hostname` = login*  ]];then
    export TRANSFORMERS_OFFLINE=0
    export HF_DATASETS_OFFLINE=0
    export HF_HOME=$LOCAL_HF_BASE
else
    export TRANSFORMERS_OFFLINE=1
    export HF_DATASETS_OFFLINE=1
    export HF_HOME=$GLOBAL_HF_BASE
fi

export PYTHONNOUSERSITE=1 # dont add .local to python path, use conda pip
export RAY_DISABLE_PYARROW_VERSION_CHECK=1
export MODIN_ENGINE=ray


#### if this is an interactive shell, even if not a login shell, set history, prompt, and sync the conda env
if [[ $- == *i* ]]; then
    HISTSIZE=-1
    HISTFILESIZE=-1
    HISTCONTROL=ignoredups
    HISTTIMEFORMAT='%F %T '

    shopt -s checkwinsize
    shopt -s histappend
    shopt -s cmdhist

    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$"\n"}history -a;"

    export LP_ENABLE_SHLVL=0  # mark seems to cause issues with wrapping lines
    source ~/liquidprompt/liquidprompt
fi

