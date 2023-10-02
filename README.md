# setup supercloud util

clone this repo into your homedir (form a login node), and add this line to your .bashrc:

```
source $HOME/supercloud_util/conda_env_tools.bash
```

Exit the shell, and login again to the same login node,
check `$MAMBA_LOCAL` is defined now

# setup mamba base env.

Check $MAMBA_LOCAL is defined

from a login node download the Miniforge install script:
```
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash ./Miniforge-pypy3-Linux-x86_64.sh -b -p  $MAMBA_LOCAL
$MAMBA_LOCAL/bin/python -m mamba.mamba init
```

Log out, and log in back into the *same* login node (try a few times if needed)
Once you do, `which python` should be `/state/partition1/user/...`.

# saving mamba base env

Run ```sync_conda_login_to_global```. This may take a couple of seconds.
This command saves $MAMBA_LOCAL to $MAMBA_GLOBAL (in the shared filesystem)

# trying mamba base env in a worker node:



